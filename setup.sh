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

# GPG のインストール (mise の署名検証に必要)
echo -e "\n${YELLOW}Checking GPG...${NC}"
if command -v gpg >/dev/null 2>&1; then
    echo -e "${GREEN}✓ GPG はインストール済みです${NC}"
else
    echo -e "${YELLOW}GPG をインストールしています...${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install -y gnupg
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y gnupg2
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm gnupg
    else
        echo -e "${RED}✗ パッケージマネージャが見つかりません。手動で GPG をインストールしてください${NC}"
    fi
    echo -e "${GREEN}✓ GPG をインストールしました${NC}"
fi

# mise のインストール
echo -e "\n${YELLOW}Checking mise...${NC}"
if command -v mise >/dev/null 2>&1; then
    echo -e "${GREEN}✓ mise はインストール済みです${NC}"
else
    echo -e "${YELLOW}mise をインストールしています...${NC}"
    curl https://mise.run | sh
    # インストール先を PATH に追加（現セッション用）
    export PATH="$HOME/.local/bin:$PATH"
    echo -e "${GREEN}✓ mise をインストールしました${NC}"
fi

# WezTerm Configuration
echo -e "\n${YELLOW}Setting up WezTerm...${NC}"
create_symlink \
    "$DOTFILES_DIR/WezTerm/.wezterm.lua" \
    "$HOME_DIR/.wezterm.lua" \
    "WezTerm configuration"

# zsh 設定
echo -e "\n${YELLOW}Setting up zsh...${NC}"
create_symlink \
    "$DOTFILES_DIR/zsh/.zshrc" \
    "$HOME_DIR/.zshrc" \
    "zsh configuration"

# mise グローバル config
echo -e "\n${YELLOW}Setting up mise...${NC}"
create_symlink \
    "$DOTFILES_DIR/mise.toml" \
    "$HOME_DIR/.config/mise/config.toml" \
    "mise global config"

# ツールを一括インストール
echo -e "\n${YELLOW}Running mise install...${NC}"
mise trust "$DOTFILES_DIR/mise.toml"
mise run install
echo -e "${GREEN}✓ mise install 完了${NC}"

echo -e "\n${GREEN}✓ Dotfiles setup completed successfully!${NC}"
