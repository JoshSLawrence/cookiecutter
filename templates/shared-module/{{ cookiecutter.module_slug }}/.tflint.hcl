tflint {
  required_version = ">= {{ cookiecutter._tools.tflint }}"
}

config {
  # stdout format
  format = "default"

  # where plugins are installed
  plugin_dir = "~/.tflint.d/plugins"

  # lint the root module, no remote module sources
  call_module_type = "local"

  # change exit code on lint failure
  force = false

  # are plugin default enabled rules, enabled
  disabled_by_default = false
}
{%- if cookiecutter.use_azurerm %}

plugin "azurerm" {
  enabled = true
  version = "{{ cookiecutter._tflint_ruleset_azurerm_version }}"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
{%- endif %}
