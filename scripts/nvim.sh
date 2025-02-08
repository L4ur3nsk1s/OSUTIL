#!/bin/bash

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}This script must be run as root. Please run with sudo.${RESET}"
        exit 1
    fi
}

# Update and upgrade system
update_system() {
    echo -e "${GREEN}Updating and upgrading the system...${RESET}"
    apt update && apt upgrade -y
}

# Install ripgrep
install_ripgrep() {
    echo -e "${GREEN}Installing ripgrep...${RESET}"
    apt install -y ripgrep
}

# Install Neovim
install_neovim() {
    echo -e "${GREEN}Installing Neovim...${RESET}"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    rm -rf /opt/nvim
    tar -C /opt -xzf nvim-linux64.tar.gz
    rm nvim-linux64.tar.gz
    echo 'export PATH="$PATH:/opt/nvim/bin"' >> ~/.zshrc
}

# Install NvChad Starter
install_nvchad() {
    echo -e "${GREEN}Installing NvChad Starter...${RESET}"
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        echo -e "${YELLOW}Existing Neovim configuration found. Backing up to ~/.config/nvim_backup${RESET}"
        mv "$NVIM_CONFIG_DIR" "$HOME/.config/nvim_backup"
    fi

    git clone --depth=1 https://github.com/NvChad/starter "$NVIM_CONFIG_DIR"
}

# Main script execution
main() {
    check_root
    update_system
    install_ripgrep
    install_neovim
    install_nvchad

    echo -e "${GREEN}Installation complete! Restart your terminal or run 'exec zsh' to apply changes.${RESET}"
}

# Run the main function
main
