{% if cookiecutter.use_azure_provider %}provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
} {% endif %}
