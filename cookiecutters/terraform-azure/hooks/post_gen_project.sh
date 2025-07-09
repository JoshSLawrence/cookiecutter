#!/bin/bash

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

# Init
if [ {{ cookiecutter.use_opentofu }} = "yes" ]; then
    echo -e "\n${COLOR_YELLOW}Initializing opentofu project${COLOR_RESET}\n"
    tofu init
else
    echo -e "\n${COLOR_YELLOW}Initializing terraform project${COLOR_RESET}\n"
    terraform init
fi

# Doc generation
echo -e "\n${COLOR_YELLOW}Generating terraform docs${COLOR_RESET}\n"
terraform-docs .

# Git and Hook setup
if [ {{ cookiecutter.create_git_repo }} = "yes" ]; then
    echo -e "\n${COLOR_YELLOW}Initializing git repo${COLOR_RESET}\n"
    git init

    if [ {{ cookiecutter.use_git_hooks }} = "yes" ]; then
        echo -e "\n${COLOR_YELLOW}Setting up pre-commit hooks${COLOR_RESET}\n"
        pre-commit install
        git add .
        pre-commit run -a
    else
        rm ".pre-commit-config.yaml"
        git add .
    fi
else
    rm ".gitignore"
    rm ".pre-commit-config.yaml"
fi


echo -e "\n${COLOR_GREEN}Project Generation Complete${COLOR_RESET}\n"
