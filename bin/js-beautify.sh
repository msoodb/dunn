#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# beautify-js.sh
# ------------------------------------------------------------
# Beautify all JS files in current directory
#
# Output format:
#   beautify-<original>.js
#
# Usage:
#   ./beautify-js.sh
#   ./beautify-js.sh <directory>
# ------------------------------------------------------------

TARGET_DIR="${1:-.}"

if ! command -v js-beautify >/dev/null 2>&1; then
    echo "[-] js-beautify not found"
    exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "[-] Directory not found: $TARGET_DIR"
    exit 1
fi

echo "[*] Beautifying JS files in: $TARGET_DIR"

find "$TARGET_DIR" -type f -name "*.js" | while read -r FILE; do
    DIR="$(dirname "$FILE")"
    BASE="$(basename "$FILE")"

    OUTPUT="$DIR/beautify-$BASE"

    echo "[*] $BASE"

    js-beautify "$FILE" > "$OUTPUT" || true
done

echo "[+] Done."
