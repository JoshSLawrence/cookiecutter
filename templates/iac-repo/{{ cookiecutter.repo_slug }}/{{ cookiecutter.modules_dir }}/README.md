# {{ cookiecutter.modules_dir }}

Every OpenTofu module in this repo lives under this directory, at whatever
depth fits (e.g. `{{ cookiecutter.modules_dir }}/network-hub` or
`{{ cookiecutter.modules_dir }}/network/hub`). There is no list of modules to
maintain. The `mise run` tasks find them by convention:

- **Module:** a directory with a `terraform.tf`. Directories inside another
  module (its `modules/` and `examples/`) belong to that module.
- **Root module:** a module that also has a `backend.tf`. It has its own
  state and can be planned and applied.

This directory is set by `MODULES_DIR` in `mise-tasks/lib/common.sh`. If you
rename it, update that too.

Scaffold modules with the cookiecutter templates rather than by hand, so they
follow both conventions and come with tflint, trivy, terraform-docs, and mise
config:

```shell
mise run new-module root
mise run new-module shared -o {{ cookiecutter.modules_dir }}/network
```
