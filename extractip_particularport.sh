#!/bin/bash

# Check if both arguments (nmap output file and port) are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <nmap_output_file> <port>"
    exit 1
fi

# Input Nmap output file and the target port
NMAP_FILE="$1"
TARGET_PORT="$2"

# Check if the Nmap output file exists
if [ ! -f "$NMAP_FILE" ]; then
    echo "File '$NMAP_FILE' not found!"
    exit 1
fi

echo "Searching for IPs with port $TARGET_PORT open in $NMAP_FILE"

# Search for the specified port and extract the corresponding IPs
awk -v port="$TARGET_PORT" '
/Nmap scan report for/ { ip=$NF }
/^PORT/ { next }
$1 ~ port && $2 == "open" { print ip }
' "$NMAP_FILE"
