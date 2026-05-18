#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"

if [[ -z "$URL" ]]; then
    echo "Usage: $0 <url> [-o output_dir] [-H 'Header: value']"
    exit 1
fi

shift || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/et_templates"

SAFE_NAME=$(echo "$URL" | sed 's|https\?://||; s|[^a-zA-Z0-9]|_|g')
OUTDIR="endpoint-test-$(date +%F_%H%M%S)"
CUSTOM_HEADERS=(
  -H "User-Agent: Mozilla/5.0"
)

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTDIR="$2"
            shift 2
            ;;
        -H|--header)
            CUSTOM_HEADERS+=("-H" "$2")
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [[ ! -d "$TEST_DIR" ]]; then
    echo "[-] Test directory not found: $TEST_DIR"
    exit 1
fi

mkdir -p "$OUTDIR"

SUMMARY="$OUTDIR/summary.txt"
: > "$SUMMARY"

HEADER_REGEX="^(HTTP/|allow:|content-type:|content-length:|server:|x-powered-by:|location:|set-cookie:|strict-transport-security:|content-security-policy:|x-frame-options:|x-content-type-options:|referrer-policy:|access-control-allow-origin:|access-control-allow-credentials:|access-control-allow-methods:)"

run_test() {
    local NAME="$1"
    shift

    local FILE="$OUTDIR/${NAME}.txt"
    local TMP_RAW
    TMP_RAW="$(mktemp)"

    curl -sk -i \
        --max-time 20 \
        "${CUSTOM_HEADERS[@]}" \
        "$@" \
        "$URL" \
        -o "$TMP_RAW" || true

    if [[ -s "$TMP_RAW" ]]; then
        tail -c 1 "$TMP_RAW" | read -r _ || echo >> "$TMP_RAW"
    fi

    local STATUS
    STATUS="$(grep -m1 '^HTTP/' "$TMP_RAW" || true)"

    local SIZE
    SIZE="$(wc -c < "$TMP_RAW" 2>/dev/null || echo "0")"

    {
        echo "=================================================="
        echo "TEST   : $NAME"
        echo "URL    : $URL"
        echo "FILE   : $FILE"
        echo

        echo "[Request]"
        printf 'curl -sk -i --max-time 20 '

        for ARG in "${CUSTOM_HEADERS[@]}"; do
            printf '%q ' "$ARG"
        done

        for ARG in "$@"; do
            printf '%q ' "$ARG"
        done

        printf '%q\n' "$URL"
        echo

        echo "[Info]"
        echo "Status : ${STATUS:-N/A}"
        echo "Size   : $SIZE bytes"
        echo

        echo "[Important Headers]"
        grep -Ei "$HEADER_REGEX" "$TMP_RAW" || true
        echo

        echo "[Raw Response]"
        cat "$TMP_RAW"
    } > "$FILE"

    {
	echo "=================================================="
	echo "TEST   : $NAME"
	echo "URL    : $URL"
	echo "FILE   : $FILE"
	echo

	echo "[Request]"
	printf 'curl -sk -i --max-time 20 '

	for ARG in "${CUSTOM_HEADERS[@]}"; do
            printf '%q ' "$ARG"
	done

	for ARG in "$@"; do
            printf '%q ' "$ARG"
	done

	printf '%q\n' "$URL"
	echo

	echo "[Info]"
	echo "Status : ${STATUS:-N/A}"
	echo "Size   : $SIZE bytes"
	echo

	echo "[Headers]"
	grep -Ei "$HEADER_REGEX" "$TMP_RAW" || true
	echo

	BODY="$(awk '
        BEGIN { body=0 }
        body { print }
        /^\r?$/ { body=1 }
    ' "$TMP_RAW")"

	if [[ -n "$BODY" ]]; then
            echo "[Body]"
            printf '%s' "$BODY" | head -c 1200
            printf '\n\n'
	fi
    } >> "$SUMMARY"

    rm -f "$TMP_RAW"

    echo "[+] $NAME -> ${STATUS:-N/A} ($SIZE bytes)"
}

echo "[*] Target : $URL"
echo "[*] Tests  : $TEST_DIR"
echo "[*] Output : $OUTDIR"
echo

while IFS= read -r TEST_FILE; do
    TEST_NAME="$(basename "$TEST_FILE" .et)"

    unset ARGS
    ARGS=()

    # shellcheck source=/dev/null
    source "$TEST_FILE"

    if [[ "${#ARGS[@]}" -eq 0 ]]; then
        echo "[!] Skipping empty test: $TEST_NAME"
        continue
    fi

    run_test "$TEST_NAME" "${ARGS[@]}"

done < <(find "$TEST_DIR" -type f -name "*.et" | sort)

echo
echo "[+] Done"
echo "[+] Summary : $SUMMARY"
