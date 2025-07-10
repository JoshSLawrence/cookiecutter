variables {
  slug     = "tftest"
  location = "{{ cookiecutter.azure_region }}"

  tags = {
    purpose = "cicd terraform testing"
  }
}

provider "azurerm" {
  # NOTE: Replace subscription_id with the actual Azure subscription ID
  # where you intend to run tests.
  subscription_id = "{{ cookiecutter.azure_subscription_id }}"
  features {}
}

run "resource_group_name_check" {

  command = plan

  assert {
    condition     = azurerm_resource_group.this.name == "rg-tftest-eastus2"
    error_message = "Resource group name does not match the expected value of: rg-tftest-eastus2."
  }
}
