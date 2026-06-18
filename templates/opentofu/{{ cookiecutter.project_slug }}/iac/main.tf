locals {
  tags = merge(var.tags, {
    owner   = "{{ cookiecutter.author }}",
    purpose = "Generated module via https://github.com/joshslawrence/cookiecutter"
  })
}

# tflint-ignore: terraform_unused_declarations
data "azurerm_client_config" "this" {}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "AZURE_NAMING_VERSION"
  suffix  = [var.slug, var.location]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = local.tags
}
