#!/bin/bash

figlet Zero Assault
# Script Name: zero_assault.sh
# Description: Automated reconnaissance and vulnerability scanning script.
# Author: msoodb
# Usage: zero_assault.sh

# Help section
function help() {
    echo "Usage: zero_assault.sh"
    echo "Description: This script performs automated tasks including bypassing 403 responses, searching for Broken Link Hijacking (BLH), subdomain takeovers, XSS vulnerabilities, and scanning for known vulnerabilities, CVEs, and exposures."
    echo "Ensure you have all required tools installed before running the script."
}

# Check if help is requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    help
    exit 0
fi

# Create the output directory
OUTPUT_DIR="zero_assault"
echo "Creating output directory: $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR


##############################################################################################################################

# Broken Link Hijacking (BLH)
echo "Scanning for Broken Link Hijacking (BLH)..."
socialhunter -f urls.txt | tee "$OUTPUT_DIR/socialhunter.urls.txt"
echo "Scanning for Broken Link Hijacking (BLH)...done!"


# Subdomain Takeovers
echo "Scanning for Subdomain Takeovers..."
nuclei -l httpx.txt -t ~/nuclei-templates/http/takeovers/ -o "$OUTPUT_DIR/nuclei-takeovers-httpx.txt"
subzy run --targets httpx.txt | tee "$OUTPUT_DIR/subzy-httpx.txt"
cat "$OUTPUT_DIR/subzy-httpx.txt" | grep -v "NOT VULNERABLE" | grep -v "HTTP ERROR" | tee "$OUTPUT_DIR/subzy-httpx-vuln.txt"
echo "Scanning for Subdomain Takeovers...done!"


# XSS - (Commented out examples, uncomment as needed)
echo "Scanning for XSS vulnerabilities..."
cat urls.txt | grep "?" > "$OUTPUT_DIR/urls-params.txt"
cat "$OUTPUT_DIR/urls-params.txt" | kxss | tee "$OUTPUT_DIR/urls-kxss.txt"
cat "$OUTPUT_DIR/urls-kxss.txt" | grep \" | awk '{print $2}' > "$OUTPUT_DIR/urls-kxss-vuln.txt"
dalfox file "$OUTPUT_DIR/urls-kxss-vuln.txt" -o "$OUTPUT_DIR/dalfox-urls-kxss-vuln.txt"
nuclei -l "$OUTPUT_DIR/urls-params.txt" -tags xss -o  "$OUTPUT_DIR/nuclei-xss-urls-params.txt"
echo "Scanning for XSS vulnerabilities...done!"


# 403 Bypass
echo "Starting 403 Bypass scans..."
for LINE in $(cat httpx-403.txt); do
    bypass-403.sh "$LINE" | tee -a "$OUTPUT_DIR/httpx-403-result.txt"
done
cat "$OUTPUT_DIR/httpx-403-result.txt" | grep 200 > "$OUTPUT_DIR/httpx-403-result-200.txt"
echo "Starting 403 Bypass scans...done!"


# Vulnerabilities, CVEs, Exposures
echo "Scanning for vulnerabilities, CVEs, and exposures..."
nuclei -l httpx.txt \
    -t ~/nuclei-templates/http/vulnerabilities/ \
    -t ~/nuclei-templates/http/cves/ \
    -t ~/nuclei-templates/http/exposures/ \
    -t ~/nuclei-templates/technologies/ \
    -o "$OUTPUT_DIR/nuclei-httpx.txt"
echo "Scanning for vulnerabilities, CVEs, and exposures...done!"

echo "Phase Zero Assault completed. Results saved in $OUTPUT_DIR."
