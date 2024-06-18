#!/bin/bash

# Function to extract subnet from IP address
get_subnet() {
    local subnet
    subnet=$(echo "$1" | awk -F '.' '{print $3}')
    echo "$subnet"
}

# Determine local subnet
SUBNET=$(ip a | grep -oP 'inet \K(192\.168|10\.)\.\d+' | awk '{print $2}')

# Check if there is a rule to drop incoming traffic
STATE=$(sudo iptables -S | grep 'INPUT -j DROP')

# If no rule to drop incoming traffic exists, set up the rules to block internet access
if [ -z "$STATE" ]; then
    # Allow incoming traffic from the detected subnet
    sudo iptables -A INPUT -s "$SUBNET".0/24 -j ACCEPT
    # Allow incoming traffic on the loopback interface
    sudo iptables -A INPUT -i lo -j ACCEPT
    # Drop all other incoming traffic
    sudo iptables -A INPUT -j DROP

    # Allow outgoing traffic to the detected subnet
    sudo iptables -A OUTPUT -d "$SUBNET".0/24 -j ACCEPT
    # Allow outgoing traffic on the loopback interface
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    # Drop all other outgoing traffic
    sudo iptables -A OUTPUT -j DROP

    echo "Subnet: $SUBNET.0/24"
    echo "Internet Banned"

# If a rule to drop incoming traffic exists, remove the rules to allow internet access
else
    # Remove the rule to drop all incoming traffic
    sudo iptables -D INPUT -j DROP
    # Remove the rule to drop all outgoing traffic
    sudo iptables -D OUTPUT -j DROP

    echo "Internet Open"
fi

