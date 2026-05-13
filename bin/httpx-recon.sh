#!/usr/bin/env bash
set -euo pipefail

# “Is an HTTP/HTTPS service running there, and if yes, what does it look like?”

INPUT="${1:-}"
OUTDIR="httpx"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    echo "Usage: $0 <subdomains_file>"
    exit 1
fi

mkdir -p "$OUTDIR"

echo "[*] Running httpx..."

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
    -o "$OUTDIR/httpx_raw.txt"

echo "[+] Done:"
echo "    $OUTDIR/httpx_raw.txt"

awk '{print $1}' "$OUTDIR/httpx_raw.txt" | sort -u > "$OUTDIR/httpx_urls.txt"
echo "    $OUTDIR/httpx_urls.txt"
