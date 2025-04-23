#!/bin/bash

# Usage: ./ferox_scan.sh <input_file> <wordlist> [port]
# Example: ./ferox_scan.sh targets.txt /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt 80

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_file> <wordlist> [port]"
    exit 1
fi

INPUT_FILE="$1"
WORDLIST="$2"
PORT="${3:-80}" # Default to port 80 if not provided
OUTPUT_DIR="ferox-output"

mkdir -p "$OUTPUT_DIR"

while read -r TARGET; do
    if [ -z "$TARGET" ]; then
        continue
    fi

    # Clean up target (remove trailing slashes, whitespace)
    CLEAN_TARGET=$(echo "$TARGET" | tr -d '[:space:]' | sed 's:/*$::')

    # Build the URL
    URL="http://$CLEAN_TARGET:$PORT"

    echo "[*] Scanning $URL with feroxbuster..."
    feroxbuster -u "$URL" -w "$WORDLIST" -o "$OUTPUT_DIR/ferox-$CLEAN_TARGET.txt" -q --threads 50
done < "$INPUT_FILE"

echo "[+] All scans completed. Results saved in $OUTPUT_DIR/"
