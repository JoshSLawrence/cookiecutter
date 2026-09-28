# AGENTS.md

Instructions for agents working in this repository. See README.md for the
overview and commands.

## Layout

```text
{{ cookiecutter.repo_slug }}/
├── {{ cookiecutter.modules_dir }}/          # every OpenTofu module, at any depth (MODULES_DIR)
├── mise-tasks/       # `mise run <task>` scripts
│   └── lib/          # common.sh: MODULES_DIR, logging, module discovery
└── mise.toml         # repo tool pins
```

## Conventions

- **OpenTofu, not Terraform.** Use `tofu` in commands, scripts, and docs.
  Follow HashiCorp's Terraform style guide for code style.
- **Modules are discovered, not listed.** A directory under `{{ cookiecutter.modules_dir }}/`
  (`MODULES_DIR` in `mise-tasks/lib/common.sh`) with a `terraform.tf` is a
  module; one that also has a `backend.tf` is a root module. Directories
  nested in a module belong to it. Never add a hand-maintained module list
  anywhere.
- **Scaffold with `mise run new-module root|shared`.** Never hand-copy a
  module.
- **Use the tasks.** Prefer `mise run test|plan|apply <module>` over ad hoc
  `tofu` commands. They run each module with its own `mise.toml` pins. Add a
  task to `mise-tasks/` when a common workflow is missing one, sourcing
  `lib/common.sh`.
- **Generated files stay generated.** Module `README.md` files come from
  terraform-docs. Edit `.header.md` and the `.tf` files, then regenerate.
- **Shared modules never configure a provider or backend.** That belongs in
  root modules.

## Safety

- Never run `mise run apply`, `tofu apply`, or `tofu destroy`, or break a
  state lease, without explicit user approval.
- `mise run plan` needs backend and cloud credentials. `mise run test`
  needs neither.
- Never commit secrets. `*.tfvars` and state files are gitignored; don't
  force-add them. Mark sensitive variables and outputs `sensitive = true`.

## Validation

- Run `pre-commit run -a` and `mise run test <module>` before finishing.
- If tflint, trivy, or shellcheck fail, surface the finding and fix the root
  cause. Never add a suppression without user approval.
