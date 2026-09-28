#!/usr/bin/env bash
#MISE description="Run tofu apply for a single root module"
set -euo pipefail

# shellcheck source=mise-tasks/lib/common.sh
source "$(dirname "$0")/lib/common.sh"

usage() {
    log_error "Usage: mise run apply <module>"
    log_error ""
    log_error "  <module>  Root module path, relative to $MODULES_DIR/ (e.g. 'network/hub')"
    log_error ""
    log_error "There's no --all on purpose: apply one root module at a time, so"
    log_error "you can't apply every module by accident."
    log_error ""
    log_error "Root modules:"
    print_modules find_root_modules
    exit 1
}

[ $# -eq 1 ] || usage
[ "$1" != "--all" ] || usage

module="$(resolve_module "$1" root)" || usage

log_step "Apply: $module"
in_module "$module" tofu init -input=false
# Interactive on purpose: tofu shows the plan and asks for approval.
in_module "$module" tofu apply

log_summary "Apply complete for $module"
