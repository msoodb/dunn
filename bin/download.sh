#!/bin/bash

set -uo pipefail

INPUT="${1:?Usage: $0 <url-or-url-file>}"

download_one() {
    local URL="$1"
    local OUTPUT="$2"

    curl "$URL" \
      -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36" \
      -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" \
      -H "Accept-Language: en-US,en;q=0.9" \
      -H "Referer: https://www.google.com/" \
      --compressed \
      --location \
      --retry 3 \
      --max-time 20 \
      --fail \
      -o "$OUTPUT"
}

safe_filename() {
    local URL="$1"
    local NAME
    local EXT

    NAME=$(basename "${URL%%\?*}")

    if [[ -z "$NAME" || "$NAME" == "/" ]]; then
        NAME="index.html"
    fi

    # remove dangerous chars
    NAME=$(echo "$NAME" | tr '/:?&=#%' '_')

    # keep extension if possible
    EXT="${NAME##*.}"

    # filename too long protection
    if [[ ${#NAME} -gt 80 ]]; then
        NAME="${NAME:0:80}"

        if [[ -n "$EXT" && "$EXT" != "$NAME" ]]; then
            NAME="${NAME}.${EXT}"
        fi
    fi

    echo "$NAME"
}

if [[ -f "$INPUT" ]]; then

    BASE_NAME="$(basename "$INPUT")"

    OUTPUT_DIR="${BASE_NAME}_dir"
    LOG_FILE="failed_${BASE_NAME}.log"

    mkdir -p "$OUTPUT_DIR"
    > "$LOG_FILE"

    while IFS= read -r URL; do

        [[ -z "$URL" ]] && continue
        [[ "$URL" =~ ^# ]] && continue

        HASH=$(echo -n "$URL" | md5sum | awk '{print $1}')
        NAME=$(safe_filename "$URL")

        OUTPUT_FILE="$OUTPUT_DIR/${HASH}_${NAME}"

        echo "[*] Downloading: $URL"

        if download_one "$URL" "$OUTPUT_FILE"; then
            echo "[+] OK: $OUTPUT_FILE"
        else
            echo "[-] FAILED: $URL"

            echo "$URL" >> "$LOG_FILE"

            rm -f "$OUTPUT_FILE" 2>/dev/null || true

            continue
        fi

    done < "$INPUT"

    echo
    echo "[+] Bulk download complete."
    echo "[+] Output dir: $OUTPUT_DIR"
    echo "[+] Failed log: $LOG_FILE"

else

    URL="$INPUT"

    OUTPUT_FILE=$(safe_filename "$URL")

    echo "[*] Downloading single URL: $URL"

    if download_one "$URL" "$OUTPUT_FILE"; then
        echo "[+] Saved as: $OUTPUT_FILE"
    else
        echo "[-] Download failed"
        exit 1
    fi
fi
