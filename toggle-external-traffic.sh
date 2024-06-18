#!/bin/bash

# Get the third octet of the local subnet from the IP address
SUBNET=$(ip a | grep -oP 'inet \K192\.168\.\d+' | awk -F '.' '{print $3}')

# Check if there is a rule to drop incoming traffic
STATE=$(sudo iptables -S | grep 'INPUT -j DROP')

# If no rule to drop incoming traffic exists, set up the rules to block internet access
if [ -z "$STATE" ]
then
    # Allow incoming traffic from the local subnet
    sudo iptables -A INPUT -s 192.168.$SUBNET.0/24 -j ACCEPT
    # Allow incoming traffic on the loopback interface
    sudo iptables -A INPUT -i lo -j ACCEPT
    # Drop all other incoming traffic
    sudo iptables -A INPUT -j DROP

    # Allow outgoing traffic to the local subnet
    sudo iptables -A OUTPUT -d 192.168.$SUBNET.0/24 -j ACCEPT
    # Allow outgoing traffic on the loopback interface
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    # Drop all other outgoing traffic
    sudo iptables -A OUTPUT -j DROP

    echo "Subnet: 192.168.$SUBNET.0/24"
    echo "Internet Banned"

# If a rule to drop incoming traffic exists, remove the rules to allow internet access
else
    # Remove the rule to drop all incoming traffic
    sudo iptables -D INPUT -j DROP
    # Remove the rule to drop all outgoing traffic
    sudo iptables -D OUTPUT -j DROP

    echo "Internet Open"
fi
