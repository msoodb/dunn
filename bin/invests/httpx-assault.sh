#!/bin/bash

figlet HTTPX.scan
# Script Name: httpx_assault.sh
# Description: Automated reconnaissance and vulnerability scanning script.
# Author: msoodb
# Usage: httpx_assault.sh


# Infra Info

mkdir infra
export DOMAIN=
whois $DOMAIN
wafw00f $DOMAIN 
dig.sh $DOMAIN 
host $DOMAIN 
nslookup $DOMAIN 
cat host | awk '{print $4}' > ip.txt
export IP=

firefox https://ipinfo.io/$IP
firefox https://www.shodan.io/host/$IP

# Is This the Origin IP?
dig -x $IP                                                   # Check Reverse DNS
nslookup $IP                                                 # Check Reverse DNS
    : ' If the result points to a domain associated with AWS or a CDN (like amazonaws.com), it is likely a WAF/CDN IP.
        If it points to something related to domain.com, it might be the origin server.'

openssl s_client -connect $DOMAIN:443 -showcerts
openssl s_client -connect $IP:443 -servername $DOMAIN
    : ' Check the Subject or Common Name (CN) in the certificate:

        If it matches $DOMAIN, it is likely the origin server.
        If it shows something like *.cloudfront.net or *.cloudflare.com, it is a WAF/CDN.'

firefix https://ipinfo.io/$IP
    : 'Check if IP belongs to a known WAF/CDN IP range:

        AWS CloudFront ranges: Use the ip-ranges.json from AWS.
        Use an online lookup tool like ipinfo.io.'

curl -v http://$IP/ -H "Host: $DOMAIN"  --insecure
    : 'Look for WAF/CDN headers like:

        x-cache
        via
        x-amz-cf-id
        cf-ray
        server: cloudflare
        
        A 301 Moved Permanently response redirecting to https://www.domain.com/ is a typical WAF/CDN behavior'

# nmap IP
nmap -Pn $IP
    : 'WAF/CDN IPs typically only allow traffic on ports 80 and 443:
        If ports like 22/tcp (SSH) or database ports are open, this is likely the origin server.'

# Check SSL
file techniques/ssl.md 

# Find pdf, image
exiftool somefile.pdf

# 
ffuf -u https://$DOMAIN/FUZZ -w ~/opt/wordlists/discovery/directory_list_2.3_medium.txt | tee -a dirs.txt


# Auto Scan
nuclei -u $DOMAIN -o nuclei.scan
nikto -h $DOMAIN -o nikto.scan -Format txt 

# Broken Link Hijacking (BLH)
socialhunter -f httpx.txt -w 10 | tee socialhunter.httpx.txt
gf urls | grep -E 'facebook|twitter|instagram|linkedin|youtube|github|reddit|tiktok|pinterest|snapchat|tumblr|flickr|stackoverflow|aparat' | sort -u > urls-socialmedia.txt
foxopen.sh urls-socialmedia.txt 

# XSS - (Commented out examples, uncomment as needed)
cat urls-params.txt | kxss
dalfox file urls-params.txt -o dalfox-urls-params.txt
nuclei -l urls-params.txt -tags xss -o  nuclei-xss-urls-params.txt

# Vulnerabilities, CVEs, Exposures
nuclei -u $DOMAIN -silent \
    -t technologies/ \
    -t http/vulnerabilities/ \
    -t http/cves/ \
    -t http/exposures/ \
    -t http/exposed-panels/ \
    -o nuclei-httpx.txt

# Testing leaked API tokens
nuclei -t http/token-spray/ -var token=SOMETOKEN