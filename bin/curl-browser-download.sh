#!/bin/bash

# ----------------------------------
#   Curl as Browser Download
# ----------------------------------

URL=$1


FILENAME=$(basename "$URL")
echo "Downloading: $URL"

curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36" \
    --referer "https://example.com" \
    --retry 3 \
    --max-time 15 \
    --output "$FILENAME" "$URL"
