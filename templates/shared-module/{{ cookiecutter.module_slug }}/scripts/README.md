# Scripts

Scripts supporting this module — e.g. ones invoked via `local-exec`
provisioners rather than inlined in `.tf` files.

Prefer a real script file here over an inline `command`/`inline` block in
a `local-exec` provisioner, even for something short. A standalone file:

- can be linted/formatted with normal shell tooling (e.g. `shellcheck`),
  instead of living unchecked inside a Terraform string
- can be run and tested directly (`./scripts/foo.sh`) without going through
  `tofu apply`
- gets syntax highlighting and diffs like any other source file, rather than
  being buried in HCL string escaping

## Example

A common pattern: a script that needs some values from the module (IDs,
tokens, etc.), invoked via a `local-exec` provisioner. `terraform_data` is
one option for wiring this up (shown below) — a `null_resource` with
`triggers`/`provisioner` works too; use whichever fits the module.

`scripts/example.sh`:

```bash
#!/usr/bin/env bash

# Describe what this script does and why it's needed here (e.g. cleaning up
# something the provider's normal resource lifecycle doesn't handle on
# destroy).
#
# This script expects the following environment variables to be available:
# - RESOURCE_ID
# - API_TOKEN
#
# `set -euo pipefail` below means the script fails immediately if any
# expected variable is unset/empty, without needing a manual check for each
# one:
#   e - exit on any command failure
#   u - treat unset variables as an error
#   pipefail - a failure anywhere in a pipe fails the whole pipeline
#
# Example call (for testing directly, without going through tofu):
#
# RESOURCE_ID="abc-123" API_TOKEN="..." ./scripts/example.sh

set -euo pipefail

curl -sf -X DELETE \
  -H "Authorization: Bearer ${API_TOKEN}" \
  "https://api.example.com/resources/${RESOURCE_ID}"
```

Calling it from `.tf`, passing inputs as environment variables rather than
interpolating them into the command string:

```hcl
resource "terraform_data" "example" {
  input = {
    resource_id = "..."
    api_token   = "..."
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = "bash ./scripts/example.sh"
    environment = {
      RESOURCE_ID = self.input.resource_id
      API_TOKEN   = self.input.api_token
    }
  }
}
```

Delete this file once a real script has been added; delete this directory
entirely if this module never needs one.


