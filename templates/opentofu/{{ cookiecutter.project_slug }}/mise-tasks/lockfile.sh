#!/usr/bin/env bash

#MISE description="Generate lockfile for all platforms"

cd "iac"

tofu init -reconfigure -upgrade

tofu providers lock \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=darwin_arm64 \
  -platform=windows_amd64
