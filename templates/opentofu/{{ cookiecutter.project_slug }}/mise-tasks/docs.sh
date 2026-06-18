#!/usr/bin/env bash

#MISE description="Generate IaC documentation using terraform-docs"

cd "iac"

terraform-docs .
