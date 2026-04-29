#!/bin/bash

# Check if target IP and port are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <target-IP> <port>"
  exit 1
fi

TARGET_IP=$1
PORT=$2

echo "Commands for SSH Penetration Testing on $TARGET_IP:$PORT"
echo "========================================================="

# 1. Scan for the specified port
echo "nmap -p $PORT $TARGET_IP"

# 2. Perform service and version detection
echo "nmap -p $PORT -sV --script=ssh2-enum-algos $TARGET_IP"

# 3. Grab the SSH banner
echo "echo | nc $TARGET_IP $PORT"

# 4. Enumerate supported algorithms and CVEs
echo "ssh-audit $TARGET_IP:$PORT -n"

# 5. Check for weak or default credentials
echo "hydra -l root -P ~/wordlists/rockyou.txt ssh://$TARGET_IP:$PORT"

# 6. Search for SSH version vulnerabilities
SSH_VERSION="<detected_version>"
echo "searchsploit $SSH_VERSION"

# 7. Check for known CVEs using Nmap
echo "nmap --script sshv1,ssh2-enum-algos -p $PORT $TARGET_IP"

# 8. Enumerate users (if supported)
echo "msfconsole -x \"use auxiliary/scanner/ssh/ssh_enumusers; set RHOSTS $TARGET_IP; set RPORT $PORT; run\""

# 9. Test SSH login with a known private key (if available)
echo "ssh -i ./private_key.pem root@$TARGET_IP -p $PORT -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# 10. Test for keystroke timing attacks (if applicable)
echo "# Placeholder for keystroke timing attack test command"

echo "========================================================="
echo "Review the above commands and run them manually as needed."
