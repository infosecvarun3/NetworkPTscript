#!/bin/bash

# Check for gobuster installation
if ! command -v gobuster &> /dev/null; then
    echo "[-] Gobuster not found. Please install it first."
    exit 1
fi

# Prompt user for input
read -p "Enter the path to the IP/URL list file: " IP_LIST
read -p "Enter port number (e.g., 80, 443): " PORT
read -p "Enter protocol (http or https): " PROTOCOL
read -p "Enter full path to wordlist: " WORDLIST
read -p "Enter number of threads (e.g., 10): " THREADS

# Validate wordlist
if [ ! -f "$WORDLIST" ]; then
    echo "[-] Wordlist not found: $WORDLIST"
    exit 1
fi

# Validate IP list
if [ ! -f "$IP_LIST" ]; then
    echo "[-] IP/URL list file not found: $IP_LIST"
    exit 1
fi

# Create output directory
OUTPUT_DIR="gobuster_output"
mkdir -p "$OUTPUT_DIR"

# Timestamped final output file for 200 OK URLs
FINAL_OUTPUT="gobuster_200_urls.txt"
> "$FINAL_OUTPUT"  # Clear if it exists

# Loop through each IP/URL in the list
while IFS= read -r TARGET; do
    # Skip empty lines
    if [[ -z "$TARGET" ]]; then
        continue
    fi

    # Construct the full URL
    URL="${PROTOCOL}://${TARGET}:${PORT}"
    OUTPUT_FILE="${OUTPUT_DIR}/$(echo "$TARGET" | sed 's/[^a-zA-Z0-9]/_/g')_port${PORT}_$(date +%Y%m%d_%H%M%S).txt"

    # Run Gobuster for each target
    echo "[*] Running gobuster on $URL ..."
    gobuster dir -u "$URL" -w "$WORDLIST" -t "$THREADS" --no-tls-verify -o "$OUTPUT_FILE"

    echo "[+] Gobuster scan complete for $URL. Results saved to $OUTPUT_FILE"

    # Grep for 200 OK status codes and append to the final file
    echo "[*] Extracting 200 OK URLs from $OUTPUT_FILE ..."
    grep " 200 " "$OUTPUT_FILE" | awk -v base="$URL" '{print base $1}' >> "$FINAL_OUTPUT"
done < "$IP_LIST"

echo "[+] 200 OK URLs have been saved to $FINAL_OUTPUT"
