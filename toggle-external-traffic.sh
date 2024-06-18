#!/bin/bash

# Function to get the local subnet dynamically
get_local_subnet() {
    # Extract all IPv4 addresses with global scope
    local addresses=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')

    # Extract subnet from the first address (assuming they are on the same subnet)
    local subnet=$(echo "$addresses" | head -n 1 | cut -d'/' -f1)

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
    sudo iptables -A INPUT -s "$LOCAL_SUBNET"/24 -j ACCEPT  # Adjust subnet mask as necessary
    # Allow incoming traffic on the loopback interface
    sudo iptables -A INPUT -i lo -j ACCEPT
    # Drop all other incoming traffic
    sudo iptables -A INPUT -j DROP

    # Allow outgoing traffic to the local subnet
    sudo iptables -A OUTPUT -d "$LOCAL_SUBNET"/24 -j ACCEPT  # Adjust subnet mask as necessary
    # Allow outgoing traffic on the loopback interface
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    # Drop all other outgoing traffic
    sudo iptables -A OUTPUT -j DROP

    echo "Subnet based on IP: $LOCAL_SUBNET/24"  # Adjust subnet mask as necessary
    echo "Internet Banned"

# If a rule to drop incoming traffic exists, remove the rules to allow internet access
else
    # Remove the rule to drop all incoming traffic
    sudo iptables -D INPUT -j DROP
    # Remove the rule to drop all outgoing traffic
    sudo iptables -D OUTPUT -j DROP

    echo "Internet Open"
fi
