terraform {
  required_version = ">= {{ cookiecutter.opentofu_version }}"
{%- if cookiecutter.use_azurerm or cookiecutter.use_azapi or cookiecutter.use_azuread or cookiecutter.use_random %}

  # `~>` allows minor and patch updates but not the next major version;
  # .terraform.lock.hcl records the exact versions in use, so commit it.
  required_providers {
{%- for name, provider in cookiecutter._providers.items() if cookiecutter['use_' ~ name] %}
    {{ name }} = {
      source  = "{{ provider.source }}"
      version = "~> {{ provider.version.split('.')[:2] | join('.') }}"
    }
{%- endfor %}
  }
{%- endif %}
}
