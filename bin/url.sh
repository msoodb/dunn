#!/bin/bash

set -euo pipefail

# -------------------------
# Defaults
# -------------------------
THREADS=5
INPUT_FILE=""

OUTPUT_DIR="urls"
RAW_FILE="$OUTPUT_DIR/urls_raw.txt"
DEDUP_FILE="$OUTPUT_DIR/urls_dedup.txt"
FINAL_FILE="$OUTPUT_DIR/urls_final.txt"
PARAMS_FILE="$OUTPUT_DIR/urls_params.txt"

# -------------------------
# Usage
# -------------------------
usage() {
    echo "Usage: $0 -i input_file [-t threads]"
    exit 1
}

# -------------------------
# Parse arguments
# -------------------------
while getopts ":i:t:" opt; do
    case ${opt} in
        i ) INPUT_FILE=$OPTARG ;;
        t ) THREADS=$OPTARG ;;
        * ) usage ;;
    esac
done

[[ -z "$INPUT_FILE" ]] && usage
[[ ! -f "$INPUT_FILE" ]] && { echo "[!] Input file not found"; exit 1; }

# -------------------------
# Setup
# -------------------------
mkdir -p "$OUTPUT_DIR"
> "$RAW_FILE"

TMP_DIR=$(mktemp -d)

# -------------------------
# Validate tools
# -------------------------
for tool in katana gau waybackurls; do
    command -v "$tool" &>/dev/null || {
        echo "[!] Missing tool: $tool"
        exit 1
    }
done

# -------------------------
# Process target (SAFE)
# -------------------------
process_target() {
    local TARGET=$1
    local OUT_FILE="$TMP_DIR/$(echo "$TARGET" | tr '/:' '_').txt"

    echo "[*] $TARGET"

    {
        katana -u "$TARGET" -fs fqdn -silent 2>/dev/null || true
        echo "$TARGET" | waybackurls 2>/dev/null || true
        echo "$TARGET" | gau --silent 2>/dev/null || true
    } > "$OUT_FILE"
}

export -f process_target
export TMP_DIR

# -------------------------
# Run (parallel safe)
# -------------------------
echo "[*] Collecting URLs..."

xargs -a "$INPUT_FILE" -P "$THREADS" -I {} bash -c 'process_target "$@"' _ {}

# -------------------------
# Merge all temp files
# -------------------------
echo "[*] Merging results..."
cat "$TMP_DIR"/*.txt > "$RAW_FILE" || true

# sanity check
if [[ ! -s "$RAW_FILE" ]]; then
    echo "[!] No URLs collected. Check your tools/input."
    exit 1
fi

# -------------------------
# Deduplicate
# -------------------------
echo "[*] Deduplicating..."
sort -u "$RAW_FILE" > "$DEDUP_FILE"

# -------------------------
# Keep only valid URLs
# -------------------------
grep -E '^https?://' "$DEDUP_FILE" > "$DEDUP_FILE.tmp"
mv "$DEDUP_FILE.tmp" "$DEDUP_FILE"

# -------------------------
# Extract PARAM URLs (IMPORTANT)
# -------------------------
echo "[*] Extracting parameterized URLs..."
grep '=' "$DEDUP_FILE" | sort -u > "$PARAMS_FILE" || true

# -------------------------
# Light normalization (SAFE, KEEP PARAMS)
# -------------------------
echo "[*] Normalizing (light)..."

cat "$DEDUP_FILE" \
| sed 's/#.*//' \
| sed 's:/*$::' \
| sort -u \
> "$FINAL_FILE"

# -------------------------
# Cleanup
# -------------------------
rm -rf "$TMP_DIR"

# -------------------------
# Stats
# -------------------------
echo "----------------------------------"
echo "[+] Raw:        $(wc -l < "$RAW_FILE")"
echo "[+] Dedup:      $(wc -l < "$DEDUP_FILE")"
echo "[+] Params:     $(wc -l < "$PARAMS_FILE")"
echo "[+] Final:      $(wc -l < "$FINAL_FILE")"
echo "----------------------------------"

echo "[✓] URLs:   $FINAL_FILE"
echo "[✓] Params: $PARAMS_FILE"
