#!/usr/bin/env bash
#MISE description="Run fmt, validate, tflint, trivy, and tofu test for one module (or all of them)"
set -euo pipefail

# shellcheck source=mise-tasks/lib/common.sh
source "$(dirname "$0")/lib/common.sh"

usage() {
    log_error "Usage: mise run test <module> | --all"
    log_error ""
    log_error "  <module>  Module path, relative to $MODULES_DIR/ (e.g. 'network/hub')"
    log_error "  --all     Test every module, one after another"
    log_error ""
    log_error "Works on root and shared modules. Runs tofu fmt, tofu validate,"
    log_error "tflint, trivy, and tofu test (when the module has tests). Needs no"
    log_error "backend access or cloud credentials."
    log_error ""
    log_error "Modules:"
    print_modules find_modules
    exit 1
}

[ $# -eq 1 ] || usage

FAILED=()

# Runs one check, recording a failure instead of exiting so a single run
# reports every broken check.
# Usage: run_check <module> <name> <command...>
run_check() {
    local module="$1" name="$2"
    shift 2
    log_info "$module: $name"
    if ! in_module "$module" "$@"; then
        log_error "$module: $name failed"
        FAILED+=("$module: $name")
    fi
}

test_one() {
    local module="$1"
    log_step "Test: $module"
    run_check "$module" "tofu fmt" tofu fmt -check -recursive -diff
    # -backend=false: validate without touching remote state
    run_check "$module" "tofu init" tofu init -input=false -backend=false
    run_check "$module" "tofu validate" tofu validate
    run_check "$module" "tflint init" tflint --init
    run_check "$module" "tflint" tflint --format compact
    # Reads the module's trivy.yaml for the severity threshold
    run_check "$module" "trivy" trivy config .
    if compgen -G "$REPO_ROOT/$module/tests/*.tftest.hcl" >/dev/null ||
        compgen -G "$REPO_ROOT/$module/*.tftest.hcl" >/dev/null; then
        run_check "$module" "tofu test" tofu test
    else
        log_info "$module: no *.tftest.hcl files, skipping tofu test"
    fi
}

if [ "$1" = "--all" ]; then
    modules="$(find_modules)"
    if [ -z "$modules" ]; then
        log_error "No modules under $MODULES_DIR/. Scaffold one with 'mise run new-module root|shared'."
        exit 1
    fi
    while IFS= read -r module; do
        test_one "$module"
    done <<< "$modules"
else
    module="$(resolve_module "$1")" || usage
    test_one "$module"
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    log_error "${#FAILED[@]} check(s) failed:"
    printf '  - %s\n' "${FAILED[@]}" >&2
    exit 1
fi

log_summary "All checks passed"
