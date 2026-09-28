terraform {
  required_version = ">= {{ cookiecutter.opentofu_version }}"
{%- if cookiecutter.use_azurerm or cookiecutter.use_azapi or cookiecutter.use_azuread or cookiecutter.use_random %}

  # A shared module only declares its providers and their minimum versions
  # here — never a `provider "x" {}` block; configuring providers is the
  # caller's job (see examples/). `>=` constraints let callers pick newer
  # releases without waiting on a module release.
  required_providers {
{%- for name, provider in cookiecutter._providers.items() if cookiecutter['use_' ~ name] %}
    {{ name }} = {
      source  = "{{ provider.source }}"
      version = ">= {{ provider.version }}"
    }
{%- endfor %}
  }
{%- endif %}
}
