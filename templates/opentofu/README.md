# OpenTofu Cookiecutter Template

This cookiecutter template generates an OpenTofu project with pre-configured tooling, git hooks, and Azure provider setup.

## Features

- **Pre-commit hooks** - Automatic formatting, linting, validation, security scanning, and documentation generation
- **Tool management** - All dependencies managed via [Mise](https://mise.jdx.dev/)
- **Latest versions** - Automatically fetches latest tool versions (or use specific versions)
- **Azure-ready** - Pre-configured Azure provider with sensible defaults

## Requirements

- [Git](https://git-scm.com/)
- [Mise](https://mise.jdx.dev/)

## Usage

```bash
cookiecutter gh:JoshSLawrence/cookiecutter --directory=templates/opentofu
```

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `project_name` | The project name | `Example` |
| `project_slug` | Auto-generated slug from project_name | _(auto)_ |
| `short_project_description` | Brief description for README | `Example OpenTofu Module` |
| `author` | Module author name | `Anonymous` |
| `azure_region` | Azure region for resources | `eastus2` |
| `subscription_id` | Azure subscription ID (optional) | _(empty)_ |
| `opentofu_version` | OpenTofu version | `latest` |
| `azurerm_version` | Azure provider version | `latest` |
| `azure_naming_version` | Azure naming module version | `latest` |
| `terraform_docs_version` | terraform-docs version | `latest` |
| `trivy_version` | Trivy security scanner version | `latest` |
| `precommit_version` | pre-commit version | `latest` |
| `tflint_version` | TFLint version | `latest` |
| `precommit_hooks_version` | pre-commit-hooks repo version | `latest` |
| `precommit_terraform_version` | pre-commit-terraform repo version | `latest` |
| `tflint_azurerm_version` | TFLint Azure plugin version | `latest` |

## What's Included

The generated project includes:

- **OpenTofu configuration** with Azure provider
- **Azure naming module** for consistent resource naming
- **Mise configuration** for tool version management
- **Pre-commit hooks** for code quality:
  - `terraform_fmt` - Format code
  - `terraform_validate` - Validate configuration
  - `terraform_docs` - Generate documentation
  - `terraform_tflint` - Lint with TFLint
  - `terraform_trivy` - Security scanning
  - `check-added-large-files` - Prevent large commits
  - `trailing-whitespace` - Clean up whitespace
- **Mise tasks** for common operations (apply, destroy, docs, test, lockfile)
- **Git repository** initialized with initial commit
- **Documentation** auto-generated from code

## Post-Generation

The template automatically:
1. Fetches latest versions (if not specified)
2. Installs all required tools via Mise
3. Initializes OpenTofu
4. Generates documentation
5. Sets up Git repository and hooks
6. Creates initial commit

All versions are dynamically fetched from official sources unless you specify a particular version.
