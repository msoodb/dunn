#!/bin/bash


# ----------------------------------------------------------------------------
#
# nmap $IP -oN nmap.ports
# nmap -sV -sC -p $PORT -oN port.$PORT-SERVICE $IP
# mkdir -p nmap.vulns
# nmap -vv --script vuln -p $PORT -oN nmap.vulns/port.$PORT-SERVICE.vuln $IP
#
# ----------------------------------------------------------------------------


IP=$1
PARAMS=$2
nmap $PARAMS $IP -oN nmap.ports
PORTS=$(cat nmap.ports | grep 'open\|closed\|filtered\|unfiltered\|open|filtered\|closed|filtered' | awk '{ print ($0+0 "," $3)}' | sed -z 's/\n/;/g;s/;$/\n/')


oIFS="$IFS"
while IFS=';' read -ra PORT; do
  for i in "${PORT[@]}"; do
    IFS=','
    read -a strarr <<< "$i"
    nmap -sV -sC -p ${strarr[0]} -oN port.${strarr[0]}.${strarr[1]} $IP
  done
done <<< "$PORTS"

mkdir -p nmap.vulns
while IFS=';' read -ra PORT; do
  for i in "${PORT[@]}"; do
    IFS=','
    read -a strarr <<< "$i"
    nmap -vv --script vuln -p ${strarr[0]} -oN nmap.vulns/port.${strarr[0]}.${strarr[1]}.vuln $IP
  done
done <<< "$PORTS"

IFS="$oIFS"
unset oIFS
