#!/bin/bash
IP=$1
HOST="target.ip"
File="/etc/hosts"

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if grep -q $HOST "$File";
    then
        sed -i "/$HOST/ s/.*/$IP\t$HOST/g" $File
    else
        echo $IP$'\t'$HOST >> $File
fi
echo $IP$'\t'$HOST added to $File
su - $SUDO_USER -c "ssh-keygen -f \"/home/$SUDO_USER/.ssh/known_hosts\" -R \"target.ip\""
