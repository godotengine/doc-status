#!/usr/bin/env bash

set -euo pipefail
IFS='$\n\t'

TMP="$(mktemp -d)"
git clone --depth=1 https://github.com/godotengine/godot.git "$TMP"

# Generate a Markdown table of the class reference coverage.
mkdir -p content/
rm -f content/index.md

# Add Git commit information to the generated page.
COMMIT_HASH="$(git -C "$TMP" rev-parse --short=9 HEAD)"
echo -e "Generated from commit [$COMMIT_HASH](https://github.com/godotengine/godot/commit/$COMMIT_HASH).\n" > content/_index.md

# Trim the first line of the output to get a valid Markdown table.
python3 "$TMP/doc/tools/doc_status.py" -u "$TMP/doc/classes" | tail -n +2 >> content/_index.md

# Build the website.
hugo

rm -rf "$TMP"
