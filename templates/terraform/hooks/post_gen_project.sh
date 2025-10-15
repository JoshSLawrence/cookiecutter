#!/bin/bash

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

echo -e "\n${COLOR_YELLOW}Installing Required Tools via Mise${COLOR_RESET}\n"
mise install || exit 1
mise upgrade || exit 1

# Init
if [ "{{ cookiecutter.use_opentofu }}" == "True" ]; then
    echo -e "\n${COLOR_YELLOW}Initializing OpenTofu Project${COLOR_RESET}\n"
    tofu init
    tofu fmt -list=false
else
    echo -e "\n${COLOR_YELLOW}Initializing Terraform Project${COLOR_RESET}\n"
    terraform init
    terraform fmt -list=false
fi

# Doc generation
echo -e "\n${COLOR_YELLOW}Generating Documentation${COLOR_RESET}\n"
terraform-docs .

# Git and Hook setup
echo -e "\n${COLOR_YELLOW}Initializing Git Repo${COLOR_RESET}\n"
git init
echo -e "\n${COLOR_YELLOW}Installing Git Hooks${COLOR_RESET}\n"
pre-commit install

# Hooks should run when the commit is attempted
echo -e "\n${COLOR_YELLOW}Creating Inital Commit${COLOR_RESET}\n"
git add .
git commit -m "feat: projected generated from cookiecutter template"

echo -e "\n${COLOR_GREEN}Project Generation Complete${COLOR_RESET}\n"

echo -e "\nNote: Depending on options selected, you will need to satisfy input 
variables in order to run a successful plan or test based on this template. Review 
the state of variables.tf and tests/test.tftest.hcl to see if applicable.\n"
