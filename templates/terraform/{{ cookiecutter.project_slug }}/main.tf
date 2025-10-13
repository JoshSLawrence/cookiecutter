{% if cookiecutter.use_azure_provider == true %}locals {
  tags = merge(var.tags, {
    owner   = "{{ cookiecutter.author }}",
    purpose = "Generated module via https://github.com/joshslawrence/cookiecutter"
  })
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "{{ cookiecutter._defaults.version_azure_naming }}"
  suffix  = [var.slug, var.location]
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name
  location = var.location
  tags     = local.tags
} {% endif %}
