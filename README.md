# Cookiecutter

A collection of my homemade
[cookiecutter](https://github.com/cookiecutter/cookiecutter) templates.

## Usage

Point cookiecutter at this repo and pass `--directory` to pick a template
from [templates](./templates):

```bash
cookiecutter gh:JoshSLawrence/cookiecutter --directory templates/<template>
```

Or, from a local clone:

```bash
cookiecutter templates/<template>
```

## Available Templates

<!-- markdownlint-disable MD013 -->
| Template | Scaffolds |
| -------- | --------- |
| [iac-repo](./templates/iac-repo/README.md) | A git repo for OpenTofu modules, with pre-commit and `mise run` tasks |
| [root-module](./templates/root-module/README.md) | An OpenTofu root module |
| [shared-module](./templates/shared-module/README.md) | An OpenTofu shared module |
<!-- markdownlint-enable MD013 -->

The module templates prompt for which providers to use (azurerm, azapi,
azuread, random) and generate the matching `required_providers`, tflint,
trivy, terraform-docs, and mise config. They scaffold a module directory
inside an existing repo and never create a git repo.

`iac-repo` is the only template that creates a git repo. It contains no
modules. Add them with `mise run new-module root|shared` in the generated
repo, which runs the module templates into its modules directory (`iac/`
by default, configurable).

## Updating Versions

Provider, tool, and hook versions are hardcoded rather than fetched at
generation time, so output is reproducible. They live in the private (`_`)
keys of each template's `cookiecutter.json`:

- [iac-repo](./templates/iac-repo/cookiecutter.json): `_tools`,
  `_precommit_revs`
- [root-module](./templates/root-module/cookiecutter.json): `_tools`,
  `_tflint_ruleset_azurerm_version`, `_providers`
- [shared-module](./templates/shared-module/cookiecutter.json): same keys as
  root-module

Keep versions that appear in more than one file in sync. To find the latest
releases:

```bash
for tool in opentofu cookiecutter pre-commit shellcheck terraform-docs tflint trivy; do
    echo "$tool: $(mise latest "$tool")"
done
for repo in terraform-linters/tflint-ruleset-azurerm pre-commit/pre-commit-hooks \
    antonbabenko/pre-commit-terraform shellcheck-py/shellcheck-py; do
    echo "$repo: $(gh api "repos/$repo/tags" -q '.[0].name')"
done
```

Provider versions are listed on the OpenTofu registry
(`https://search.opentofu.org/provider/<namespace>/<name>`).

Then check that every template still renders and passes its own checks:

```bash
./tools/test.sh
```
