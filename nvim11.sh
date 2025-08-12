# Download latest Neovim tarball
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

# Extract
tar xzf nvim-linux-x86_64.tar.gz

# Move to /usr/local/nvim
sudo mv nvim-linux-x86_64 /usr/local/nvim

# Add Neovim to PATH in .zshrc
echo 'export PATH=/usr/local/nvim/bin:$PATH' >> ~/.zshrc

# Reload your zsh config
source ~/.zshrc

# Verify
nvim --version
