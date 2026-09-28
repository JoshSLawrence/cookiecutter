#!/usr/bin/env bash
# shellcheck shell=bash
#
# Shared helpers for the mise tasks. Source it; don't run it. It isn't
# executable on purpose: mise lists every executable file under mise-tasks/
# as a task.
#
# Modules live under MODULES_DIR (below). They're found by convention, never
# by a hand-maintained list, so adding, moving, or deleting one needs no task
# changes:
#
# - A module is a directory with a terraform.tf. Directories nested inside
#   another module (its modules/ and examples/) belong to that module and are
#   checked through it.
# - A root module is a module that also has a backend.tf, i.e. has its own
#   state and can be planned and applied.
#
# The root-module and shared-module cookiecutter templates follow both
# conventions.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_START_TIME=${EPOCHSECONDS:-$(date +%s)}

# Resolved from this file's location, not $PWD, so tasks behave the same
# wherever mise is invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Where modules live, relative to the repo root, without a trailing slash.
# Every task finds modules here, and `mise run new-module` creates them here
# unless given -o. To move all modules, change this and move the directory.
MODULES_DIR="{{ cookiecutter.modules_dir }}"
MODULES_PATH="$REPO_ROOT/$MODULES_DIR"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_step() {
    echo ""
    echo -e "${CYAN}== ${1}${NC}"
}

log_summary() {
    local message="${1:-Done}"
    local now=${EPOCHSECONDS:-$(date +%s)}
    echo ""
    echo -e "${GREEN}== ${message} ($((now - SCRIPT_START_TIME))s)${NC}"
}

# Print every module under $MODULES_DIR, one per line, relative to the repo
# root (e.g. "iac/network/hub"). Sorted so output is stable.
find_modules() {
    [ -d "$MODULES_PATH" ] || return 0
    find "$MODULES_PATH" -type d -name ".terraform" -prune -o -type f -name "terraform.tf" -print \
        | sed -e "s#^$REPO_ROOT/##" -e 's#/terraform.tf$##' \
        | sort \
        | awk '{ for (m in kept) if (index($0, m "/") == 1) next; kept[$0] = 1; print }'
}

# Print every root module under $MODULES_DIR (modules with a backend.tf).
find_root_modules() {
    local module
    while IFS= read -r module; do
        if [ -f "$REPO_ROOT/$module/backend.tf" ]; then
            echo "$module"
        fi
    done < <(find_modules)
}

# Print a list of modules for usage messages, or a hint when there are none.
# Usage: print_modules <find_modules|find_root_modules>
print_modules() {
    local modules module
    modules="$("$1")"
    if [ -z "$modules" ]; then
        echo "  (none yet: scaffold one with 'mise run new-module root|shared')" >&2
    else
        while IFS= read -r module; do
            echo "  - $module" >&2
        done <<< "$modules"
    fi
}

# Normalize a module argument (relative to $MODULES_DIR or to the repo root)
# to a repo-relative path, e.g. with MODULES_DIR=iac, "network/hub" or
# "iac/network/hub" -> "iac/network/hub". Fails if it isn't a module (or,
# with "root", a root module).
# Usage: resolve_module <path> [root]
resolve_module() {
    local module="${1%/}"
    module="$MODULES_DIR/${module#"$MODULES_DIR"/}"
    if [ ! -f "$REPO_ROOT/$module/terraform.tf" ]; then
        log_error "Not a module: $1 (expected $module/terraform.tf)."
        return 1
    fi
    if [ "${2:-}" = "root" ] && [ ! -f "$REPO_ROOT/$module/backend.tf" ]; then
        log_error "Not a root module: $1 (no backend.tf). Only root modules have state to plan or apply."
        return 1
    fi
    echo "$module"
}

# Run a command inside a module with mise, so the module's own mise.toml pins
# (if any) take precedence over the repo-root ones.
# Usage: in_module <repo-relative module path> <command...>
in_module() {
    local module="$1"
    shift
    (cd "$REPO_ROOT/$module" && mise exec -- "$@")
}
