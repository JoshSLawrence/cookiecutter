# Scripts

Scripts supporting this configuration — e.g. ones invoked via `local-exec`
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

A common pattern: a script that needs some values from the configuration
(IDs, tokens, etc.), invoked via a `local-exec` provisioner.

`scripts/example.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# This script expects the following environment variables:
# - RESOURCE_ID
# - API_TOKEN

curl -sf -X DELETE \
  -H "Authorization: Bearer ${API_TOKEN}" \
  "https://api.example.com/resources/${RESOURCE_ID}"
```

Calling it from `.tf`:

```hcl
resource "terraform_data" "cleanup" {
  input = {
    resource_id = azurerm_resource.example.id
    api_token   = var.api_token
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
entirely if this configuration never needs one.
