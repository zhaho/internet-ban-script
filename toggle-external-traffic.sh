#!/bin/bash

# Function to get the local subnet dynamically
get_local_subnet() {
    local ip=$(ip route | awk '/default/ { print $3 }')
    local subnet=$(ip route | awk -v ip="$ip" '$1 == ip { print $1 }')
    echo "${subnet}"
}

# Detect the local subnet
LOCAL_SUBNET=$(get_local_subnet)

if [ -z "$LOCAL_SUBNET" ]; then
    echo "Failed to detect local subnet."
    exit 1
fi

# Check if there is a rule to drop incoming traffic
STATE=$(sudo iptables -S | grep 'INPUT -j DROP')

# If no rule to drop incoming traffic exists, set up the rules to block internet access
if [ -z "$STATE" ]; then
    # Allow incoming traffic from the local subnet
    sudo iptables -A INPUT -s "$LOCAL_SUBNET" -j ACCEPT
    # Allow incoming traffic on the loopback interface
    sudo iptables -A INPUT -i lo -j ACCEPT
    # Drop all other incoming traffic
    sudo iptables -A INPUT -j DROP

    # Allow outgoing traffic to the local subnet
    sudo iptables -A OUTPUT -d "$LOCAL_SUBNET" -j ACCEPT
    # Allow outgoing traffic on the loopback interface
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    # Drop all other outgoing traffic
    sudo iptables -A OUTPUT -j DROP

    echo "Subnet: $LOCAL_SUBNET"
    echo "Internet Closed"

# If a rule to drop incoming traffic exists, remove the rules to allow internet access
else
    # Remove the rule to drop all incoming traffic
    sudo iptables -D INPUT -j DROP
    # Remove the rule to drop all outgoing traffic
    sudo iptables -D OUTPUT -j DROP

    echo "Internet Open"
fi
