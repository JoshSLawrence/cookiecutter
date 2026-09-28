# Examples

Usage examples for callers of this module. Unlike the module itself, an
example is a root module: it configures its own `provider`/backend and calls
this module by relative `source`, e.g.:

```hcl
terraform {
  required_version = ">= {{ cookiecutter.opentofu_version }}"
}

provider "azurerm" {
  # ...
}

module "this" {
  source = "../.."

  # required inputs for the module under test
}
```

Add one subdirectory per example (e.g. `examples/basic/`), each runnable on
its own with `tofu init` / `tofu plan`.

The relative `source = "../.."` above is only for exercising the module
in-place, before it's ever tagged. Real callers outside this repo reference
it via Git source with a pinned, module-scoped tag instead — see the
"Usage" section this module's generated `README.md` (from `.header.md`), or
the repo root [README.md](../../../README.md#using-a-shared-module).

Delete this file once a real example has been added.
