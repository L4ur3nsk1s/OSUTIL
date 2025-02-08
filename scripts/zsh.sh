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

# Install Zsh & Oh My Zsh
install_zsh() {
    echo -e "${GREEN}Installing Zsh and Oh My Zsh...${RESET}"
    apt install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# Install plugins and Powerlevel10k
install_plugins() {
    echo -e "${GREEN}Installing Oh My Zsh plugins and Powerlevel10k...${RESET}"
    
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

    # Update .zshrc
    echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> ~/.zshrc
    echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc
    echo "alias zshconfig=\"nvim ~/.zshrc\"" >> ~/.zshrc
    echo "alias ohmyzsh=\"nvim ~/.oh-my-zsh\"" >> ~/.zshrc
}

# Main script execution
main() {
    check_root
    update_system
    install_zsh
    install_plugins

    echo -e "${GREEN}Installation complete! Restart your terminal or run 'exec zsh' to apply changes.${RESET}"
}

# Run the main function
main
