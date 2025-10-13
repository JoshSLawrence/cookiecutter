# Cookiecutter

A collection of my homemade cookiecutters.

## Usage

- Use [the cookiecutter cli](https://github.com/cookiecutter/cookiecutter).
- Reference this repository: [https://github.com/joshslawrence](https://github.com/cookiecutter/cookiecutter)
- Pass the `--directory` argument pointing to the cookiecutter you wish to use.
- All available cookiecutters in this repository are located in `cookiecutters`.

## Available Cookiecutters

A list of cookiecutters provided by this project and how to use them.

### Terraform

This cookiecutter serves a starting point for terraform modules.

- [Terraform cookiecutter README.md](./cookiecutters/terraform/README.md)

```bash
cookiecutter "https://github.com/joshslawrence/cookiecutter" \
    --directory="templates/terraform"
```
