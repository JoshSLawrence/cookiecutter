terraform {
  required_providers { {% if cookiecutter.use_azure_provider == true %} 
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "{{ cookiecutter._defaults.version_azure_provider }}"
    }{% endif %}
  } {% if cookiecutter.use_opentofu == true %} 
  required_version = "{{ cookiecutter._defaults.version_opentofu }}"{% else %}
  required_version = "{{ cookiecutter._defaults.version_terraform }}"{% endif %}
}
