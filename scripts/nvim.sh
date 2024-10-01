#!/bin/bash
apt update && sudo apt upgrade -y
apt install ripgrep -y
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
rm -rf /opt/nvim
tar -C /opt -xzf nvim-linux64.tar.gz
echo "export PATH="$PATH:/opt/nvim-linux64/bin"" >>~/.zshrc
source ~/.zshrc
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
