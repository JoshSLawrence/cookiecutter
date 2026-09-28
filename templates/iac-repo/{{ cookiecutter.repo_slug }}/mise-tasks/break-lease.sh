#!/usr/bin/env bash
#MISE description="Break a stuck azurerm state lease for one root module (or all of them)"
set -euo pipefail

# shellcheck source=mise-tasks/lib/common.sh
source "$(dirname "$0")/lib/common.sh"

usage() {
    log_error "Usage: mise run break-lease <module> | --all"
    log_error ""
    log_error "  <module>  Root module path, relative to $MODULES_DIR/ (e.g. 'network/hub')"
    log_error "  --all     Break the lease on every root module's state"
    log_error ""
    log_error "Reads the module's azurerm backend from backend.tf and runs"
    log_error "'az storage blob lease break' to release a lock left behind by a"
    log_error "cancelled or crashed plan/apply. Needs the az CLI, logged in."
    log_error ""
    log_error "Root modules:"
    print_modules find_root_modules
    exit 1
}

[ $# -eq 1 ] || usage

# Print one attribute of the azurerm backend block in a module's backend.tf,
# or nothing if unset. Commented-out lines don't match.
# Usage: backend_attr <module> <attribute>
backend_attr() {
    sed -n -E "s/^[[:space:]]*${2}[[:space:]]*=[[:space:]]*\"([^\"]*)\".*/\1/p" \
        "$REPO_ROOT/$1/backend.tf" | head -n1
}

# Returns 0 on success (including "nothing to break"), 1 on failure.
break_one() {
    local module="$1"
    log_step "Break lease: $module"

    local account container key subscription
    account="$(backend_attr "$module" storage_account_name)"
    container="$(backend_attr "$module" container_name)"
    key="$(backend_attr "$module" key)"
    subscription="$(backend_attr "$module" subscription_id)"

    if [ -z "$account" ] || [ -z "$container" ] || [ -z "$key" ]; then
        log_error "No azurerm backend in $module/backend.tf (needs storage_account_name, container_name, and key). Configure the backend first."
        return 1
    fi
    log_info "State blob: $account/$container/$key"

    local blob_args=(--account-name "$account" --container-name "$container" --auth-mode login)
    # Only pass a subscription when backend.tf sets one, so the active az
    # context isn't overridden with an empty value.
    if [ -n "$subscription" ]; then
        blob_args+=(--subscription "$subscription")
    fi

    local lease_state
    if ! lease_state="$(az storage blob show "${blob_args[@]}" --name "$key" \
        --query "properties.lease.state" -o tsv)"; then
        log_error "Could not read $account/$container/$key. Check 'az login', your access to the storage account, and that the state blob exists."
        return 1
    fi

    if [ "$lease_state" != "leased" ]; then
        log_info "No active lease (state: ${lease_state:-none}), nothing to break."
        return 0
    fi

    log_warn "Blob is leased, breaking the lease."
    if ! az storage blob lease break "${blob_args[@]}" --blob-name "$key" \
        --lease-break-period 0 >/dev/null; then
        log_error "Failed to break the lease on $key. Check your permissions on the storage account."
        return 1
    fi
    log_info "Lease broken for $module"
}

if ! command -v az >/dev/null 2>&1; then
    log_error "The az CLI is required. Install it: https://learn.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

FAILED=()
if [ "$1" = "--all" ]; then
    while IFS= read -r module; do
        [ -n "$module" ] || continue
        break_one "$module" || FAILED+=("$module")
    done <<< "$(find_root_modules)"
else
    module="$(resolve_module "$1" root)" || usage
    break_one "$module" || FAILED+=("$module")
fi

if [ ${#FAILED[@]} -gt 0 ]; then
    log_error "Could not break the lease for: ${FAILED[*]}. See the output above."
    exit 1
fi

log_summary "Lease break complete"
