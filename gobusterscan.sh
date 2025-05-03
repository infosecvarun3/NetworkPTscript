#!/bin/bash

# Check if the necessary arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <ip_list_file> <wordlist_file>"
    exit 1
fi

# Input files
IP_LIST="$1"
WORDLIST="$2"

# Output file for successful 200 status URLs
OUTPUT_FILE="successful_urls.txt"
: > "$OUTPUT_FILE"  # Clear the output file if it exists

# Check if the IP list file exists
if [ ! -f "$IP_LIST" ]; then
    echo "IP list file '$IP_LIST' not found!"
    exit 1
fi

# Check if the wordlist file exists
if [ ! -f "$WORDLIST" ]; then
    echo "Wordlist file '$WORDLIST' not found!"
    exit 1
fi

# Loop through each IP in the list
while IFS= read -r IP; do
    echo "Brute forcing directories on IP: $IP"

    # Run gobuster to brute force directories and filter for 200 OK status codes
    gobuster dir -u "http://$IP" -w "$WORDLIST" -t 50 -s "200" | while read line; do
        # Check if the line contains the 200 status code
        if [[ "$line" =~ "200" ]]; then
            # Extract and append the URL with 200 status to the output file
            echo "http://$IP${line#*200}" >> "$OUTPUT_FILE"
        fi
    done

    echo "Finished brute forcing on $IP"
    echo "-----------------------------------------------"
done < "$IP_LIST"

echo "Brute forcing complete. All successful URLs (200 OK) saved to $OUTPUT_FILE."
