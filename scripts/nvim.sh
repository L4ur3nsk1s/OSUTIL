#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install ripgrep -y
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
echo "export PATH="$PATH:/opt/nvim-linux64/bin"" >>~/.zshrc
source ~/.zshrc
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
sudo apt install ripgrep -y