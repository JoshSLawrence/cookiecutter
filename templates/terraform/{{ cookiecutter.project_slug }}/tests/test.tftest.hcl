{% if cookiecutter.use_azure_provider %}variables {
  slug     = "tftest"
  location = "{{ cookiecutter._defaults.region_azure }}"

  tags = {
    purpose = "cicd terraform testing"
  }
}

provider "azurerm" {
  # NOTE: Replace subscription_id with the actual Azure subscription ID
  # where you intend to run tests.
  subscription_id = "" # NOTE: Set your sub id in which tests should be ran
  features {}
}

run "resource_group_name_check" {

  command = plan

  assert {
    condition     = azurerm_resource_group.this.name == "rg-tftest-eastus2"
    error_message = "Resource group name does not match the expected value of: rg-tftest-eastus2."
  }
} {% endif %}
