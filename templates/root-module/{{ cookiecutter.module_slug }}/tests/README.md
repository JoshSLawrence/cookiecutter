# Tests

OpenTofu tests for validating configuration logic. Tests can use mock
providers to validate input constraints without creating real infrastructure.

## Test file conventions

- Use `.tftest.hcl` extension for test files
- Use `mock_provider` at the top of each test file for unit tests
- Organize tests by feature (e.g. `01_input_validation.tftest.hcl`)
- Use numeric prefixes to control execution order:
  - `01_`–`89_` — unit/validation tests (mock providers, fast)
  - `90_`–`99_` — integration tests (real providers, slower)

## Running tests

```bash
tofu test
```

## Example test

```hcl
mock_provider "azurerm" {}

variables {
  environment = "dev"
}

run "environment_valid" {
  command = plan

  variables {
    environment = "prod"
  }
}

run "environment_invalid" {
  command = plan

  variables {
    environment = "invalid"
  }

  expect_failures = [var.environment]
}
```

## What to test

- **Variable validation blocks** — test valid values pass and invalid values
  fail
- **Conditional resource creation** — verify feature flags work as expected
- **Default values** — verify defaults produce expected plans

Delete this file once real tests have been added; delete this directory
entirely if this configuration doesn't need tests.
