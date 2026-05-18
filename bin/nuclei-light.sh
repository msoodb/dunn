#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# nuclei-light.sh
# ------------------------------------------------------------
# Lightweight nuclei reconnaissance scan.
#
# Usage:
#   ./nuclei-light.sh <urls_or_hosts_file>
#
# Example:
#   ./nuclei-light.sh inventory/httpx/httpx_urls.txt
# ------------------------------------------------------------

INPUT="${1:-}"
OUTDIR="nuclei"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    echo "Usage: $0 <urls_or_hosts_file>"
    exit 1
fi

if ! command -v nuclei >/dev/null 2>&1; then
    echo "[-] nuclei not found"
    exit 1
fi

mkdir -p "$OUTDIR"

BASE="$(basename "$INPUT")"
BASE="${BASE%.*}"

RAW_OUT="$OUTDIR/${BASE}_nuclei_light_raw.txt"
INTERESTING_OUT="$OUTDIR/${BASE}_nuclei_interesting.txt"
SUMMARY_OUT="$OUTDIR/${BASE}_nuclei_summary.txt"

echo "[*] Running lightweight nuclei..."
echo "[*] Input : $INPUT"
echo "[*] Output: $RAW_OUT"

nuclei \
    -l "$INPUT" \
    -tags exposure,tech,panel,misconfig,default-login \
    -severity info,low,medium \
    -rate-limit 50 \
    -concurrency 25 \
    -timeout 5 \
    -retries 1 \
    -silent \
    -nc \
    -o "$RAW_OUT" || true

grep -Ei \
'grafana|jenkins|swagger|graphql|kibana|git|env|backup|admin|debug|panel|login|exposure|misconfig|default' \
"$RAW_OUT" > "$INTERESTING_OUT" || true

if [[ ! -s "$INTERESTING_OUT" ]]; then
    rm -f "$INTERESTING_OUT"
fi

{
    echo "NUCLEI LIGHT SUMMARY"
    echo "===================="
    echo
    echo "Input : $INPUT"
    echo "Raw   : $RAW_OUT"
    echo "Date  : $(date)"
    echo
    echo "[Counts]"
    echo "Total findings: $(wc -l < "$RAW_OUT" 2>/dev/null || echo 0)"
    echo
    echo "[Severity]"
    for SEV in info low medium high critical; do
        COUNT="$(grep -ic "\[$SEV\]" "$RAW_OUT" 2>/dev/null || true)"
        printf "%-10s %s\n" "$SEV:" "$COUNT"
    done
} > "$SUMMARY_OUT"

echo "[+] Done:"
echo "    $RAW_OUT"
echo "    $SUMMARY_OUT"

if [[ -f "$INTERESTING_OUT" ]]; then
    echo "    $INTERESTING_OUT"
fi
