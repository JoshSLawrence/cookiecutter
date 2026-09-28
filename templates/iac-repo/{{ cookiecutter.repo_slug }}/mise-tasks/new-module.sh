#!/usr/bin/env bash
#MISE description="Scaffold a root or shared module from the cookiecutter templates"
set -euo pipefail

# shellcheck source=mise-tasks/lib/common.sh
source "$(dirname "$0")/lib/common.sh"

usage() {
    log_error "Usage: mise run new-module <root|shared> [-o <dir>] [cookiecutter args...]"
    log_error ""
    log_error "  root|shared       Template to use: root-module or shared-module"
    log_error "  -o, --output-dir  Directory to create the module in, relative to the"
    log_error "                    repo root (default: '$MODULES_DIR')."
    log_error "                    e.g. '-o $MODULES_DIR/network' -> $MODULES_DIR/network/<slug>"
    log_error "  cookiecutter      Passed through, e.g. --no-input module_name=hub"
    log_error ""
    log_error "Change the default for the whole repo with MODULES_DIR in"
    log_error "mise-tasks/lib/common.sh."
    log_error ""
    log_error "Templates come from \$COOKIECUTTER_TEMPLATE (default:"
    log_error "gh:JoshSLawrence/cookiecutter). Point it at a local clone to try"
    log_error "template changes. The repo's pinned OpenTofu version is the default"
    log_error "opentofu_version."
    exit 1
}

[ $# -ge 1 ] || usage
case "$1" in
    root | shared) template="templates/$1-module" ;;
    *) usage ;;
esac
shift

output_dir="$MODULES_DIR"
cookiecutter_args=()
while [ $# -gt 0 ]; do
    case "$1" in
        -o | --output-dir)
            [ $# -ge 2 ] || usage
            output_dir="${2%/}"
            shift 2
            ;;
        --output-dir=*)
            output_dir="${1#*=}"
            output_dir="${output_dir%/}"
            shift
            ;;
        -h | --help) usage ;;
        *)
            cookiecutter_args+=("$1")
            shift
            ;;
    esac
done

# Relative paths are relative to the repo root, not wherever mise was run.
case "$output_dir" in
    /*) output_path="$output_dir" ;;
    *) output_path="$REPO_ROOT/$output_dir" ;;
esac

# The other tasks only look under MODULES_DIR, so warn rather than fail: a
# one-off location may be intended.
case "$output_path/" in
    "$MODULES_PATH/"*) ;;
    *) log_warn "$output_dir is outside $MODULES_DIR/, so test, plan, and apply won't find this module. Change MODULES_DIR in mise-tasks/lib/common.sh if modules belong there." ;;
esac

source_repo="${COOKIECUTTER_TEMPLATE:-gh:JoshSLawrence/cookiecutter}"
mkdir -p "$output_path"

log_step "Scaffolding $template into ${output_path#"$REPO_ROOT"/}"
# ${arr[@]+"${arr[@]}"}: expanding an empty array trips `set -u` on bash 3.2
cookiecutter "$source_repo" --directory "$template" -o "$output_path" \
    opentofu_version="$(mise current opentofu)" \
    ${cookiecutter_args[@]+"${cookiecutter_args[@]}"}

log_summary "Module scaffolded. Run 'mise run test <module>' to check it."
