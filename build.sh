#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

TMP="$(mktemp -d)"
git clone --depth=1 https://github.com/godotengine/godot.git "$TMP"

# Generate a Markdown table of the class reference coverage.
mkdir -p content/
rm -f content/_index.md

# Add Git commit information to the generated page.
COMMIT_HASH="$(git -C "$TMP" rev-parse --short=9 HEAD)"
COMMIT_DATE="$(git -C "$TMP" log -1 --pretty=%cd --date=format:%Y-%m-%d)"
echo -e "\nBuilding status page for Godot commit $COMMIT_HASH ($COMMIT_DATE):"
echo "https://github.com/godotengine/godot/commit/$COMMIT_HASH"

# This template must end with a blank line so the table that will be appended
# can be parsed correctly.
cat << EOF > content/_index.md
# Godot class reference status

Generated from Godot commit [$COMMIT_HASH](https://github.com/godotengine/godot/commit/$COMMIT_HASH)
($COMMIT_DATE).

Interested in contributing? See
[Contribute to the class reference](https://docs.godotengine.org/en/latest/community/contributing/updating_the_class_reference.html)
in the documentation.

EOF

# Trim the first line of the output to get a valid Markdown table.
# Ensure that module documentation is also included in the report.
python3 "$TMP/doc/tools/doc_status.py" -u "$TMP/doc/classes" "$TMP"/modules/*/doc_classes | tail -n +2 >> content/_index.md

# Fade out `0/0` completion ratios as they can't be completed (there's nothing to document).
sed -i 's:0/0:<span style="opacity\: 0.5">0/0</span>:g' content/_index.md

# Add classes for completion percentages to style them for easier visual grepping.
# Incomplete percentages (0-99%).
sed -Ei 's:\s([0-9][0-9]?)%:<span class="completion-incomplete" style="--percentage\: \1">\1%</span>:g' content/_index.md
# Complete percentages (100%).
sed -Ei 's:100%:<span class="completion-complete">100%</span>:g' content/_index.md

# Shorten class links' text to decrease the table's width.
sed -Ei 's:(https\:.+(class_.+)\.html):[\2](\1):g' content/_index.md

# Build the website with optimizations enabled.
hugo --minify

rm -rf "$TMP"
