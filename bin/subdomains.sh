#!/bin/bash

set -euo pipefail

# --------------------------------------------------
#  Subdomain Enumeration & Validation Script
# --------------------------------------------------
# Description:
# This script performs automated subdomain enumeration
# for a list of target domains (scope file). It aggregates
# subdomains from multiple sources and validates them
# using DNS resolution.
#
# Data sources include:
#   - crtsh
#   - subfinder
#   - assetfinder
#   - github-subdomains
#
# The script:
#   1. Reads domains from a scope file
#   2. Enumerates subdomains using multiple tools
#   3. Merges and deduplicates all results
#   4. Resolves subdomains using dnsx
#   5. Extracts live/active subdomains
#   6. Stores all outputs in a structured directory
#
# Output structure:
#   subdomains_output/
#     ├── subdomains.txt            (raw + deduplicated)
#     ├── subdomains_resolved.txt   (dnsx resolution output)
#     └── subdomains_alive.txt      (active/valid hosts)
#
# Usage:
#   ./script.sh -s scope.txt
#
# Requirements:
#   - crtsh
#   - subfinder
#   - assetfinder
#   - github-subdomains
#   - dnsx
#   - GITHUB_TOKEN (for github-subdomains)
# --------------------------------------------------

OUTPUT_DIR="subdomains"
OUTPUT_FILE="$OUTPUT_DIR/subdomains.txt"
RESOLVED_FILE="$OUTPUT_DIR/subdomains_resolved.txt"
ALIVE_FILE="$OUTPUT_DIR/subdomains_alive.txt"

mkdir -p "$OUTPUT_DIR"
> "$OUTPUT_FILE"

process_scope() {
    local DOMAIN=$1

    echo "[+] Processing: $DOMAIN"

    TEMP_FILE=$(mktemp)

    # crtsh
    echo "[*] crtsh"
    crtsh -d "$DOMAIN" -r 2>/dev/null >> "$TEMP_FILE" || true

    # subfinder
    echo "[*] subfinder"
    subfinder -d "$DOMAIN" 2>/dev/null >> "$TEMP_FILE" || true

    # assetfinder
    echo "[*] assetfinder"
    echo "$DOMAIN" | assetfinder -subs-only 2>/dev/null >> "$TEMP_FILE" || true

    # github-subdomains
    echo "[*] github-subdomains"
    github-subdomains -d "$DOMAIN" -t "$GITHUB_TOKEN" -o github_tmp 2>/dev/null || true
    [[ -f github_tmp ]] && cat github_tmp >> "$TEMP_FILE" && rm -f github_tmp

    # merge + dedup into global output
    sort -u "$TEMP_FILE" >> "$OUTPUT_FILE"

    rm -f "$TEMP_FILE"

    echo "[+] Done: $DOMAIN"
}

# -------------------------
# Argument parsing (simple)
# -------------------------
if [[ $# -lt 2 || "$1" != "-s" ]]; then
    echo "Usage: $0 -s scope.txt"
    exit 1
fi

SCOPE_FILE=$2

[[ ! -f "$SCOPE_FILE" ]] && {
    echo "[!] Scope file not found"
    exit 1
}

# -------------------------
# Main enumeration
# -------------------------
while IFS= read -r DOMAIN || [[ -n "$DOMAIN" ]]; do
    [[ -z "$DOMAIN" ]] && continue
    process_scope "$DOMAIN"
done < "$SCOPE_FILE"

# -------------------------
# Final cleanup
# -------------------------
echo "[*] Deduplicating..."
sort -u "$OUTPUT_FILE" -o "$OUTPUT_FILE"

# -------------------------
# DNS resolution (NEW)
# -------------------------
echo "[*] Resolving subdomains with dnsx..."

dnsx -l "$OUTPUT_FILE" -silent -resp -nc > "$RESOLVED_FILE"

# -------------------------
# Extract alive hosts (NEW)
# -------------------------
echo "[*] Extracting alive subdomains..."

awk '{print $1}' "$RESOLVED_FILE" | sort -u > "$ALIVE_FILE"

# -------------------------
# Summary
# -------------------------
echo "----------------------------------"
echo "[+] Raw subdomains:     $OUTPUT_FILE"
echo "[+] Resolved subdomains:$RESOLVED_FILE"
echo "[+] Alive subdomains:   $ALIVE_FILE"
echo "----------------------------------"

echo "[✓] Done!"
