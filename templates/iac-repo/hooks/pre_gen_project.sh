#!/usr/bin/env bash
set -euo pipefail

# Runs in the output directory before anything is generated, so only the
# cookiecutter variables can be validated here.

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1" >&2; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

REPO_SLUG="{{ cookiecutter.repo_slug }}"
MODULES_DIR="{{ cookiecutter.modules_dir }}"
OPENTOFU_VERSION="{{ cookiecutter.opentofu_version }}"

log_info "Running pre-generation checks"

if [[ ! "$REPO_SLUG" =~ ^[a-z0-9]+([-_.][a-z0-9]+)*$ ]]; then
    log_error "repo_slug '$REPO_SLUG' is invalid: use lowercase letters, digits, and single '-', '_' or '.' separators (e.g. 'config-network')."
    exit 1
fi

# Relative path segments only: the tasks join it onto the repo root.
if [[ ! "$MODULES_DIR" =~ ^[A-Za-z0-9_-][A-Za-z0-9._-]*(/[A-Za-z0-9_-][A-Za-z0-9._-]*)*$ ]]; then
    log_error "modules_dir '$MODULES_DIR' is invalid: use a relative path inside the repo without a trailing slash (e.g. 'iac' or 'modules')."
    exit 1
fi

if [[ ! "$OPENTOFU_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_error "opentofu_version '$OPENTOFU_VERSION' is invalid: use an exact version like '1.9.0' (it's pinned in mise.toml)."
    exit 1
fi

for cmd in git mise; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "$cmd is required to set up the repo. Install it and retry (mise: https://mise.jdx.dev)."
        exit 1
    fi
done

# Not fatal: generating into another repo is sometimes intended (e.g. a
# scratch clone), but it's usually a wrong working directory.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log_warn "Generating inside an existing git repo ($(git rev-parse --show-toplevel)). The new repo will be nested in it."
fi

log_info "Pre-generation checks passed"
