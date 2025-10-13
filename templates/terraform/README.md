# terraform

This cookiecutter template provisions an OpenTofu or Terraform project complete
with the following checks via Git hooks:

- Linting
- Formatting
- Security
- Policy
- Document Generation
- Built in Validation

## Requirements

- [Git](https://git-scm.com/)
- [Mise](https://mise.jdx.dev/)

> Mise is used to install all dependencies required for the generated terraform
> project. If you are not familiar with mise it is highly recommended to leverage
> mise to manage project dependencies. It acts akin to a package manager, read more
> here: [https://mise.jdx.dev/] - if you make the switch do not forget to uninstall
> tools outside of mise to avoid conflicts with the mise managed version.

## Inputs

- `use_opentofu` - If the project should be initalized using OpenTofu.
- `use_azure_provider` - Sets the required version in the config.
- `project_name` - The module name.
- `project_slug` - Auto generated using `project_name`. The default should be accepted.
- `short_project_description` - Inserted in the generated README header via terraform-docs.
- `author` - The module author.

## Defaults

List of defaults that are set when generating a terraform project using this template.

### Versions

- [OpenTofu](https://opentofu.org/) - Constraint is set to `>= v1.10.6`
- [Terraform](https://developer.hashicorp.com/terraform) - Constraint is set to `>= 1.13.3`
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) - Constraint is set to `>= 4.47.0`
- [Azure Naming](https://github.com/Azure/terraform-azurerm-naming) - This module version is set to `0.4.2`

### Other

- `Azure Region` - The input variable `location` and included example test's
    input variable `location` is set to `eastus2`
