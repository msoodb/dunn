#!/bin/bash

LIST=$1
PATH_TO_TEST=$2

if [[ -z "$LIST" || -z "$PATH_TO_TEST" ]]; then
    echo "Usage: $0 urls.txt /path"
    exit 1
fi

echo "Starting 403 Bypass scans..."

while IFS= read -r LINE; do
    echo "Testing: $LINE$PATH_TO_TEST"

    ./bypass-403.sh "$LINE" "$PATH_TO_TEST" | tee -a "${LIST}.bypass"

done < "$LIST"

echo "Starting 403 Bypass scans...done!"
