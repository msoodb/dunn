#!/usr/bin/env bash
set -euo pipefail

# “Is an HTTP/HTTPS service running there, and if yes, what does it look like?”

INPUT="${1:-}"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    echo "Usage: $0 <subdomains_file>"
    exit 1
fi

# ----------------------------------
# Paths
# ----------------------------------

INPUT_NAME=$(basename "$INPUT")
INPUT_BASE="${INPUT_NAME%.*}"

BASE_OUTDIR="httpx"
OUTDIR="$BASE_OUTDIR/$INPUT_BASE"

mkdir -p "$OUTDIR"

# ----------------------------------
# Files
# ----------------------------------

RAW_OUTPUT="$OUTDIR/httpx_raw.txt"
URLS_OUTPUT="$OUTDIR/httpx_urls.txt"

# ----------------------------------
# Run httpx
# ----------------------------------

echo "[*] Running httpx on: $INPUT"

httpx -l "$INPUT" \
    -sc \
    -ip \
    -title \
    -server \
    -tech-detect \
    -cname \
    -location \
    -follow-host-redirects \
    -silent \
    -o "$RAW_OUTPUT"

echo "[+] Done:"
echo "    $RAW_OUTPUT"

awk '{print $1}' "$RAW_OUTPUT" | sort -u > "$URLS_OUTPUT"

echo "    $URLS_OUTPUT"
