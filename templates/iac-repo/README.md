# IaC Repo Template

Scaffolds a new git repo for [OpenTofu](https://opentofu.org) modules, with
pre-commit hooks, pinned tools, and `mise run` tasks to scaffold, test, plan,
and apply any module in it.

It doesn't create any modules. Add them with the
[root-module](../root-module/README.md) and
[shared-module](../shared-module/README.md) templates, via
`mise run new-module` in the generated repo.

## Requirements

- [cookiecutter](https://cookiecutter.readthedocs.io) 2.2+
- [git](https://git-scm.com) 2.28+
- [mise](https://mise.jdx.dev)

## Usage

Run from the directory that should contain the new repo:

```bash
cookiecutter gh:JoshSLawrence/cookiecutter --directory templates/iac-repo
```

## Inputs

<!-- markdownlint-disable MD013 -->
| Input | Description | Default |
| ----- | ----------- | ------- |
| `repo_name` | Display name, used as the README title | `Example IaC` |
| `repo_slug` | Repo directory name | derived from `repo_name` |
| `description` | Short description for the README | `OpenTofu infrastructure as code` |
| `modules_dir` | Where modules live, relative to the repo root. Stored as `MODULES_DIR` in `mise-tasks/lib/common.sh` | `iac` |
| `opentofu_version` | Pinned in `mise.toml`, used by the hooks, and the default for new modules | `1.9.0` |
<!-- markdownlint-enable MD013 -->

Tool and pre-commit hook versions are hardcoded in `cookiecutter.json`. See
the root [README](../../README.md#updating-versions).

## Generated Structure

```text
<repo_slug>/
├── .gitignore
├── .pre-commit-config.yaml   # fmt, validate, docs, tflint, trivy, shellcheck
├── AGENTS.md
├── <modules_dir>/            # default iac/
│   └── README.md             # module conventions; modules go here
├── mise-tasks/
│   ├── apply.sh              # mise run apply <module>
│   ├── break-lease.sh        # mise run break-lease <module> | --all
│   ├── lib/
│   │   └── common.sh         # MODULES_DIR, logging, module discovery
│   ├── new-module.sh         # mise run new-module <root|shared> [-o <dir>]
│   ├── plan.sh               # mise run plan <module> | --all
│   └── test.sh               # mise run test <module> | --all
├── mise.toml                 # tool pins
└── README.md
```

The tasks find modules by convention instead of a list: a directory under
`MODULES_DIR` with a `terraform.tf` is a module, and one that also has a
`backend.tf` is a root module. Both module templates follow this.

`mise run new-module` creates modules in `MODULES_DIR` by default. Pass
`-o <dir>` (relative to the repo root) to put one elsewhere, e.g.
`-o modules/network` for a nested module. To move every module (e.g. to
`modules/`, as in shared-modules), change `MODULES_DIR` in
`mise-tasks/lib/common.sh`.

## Post-Generation

The post-generation hook:

1. Runs `git init` (branch `main`).
1. Installs the tools pinned in `mise.toml`. It only installs those tools, not
   everything in your global mise config.
1. Runs `pre-commit install`.
1. Makes an initial commit, which runs the hooks. If git has no
   `user.email`, or a hook fails, it skips the commit and leaves the files
   staged.
