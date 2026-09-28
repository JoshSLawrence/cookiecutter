# Provider configuration lives only in root modules; shared and child modules
# inherit it from here.
{%- if cookiecutter.use_azurerm %}

provider "azurerm" {
  # Reads the subscription from ARM_SUBSCRIPTION_ID unless subscription_id is
  # set here.
  features {}
}
{%- endif %}
{%- if cookiecutter.use_azapi %}

provider "azapi" {}
{%- endif %}
{%- if cookiecutter.use_azuread %}

provider "azuread" {}
{%- endif %}
{%- if cookiecutter.use_random%}

provider "random" {}
{%- endif %}
