# AGENTS.md

Guidance for agents working in this repo: a personal collection of
[cookiecutter](https://github.com/cookiecutter/cookiecutter) templates. It's
consumed as a git submodule by
[shared-modules](https://github.com/JoshSLawrence/shared-modules), and repos
generated from `iac-repo` fetch the module templates from it, so a template
change can break scaffolding (and CI) elsewhere.

## Structure

```text
cookiecutter/
├── README.md
├── templates/
│   ├── iac-repo/                     # git repo for OpenTofu modules
│   │   ├── cookiecutter.json         # prompts, defaults, pinned versions
│   │   ├── hooks/
│   │   │   ├── post_gen_project.sh   # runs inside the generated output
│   │   │   └── pre_gen_project.sh    # runs before generation; validates inputs
│   │   ├── README.md                 # template docs (inputs, usage)
│   │   └── {{ cookiecutter.repo_slug }}/
│   ├── root-module/                  # OpenTofu root module (same layout,
│   │   └── ...                       #   output dir {{ cookiecutter.module_slug }})
│   └── shared-module/                # OpenTofu shared module (same layout)
└── tools/
    ├── publish.sh                    # zips a template into gitignored publish/
    └── test.sh                       # renders templates and runs their checks
```

## Conventions

- **Only `iac-repo` creates a git repo.** The module templates scaffold a
  module directory only: no `git init`, commit, `.gitignore`, or
  `.pre-commit-config.yaml`. The containing repo provides those.
- **`iac-repo` contains no modules.** Modules are added with its
  `mise run new-module root|shared` task, which runs the module templates.
  Keep its module discovery convention (`terraform.tf` = module, plus
  `backend.tf` = root module) in step with what the module templates
  generate.
- **The modules directory is configurable.** `modules_dir` is rendered into
  `MODULES_DIR` in `mise-tasks/lib/common.sh`, which every task sources.
  Never hardcode `iac/` in `mise-tasks/`. It's deliberately not a mise
  `[env]` value: that would make `mise.toml` require `mise trust`.
- **Versions are hardcoded, never fetched.** Provider, tool, hook, and tflint
  ruleset versions live in private `_` keys in each `cookiecutter.json`. Keep
  a version identical everywhere it appears. Don't add "latest" lookups to
  hooks.
- **Providers are opt-in prompts.** Each `_providers` entry needs a matching
  `use_<name>` boolean. `terraform.tf` loops over `_providers`, but
  `providers.tf` (root) and `.tflint.hcl` handle each provider explicitly.
- **Constraints differ by module type.** Shared modules use
  `>= <version>` so callers can go newer. Root modules use
  `~> <major>.<minor>` and commit the lock file.
- **Shell stays shellcheck-clean unrendered.** Keep Jinja inside quoted
  strings in hooks (no `{% for %}` blocks). `iac-repo`'s `mise-tasks/*.sh`
  are copied without rendering (`_copy_without_render`), so they're plain
  bash. `mise-tasks/lib/common.sh` is rendered (for `MODULES_DIR`), so it
  must stay free of `{{`, `{%`, and `{#` (e.g. `${#array[@]}`).
- **`iac-repo` tasks must run on bash 3.2** (macOS `/bin/bash`): no
  `mapfile`, `${var,,}`, or `"${empty_array[@]}"` under `set -u`.

## Validating changes

```bash
shellcheck -x templates/*/hooks/*.sh tools/test.sh
(cd "templates/iac-repo/{{ cookiecutter.repo_slug }}" && shellcheck -x mise-tasks/*.sh mise-tasks/lib/common.sh)
./tools/test.sh
```

`tools/test.sh` renders each module template with every provider on and with
none, then runs `tofu fmt -check`, `tofu validate`, `tflint`, and `trivy`.
For `iac-repo` it renders the repo, scaffolds a root and a shared module into
it from this working tree, and runs its `test` and `plan` tasks and
pre-commit hooks. It needs network access for tools, providers, plugins, and
hook environments.

## Gotchas

- **Single-underscore keys aren't rendered or prompted.** Use them for
  literal data (`_providers`, `_tools`). A `__double` key would be rendered.
- **Booleans need cookiecutter 2.2+.** `use_*: true` shows a yes/no prompt.
  On the CLI (`use_azapi=true`) cookiecutter converts the string to a bool.
- **Bash `${#array[@]}` is a Jinja comment opener (`{#`).** Any rendered
  file containing it breaks generation. Keep such scripts in
  `_copy_without_render`.
- **`_copy_without_render` globs match across `/`.** `mise-tasks/*.sh` would
  also match `mise-tasks/lib/common.sh` and leave `MODULES_DIR` unrendered,
  so `iac-repo` lists each task file by name. Add new task scripts to that
  list.
- **Cookiecutter keeps file modes.** Tasks under `iac-repo`'s `mise-tasks/`
  must stay executable (mise only lists executable files), and
  `mise-tasks/lib/common.sh` must not be, or it shows up as a task.
- **pre_gen can't see generated files.** It runs before generation, so it
  can only validate cookiecutter variables.
- **post_gen runs inside the generated output.** Paths are relative to it.
- **A failing hook deletes the generated output.** Error messages should say
  which step failed and what to fix. `iac-repo`'s initial commit only warns
  on failure, so a hook finding doesn't throw the repo away.
- **`_copy_without_render` covers `.terraform-docs.yaml`.** Its Go template
  syntax (`{{ .Content }}`) would otherwise break Jinja rendering.
