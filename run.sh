#!/bin/bash

# Full path to Docker
DOCKER_PATH="/usr/local/bin/docker"
# If using Docker Desktop, it might be here instead
if [ ! -f "$DOCKER_PATH" ]; then
    DOCKER_PATH="/Applications/Docker.app/Contents/Resources/bin/docker"
fi

extract_vocals() {
    # Log file for debugging
    local log_file="$HOME/vocals_extract_log.txt"
    
    echo "Script started at $(date)" > "$log_file"
    echo "Input file: $1" >> "$log_file"
    
    # Validate input file exists
    if [ -z "$1" ] || [ ! -f "$1" ]; then
        echo "Error: Input file not found or not specified: '$1'" >> "$log_file"
        exit 1
    fi
    
    local input_dir="$HOME/programs/demucs-docker/input" 
    local output_dir="$HOME/programs/demucs-docker/output"
    mkdir -p "$input_dir" "$output_dir"
    
    local file_path="$1"
    local file_name="$(basename "$file_path")"
    local base_name="${file_name%.*}"
    
    echo "File path: $file_path" >> "$log_file"
    echo "File name: $file_name" >> "$log_file"
    
    # Clean directories
    rm -rf "$input_dir"/* "$output_dir"/*
    
    # Copy input file
    echo "Copying file to input directory" >> "$log_file"
    cp "$file_path" "$input_dir/"
    
    # Check if Docker is running
    if ! "$DOCKER_PATH" info &>/dev/null; then
        echo "Error: Docker is not running" >> "$log_file"
        osascript -e 'display notification "Please start Docker Desktop first" with title "Vocals Extraction Error"'
        exit 1
    fi
    
    echo "Running Docker command" >> "$log_file"
    
    # Run demucs with preferred model
    "$DOCKER_PATH" run --rm \
        -v "$input_dir:/app/input" \
        -v "$output_dir:/app/output" \
        -v "$HOME/.cache/demucs-models:/root/.cache/torch/hub/checkpoints" \
        demucs "/app/input/$file_name" -o /app/output -n mdx_extra_q >> "$log_file" 2>&1
    
    # Path to the separated vocals stem
    local vocals_path="$output_dir/mdx_extra_q/$base_name/vocals.wav"
    
    echo "Looking for vocals at: $vocals_path" >> "$log_file"
    
    if [ ! -f "$vocals_path" ]; then
        echo "Error: Could not find separated vocals track" >> "$log_file"
        osascript -e 'display notification "Failed to extract vocals" with title "Vocals Extraction Error"'
        exit 1
    fi
    
    # Save the vocals file to the original location for later use
    local dest_dir="$(dirname "$file_path")/vocals"
    mkdir -p "$dest_dir"
    
    echo "Copying vocals to: $dest_dir/${base_name}_vocals.wav" >> "$log_file"
    cp "$vocals_path" "$dest_dir/${base_name}_vocals.wav"
    
    # Show notification and open the folder
    osascript -e "display notification \"Saved to ${dest_dir}/${base_name}_vocals.wav\" with title \"Vocals Extraction Complete\""
    open "$dest_dir"
    
    echo "Script completed successfully" >> "$log_file"
}

# Call the function with the first argument passed to the script
extract_vocals "$1"