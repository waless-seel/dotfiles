#!/bin/bash

# Dotfiles Setup Script
# This script creates symbolic links for dotfiles configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo -e "${YELLOW}Starting dotfiles setup...${NC}"

# Function to create symlink
create_symlink() {
    local src="$1"
    local dest="$2"
    local name="$3"

    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"

    # Remove existing symlink or file
    if [ -L "$dest" ] || [ -e "$dest" ]; then
        echo -e "${YELLOW}Removing existing $name...${NC}"
        rm -f "$dest"
    fi

    # Create symlink
    ln -s "$src" "$dest"
    echo -e "${GREEN}✓ Created symlink for $name${NC}"
}

# WezTerm Configuration
echo -e "\n${YELLOW}Setting up WezTerm...${NC}"
create_symlink \
    "$DOTFILES_DIR/WezTerm/.wezterm.lua" \
    "$HOME_DIR/.wezterm.lua" \
    "WezTerm configuration"

echo -e "\n${GREEN}✓ Dotfiles setup completed successfully!${NC}"
