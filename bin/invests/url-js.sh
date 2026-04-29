#!/bin/bash

# ----------------------------------
#   JS Enumeration
# ----------------------------------

URLS=$1

# Check if input file is provided
if [[ -z "$URLS" ]]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Check if the input file exists
if [[ ! -f "$URLS" ]]; then
    echo "File not found: $URLS"
    exit 1
fi

# Extract JS lines to a separate file
grep -Ei '\.js(\?.*)?$' "$URLS" > urls-js.txt

# Remove JS lines from the original file
grep -vEi '\.js(\?.*)?$' "$URLS" > temp.txt && mv temp.txt "$URLS"

echo "JS URLs have been moved to urls-js.txt and removed from $URLS."
