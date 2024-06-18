# Internet Access Control Script using iptables

This script manages internet access on a Linux system using `iptables` firewall rules. It automatically detects the local subnet and blocks internet access if not already blocked.

## Usage

1. **Download the script**: Clone the repo or download `toggle-external-traffic.sh` to your Linux system.

2. **Make the Script Executable**: Ensure the script has executable permissions using the following command:
   ```bash
   chmod +x toggle-external-traffic.sh
   ```
 3. **Run the script**:
     ```bash
     sudo ./toggle-external-traffic.sh
     ```

