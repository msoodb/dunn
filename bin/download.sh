#!/bin/bash

# ----------------------------------
#  Bulk URL Downloader (JS/Asset Collector)
# ----------------------------------
# Description:
# This script downloads a list of URLs from a file using curl with
# browser-like headers. Each file is saved with a unique hash-based
# filename to prevent overwriting duplicates. Failed downloads are
# logged separately for later review.
#
# Features:
# - Reads URLs from input file (one per line)
# - Adds browser User-Agent and referer headers
# - Generates unique filenames using MD5 hash of URL
# - Prevents file overwriting
# - Retries failed downloads automatically
# - Logs failed URLs for debugging
# ----------------------------------


URL_FILE=$1
OUTPUT_DIR="${URL_FILE}_dir/"
LOG_FILE="failed_${URL_FILE}.log"

# Ensure the log file and URL file are distinct
if [[ "$URL_FILE" == "$LOG_FILE" ]]; then
    echo "Error: The URL file and log file must not be the same."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
> "$LOG_FILE" # Clear the log file content, not the URL file

while IFS= read -r URL; do
    # Generate a unique filename using the URL hash
    HASH=$(echo -n "$URL" | md5sum | awk '{print $1}')
    FILENAME=$(basename "$URL")
    UNIQUE_FILENAME="${HASH}_$FILENAME"

    echo "Downloading: $URL"

    curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36" \
         --referer "https://example.com" \
         --retry 3 \
         --max-time 15 \
         --output "$OUTPUT_DIR/$UNIQUE_FILENAME" "$URL" || {
        echo "Failed: $URL" >> "$LOG_FILE"
    }
done < "$URL_FILE"

echo "Download complete. Check $LOG_FILE for failed URLs."
