#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "${BASH_SOURCE[0]}")"

GODOT_TMP_DIR="$(mktemp -d)"
git clone --depth=1 https://github.com/godotengine/godot.git "$GODOT_TMP_DIR"

# Generate a Markdown table of the class reference coverage.
mkdir -p content/
rm -f content/_index.md

# Add Git commit information to the generated page.
COMMIT_HASH="$(git -C "$GODOT_TMP_DIR" rev-parse --short=9 HEAD)"
COMMIT_DATE="$(git -C "$GODOT_TMP_DIR" log -1 --pretty=%cd --date=format:%Y-%m-%d)"
echo -e "\nBuilding status page for Godot commit $COMMIT_HASH ($COMMIT_DATE):"
echo "https://github.com/godotengine/godot/commit/$COMMIT_HASH"

# This template must end with a blank line so the table that will be appended
# can be parsed correctly.
cat << EOF > content/_index.md
# Godot class reference status

Generated from Godot commit [\`$COMMIT_HASH\`](https://github.com/godotengine/godot/commit/$COMMIT_HASH)
($COMMIT_DATE).

Interested in contributing? See
[Contribute to the class reference](https://docs.godotengine.org/en/latest/community/contributing/updating_the_class_reference.html)
in the documentation. To avoid conflicts with pending contributions, check
[open documentation pull requests](https://github.com/godotengine/godot/pulls?q=is%3Apr+is%3Aopen+label%3Adocumentation)
before starting to work on a class.

EOF

# Trim the first line of the output to get a valid Markdown table.
# Ensure that module and platform documentation is also included in the report.
NO_COLOR=1 python3 "$GODOT_TMP_DIR/doc/tools/doc_status.py" -u "$GODOT_TMP_DIR/doc/classes" "$GODOT_TMP_DIR"/modules/*/doc_classes "$GODOT_TMP_DIR"/platform/*/doc_classes | tail -n +2 >> content/_index.md

# Fade out `0/0` completion ratios as they can't be completed (there's nothing to document).
sed -i 's:0/0:<span style="opacity\: 0.3">0/0</span>:g' content/_index.md

# Add classes for completion percentages to style them for easier visual grepping.
# Incomplete percentages (0-99%).
sed -Ei 's:\s([0-9][0-9]?)%:<span class="completion-incomplete" style="--percentage\: \1">\1%</span>:g' content/_index.md
# Complete percentages (100%).
sed -Ei 's:100%:<span class="completion-complete">100%</span>:g' content/_index.md

# Shorten class links' text to decrease the table's width.
sed -Ei 's:(https\:.+classes/(class_.+)\.html):[\2](\1):g' content/_index.md

# Build the website with optimizations enabled.
hugo --minify

rm -rf "$GODOT_TMP_DIR"
