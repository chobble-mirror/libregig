#!/usr/bin/env bash

# Directory to store custom hooks
HOOK_DIR=".githooks"

# Git hooks directory
GIT_HOOK_DIR=".git/hooks"

# Create hooks directory if not exists
mkdir -p "$GIT_HOOK_DIR"

# Create symbolic links for each hook file
for hook in "$HOOK_DIR"/*; do
  hook_name=$(basename "$hook")
  ln -sfv "../../$HOOK_DIR/$hook_name" "$GIT_HOOK_DIR/$hook_name"
done
