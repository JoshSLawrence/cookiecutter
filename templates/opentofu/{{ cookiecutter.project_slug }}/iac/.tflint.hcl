tflint {
  required_version = ">= TFLINT_VERSION"
}

config {
  # stdout format
  format = "default"

  # where plugins, such as azurerm below, are installed
  plugin_dir = "~/.tflint.d/plugins"

  # lint the root module, no remote module sources
  call_module_type = "local"

  # change exit code on lint failure
  force = false

  # are plugin default enabled rules, enabled
  disabled_by_default = false

  # NOTE: Optional - set to n-number of var files as needed for better linting
  # varfile = ["terraform.tfvars"]
}

plugin "azurerm" {
  enabled = true
  version = "TFLINT_AZURERM_VERSION"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
