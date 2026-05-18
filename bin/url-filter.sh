#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
#  URL Keyword Filter
# --------------------------------------------------
# Filters a URL list by interesting security/recon keywords.
#
# Usage:
#   ./filter_urls.sh urls.txt
#
# Files:
#   url_patterns.txt              keywords list
#   filtered_urls/
#     ├── all_interesting_urls.txt
#     ├── summary.txt
#     └── <keyword>.txt
# --------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/web_keywords.txt"

URL_FILE="${1:-}"
OUTPUT_DIR="filtered_urls"

if [[ -z "$URL_FILE" ]]; then
  echo "Usage: $0 <url_file>"
  exit 1
fi

if [[ ! -f "$URL_FILE" ]]; then
  echo "Error: URL file not found: $URL_FILE"
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

ALL_OUTPUT="$OUTPUT_DIR/all_interesting_urls.txt"
SUMMARY_FILE="$OUTPUT_DIR/summary.txt"

> "$ALL_OUTPUT"
> "$SUMMARY_FILE"

echo "[*] Filtering URLs from: $URL_FILE"
echo "[*] Using keywords from: $CONFIG_FILE"
echo

# Clean input once
TMP_URLS="$(mktemp)"
sort -u "$URL_FILE" > "$TMP_URLS"

while IFS= read -r KEYWORD || [[ -n "$KEYWORD" ]]; do
  # Skip empty lines and comments
  [[ -z "$KEYWORD" ]] && continue
  [[ "$KEYWORD" =~ ^# ]] && continue

  # Safe output filename
  SAFE_NAME="$(echo "$KEYWORD" | tr -cd '[:alnum:]_.-')"
  OUTPUT_FILE="$OUTPUT_DIR/${SAFE_NAME}.txt"

  grep -iF "$KEYWORD" "$TMP_URLS" | sort -u > "$OUTPUT_FILE" || true

  if [[ ! -s "$OUTPUT_FILE" ]]; then
    rm -f "$OUTPUT_FILE"
    continue
  fi

  COUNT="$(wc -l < "$OUTPUT_FILE")"

  cat "$OUTPUT_FILE" >> "$ALL_OUTPUT"

  printf "%-25s %s\n" "$KEYWORD" "$COUNT" | tee -a "$SUMMARY_FILE"

done < "$CONFIG_FILE"

sort -u "$ALL_OUTPUT" -o "$ALL_OUTPUT"

TOTAL="$(wc -l < "$ALL_OUTPUT")"

{
  echo
  echo "Total unique interesting URLs: $TOTAL"
  echo "Output directory: $OUTPUT_DIR"
  echo "Combined file: $ALL_OUTPUT"
} | tee -a "$SUMMARY_FILE"

rm -f "$TMP_URLS"

echo
echo "[+] Done."
