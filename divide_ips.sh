#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file=$1

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found!"
    exit 1
fi

# Get current date in DDMonthYYYY format (e.g., 24Apr2025)
current_date=$(date +"%d%b%Y")

# Initialize counter
count=1
line_count=0
output_file=""

# Read input file line by line
while IFS= read -r ip; do
    # Skip empty lines
    if [ -z "$ip" ]; then
        continue
    fi
    
    # Every 10 lines, create a new output file
    if [ $((line_count % 10)) -eq 0 ]; then
        output_file="${count}-${current_date}.txt"
        count=$((count + 1))
        # Clear the output file if it exists
        > "$output_file"
    fi
    
    # Write the IP to the current output file
    echo "$ip" >> "$output_file"
    line_count=$((line_count + 1))
done < "$input_file"

echo "Divided $line_count IPs into $((count - 1)) files with 10 IPs each."
