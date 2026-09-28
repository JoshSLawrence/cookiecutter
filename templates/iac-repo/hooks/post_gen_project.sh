#!/usr/bin/env bash
set -euo pipefail

# Runs inside the generated repo.

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1" >&2; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

# Cookiecutter deletes the generated repo when a hook fails, so say which
# step broke rather than leaving the user with a bare exit code.
trap 'log_error "Post-generation step failed: $BASH_COMMAND. Fix the issue above and rerun cookiecutter."' ERR

TOOLS=(
    "opentofu@{{ cookiecutter.opentofu_version }}"
    "cookiecutter@{{ cookiecutter._tools.cookiecutter }}"
    "pre-commit@{{ cookiecutter._tools['pre-commit'] }}"
    "shellcheck@{{ cookiecutter._tools.shellcheck }}"
    "terraform-docs@{{ cookiecutter._tools['terraform-docs'] }}"
    "tflint@{{ cookiecutter._tools.tflint }}"
    "trivy@{{ cookiecutter._tools.trivy }}"
)

log_info "Initializing git repo"
git init --quiet --initial-branch=main

log_info "Installing pinned tools: ${TOOLS[*]}"
mise trust --quiet mise.toml
# Install exactly the pinned tools: a bare `mise install` would also install
# everything in the global and parent-directory mise configs.
mise install "${TOOLS[@]}"

log_info "Installing pre-commit hooks"
mise exec -- pre-commit install

git add --all
# Not fatal: without a git identity (or if a hook fails on the first run) the
# repo is still usable; the files stay staged for the user to commit.
if ! git config user.email >/dev/null 2>&1; then
    log_warn "No git user.email configured, so no initial commit was made. Set one and commit the staged files."
elif ! git commit --quiet -m "chore: initial commit from cookiecutter iac-repo template"; then
    log_warn "Initial commit failed (see the pre-commit output above). Fix the findings and commit the staged files."
fi

log_info "Repo generated: $(pwd)"
echo "Next steps:"
echo "  - Scaffold modules under {{ cookiecutter.modules_dir }}/: 'mise run new-module root' or 'mise run new-module shared'."
echo "  - List tasks with 'mise tasks'. Run a task with no arguments for usage."
echo "  - Add a remote: git remote add origin <url>"
