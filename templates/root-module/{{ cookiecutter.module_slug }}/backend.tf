terraform {
  # Configure remote state before the first `tofu apply`. Until then, state
  # is stored locally in terraform.tfstate — never commit that file.
  #
  # backend "azurerm" {
  #   resource_group_name  = "<rg-name>"
  #   storage_account_name = "<storage-account>"
  #   container_name       = "tfstate"
  #   key                  = "{{ cookiecutter.module_slug }}.tfstate"
  #   use_azuread_auth     = true
  # }
}
