#!/bin/bash
SUBNET=$(ip a | grep -oP 'inet \K192\.168\.\d+' | awk -F '.' '{print $3}')
STATE=$(sudo iptables -S | grep 'INPUT -j DROP')
if [ -z "$STATE" ]
then
        sudo iptables -A INPUT -s 192.168.$SUBNET.0/24 -j ACCEPT
        sudo iptables -A INPUT -i lo -j ACCEPT
        sudo iptables -A INPUT -j DROP
        sudo iptables -A OUTPUT -d 192.168.68.0/24 -j ACCEPT
        sudo iptables -A OUTPUT -o lo -j ACCEPT
        sudo iptables -A OUTPUT -j DROP
echo "Subnet: 192.168.$SUBNET.0/24"        
echo "Internet Banned"
else
        sudo iptables -D INPUT -j DROP
        sudo iptables -D OUTPUT -j DROP
echo "Internet Open"
fi
