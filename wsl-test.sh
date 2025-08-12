#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

backup_file() {
  local file=$1
  if [ -f "$file" ]; then
    local backup_name="${file}.bak_$(date +%s)"
    cp "$file" "$backup_name"
    info "Backed up $file to $backup_name"
  fi
}

install_core_packages() {
  info "Updating Ubuntu packages..."
  sudo apt update && sudo apt upgrade -y
  info "Installing core packages..."
  sudo apt install -y python3 python3-pip python3-venv nodejs npm rustc cargo zsh neovim openssh-client htop curl wget git tmux fzf ripgrep fd-find bat autojump sudo
  # Note: 'bat' might be installed as 'batcat' in Ubuntu, autojump requires additional setup below
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh (unattended)..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    info "Oh My Zsh already installed"
  fi
}

set_zsh_default_shell() {
  local zsh_path current_shell
  zsh_path=$(which zsh)
  current_shell=$(getent passwd "$USER" | cut -d: -f7)
  if [[ "$current_shell" != "$zsh_path" ]]; then
    info "Setting Zsh as default shell..."
    chsh -s "$zsh_path"
  else
    info "Zsh is already the default shell"
  fi
}

install_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ ! -d "${zsh_custom}/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom}/plugins/zsh-autosuggestions"
  fi
  if [ ! -d "${zsh_custom}/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${zsh_custom}/plugins/zsh-syntax-highlighting"
  fi
}

configure_zshrc() {
  local zshrc="$HOME/.zshrc"
  backup_file "$zshrc"
  info "Writing new .zshrc configuration..."
  cat > "$zshrc" << 'EOF'
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
  autojump
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
alias update='sudo apt update && sudo apt upgrade -y'
alias h='htop'
alias vi='nvim'
alias c='clear'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias bat='batcat' # Ubuntu uses 'batcat' command
alias ports='ss -tuln' # netstat is deprecated, ss is recommended
alias df='df -h'
alias du='du -h --max-depth=1'

export EDITOR=nvim
export PAGER=less

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh
EOF
  info ".zshrc configured"
}

configure_ssh() {
  local ssh_dir="$HOME/.ssh"
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"
  if [ ! -f "$ssh_dir/id_rsa" ]; then
    info "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa" -N ""
  fi
  local ssh_config="$ssh_dir/config"
  if ! grep -q "ControlMaster" "$ssh_config" 2>/dev/null; then
    cat >> "$ssh_config" << EOF

Host *
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 10m
EOF
    chmod 600 "$ssh_config"
    info "Configured SSH multiplexing"
  else
    info "SSH multiplexing already configured"
  fi
}

upgrade_pip_and_install_python_pkgs() {
  info "Upgrading pip and installing Python packages..."
  python3 -m pip install --upgrade pip setuptools wheel virtualenv requests flask
}

setup_rust_toolchain() {
  info "Setting up Rust toolchain and components..."
  if command -v rustup >/dev/null 2>&1; then
    rustup default stable || true
    rustup component add clippy rustfmt || true
  else
    warn "rustup not found, skipping Rust components setup"
  fi
}

setup_neovim_plug() {
  local nvim_autoload="$HOME/.local/share/nvim/site/autoload"
  local plug_file="$nvim_autoload/plug.vim"
  if [ ! -f "$plug_file" ]; then
    info "Installing vim-plug for Neovim..."
    mkdir -p "$nvim_autoload"
    curl -fLo "$plug_file" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  local nvim_config_dir="$HOME/.config/nvim"
  local nvim_init="$nvim_config_dir/init.vim"
  if [ ! -f "$nvim_init" ]; then
    info "Creating basic Neovim config..."
    mkdir -p "$nvim_config_dir"
    cat > "$nvim_init" << EOF
call plug#begin('~/.local/share/nvim/plugged')

" Example plugins:
" Plug 'tpope/vim-sensible'

call plug#end()

syntax on
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
EOF
  else
    info "Neovim init.vim already exists, skipping"
  fi
}

setup_fastfetch_config() {
  local conf="$HOME/.config/fastfetch/config.conf"
  mkdir -p "$(dirname "$conf")"
  if [ ! -f "$conf" ]; then
    info "Creating fastfetch config..."
    cat > "$conf" << EOF
show_cpu=true
show_gpu=true
show_memory=true
show_disk=true
EOF
  else
    info "fastfetch config already exists"
  fi
}

install_xfce_vnc() {
  read -rp "Install XFCE desktop + VNC server? (y/N): " xfce_choice
  if [[ "$xfce_choice" =~ ^[Yy]$ ]]; then
    info "Installing XFCE + VNC..."
    sudo apt update
    sudo apt install -y xfce4 tigervnc-standalone-server dbus-x11

    mkdir -p "$HOME/.vnc"
    echo "wsl" | vncpasswd -f > "$HOME/.vnc/passwd"
    chmod 600 "$HOME/.vnc/passwd"

    cat > "$HOME/startxfce.sh" << 'EOL'
#!/bin/bash
export DISPLAY=:1
vncserver -kill :1 > /dev/null 2>&1 || true
vncserver :1 -geometry 1280x720 -depth 24 -localhost no
echo "VNC server started at :1"
echo "Connect your VNC client to <your-windows-ip>:5901"
echo "Default password is 'wsl' (change in ~/.vnc/passwd)"
echo "Stop the server with: vncserver -kill :1"
EOL

    chmod +x "$HOME/startxfce.sh"
    info "XFCE + VNC setup complete. Use ./startxfce.sh to start the desktop."
  else
    info "Skipping XFCE + VNC installation."
  fi
}

main() {
  install_core_packages
  install_oh_my_zsh
  set_zsh_default_shell
  install_zsh_plugins
  configure_zshrc
  configure_ssh
  upgrade_pip_and_install_python_pkgs
  setup_rust_toolchain
  setup_neovim_plug
  setup_fastfetch_config
  install_xfce_vnc

  echo ""
  info "Setup complete!"
  echo "Restart your terminal or run 'zsh' to start your new shell."
  echo "Use 'htop' to monitor system processes."
  echo "Use 'fastfetch' for quick system info."
  echo "Use 'batcat' as an enhanced 'cat' with syntax highlighting."
  echo "Neovim installed with vim-plug for plugin management."
  echo "Rust, Python, Node.js toolchains installed and ready."
  echo "If installed, start XFCE desktop with: ./startxfce.sh"
}

main "$@"
