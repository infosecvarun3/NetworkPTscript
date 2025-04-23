#!/bin/bash

# Usage: ./nmap_scan.sh input_file.txt

# Check if input file is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
BASENAME=$(basename "$INPUT_FILE" .txt)
OUTPUT_DIR="Out"
OUTPUT_FILE="$OUTPUT_DIR/output-$BASENAME.txt"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Run the nmap scan
echo "Running Nmap scan on targets from $INPUT_FILE..."
nmap -sC -sV -v -iL "$INPUT_FILE" -oN "$OUTPUT_FILE" --max-retries 3 --min-rate 1000

echo "Scan complete. Output saved to $OUTPUT_FILE"
