#!/bin/bash

# Make me king
while true
do 
    chmod -x /usr/bin/chattr
    set +o noclobber /root/king.txt
    ./busybox chattr -ia /root/king.txt
    echo msoodb > /root/king.txt
    ./busybox chattr +ia /root/king.txt
    set -o noclobber /root/king.txt
done