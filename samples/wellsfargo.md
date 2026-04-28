```sh
# Preperation
cd Operations
mkdir wellsfargo.com
cd wellsfargo.com
echo wellsfargo.com > target

# Do some Google Dorking
FGDS.sh wellsfargo.com

# subdomains
sub.sh subdomains
host.sh subdomains
url.sh wellsfargo.com
cat urls  | uro > urls.uro
cat urls.uro | httpx -mc 200,403 -o urls.uro.live

# 403
403.sh hosts.403

# Subdomains takeover
nuclei -t ~/nuclei-templates/http/takeovers/ -l hosts.live
subzy run --targets hosts.live | tee subzy.hosts.live

# Try to find Vulnerabilities
nuclei -l hosts.live -t ~/nuclei-templates/http/vulnerabilities/ -t ~/nuclei-templates/http/cves/ -t ~/nuclei-templates/http/exposures/ -o hosts.live.vulnerabilities.cves.exposures


# Extract Params and js files from urls
cat urls | grep "=" | tee params
cat urls | grep -iE '.js' | grep -ivE '.json' | sort -u | tee js

# Test XSS
cat params | kxss