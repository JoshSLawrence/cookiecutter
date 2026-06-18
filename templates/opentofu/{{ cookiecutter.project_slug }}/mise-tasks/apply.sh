#!/usr/bin/env bash

#MISE description="Apply IaC"

cd "iac"

tofu init --reconfigure --upgrade

tofu apply --input=false
