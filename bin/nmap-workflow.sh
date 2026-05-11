#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

RUN_VULN=false
RUN_UDP=false
RUN_XML=false

if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <target> [--vuln] [--udp] [--xml]"
    exit 1
fi

shift || true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --vuln) RUN_VULN=true ;;
        --udp)  RUN_UDP=true ;;
        --xml)  RUN_XML=true ;;
        *)
            echo "[!] Unknown option: $1"
            echo "Usage: $0 <target> [--vuln] [--udp] [--xml]"
            exit 1
            ;;
    esac
    shift
done

OUTDIR="nmap"
DISCOVERY_FILE="$OUTDIR/tcp_discovery.txt"
PORTS_FILE="$OUTDIR/open_ports.txt"
SERVICES_FILE="$OUTDIR/services.txt"
SUMMARY_FILE="$OUTDIR/summary.txt"

mkdir -p "$OUTDIR"

echo "[*] Target: $TARGET"
echo "[*] Output: $OUTDIR"

echo "[*] Finding open TCP ports..."

nmap -Pn -T4 -p- --min-rate 5000 "$TARGET" \
    -oN "$DISCOVERY_FILE"

OPEN_PORTS=$(
    awk '/^[0-9]+\/tcp[[:space:]]+open/ {
        split($1,a,"/")
        print a[1]
    }' "$DISCOVERY_FILE" | paste -sd, -
)

if [[ -z "$OPEN_PORTS" ]]; then
    echo "[!] No open TCP ports found."

    {
        echo "Target: $TARGET"
        echo "Date: $(date)"
        echo
        echo "No open TCP ports found."
    } > "$SUMMARY_FILE"

    exit 0
fi

echo "$OPEN_PORTS" > "$PORTS_FILE"
echo "[+] Open TCP ports: $OPEN_PORTS"

echo "[*] Running service detection..."

if [[ "$RUN_XML" == true ]]; then
    nmap -Pn -sV -sC -p "$OPEN_PORTS" "$TARGET" \
        -oN "$SERVICES_FILE" \
        -oX "$OUTDIR/services.xml"
else
    nmap -Pn -sV -sC -p "$OPEN_PORTS" "$TARGET" \
        -oN "$SERVICES_FILE"
fi

echo "[*] Creating summary..."

{
    echo "Target: $TARGET"
    echo "Date: $(date)"
    echo
    echo "Open TCP Ports:"
    echo "$OPEN_PORTS"
    echo
    echo "Services:"
    awk '/^[0-9]+\/tcp[[:space:]]+open/ {
        print "  " $0
    }' "$SERVICES_FILE"
} > "$SUMMARY_FILE"

if [[ "$RUN_VULN" == true ]]; then
    echo "[*] Running vuln NSE scan..."

    if [[ "$RUN_XML" == true ]]; then
        nmap -Pn -vv --script vuln -p "$OPEN_PORTS" "$TARGET" \
            -oN "$OUTDIR/vulns.txt" \
            -oX "$OUTDIR/vulns.xml"
    else
        nmap -Pn -vv --script vuln -p "$OPEN_PORTS" "$TARGET" \
            -oN "$OUTDIR/vulns.txt"
    fi
else
    echo "[*] Skipping vuln scan. Use --vuln to enable it."
fi

if [[ "$RUN_UDP" == true ]]; then
    echo "[*] Running top UDP scan..."

    nmap -Pn -sU --top-ports 100 -T3 "$TARGET" \
        -oN "$OUTDIR/udp.txt"
else
    echo "[*] Skipping UDP scan. Use --udp to enable it."
fi

echo "[+] Done."
echo "[+] Main file to read: $SUMMARY_FILE"
