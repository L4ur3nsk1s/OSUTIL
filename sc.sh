#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "Updating packages..."
pkg update -y && pkg upgrade -y

echo "Installing core packages..."
pkg install -y python nodejs rust neovim zsh openssh htop fastfetch bat fzf ripgrep fd tmux tig curl wget proot-distro git

echo "Installing Oh My Zsh..."
# Install Oh My Zsh unattended if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Setting zsh as default shell..."
ZSH_PATH=$(which zsh)
CURRENT_SHELL=$(grep "^$(whoami):" /data/data/com.termux/files/usr/etc/passwd | cut -d: -f7 || echo "")
if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
  chsh -s "$ZSH_PATH"
fi

echo "Installing Oh My Zsh plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

echo "Configuring .zshrc..."

ZSHRC="$HOME/.zshrc"

# Backup old .zshrc if exists
if [ -f "$ZSHRC" ]; then
  cp "$ZSHRC" "$ZSHRC.bak_$(date +%s)"
fi

cat > "$ZSHRC" << 'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  npm
  node
  rust
  tmux
  fzf
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias ..='cd ..'
alias ...='cd ../..'
alias update='pkg update && pkg upgrade -y'
alias h='htop'
alias vi='nvim'
alias c='clear'
alias venv='python -m venv .venv && source .venv/bin/activate'
alias batcat='bat' # alias batcat to bat for convenience
alias ports='netstat -tulanp'

# Environment variables
export EDITOR=nvim
export PAGER=bat

# Enable fzf key bindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load autosuggestions and syntax highlighting (sometimes needed explicitly)
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/pluginsSetting up Node.js global packages...
npm error Can't install npm globally as it will very likely break installation of global packages using npm. See https://github.com/termux/termux-packages/issues/13293
npm error A complete log of this run can be found in: /data/data/com.termux/files/home/.npm/_logs/2025-08-12T19_47_20_520Z-debug-0.log
➜  ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

echo "Configuring SSH..."
SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
if [ ! -f "$SSH_DIR/id_rsa" ]; then
  echo "Generating SSH key pair..."
  ssh-keygen -t rsa -b 4096 -f "$SSH_DIR/id_rsa" -N ""
fi

SSH_CONFIG="$SSH_DIR/config"
if ! grep -q "ControlMaster" "$SSH_CONFIG" 2>/dev/null; then
  cat >> "$SSH_CONFIG" << EOF

Host *
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 10m
EOF
  chmod 600 "$SSH_CONFIG"
fi

echo "Upgrading pip and installing Python packages..."
pip install --upgrade pip setuptools wheel virtualenv requests flask

echo "Setting up Rust toolchain and components..."
rustup default stable || true
rustup component add clippy rustfmt || true

echo "Setting up Neovim plugins manager (vim-plug)..."
NVIM_AUTOLOAD="$HOME/.local/share/nvim/site/autoload"
NVIM_AUTOLOAD_FILE="$NVIM_AUTOLOAD/plug.vim"
if [ ! -f "$NVIM_AUTOLOAD_FILE" ]; then
  mkdir -p "$NVIM_AUTOLOAD"
  curl -fLo "$NVIM_AUTOLOAD_FILE" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_INIT="$NVIM_CONFIG_DIR/init.vim"
if [ ! -f "$NVIM_INIT" ]; then
  mkdir -p "$NVIM_CONFIG_DIR"
  cat > "$NVIM_INIT" << EOF
call plug#begin('~/.local/share/nvim/plugged')

" Add plugins here, for example:
" Plug 'tpope/vim-sensible'

call plug#end()

syntax on
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
EOF
fi

echo "Setting up fastfetch config..."
FASTFETCH_CONF="$HOME/.config/fastfetch/config.conf"
mkdir -p "$(dirname "$FASTFETCH_CONF")"
if [ ! -f "$FASTFETCH_CONF" ]; then
  cat > "$FASTFETCH_CONF" << EOF
show_cpu=true
show_gpu=true
show_memory=true
show_disk=true
EOF
fi

echo ""
echo "Setup complete! Restart Termux or start zsh by typing 'zsh'."
echo "Use 'htop' to monitor system processes."
echo "Use 'fastfetch' for system info."
echo "Use 'bat' as an enhanced cat command with syntax highlighting."
echo "Neovim installed with vim-plug for easy plugin management."
echo "Rust, Python, Node.js toolchains are installed and ready."
