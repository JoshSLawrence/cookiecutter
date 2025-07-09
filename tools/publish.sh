#!/bin/bash

# NOTE: Tool to zip a given cookiecutter and drop off
# in the directory 'publish' in the root of the repo

RESET_COLOR='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'

# Ensure execution context is in project directory
cd $(dirname $0)

ROOT_DIR=$(git rev-parse --show-toplevel)
PUBLISH_DIR="$ROOT_DIR/publish"
COOKIECUTTER_DIR="$ROOT_DIR/cookiecutters"

# Prompt for cookiecutter to zip for publish
TARGET_COOKIECUTTER=$(ls $COOKIECUTTER_DIR | fzf --prompt="Select a cookiecutter to publish ❯ ")
ZIP="$TARGET_COOKIECUTTER.zip"

# Zip cookiecutter and drop off in /publish dir in root of repo
cd $COOKIECUTTER_DIR
zip -r --quiet $ZIP $TARGET_COOKIECUTTER \
    --exclude "*.DS_Store" "*.terraform" \
    "*.terraform/*" "*.terraform.lock.hcl"

mkdir -p "$PUBLISH_DIR"
mv $ZIP "$PUBLISH_DIR/$ZIP"

echo -e "${GREEN}[PUBLISHED]${RESET_COLOR} Cookiecutter ${YELLOW}$TARGET_COOKIECUTTER${RESET_COLOR} to ${YELLOW}$PUBLISH_DIR/$ZIP${RESET_COLOR}"
