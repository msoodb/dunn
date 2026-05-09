
Man in the middle proxy



# Topic
- Getting Burp Proxy
- Setting up Firefox to proxy through Burp
- UI overview
    - Target
    - Proxy
    - Spider
    - Intruder
    - Repeater
    - Sequencer
    - Decoder
    - Comparer
- Target deep dive
    - Using the site map
    - Setting up your scope
- Proxy deep dive
    - Using the HTTP history and filtering
    - Intercepting requests and responses
    - Match and replace
    - Unhiding hidden form fields
- Using Repeater
    - Sending requests from proxy history
    - Manipulating requests
        - Identifying XSS with ease
- Using Decoder
    - Decoding data from a request
    - Encoding and hashing data
- Using Intruder 

# Important
- scope
    - add/remove to scope
    - regex in scope for domain and all subdomains      
        - [*.example.com]  .*\.example\.com$
        - [*web-security-academy.net]  .*\.web-security-academy\.net$
        - [*ctf.hacker101.com]  .*\.ctf.hacker101\.com$
    - remove Out of Scope subdomains then.



# Setup FoxyProxy
- Add FoxyProxy to Firefox
- Add a Burp Proxy
    - Burp > Proxy > Options
    - Add Burp Proxy
- Add the Burp CA
    - Browse http://127.0.0.1:8080/
    - Save Burp CA
    - Import CA to Firefox
- Fix SSL Errors (If Necessary)

# Burp Configuration For Tor Proxy
https://brezular.com/2020/01/02/how-to-configure-burpsuite-to-use-tor-as-proxy/
- Configure Burp To Use Tor as Socks Proxy:
    - Open Burp and navigate to User Option-> Connection-> SOCKS Proxy and click Check button - Use SoCKS proxy. Insert the Tor socket settings (Picture 2).
    127.0.0.1
    9050


# Burp UserAgent
https://github.com/codewatchorg/Burp-UserAgent
- Update or set the User-Agent header in all requests to a specific value.

# Proxy → Match and replace
- Request Header
- globally modify every request leaving Burp so the User-Agent always includes HackerOne
- Match: ^User-Agent:\s*(.*)$
- Replace: User-Agent: $1 HackerOne

# Project -> task -> Resource pool
- Automated web scans of Hilton websites should be limited to a maximum of 100 requests/minute for each website.
