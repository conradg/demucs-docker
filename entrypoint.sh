#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input-file>"
    exit 1
fi

input_file="$1"
# Check that the file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' does not exist."
    exit 1
fi

# Derive output directory name
base=$(basename "$input_file")
name="${base%.*}"
dir=$(dirname "$input_file")
output_dir="$dir/${name} - split"

# Remove any existing output directory to avoid conflicts
rm -rf "$output_dir"
mkdir -p "$output_dir"

echo "Processing $base with Demucs..."
demucs "$input_file"

# Demucs by default writes output to /app/separated (or similar)
# Move it into the output folder.
if [ -d "/app/separated" ]; then
    mv /app/separated "$output_dir"
    echo "✅ Successfully separated $base"
    echo "Output saved to: $output_dir"
else
    echo "Error: Demucs did not produce output in /app/separated."
    exit 1
fi

