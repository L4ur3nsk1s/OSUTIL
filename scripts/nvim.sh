#!/bin/bash

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

# Update and upgrade system
update_system() {
    echo -e "${GREEN}Updating and upgrading the system...${RESET}"
    pkg update && pkg upgrade -y
}

# Install ripgrep
install_ripgrep() {
    echo -e "${GREEN}Installing ripgrep...${RESET}"
    pkg install -y ripgrep
}

# Install Neovim
install_neovim() {
    echo -e "${GREEN}Installing Neovim...${RESET}"
    pkg install -y neovim
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
    update_system
    install_ripgrep
    install_neovim
    install_nvchad
    
    echo -e "${GREEN}Installation complete! Restart your terminal or run 'exec bash' to apply changes.${RESET}"
}

# Run the main function
main