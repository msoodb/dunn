#!/bin/bash

# ----------------------------------
#   DNS + IP Intelligence Recon
# ----------------------------------

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

OUTDIR="dns_intel_$(date +%F)"
mkdir -p "$OUTDIR"

echo "[*] Running DNS + WHOIS recon for $TARGET"

# ----------------------------------
# DNS ENUMERATION
# ----------------------------------

dig "$TARGET" > "$OUTDIR/dig_full.txt"
dig +short "$TARGET" > "$OUTDIR/a_record.txt"
dig +short NS "$TARGET" > "$OUTDIR/ns.txt"
dig +short MX "$TARGET" > "$OUTDIR/mx.txt"
dig +short TXT "$TARGET" > "$OUTDIR/txt.txt"
dig +trace "$TARGET" > "$OUTDIR/trace.txt"
host "$TARGET" > "$OUTDIR/host.txt"

# ----------------------------------
# WHOIS INTEL
# ----------------------------------

echo "[*] Running WHOIS..."

whois "$TARGET" > "$OUTDIR/whois.txt"

# ----------------------------------
# DONE
# ----------------------------------

echo "[+] Done. Results stored in $OUTDIR/"
