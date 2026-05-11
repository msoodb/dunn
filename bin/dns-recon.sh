#!/usr/bin/env bash
set -euo pipefail


# “Where do these hosts point?”

INPUT="${1:-}"
OUTDIR="dns"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    echo "Usage: $0 <subdomains_file>"
    exit 1
fi

mkdir -p "$OUTDIR"

echo "[*] Collecting DNS records..."

dnsx -l "$INPUT" \
    -resp \
    -a \
    -aaaa \
    -cname \
    -ns \
    -mx \
    -txt \
    -silent > "$OUTDIR/dns_records.txt"

find "$OUTDIR" -type f -empty -delete

echo "[+] Done:"
echo "    $OUTDIR/dns_records.txt"
