locals {
  tags = merge(var.tags, {
    owner   = "josh@joshlawrence.dev",
    purpose = "Generated module via https://github.com/joshslawrence/cookiecutter"
  })
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix  = [var.slug, var.location]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = local.tags
}
