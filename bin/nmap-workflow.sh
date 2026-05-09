#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Nmap Workflow Script
# ------------------------------------------------------------
# Flow:
#   1. Fast TCP port discovery
#   2. Service/version/default script scan on open ports
#   3. Optional vuln NSE scan on open ports
#
# Usage:
#   ./nmap-workflow.sh <target> [options]
#
# Examples:
#   ./nmap-workflow.sh 10.10.10.10
#   ./nmap-workflow.sh example.com --vuln
#   ./nmap-workflow.sh 10.10.10.10 --udp
# ------------------------------------------------------------

TARGET="${1:-}"
RUN_VULN=false
RUN_UDP=false

if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <target> [--vuln] [--udp]"
    exit 1
fi

shift || true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vuln)
            RUN_VULN=true
            ;;
        --udp)
            RUN_UDP=true
            ;;
        *)
            echo "[!] Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

OUTDIR="nmap_output/$TARGET"
PORTDIR="$OUTDIR/ports"
SERVICEDIR="$OUTDIR/services"
VULNDIR="$OUTDIR/vulns"
UDPDIR="$OUTDIR/udp"

mkdir -p "$PORTDIR" "$SERVICEDIR" "$VULNDIR" "$UDPDIR"

echo "[*] Target: $TARGET"
echo "[*] Output: $OUTDIR"

# ------------------------------------------------------------
# 1. TCP Port Discovery
# ------------------------------------------------------------

echo "[*] Running full TCP port scan..."

nmap -Pn -T4 -p- --min-rate 5000 \
    -oN "$PORTDIR/tcp_all_ports.txt" \
    "$TARGET"

OPEN_PORTS=$(
    awk '/^[0-9]+\/tcp[[:space:]]+open/ {
        split($1,a,"/")
        print a[1]
    }' "$PORTDIR/tcp_all_ports.txt" | paste -sd, -
)

if [[ -z "$OPEN_PORTS" ]]; then
    echo "[!] No open TCP ports found."
else
    echo "[+] Open TCP ports: $OPEN_PORTS"

    echo "$OPEN_PORTS" > "$PORTDIR/open_tcp_ports.txt"

    # ------------------------------------------------------------
    # 2. Service Scan
    # ------------------------------------------------------------

    echo "[*] Running service/version/default script scan..."

    nmap -Pn -sV -sC -p "$OPEN_PORTS" \
        -oN "$SERVICEDIR/tcp_services.txt" \
        -oX "$SERVICEDIR/tcp_services.xml" \
        "$TARGET"

    # ------------------------------------------------------------
    # 3. Per-Port Service Scan Outputs
    # ------------------------------------------------------------

    echo "[*] Creating per-port service scan files..."

    while IFS= read -r port; do
        service=$(
            awk -v p="$port" '
                $1 ~ "^"p"/tcp" && $2 == "open" {
                    print $3
                }
            ' "$SERVICEDIR/tcp_services.txt" | head -n1
        )

        service="${service:-unknown}"
        service_safe=$(echo "$service" | tr -cd '[:alnum:]_.-')

        nmap -Pn -sV -sC -p "$port" \
            -oN "$SERVICEDIR/port.${port}.${service_safe}.txt" \
            "$TARGET"

    done < <(echo "$OPEN_PORTS" | tr ',' '\n')

    # ------------------------------------------------------------
    # 4. Optional Vuln Scan
    # ------------------------------------------------------------

    if [[ "$RUN_VULN" == true ]]; then
        echo "[*] Running vuln script scan..."

        nmap -Pn -vv --script vuln -p "$OPEN_PORTS" \
            -oN "$VULNDIR/tcp_vulns.txt" \
            -oX "$VULNDIR/tcp_vulns.xml" \
            "$TARGET"
    else
        echo "[*] Skipping vuln scan. Use --vuln to enable it."
    fi
fi

# ------------------------------------------------------------
# 5. Optional UDP Scan
# ------------------------------------------------------------

if [[ "$RUN_UDP" == true ]]; then
    echo "[*] Running top UDP ports scan..."

    nmap -Pn -sU --top-ports 100 -T3 \
        -oN "$UDPDIR/udp_top_100.txt" \
        "$TARGET"
else
    echo "[*] Skipping UDP scan. Use --udp to enable it."
fi

echo "[+] Done."
echo "[+] Results saved in: $OUTDIR"
