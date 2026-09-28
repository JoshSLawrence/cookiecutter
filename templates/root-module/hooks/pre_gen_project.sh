#!/usr/bin/env bash
set -euo pipefail

# Runs in the output directory before anything is generated, so only the
# cookiecutter variables can be validated here.

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

MODULE_SLUG="{{ cookiecutter.module_slug }}"
OPENTOFU_VERSION="{{ cookiecutter.opentofu_version }}"

log_info "Running pre-generation checks"

# The slug becomes the directory name (and the suggested state key), so keep
# it to lowercase words joined by hyphens.
if [[ ! "$MODULE_SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    log_error "module_slug '$MODULE_SLUG' is invalid: use lowercase letters, digits, and single hyphens (e.g. 'network-hub')."
    exit 1
fi

if [[ ! "$OPENTOFU_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_error "opentofu_version '$OPENTOFU_VERSION' is invalid: use an exact version like '1.9.0' (it's pinned in mise.toml)."
    exit 1
fi

if ! command -v mise >/dev/null 2>&1; then
    log_error "mise is required to install the module's pinned tools. Install it from https://mise.jdx.dev and retry."
    exit 1
fi

log_info "Pre-generation checks passed"
