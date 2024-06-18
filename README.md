# Internet Ban Script

This repository contains a Bash script to manage internet access on a machine by modifying iptables rules. The script either blocks or allows internet access based on the current iptables state.

## Script Overview

The script performs the following actions:
1. Determines the local subnet.
2. Checks the current state of iptables rules.
3. If internet access is allowed, it blocks internet access while allowing local network and loopback communication.
4. If internet access is blocked, it removes the rules blocking internet access.

## Usage

### Prerequisites

- `iptables` must be installed and accessible with `sudo` privileges.
- The script should be run with `sudo` to modify iptables rules.

### Running the Script

To run the script, execute the following command in your terminal:

```bash
sudo ./internet_ban.sh
