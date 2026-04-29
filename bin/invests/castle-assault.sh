#!/bin/bash

figlet CASTLE.scan
# Script Name: castle_assault.sh
# Description: Castle vulnerability scanning script.
# Author: msoodb

# IPs
gf ip-m  | sort -u > ips.txt
for ip in ips:
    dig -x ip
done

# Auto Scan
nuclei -l castles.txt -o nuclei.castles.txt

# Subdomain Takeovers
nuclei -l httpx.txt -t ~/nuclei-templates/http/takeovers/ -o nuclei-takeovers-httpx.txt
subzy run --targets httpx.txt | tee subzy-httpx.txt


# 403 Bypass
bypass-403-list.sh httpx-403.txt

# Broken Link Hijacking (BLH)
socialhunter -f httpx.txt -w 10 | tee socialhunter.httpx.txt

#
replace_fuzz.sh "https://www.mactag.com/case-studies?filter_from=FUZZ&filter_to=2015-10-31" ~/Projects/dunn/payloads/open-redirect.txt 
