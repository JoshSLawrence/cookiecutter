#!/usr/bin/env bash

#MISE description="Destory IaC"

cd "iac"

tofu init --reconfigure --upgrade

tofu destroy
