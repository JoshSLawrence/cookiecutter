# Cookiecutter

A collection of my homemade cookiecutters.

## Usage

- Install and call [the cookiecutter cli](https://github.com/cookiecutter/cookiecutter).
- Reference this repository: [https://github.com/joshslawrence](https://github.com/cookiecutter/cookiecutter)
- Pass the `--directory` argument pointing to the cookiecutter template you wish to use.
- All available cookiecutter templates in this repository are located in [templates](./templates).

> See section below for copy-paste examples to generate projects using my templates.

## Available Cookiecutters

A list of cookiecutters provided by this project and how to use them.

### Terraform

This cookiecutter serves a starting point for terraform modules.

- [OpenTofu cookiecutter README.md](./templates/opentofu/README.md)

```bash
cookiecutter "https://github.com/joshslawrence/cookiecutter" \
    --directory="templates/opentofu"
```
