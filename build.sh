#!/usr/bin/env bash

set -euo pipefail
IFS='$\n\t'

TMP="$(mktemp -d)"
git clone --depth=1 https://github.com/godotengine/godot.git "$TMP"

# Generate a Markdown table of the class reference coverage.
mkdir -p content/
rm -f content/_index.md

# Add Git commit information to the generated page.
# Must end with a blank line so the table that will be appended can be parsed correctly.
COMMIT_HASH="$(git -C "$TMP" rev-parse --short=9 HEAD)"
cat << EOF > content/_index.md
# Godot class reference status

Generated from Godot commit [$COMMIT_HASH](https://github.com/godotengine/godot/commit/$COMMIT_HASH).

EOF

# Trim the first line of the output to get a valid Markdown table.
# Ensure that module documentation is also included in the report.
python3 "$TMP/doc/tools/doc_status.py" -u "$TMP/doc/classes" "$TMP"/modules/*/doc_classes | tail -n +2 >> content/_index.md

# Fade out `0/0` completion ratios as they can't be completed (there's nothing
# to document).
sed -i 's:0/0:<span style="opacity\: 0.5">0/0</span>:g' content/_index.md

# Build the website with optimizations enabled.
hugo --minify

rm -rf "$TMP"
