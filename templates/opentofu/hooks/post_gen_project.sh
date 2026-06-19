#!/bin/bash

# Color definitions
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

# Decorated logging function
decorate_log() {
    local log_info="${COLOR_GREEN}[INFO]${COLOR_RESET}"
    local log_pass="${COLOR_GREEN}[PASS]${COLOR_RESET}"
    local log_warning="${COLOR_YELLOW}[WARNING]${COLOR_RESET}"
    local log_error="${COLOR_RED}[ERROR]${COLOR_RESET}"
    local log_fail="${COLOR_RED}[FAIL]${COLOR_RESET}"

    local log_type=$1
    local log_message=$2

    if [ $log_type = "INFO" ]; then
        echo -e "${log_info} ${log_message}"
    elif [ $log_type = "PASS" ]; then
        echo -e "${log_pass} ${log_message}"
    elif [ $log_type = "WARN" ]; then
        echo -e "${log_warning} ${log_message}"
    elif [ $log_type = "ERROR" ]; then
        echo -e "${log_error} ${log_message}"
    elif [ $log_type = "FAIL" ]; then
        echo -e "${log_fail} ${log_message}"
    else
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} Invalid log type.\n\n\tReceived: $log_type\n\tValid Types: INFO, PASS, WARN, ERROR, FAIL\n"
        exit 1
    fi
}

# Fetch latest versions using mise
echo ""
decorate_log "INFO" "Fetching Latest Versions"
echo ""

# Get user-specified versions from cookiecutter
USER_OPENTOFU_VERSION="{{ cookiecutter.opentofu_version }}"
USER_AZURERM_VERSION="{{ cookiecutter.azurerm_version }}"
USER_AZURE_NAMING_VERSION="{{ cookiecutter.azure_naming_version }}"
USER_TERRAFORM_DOCS_VERSION="{{ cookiecutter.terraform_docs_version }}"
USER_TRIVY_VERSION="{{ cookiecutter.trivy_version }}"
USER_PRECOMMIT_VERSION="{{ cookiecutter.precommit_version }}"
USER_TFLINT_VERSION="{{ cookiecutter.tflint_version }}"
USER_PRECOMMIT_HOOKS_VERSION="{{ cookiecutter.precommit_hooks_version }}"
USER_PRECOMMIT_TERRAFORM_VERSION="{{ cookiecutter.precommit_terraform_version }}"
USER_TFLINT_AZURERM_VERSION="{{ cookiecutter.tflint_azurerm_version }}"

# Fetch latest OpenTofu version
if [ -n "$USER_OPENTOFU_VERSION" ] && [ "$USER_OPENTOFU_VERSION" != "latest" ]; then
    OPENTOFU_VERSION="$USER_OPENTOFU_VERSION"
    decorate_log "INFO" "Using user-specified OpenTofu version: $OPENTOFU_VERSION"
else
    # Run from /tmp to avoid reading the local mise.toml with placeholders
    OPENTOFU_VERSION=$(cd /tmp && mise ls-remote opentofu 2>/dev/null | tail -1)
    if [ -z "$OPENTOFU_VERSION" ]; then
        OPENTOFU_VERSION="1.10.6"
    fi
    decorate_log "INFO" "Using latest OpenTofu version: $OPENTOFU_VERSION"
fi

# For Azure provider, we'll query the Terraform registry since mise doesn't track providers
if [ -n "$USER_AZURERM_VERSION" ] && [ "$USER_AZURERM_VERSION" != "latest" ]; then
    AZURERM_VERSION="$USER_AZURERM_VERSION"
    decorate_log "INFO" "Using user-specified Azure provider version: $AZURERM_VERSION"
