#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <nmap_output_file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "File '$FILE' not found!"
    exit 1
fi

OUTPUT_FILE="parsed_output.txt"
: > "$OUTPUT_FILE"  # Clear previous content

echo "Parsing Nmap multi-host output from: $FILE"
echo "==============================================" | tee -a "$OUTPUT_FILE"

# Split file into per-host temporary files
awk '
BEGIN { RS="Nmap scan report for "; ORS="" }
/./ {
    print "Nmap scan report for " $0 > ("/tmp/hostblock_" NR ".txt")
}
' "$FILE"

# Process each host
for hostfile in /tmp/hostblock_*.txt; do
    {
        echo "----------------------------------------------"

        # Extract IP or DNS
        FIRST_LINE=$(head -n1 "$hostfile")
        if [[ "$FIRST_LINE" =~ \(([^)]+)\) ]]; then
            DNS_NAME=$(echo "$FIRST_LINE" | awk '{print $5}')
            IP=$(echo "$FIRST_LINE" | grep -oP '\(\K[^\)]+' )
        else
            IP=$(echo "$FIRST_LINE" | awk '{print $5}')
            DNS_NAME=""
        fi

        echo "Target IP: $IP"
        [ -n "$DNS_NAME" ] && echo "DNS Name: $DNS_NAME"

        # Host status
        grep -q "Host is up" "$hostfile" && echo "Host is UP" || echo "Host is DOWN"

        # Device type
        DEVICE_TYPE=$(grep -i "Device type:" "$hostfile" | head -n1 | sed 's/Device type:[[:space:]]*//')
        [ -n "$DEVICE_TYPE" ] && echo "Device Type: $DEVICE_TYPE" || echo "Device Type: Unknown"

        # If port 3389 is open, show DNS
        if grep -q "^3389/.*open" "$hostfile"; then
            [ -n "$DNS_NAME" ] && echo "DNS Name (for 3389): $DNS_NAME"
        fi

        echo
        echo "Open Ports, Services, and Versions:"
        echo "------------------------------------"
        awk '/PORT/{flag=1; next} /^Service Info:|^MAC Address:|^Device type:|^OS details:|^Running:|^Aggressive OS guesses:|^Uptime guess:|^Network Distance:|^TCP Sequence Prediction:|^IP ID Sequence Generation:|^Service detection performed:|^Nmap done:/{flag=0} flag && $2 == "open" {print $1, $3, substr($0, index($0,$4))}' "$hostfile"

        # Comma-separated ports without protocol
        OPEN_PORTS=$(awk '/PORT/{flag=1; next} /^Nmap done:/{flag=0} flag && $2 == "open" {split($1,a,"/"); print a[1]}' "$hostfile" | paste -sd, -)
        if [ -n "$OPEN_PORTS" ]; then
            echo
            echo "Open Ports (comma-separated): $OPEN_PORTS"
        else
            echo
            echo "No open ports found."
        fi
        echo
    } | tee -a "$OUTPUT_FILE"
done

# Cleanup
rm -f /tmp/hostblock_*.txt

echo "✅ Parsed output saved to $OUTPUT_FILE"
