#!/usr/bin/env bash
set -euo pipefail

# Runs inside the generated module directory.

log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1" >&2; }

# Cookiecutter deletes the generated module when a hook fails, so say which
# step broke rather than leaving the user with a bare exit code.
trap 'log_error "Post-generation step failed: $BASH_COMMAND. Fix the issue above and rerun cookiecutter."' ERR

TOOLS=(
    "opentofu@{{ cookiecutter.opentofu_version }}"
    "terraform-docs@{{ cookiecutter._tools['terraform-docs'] }}"
    "tflint@{{ cookiecutter._tools.tflint }}"
    "trivy@{{ cookiecutter._tools.trivy }}"
)

log_info "Installing pinned tools: ${TOOLS[*]}"
mise trust --quiet mise.toml
# Install exactly the pinned tools: a bare `mise install` would also install
# everything in the global and parent-directory mise configs.
mise install "${TOOLS[@]}"

log_info "Initializing and formatting"
mise exec -- tofu init -backend=false -input=false
mise exec -- tofu fmt -list=false

log_info "Generating README.md"
mise exec -- terraform-docs .

log_info "Module generated: $(pwd)"
echo "Next steps:"
echo "  - Configure remote state in backend.tf, then run 'tofu init'."
echo "  - Add resources to main.tf, plus inputs and outputs."
echo "  - Commit .terraform.lock.hcl. Add hashes for other platforms (e.g. CI)"
echo "    with 'tofu providers lock -platform=linux_amd64 -platform=darwin_arm64'."
echo "  - Run 'mise exec -- tflint --init' to install any tflint plugins."
