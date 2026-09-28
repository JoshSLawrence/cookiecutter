#!/usr/bin/env bash
set -euo pipefail

# Renders the templates and runs each result's own checks, so a bumped version
# or template edit can't ship a scaffold that fails them. Run after changing a
# template or its pinned versions.
#
# - root-module / shared-module: rendered with every provider enabled and
#   with none, then fmt, validate, tflint, and trivy.
# - iac-repo: rendered with the default and a nested modules_dir, then a root
#   and a shared module are scaffolded into each with `mise run new-module`
#   (from this working tree), and its test and plan tasks and pre-commit
#   hooks are run.
#
# Usage: tools/test.sh [template...]   (defaults to all templates)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$(mktemp -d)"
trap 'rm -rf "$OUT_DIR"' EXIT

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

for cmd in cookiecutter git mise; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "$cmd is required. Install it (e.g. 'mise use -g $cmd' for cookiecutter) and retry."
        exit 1
    fi
done

TEMPLATES=("$@")
if [ ${#TEMPLATES[@]} -eq 0 ]; then
    TEMPLATES=(iac-repo root-module shared-module)
fi

FAILED=()

# Runs a command in a rendered directory with its pinned tools, recording a
# failure instead of exiting so one run reports every broken check.
# Usage: run_check <name> <dir> <command...>
run_check() {
    local name=$1 dir=$2
    shift 2
    log_info "$name: $*"
    if ! (cd "$dir" && mise exec -- "$@"); then
        FAILED+=("$name: $*")
    fi
}

test_module_template() {
    local template=$1 providers name dir
    for providers in true false; do
        name="test-${template}-providers-${providers}"
        dir="$OUT_DIR/$name"
        log_info "Rendering templates/$template (providers: $providers) into $dir"

        if ! cookiecutter --no-input "$ROOT_DIR/templates/$template" -o "$OUT_DIR" \
            module_name="$name" \
            use_azurerm="$providers" use_azapi="$providers" \
            use_azuread="$providers" use_random="$providers"; then
            FAILED+=("$name: render")
            continue
        fi

        run_check "$name" "$dir" tofu fmt -check -recursive
        run_check "$name" "$dir" tofu validate
        run_check "$name" "$dir" tflint --init
        run_check "$name" "$dir" tflint
        run_check "$name" "$dir" trivy config --config trivy.yaml .
    done
}

# Renders iac-repo with the given modules_dir, scaffolds a root module into
# the default location and a shared module into a nested one with -o, then
# runs the repo's tasks and hooks against them.
# Usage: test_iac_repo_with <modules_dir>
test_iac_repo_with() {
    local modules_dir=$1
    local name="test-iac-repo-${modules_dir//\//-}"
    local dir="$OUT_DIR/$name"
    log_info "Rendering templates/iac-repo (modules_dir: $modules_dir) into $dir"

    if ! cookiecutter --no-input "$ROOT_DIR/templates/iac-repo" -o "$OUT_DIR" \
        repo_name="$name" modules_dir="$modules_dir"; then
        FAILED+=("$name: render")
        return
    fi

    run_check "$name" "$dir" git rev-parse --verify --quiet HEAD
    run_check "$name" "$dir" test -x .git/hooks/pre-commit
    run_check "$name" "$dir" test -f "$modules_dir/README.md"

    # Scaffold from this working tree, not GitHub, so unpushed template
    # changes are what gets tested. The root module only uses random, so it
    # can be planned (with local state) without cloud credentials.
    export COOKIECUTTER_TEMPLATE="$ROOT_DIR"
    run_check "$name" "$dir" mise run new-module root --no-input \
        module_name=network use_azurerm=false use_random=true
    run_check "$name" "$dir" mise run new-module shared -o "$modules_dir/shared" --no-input \
        module_name=key-vault use_azapi=true
    unset COOKIECUTTER_TEMPLATE

    run_check "$name" "$dir" test -f "$modules_dir/network/backend.tf"
    run_check "$name" "$dir" test -f "$modules_dir/shared/key-vault/terraform.tf"
    run_check "$name" "$dir" mise run test --all
    # Accepts the path with or without the MODULES_DIR prefix
    run_check "$name" "$dir" mise run test "$modules_dir/shared/key-vault/"
    run_check "$name" "$dir" mise run plan network
    run_check "$name" "$dir" git add --all
    run_check "$name" "$dir" pre-commit run --all-files
}

test_iac_repo() {
    test_iac_repo_with iac
    # A non-default, nested directory, to catch anything that assumes iac/
    test_iac_repo_with infra/modules
}

for template in "${TEMPLATES[@]}"; do
    case "$template" in
        iac-repo) test_iac_repo ;;
        root-module | shared-module) test_module_template "$template" ;;
        *)
            log_error "Unknown template '$template'. Expected one of: iac-repo, root-module, shared-module."
            exit 1
            ;;
    esac
done

if [ ${#FAILED[@]} -gt 0 ]; then
    log_error "${#FAILED[@]} check(s) failed:"
    printf '  - %s\n' "${FAILED[@]}" >&2
    exit 1
fi

log_info "All templates rendered and passed their checks"
