#!/usr/bin/env bash
set -e

packages=(
    "@github/copilot"
)

for package in "${packages[@]}"; do
    echo "Installing $package..."
    npm install -g "$package"
done
