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
echo "[*] Building summary..."

join_lines() {
    local file="$1"

    if [ -s "$file" ]; then
        paste -sd ',' "$file"
    else
        printf "None"
    fi
}

indent_file() {
    local file="$1"

    if [ -s "$file" ]; then
        sed 's/^/  /' "$file"
    else
        printf "  None\n"
    fi
}

{
    printf "\n"
    printf "DNS / IP / WAF INTELLIGENCE SUMMARY\n"
    printf "===================================\n\n"

    printf "%-16s: %s\n" "Target" "$TARGET"
    printf "%-16s: %s\n" "Date" "$(date)"
    printf "%-16s: %s\n\n" "Output Dir" "$OUTDIR"

    printf "[HOST]\n"
    indent_file "$OUTDIR/host.txt"
    printf "\n"

    A_RECORDS=$(join_lines "$OUTDIR/a_record.txt")
    AAAA_RECORDS=$(join_lines "$OUTDIR/aaaa_record.txt")
    CNAME_RECORDS=$(join_lines "$OUTDIR/cname.txt")
    NS_RECORDS=$(join_lines "$OUTDIR/ns.txt")
    MX_RECORDS=$(join_lines "$OUTDIR/mx.txt")

    printf "[DNS RECORDS]\n"
    printf "  %-8s : %s\n" "[A]" "$A_RECORDS"
    printf "  %-8s : %s\n" "[AAAA]" "$AAAA_RECORDS"
    printf "  %-8s : %s\n" "[CNAME]" "$CNAME_RECORDS"
    printf "  %-8s : %s\n" "[NS]" "$NS_RECORDS"
    printf "  %-8s : %s\n" "[MX]" "$MX_RECORDS"
    printf "  %-8s :\n" "[TXT]"
    if [ -s "$OUTDIR/txt.txt" ]; then
	sed 's/^/             /' "$OUTDIR/txt.txt"
    else
	printf "             None\n"
    fi
    printf "\n"

    printf "[WAF]\n"
    grep -hiE \
        "behind|cloudflare|akamai|imperva|sucuri|fastly|aws|No WAF" \
        "$OUTDIR"/wafw00f_*.txt 2>/dev/null \
        | sed 's/^/  /' || printf "  None\n"
    printf "\n"

    printf "[REVERSE DNS]\n"

    if [ -s "$OUTDIR/ips.txt" ]; then
        while read -r IP; do
            PTR=$(dig +short -x "$IP" | paste -sd ',')

            if [ -z "$PTR" ]; then
                PTR="None"
            fi

            printf "  %-15s : %s\n" "$IP" "$PTR"
        done < "$OUTDIR/ips.txt"
    else
        printf "  None\n"
    fi

    printf "\n"

    printf "[ASN / NETWORK]\n"
    grep -hiE \
        "origin:|originas:|aut-num:|CIDR:|route:|inetnum:|netname:" \
        "$OUTDIR/ip_whois.txt" 2>/dev/null \
        | sed 's/^/  /' || printf "  None\n"
    printf "\n"

    printf "[INTERESTING TXT]\n"
    grep -hiEi \
        "spf|dmarc|dkim|google|amazonses|atlassian|docker|dropbox|facebook|zoom|github|slack" \
        "$OUTDIR/txt.txt" 2>/dev/null \
        | sed 's/^/  /' || printf "  None\n"

    printf "\n"

} > "$OUTDIR/summary.txt"

echo "[+] Done."
echo "[+] Results stored in: $OUTDIR/"
echo "[+] Main summary: $OUTDIR/summary.txt"
