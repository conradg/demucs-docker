#!/bin/bash
set -e

# Default values
INPUT_FILE=""
OUTPUT_DIR=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --input|-i)
            INPUT_FILE="$2"
            shift 2
            ;;
        --output|-o)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Usage: $0 --input <input-file> [--output <output-dir>]"
            exit 1
            ;;
    esac
done

# Check if input file is provided
if [ -z "$INPUT_FILE" ]; then
    echo "Error: Input file is required"
    echo "Usage: $0 --input <input-file> [--output <output-dir>]"
    exit 1
fi

# Check that the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' does not exist."
    exit 1
fi

# If output directory is not specified, use the input file's directory
if [ -z "$OUTPUT_DIR" ]; then
    base=$(basename "$INPUT_FILE")
    name="${base%.*}"
    dir=$(dirname "$INPUT_FILE")
    OUTPUT_DIR="$dir/${name} - split"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Processing $INPUT_FILE with Demucs..."
echo "Output will be saved to: $OUTPUT_DIR"

# Run Demucs
demucs "$INPUT_FILE"

# Move output to specified directory
if [ -d "/app/separated" ]; then
    mv /app/separated/* "$OUTPUT_DIR/"
    rm -rf /app/separated
    echo "✅ Successfully separated audio"
    echo "Output saved to: $OUTPUT_DIR"
else
    echo "Error: Demucs did not produce output in /app/separated."
    exit 1
fi

