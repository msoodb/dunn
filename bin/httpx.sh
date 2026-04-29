#!/bin/bash

# ----------------------------------
#   httpx Enumeration (clean version)
# ----------------------------------

SUBDOMAINS=$1
OUTPUT_DIR="httpx"

if [ -z "$SUBDOMAINS" ]; then
    echo "Usage: $0 <subdomains_file>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "[*] Running httpx..."

# ----------------------------------
# Run httpx (raw output inside dir)
# ----------------------------------

httpx -l "$SUBDOMAINS" -sc -ip -title -nc -o "$OUTPUT_DIR/httpx-raw.txt"

# ----------------------------------
# Extract alive hosts
# ----------------------------------

awk '{print $1}' "$OUTPUT_DIR/httpx-raw.txt" | sort -u > "$OUTPUT_DIR/httpx.txt"

# ----------------------------------
# Helper: only save if data exists
# ----------------------------------

save_if_not_empty () {
    CODE=$1
    OUTFILE=$2

    grep "\[$CODE\]" "$OUTPUT_DIR/httpx-raw.txt" | awk '{print $1}' | sort -u > "$OUTFILE"

    if [ ! -s "$OUTFILE" ]; then
        rm -f "$OUTFILE"
    fi
}

# ----------------------------------
# Status-based grouping
# ----------------------------------

save_if_not_empty "200" "$OUTPUT_DIR/httpx-2xx.txt"
save_if_not_empty "3"   "$OUTPUT_DIR/httpx-3xx.txt"
save_if_not_empty "403" "$OUTPUT_DIR/httpx-403.txt"
save_if_not_empty "404" "$OUTPUT_DIR/httpx-404.txt"
save_if_not_empty "5"   "$OUTPUT_DIR/httpx-5xx.txt"

echo "[+] Done:"
echo "    - $OUTPUT_DIR/httpx-raw.txt"
echo "    - $OUTPUT_DIR/httpx.txt"
echo "    - $OUTPUT_DIR/* (status groups)"
