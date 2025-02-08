#!/bin/bash

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to check if the script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${YELLOW}This script must be run as root. Please run with sudo.${RESET}"
        exit 1
    fi
}

# Update and upgrade the system
update_system() {
    echo -e "${GREEN}Updating and upgrading the system...${RESET}"
    apt update && apt upgrade -y
}

# Install essential packages
install_essential_packages() {
    echo -e "${GREEN}Installing essential packages...${RESET}"
    apt install -y git wget zsh bat eza nala gh
}

# Install development tools
install_development_tools() {
    echo -e "${GREEN}Installing development tools...${RESET}"
    apt install -y golang rustc nodejs npm python3 python3-pip php
}

# Install additional utilities (optional)
install_additional_utilities() {
    echo -e "${GREEN}Installing additional utilities...${RESET}"
    apt install -y build-essential curl
}

# Main script execution
main() {
    check_root
    update_system

    read -p "Do you want to install essential packages? (yes/no): " install_essentials
    [[ $install_essentials == "yes" ]] && install_essential_packages

    read -p "Do you want to install development tools? (yes/no): " install_dev_tools
    [[ $install_dev_tools == "yes" ]] && install_development_tools

    read -p "Do you want to install additional utilities? (yes/no): " install_additional_utils
    [[ $install_additional_utils == "yes" ]] && install_additional_utilities

    echo -e "${GREEN}All installations are complete!${RESET}"
}

# Run the main function
main
