#!/usr/bin/env bash
#MISE description="Run tofu plan for one root module (or all of them)"
set -euo pipefail

# shellcheck source=mise-tasks/lib/common.sh
source "$(dirname "$0")/lib/common.sh"

usage() {
    log_error "Usage: mise run plan <module> | --all"
    log_error ""
    log_error "  <module>  Root module path, relative to $MODULES_DIR/ (e.g. 'network/hub')"
    log_error "  --all     Plan every root module, one after another"
    log_error ""
    log_error "Root modules:"
    print_modules find_root_modules
    exit 1
}

[ $# -eq 1 ] || usage

plan_one() {
    local module="$1"
    log_step "Plan: $module"
    # Chained with && because errexit is off when this runs under `||`.
    in_module "$module" tofu init -input=false &&
        in_module "$module" tofu plan -input=false
}

if [ "$1" = "--all" ]; then
    modules="$(find_root_modules)"
    if [ -z "$modules" ]; then
        log_error "No root modules under $MODULES_DIR/. Scaffold one with 'mise run new-module root'."
        exit 1
    fi
    FAILED=()
    while IFS= read -r module; do
        plan_one "$module" || FAILED+=("$module")
    done <<< "$modules"
    if [ ${#FAILED[@]} -gt 0 ]; then
        log_error "Plan failed for: ${FAILED[*]}. See the output above."
        exit 1
    fi
else
    module="$(resolve_module "$1" root)" || usage
    plan_one "$module"
fi

log_summary "Plan complete"
