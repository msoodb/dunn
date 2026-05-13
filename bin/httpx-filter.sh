#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYWORDS_FILE="$SCRIPT_DIR/web_keywords.txt"
OUTDIR="filtered_httpx"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    echo "Usage: $0 <httpx-raw.txt>"
    exit 1
fi

mkdir -p "$OUTDIR"/{keywords,status,technologies}

echo "[*] Filtering: $INPUT"

# -----------------------------
# Keyword filters
# -----------------------------
if [[ -f "$KEYWORDS_FILE" ]]; then
    while IFS= read -r KEYWORD; do
        [[ -z "$KEYWORD" || "$KEYWORD" =~ ^# ]] && continue

        SAFE_NAME="$(echo "$KEYWORD" | tr -cs 'A-Za-z0-9._-' '_' | sed 's/^_//;s/_$//')"
        OUT="$OUTDIR/keywords/${SAFE_NAME}.txt"

        grep -iE "$KEYWORD" "$INPUT" | sort -u > "$OUT" || true
        [[ -s "$OUT" ]] || rm -f "$OUT"
    done < "$KEYWORDS_FILE"
fi

# -----------------------------
# Status code filters
# Works with normal httpx output containing [200], [403], etc.
# -----------------------------
for CODE in 200 201 204 301 302 307 308 400 401 403 404 500 502 503; do
    OUT="$OUTDIR/status/${CODE}.txt"
    grep -E "\[$CODE\]" "$INPUT" | sort -u > "$OUT" || true
    [[ -s "$OUT" ]] || rm -f "$OUT"
done

# -----------------------------
# Technology filters
# Requires httpx with -tech-detect
# -----------------------------
TECHS=(
    "wordpress"
    "drupal"
    "joomla"
    "nginx"
    "apache"
    "iis"
    "cloudflare"
    "akamai"
    "fastly"
    "aws"
    "azure"
    "google"
    "spring"
    "tomcat"
    "jenkins"
    "grafana"
    "kibana"
    "swagger"
    "graphql"
    "next.js"
    "react"
    "vue"
    "angular"
    "php"
    "laravel"
    "django"
    "express"
)

for TECH in "${TECHS[@]}"; do
    SAFE_NAME="$(echo "$TECH" | tr -cs 'A-Za-z0-9._-' '_' | sed 's/^_//;s/_$//')"
    OUT="$OUTDIR/technologies/${SAFE_NAME}.txt"

    grep -i "$TECH" "$INPUT" | sort -u > "$OUT" || true
    [[ -s "$OUT" ]] || rm -f "$OUT"
done

# -----------------------------
# High-value combined filter
# -----------------------------
grep -iE \
'api|admin|auth|login|portal|console|dashboard|dev|qa|test|uat|stage|staging|internal|crm|cms|sso|oauth|graphql|swagger|jenkins|grafana|kibana|jira|confluence|git|vpn|upload|download|file|backup|debug|monitor|metrics|health' \
"$INPUT" | sort -u > "$OUTDIR/interesting.txt" || true

[[ -s "$OUTDIR/interesting.txt" ]] || rm -f "$OUTDIR/interesting.txt"

# -----------------------------
# Summary
# -----------------------------
echo
echo "[+] Done."
echo "[+] Output directory: $OUTDIR"
echo

find "$OUTDIR" -type f | sort | while read -r FILE; do
    printf "%5s  %s\n" "$(wc -l < "$FILE")" "$FILE"
done
