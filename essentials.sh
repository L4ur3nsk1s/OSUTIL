#!/bin/bash

# Function to check if the script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Please run with sudo."
        exit 1
    fi
}

# Update and upgrade the system
update_system() {
    echo "Updating and upgrading the system..."
    sudo apt update && sudo apt upgrade -y
}

# Install essential packages
install_essential_packages() {
    echo "Installing essential packages..."
    sudo apt install -y git wget zsh bat eza nala gh
}

# Install development tools
install_development_tools() {
    echo "Installing development tools..."
    sudo apt install -y golang rustc nodejs npm python3 python3-pip php
}

# Install additional utilities (optional)
install_additional_utilities() {
    echo "Installing additional utilities..."
    sudo apt install -y build-essential curl
}

# Main script execution
main() {
    check_root
    update_system
    install_essential_packages
    install_development_tools
    install_additional_utilities

    echo "All installations are complete!"
}

# Run the main function
main