else
    # Query Terraform registry for latest azurerm provider version
    AZURERM_VERSION=$(curl -s https://registry.terraform.io/v1/providers/hashicorp/azurerm | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "4.47.0")
    decorate_log "INFO" "Using latest Azure provider version: $AZURERM_VERSION"
fi

# Azure Naming Module
if [ -n "$USER_AZURE_NAMING_VERSION" ] && [ "$USER_AZURE_NAMING_VERSION" != "latest" ]; then
    AZURE_NAMING_VERSION="$USER_AZURE_NAMING_VERSION"
    decorate_log "INFO" "Using user-specified Azure naming module version: $AZURE_NAMING_VERSION"
else
    # Query Terraform registry for latest Azure naming module version
    AZURE_NAMING_VERSION=$(curl -s https://registry.terraform.io/v1/modules/Azure/naming/azurerm | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "0.4.3")
    decorate_log "INFO" "Using latest Azure naming module version: $AZURE_NAMING_VERSION"
fi

# Fetch latest versions for other tools using mise
decorate_log "INFO" "Fetching versions for other tools"

# Terraform Docs
if [ -n "$USER_TERRAFORM_DOCS_VERSION" ] && [ "$USER_TERRAFORM_DOCS_VERSION" != "latest" ]; then
    TERRAFORM_DOCS_VERSION="$USER_TERRAFORM_DOCS_VERSION"
    decorate_log "INFO" "Using user-specified terraform-docs version: $TERRAFORM_DOCS_VERSION"
else
    TERRAFORM_DOCS_VERSION=$(cd /tmp && mise ls-remote terraform-docs 2>/dev/null | tail -1)
    if [ -z "$TERRAFORM_DOCS_VERSION" ]; then TERRAFORM_DOCS_VERSION="0.18.0"; fi
    decorate_log "INFO" "Using latest terraform-docs version: $TERRAFORM_DOCS_VERSION"
fi

# Trivy
if [ -n "$USER_TRIVY_VERSION" ] && [ "$USER_TRIVY_VERSION" != "latest" ]; then
    TRIVY_VERSION="$USER_TRIVY_VERSION"
    decorate_log "INFO" "Using user-specified trivy version: $TRIVY_VERSION"
else
    TRIVY_VERSION=$(cd /tmp && mise ls-remote trivy 2>/dev/null | tail -1)
    if [ -z "$TRIVY_VERSION" ]; then TRIVY_VERSION="0.50.0"; fi
    decorate_log "INFO" "Using latest trivy version: $TRIVY_VERSION"
fi

# Pre-commit
if [ -n "$USER_PRECOMMIT_VERSION" ] && [ "$USER_PRECOMMIT_VERSION" != "latest" ]; then
    PRECOMMIT_VERSION="$USER_PRECOMMIT_VERSION"
    decorate_log "INFO" "Using user-specified pre-commit version: $PRECOMMIT_VERSION"
else
    PRECOMMIT_VERSION=$(cd /tmp && mise ls-remote pre-commit 2>/dev/null | tail -1)
    if [ -z "$PRECOMMIT_VERSION" ]; then PRECOMMIT_VERSION="3.7.0"; fi
    decorate_log "INFO" "Using latest pre-commit version: $PRECOMMIT_VERSION"
fi

# TFLint
if [ -n "$USER_TFLINT_VERSION" ] && [ "$USER_TFLINT_VERSION" != "latest" ]; then
    TFLINT_VERSION="$USER_TFLINT_VERSION"
    decorate_log "INFO" "Using user-specified tflint version: $TFLINT_VERSION"
else
    TFLINT_VERSION=$(cd /tmp && mise ls-remote tflint 2>/dev/null | tail -1)
    if [ -z "$TFLINT_VERSION" ]; then TFLINT_VERSION="0.50.0"; fi
    decorate_log "INFO" "Using latest tflint version: $TFLINT_VERSION"
fi

# Fetch latest versions for pre-commit hooks
decorate_log "INFO" "Fetching pre-commit hook versions"

# Pre-commit-hooks
if [ -n "$USER_PRECOMMIT_HOOKS_VERSION" ] && [ "$USER_PRECOMMIT_HOOKS_VERSION" != "latest" ]; then
    PRECOMMIT_HOOKS_VERSION="$USER_PRECOMMIT_HOOKS_VERSION"
    decorate_log "INFO" "Using user-specified pre-commit-hooks version: $PRECOMMIT_HOOKS_VERSION"
else
    PRECOMMIT_HOOKS_VERSION=$(curl -s https://api.github.com/repos/pre-commit/pre-commit-hooks/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 || echo "v6.0.0")
    decorate_log "INFO" "Using latest pre-commit-hooks version: $PRECOMMIT_HOOKS_VERSION"
fi

# Pre-commit-terraform
if [ -n "$USER_PRECOMMIT_TERRAFORM_VERSION" ] && [ "$USER_PRECOMMIT_TERRAFORM_VERSION" != "latest" ]; then
    PRECOMMIT_TERRAFORM_VERSION="$USER_PRECOMMIT_TERRAFORM_VERSION"
    decorate_log "INFO" "Using user-specified pre-commit-terraform version: $PRECOMMIT_TERRAFORM_VERSION"
else
    PRECOMMIT_TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/antonbabenko/pre-commit-terraform/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 || echo "v1.99.5")
    decorate_log "INFO" "Using latest pre-commit-terraform version: $PRECOMMIT_TERRAFORM_VERSION"
fi

# TFLint Azure plugin
if [ -n "$USER_TFLINT_AZURERM_VERSION" ] && [ "$USER_TFLINT_AZURERM_VERSION" != "latest" ]; then
    TFLINT_AZURERM_VERSION="$USER_TFLINT_AZURERM_VERSION"
    decorate_log "INFO" "Using user-specified tflint-azurerm version: $TFLINT_AZURERM_VERSION"
else
    TFLINT_AZURERM_VERSION=$(curl -s https://api.github.com/repos/terraform-linters/tflint-ruleset-azurerm/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//' || echo "0.32.0")
    decorate_log "INFO" "Using latest tflint-azurerm version: $TFLINT_AZURERM_VERSION"
fi

echo ""
decorate_log "INFO" "Version Summary"
decorate_log "INFO" "OpenTofu: ${OPENTOFU_VERSION}, AzureRM Provider: ${AZURERM_VERSION}, Azure Naming Module: ${AZURE_NAMING_VERSION}"
decorate_log "INFO" "Tools - terraform-docs: ${TERRAFORM_DOCS_VERSION}, trivy: ${TRIVY_VERSION}, pre-commit: ${PRECOMMIT_VERSION}, tflint: ${TFLINT_VERSION}"
decorate_log "INFO" "Pre-commit hooks - pre-commit-hooks: ${PRECOMMIT_HOOKS_VERSION}, pre-commit-terraform: ${PRECOMMIT_TERRAFORM_VERSION}"
decorate_log "INFO" "TFLint plugins - azurerm: ${TFLINT_AZURERM_VERSION}"

# Update terraform.tf with the versions
decorate_log "INFO" "Updating iac/terraform.tf with resolved versions"
sed -i.bak "s/OPENTOFU_VERSION/>= ${OPENTOFU_VERSION}/g" iac/terraform.tf
sed -i.bak "s/AZURERM_VERSION/>= ${AZURERM_VERSION}/g" iac/terraform.tf
rm -f iac/terraform.tf.bak

# Update iac/main.tf with the Azure naming module version
decorate_log "INFO" "Updating iac/main.tf with Azure naming module version"
sed -i.bak "s/AZURE_NAMING_VERSION/${AZURE_NAMING_VERSION}/g" iac/main.tf
rm -f iac/main.tf.bak

# Update mise.toml with the resolved versions
decorate_log "INFO" "Updating mise.toml with resolved versions"
sed -i.bak "s/OPENTOFU_VERSION/${OPENTOFU_VERSION}/g" mise.toml
sed -i.bak "s/TERRAFORM_DOCS_VERSION/${TERRAFORM_DOCS_VERSION}/g" mise.toml
sed -i.bak "s/TRIVY_VERSION/${TRIVY_VERSION}/g" mise.toml
sed -i.bak "s/PRECOMMIT_VERSION/${PRECOMMIT_VERSION}/g" mise.toml
sed -i.bak "s/TFLINT_VERSION/${TFLINT_VERSION}/g" mise.toml
rm -f mise.toml.bak

# Update .pre-commit-config.yaml with the latest hook versions
decorate_log "INFO" "Updating .pre-commit-config.yaml with latest hook versions"
sed -i.bak "s/PRECOMMIT_HOOKS_VERSION/${PRECOMMIT_HOOKS_VERSION}/g" .pre-commit-config.yaml
sed -i.bak "s/PRECOMMIT_TERRAFORM_VERSION/${PRECOMMIT_TERRAFORM_VERSION}/g" .pre-commit-config.yaml
rm -f .pre-commit-config.yaml.bak

# Update iac/.tflint.hcl with the latest tflint and plugin versions
decorate_log "INFO" "Updating iac/.tflint.hcl with latest tflint and plugin versions"
sed -i.bak "s/TFLINT_VERSION/${TFLINT_VERSION}/g" iac/.tflint.hcl
sed -i.bak "s/TFLINT_AZURERM_VERSION/${TFLINT_AZURERM_VERSION}/g" iac/.tflint.hcl
rm -f iac/.tflint.hcl.bak

echo ""
decorate_log "INFO" "Installing Required Tools via Mise"
echo ""
# Trust the mise config file
mise trust || true
mise install || exit 1

# Init
echo ""
decorate_log "INFO" "Initializing OpenTofu Project"
echo ""
cd iac
tofu init
tofu fmt -list=false
cd ..

# Doc generation
echo ""
decorate_log "INFO" "Generating Documentation"
echo ""
cd iac
terraform-docs .
cd ..

# Git and Hook setup
echo ""
decorate_log "INFO" "Initializing Git Repo"
echo ""
git init
echo ""
decorate_log "INFO" "Installing Git Hooks"
echo ""
pre-commit install

# Hooks should run when the commit is attempted
echo ""
decorate_log "INFO" "Creating Initial Commit"
echo ""
git add .
git commit -m "feat: project generated from cookiecutter template" -m "Generated using the OpenTofu cookiecutter template from:
https://github.com/JoshSLawrence/cookiecutter

Template: opentofu"

echo ""
decorate_log "PASS" "Project Generation Complete"
echo ""

# Provide helpful notes based on whether subscription_id was set
{%- if cookiecutter.subscription_id %}
decorate_log "INFO" "Default subscription_id has been set to: {{ cookiecutter.subscription_id }}"
echo "You can override this by passing -var='subscription_id=OTHER_SUB_ID' when running tofu commands."
echo ""
{%- else %}
decorate_log "WARN" "You will need to provide a value for the 'subscription_id' variable to run a successful plan or apply."
echo "You can:"
echo "  - Set it via command line: tofu plan -var='subscription_id=YOUR_SUB_ID'"
echo "  - Set it in a .tfvars file: subscription_id = \"YOUR_SUB_ID\""
echo "  - Set it via environment variable: export TF_VAR_subscription_id=YOUR_SUB_ID"
echo ""
{%- endif %}
