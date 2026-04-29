
#!/bin/bash

# Usage: ./common-url <base_url> <interesting_urls>
# Example: ./common-url https://example.com interesting_urls.txt

if [ $# -ne 2 ]; then
  echo "Usage: $0 <base_url> <interesting_urls>"
  exit 1
fi

BASE_URL="$1"
URL_LIST="$2"
OUTPUT_FILE="common_urls.txt"

# Check if the URL list file exists
if [ ! -f "$URL_LIST" ]; then
  echo "Error: File '$URL_LIST' not found."
  exit 1
fi

# Generate URLs
echo "Generating URLs for base URL: $BASE_URL"
> "$OUTPUT_FILE" # Clear the output file before appending
while IFS= read -r PATH; do
  echo "$BASE_URL$PATH" >> "$OUTPUT_FILE"
done < "$URL_LIST"

echo "URLs have been saved to $OUTPUT_FILE."
