#!/bin/bash

# Update and install basic packages
pkg update && pkg upgrade -y
pkg install -y zsh git neovim neofetch curl wget

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Change default shell to zsh
chsh -s zsh

# Install some useful zsh plugins via omz
# You can add plugins like zsh-users/zsh-autosuggestions, zsh-users/zsh-syntax-highlighting
sed -i '/^plugins=(/a plugins+=(git zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc

# Install additional tools for a better experience
pkg install -y htop python git clang

# Clean up
pkg clean

# Install neofetch and run it
neofetch

# Print message for reboot
echo "Setup complete! Restart your Termux session to use Zsh as your default shell."
