#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-}"
OUTDIR="${2:-prioritized}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSV_FILE="$SCRIPT_DIR/prioritization_keywords.csv"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
    echo "Usage: $0 <urls_file> [output_dir]"
    exit 1
fi

if [[ ! -f "$CSV_FILE" ]]; then
    echo "[-] Missing CSV file: $CSV_FILE"
    exit 1
fi

mkdir -p "$OUTDIR"

P1="$OUTDIR/p1.txt"
P2="$OUTDIR/p2.txt"
P3="$OUTDIR/p3.txt"
ALL="$OUTDIR/all_prioritized.txt"
CLEAN_INPUT="$OUTDIR/input_clean.txt"
REPORT="$OUTDIR/summary.txt"

: > "$P1"
: > "$P2"
: > "$P3"

echo "[*] Input : $INPUT"
echo "[*] CSV   : $CSV_FILE"
echo "[*] Output: $OUTDIR"

# ------------------------------------------------------------
# Clean noisy static assets before prioritization
# ------------------------------------------------------------

grep -Eiv '\.(jpg|jpeg|png|gif|svg|webp|ico|css|woff|woff2|ttf|eot|mp4|mp3|avi|mov|pdf)(\?|$)' "$INPUT" \
    | grep -Eiv '/fileadmin/|/assets/|/static/|/images/|/image/|/img/|/css/|/fonts/|/font/|/media/|/cdn/' \
    | sort -u > "$CLEAN_INPUT" || true

# ------------------------------------------------------------
# Match CSV keywords by priority
# CSV format: keyword,priority
# ------------------------------------------------------------

while IFS=',' read -r KEYWORD PRIORITY; do
    KEYWORD="$(echo "$KEYWORD" | xargs)"
    PRIORITY="$(echo "$PRIORITY" | xargs)"

    [[ -z "$KEYWORD" ]] && continue
    [[ "$KEYWORD" =~ ^# ]] && continue
    [[ "$KEYWORD" == "keyword" ]] && continue

    # Escape regex chars in keyword, then match as URL segment/parameter-ish token
    SAFE_KEYWORD="$(printf '%s\n' "$KEYWORD" | sed -E 's/[][(){}.^$*+?|\\]/\\&/g')"
    REGEX="(^|[/:?&=._-])${SAFE_KEYWORD}([/:?&=._-]|$)"

    case "$PRIORITY" in
        1)
            grep -iE "$REGEX" "$CLEAN_INPUT" >> "$P1" || true
            ;;
        2)
            grep -iE "$REGEX" "$CLEAN_INPUT" >> "$P2" || true
            ;;
        3)
            grep -iE "$REGEX" "$CLEAN_INPUT" >> "$P3" || true
            ;;
        *)
            echo "[!] Skipping invalid priority: $KEYWORD,$PRIORITY"
            ;;
    esac
done < "$CSV_FILE"

sort -u "$P1" -o "$P1"
sort -u "$P2" -o "$P2"
sort -u "$P3" -o "$P3"

# Remove P1 from P2/P3 and P2 from P3
grep -Fvx -f "$P1" "$P2" > "$P2.tmp" || true
mv "$P2.tmp" "$P2"

cat "$P1" "$P2" | sort -u > "$OUTDIR/p1_p2.tmp"
grep -Fvx -f "$OUTDIR/p1_p2.tmp" "$P3" > "$P3.tmp" || true
mv "$P3.tmp" "$P3"
rm -f "$OUTDIR/p1_p2.tmp"

cat "$P1" "$P2" "$P3" | sort -u > "$ALL"

{
    echo "PRIORITIZATION SUMMARY"
    echo "======================"
    echo
    echo "Input       : $INPUT"
    echo "Clean input : $CLEAN_INPUT"
    echo "CSV         : $CSV_FILE"
    echo "Date        : $(date)"
    echo
    printf "%-12s %s\n" "Original:" "$(wc -l < "$INPUT")"
    printf "%-12s %s\n" "Clean:" "$(wc -l < "$CLEAN_INPUT")"
    printf "%-12s %s\n" "P1:" "$(wc -l < "$P1")"
    printf "%-12s %s\n" "P2:" "$(wc -l < "$P2")"
    printf "%-12s %s\n" "P3:" "$(wc -l < "$P3")"
    printf "%-12s %s\n" "All:" "$(wc -l < "$ALL")"
} > "$REPORT"

echo "[+] Done:"
echo "    $P1"
echo "    $P2"
echo "    $P3"
echo "    $ALL"
echo "    $REPORT"
