#!/bin/bash

set -euo pipefail

# ----------------------------------
#   DNS + IP + WAF Intelligence Recon
# ----------------------------------
# Usage:
#   ./dns_intel.sh example.com
#
# Output:
#   dns_intel_YYYY-MM-DD_HHMM/
# ----------------------------------

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Remove protocol/path if user gives full URL
TARGET=$(echo "$TARGET" | sed -E 's#^https?://##; s#/.*##')

OUTDIR="dns_intel_$(date +%F_%H%M)"
mkdir -p "$OUTDIR"

echo "[*] Running DNS + WHOIS + WAF recon for: $TARGET"
echo "[*] Output directory: $OUTDIR"

# ----------------------------------
# Dependency check
# ----------------------------------

REQUIRED_TOOLS=("dig" "host" "whois" "wafw00f")

for TOOL in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$TOOL" >/dev/null 2>&1; then
        echo "[-] Missing tool: $TOOL"
        echo "    Install it first."
        exit 1
    fi
done

# ----------------------------------
# DNS ENUMERATION
# ----------------------------------

echo "[*] Running DNS checks..."

dig "$TARGET" > "$OUTDIR/dig_full.txt"
dig +short A "$TARGET" > "$OUTDIR/a_record.txt"
dig +short AAAA "$TARGET" > "$OUTDIR/aaaa_record.txt"
dig +short CNAME "$TARGET" > "$OUTDIR/cname.txt"
dig +short NS "$TARGET" > "$OUTDIR/ns.txt"
dig +short MX "$TARGET" > "$OUTDIR/mx.txt"
dig +short TXT "$TARGET" > "$OUTDIR/txt.txt"
dig +short SOA "$TARGET" > "$OUTDIR/soa.txt"
dig +trace "$TARGET" > "$OUTDIR/trace.txt"
host "$TARGET" > "$OUTDIR/host.txt"

# ----------------------------------
# REVERSE DNS FOR IPs
# ----------------------------------

echo "[*] Running reverse DNS on discovered IPs..."

cat "$OUTDIR/a_record.txt" "$OUTDIR/aaaa_record.txt" 2>/dev/null \
    | sort -u \
    > "$OUTDIR/ips.txt"

if [ -s "$OUTDIR/ips.txt" ]; then
    while read -r IP; do
        echo "### $IP ###"
        dig +short -x "$IP"
        echo
    done < "$OUTDIR/ips.txt" > "$OUTDIR/reverse_dns.txt"
else
    echo "No IPs found." > "$OUTDIR/reverse_dns.txt"
fi

# ----------------------------------
# WHOIS INTEL
# ----------------------------------

echo "[*] Running WHOIS..."

whois "$TARGET" > "$OUTDIR/whois.txt" || true

if [ -s "$OUTDIR/ips.txt" ]; then
    while read -r IP; do
        echo "### WHOIS for $IP ###"
        whois "$IP"
        echo
        echo "----------------------------------"
        echo
    done < "$OUTDIR/ips.txt" > "$OUTDIR/ip_whois.txt" || true
fi

# ----------------------------------
# WAF DETECTION
# ----------------------------------

echo "[*] Running WAF detection..."

wafw00f "https://$TARGET" > "$OUTDIR/wafw00f_https.txt" 2>&1 || true
wafw00f "http://$TARGET" > "$OUTDIR/wafw00f_http.txt" 2>&1 || true

# ----------------------------------
# SUMMARY
# ----------------------------------

{
    echo "Target: $TARGET"
    echo "Date: $(date)"
    echo
    echo "A records:"
    cat "$OUTDIR/a_record.txt"
    echo
    echo "AAAA records:"
    cat "$OUTDIR/aaaa_record.txt"
    echo
    echo "NS records:"
    cat "$OUTDIR/ns.txt"
    echo
    echo "MX records:"
    cat "$OUTDIR/mx.txt"
    echo
    echo "TXT records:"
    cat "$OUTDIR/txt.txt"
    echo
    echo "WAF HTTPS result:"
    grep -iE "is behind|seems to be behind|No WAF|firewall" "$OUTDIR/wafw00f_https.txt" || cat "$OUTDIR/wafw00f_https.txt"
} > "$OUTDIR/summary.txt"

echo "[+] Done."
echo "[+] Results stored in: $OUTDIR/"
echo "[+] Main summary: $OUTDIR/summary.txt"
