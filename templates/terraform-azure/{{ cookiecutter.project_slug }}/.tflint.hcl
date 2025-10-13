tflint {
  required_version = ">= 0.58.1"
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
  version = "0.28.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# NOTE: This is the only rule not enabled by default from the azurerm rulset
rule "azurerm_resource_missing_tags" {
  enabled = true
  tags    = ["owner", "purpose"]
}
