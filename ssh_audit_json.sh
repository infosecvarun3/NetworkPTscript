#!/bin/bash

# Usage: ./ssh_audit_json.sh <input_file> [port]
# Example: ./ssh_audit_json.sh targets.txt 22

INPUT_FILE="$1"
PORT="${2:-22}"  # Default to port 22 if not specified
OUTPUT_DIR="ssh-audit-json"

# Check input
if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input_file> [port]"
    exit 1
fi

# Check if ssh-audit is installed
if ! command -v ssh-audit &>/dev/null; then
    echo "[-] ssh-audit not found. Please install it: apt install ssh-audit"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Process each host
while read -r HOST; do
    HOST=$(echo "$HOST" | tr -d '[:space:]')
    if [ -z "$HOST" ]; then continue; fi

    echo "[*] Auditing $HOST..."
    OUTPUT_FILE="$OUTPUT_DIR/ssh-audit-$HOST.json"

    ssh-audit -p "$PORT" "$HOST" --json > "$OUTPUT_FILE"

    echo "    [+] Saved: $OUTPUT_FILE"
done < "$INPUT_FILE"

echo "[+] All JSON reports saved in $OUTPUT_DIR/"
