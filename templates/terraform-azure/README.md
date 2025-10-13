# terraform-azure

This cookiecutter provisions a module project defaulting to the Azure provider.

## Requirements

- [OpenTofu](https://opentofu.org/) or [Terraform](https://developer.hashicorp.com/terraform)
- [pre-commit](https://pre-commit.com/)
- [tflint](https://github.com/terraform-linters/tflint)
- [trivy](https://trivy.dev/latest/)

## Inputs

- `is_config_or_module` - Will omit the providers.tf file if use case is a
    shared module (not config).
- `use_opentofu` - If the project should be initalized using OpenTofu.
- `terraform_or_tofu_version` - Sets the required version in the config.
- `azure_provider_version` - Sets the required version in the config.
- `azure_region` - Inserted into the sample test in tests/terraform.tftest.hcl
- `project_name` - The module name.
- `project_slug` - Auto generated using `project_name`. The default should be accepted.
- `short_project_description` - Inserted in the generated README header via terraform-docs.
- `author` - The module author.
- `create_git_repo` - Determines if a git repo will be created.
- `use_git_hooks` - Determines if hooks using the pre-commit framework will be installed.
- `tests_azure_subscription_id` - Inserted into the provider config in tests/terraform.tftest.hcl
