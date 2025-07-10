terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "{{ cookiecutter.azure_provider_version }}"
    }
  }
  required_version = "{{ cookiecutter.terraform_or_tofu_version }}"
}
