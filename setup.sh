#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to detect shell
detect_shell() {
    if [ "$SHELL" = "/bin/zsh" ]; then
        echo "zsh"
    elif [ "$SHELL" = "/bin/bash" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Function to get shell config file
get_shell_config() {
    local shell_type=$1
    if [ "$shell_type" = "zsh" ]; then
        echo "$HOME/.zshrc"
    elif [ "$shell_type" = "bash" ]; then
        echo "$HOME/.bashrc"
    else
        echo ""
    fi
}

# Main setup process
echo -e "${BLUE}Setting up Demucs Docker alias...${NC}"

# Detect shell
SHELL_TYPE=$(detect_shell)
if [ "$SHELL_TYPE" = "unknown" ]; then
    echo "Could not detect shell type. Please manually add the alias to your shell configuration file."
    exit 1
fi

# Get config file
CONFIG_FILE=$(get_shell_config "$SHELL_TYPE")
if [ -z "$CONFIG_FILE" ]; then
    echo "Could not determine shell configuration file."
    exit 1
fi

# Create the alias with path conversion
ALIAS_LINE='alias demucs='"'"'function _demucs() { docker run -v "$(pwd)":/data conradgodfrey/demucs:latest --input "/data/$1" ${2:+--output "/data/$2"}; }; _demucs'"'"

# Check if alias already exists
if grep -q "alias demucs=" "$CONFIG_FILE"; then
    echo -e "${GREEN}Demucs alias already exists in $CONFIG_FILE${NC}"
else
    # Add alias to config file
    echo -e "\n# Demucs Docker alias" >> "$CONFIG_FILE"
    echo "$ALIAS_LINE" >> "$CONFIG_FILE"
    echo -e "${GREEN}Added Demucs alias to $CONFIG_FILE${NC}"
fi

# Install completion script for zsh
if [ "$SHELL_TYPE" = "zsh" ]; then
    COMPLETION_DIR="$HOME/.zsh/completion"
    mkdir -p "$COMPLETION_DIR"
    cp "$(dirname "$0")/demucs-completion.zsh" "$COMPLETION_DIR/_demucs"
    
    # Add completion directory to fpath if not already there
    if ! grep -q "fpath=(\$HOME/.zsh/completion \$fpath)" "$CONFIG_FILE"; then
        echo -e "\n# Add completion directory to fpath" >> "$CONFIG_FILE"
        echo 'fpath=($HOME/.zsh/completion $fpath)' >> "$CONFIG_FILE"
        echo 'autoload -U compinit && compinit' >> "$CONFIG_FILE"
    fi
    echo -e "${GREEN}Installed zsh completion script${NC}"
fi

# Make the script executable
chmod +x "$(dirname "$0")/entrypoint.sh"

echo -e "\n${BLUE}Setup complete!${NC}"
echo -e "To use Demucs, either:"
echo -e "1. Restart your terminal, or"
echo -e "2. Run: source $CONFIG_FILE"
echo -e "\nUsage examples:"
echo -e "  demucs your-song.mp3                    # Output will be in 'your-song - split' folder"
echo -e "  demucs your-song.mp3 output-folder      # Output will be in 'output-folder'" 