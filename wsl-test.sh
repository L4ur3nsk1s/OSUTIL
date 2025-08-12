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
  sudo apt install -y \
    python3 python3-pip python3-venv \
    nodejs npm \
    rustc cargo \
    zsh neovim \
    openssh-client \
    htop curl wget git tmux \
    fzf ripgrep fd-find bat autojump \
   unzip
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh (unattended)..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "${zsh_custom}/plugins/zsh-autosuggestions"
  fi
  if [ ! -d "${zsh_custom}/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "${zsh_custom}/plugins/zsh-syntax-highlighting"
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
alias bat='batcat'
alias ports='ss -tuln'
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
  python3 -m pip install --upgrade pip setuptools wheel virtualenv \
    requests flask black isort
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

setup_neovim_nvchad() {
  info "Installing NvChad Starter config for Neovim..."

  if [ -d "$HOME/.config/nvim" ]; then
    local backup_dir="$HOME/.config/nvim.bak_$(date +%s)"
    mv "$HOME/.config/nvim" "$backup_dir"
    info "Existing Neovim config backed up to $backup_dir"
  fi

  git clone https://github.com/NvChad/starter "$HOME/.config/nvim" --depth 1
  info "NvChad Starter installed! Launching Neovim to finalize setup..."
  nvim
}

setup_fastfetch() {
  local api_url="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"
  local version
  version=$(curl -fsSL "$api_url" | grep -Po '"tag_name": "\K.*?(?=")')
  
  if [[ -z "$version" ]]; then
    error "Could not retrieve the latest Fastfetch version."
    return 1
  fi

  info "Latest fastfetch version: $version"

  local arch
  case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64|arm64) arch="aarch64" ;;
    armv7l) arch="armv7l" ;;
    *) 
      error "Unsupported architecture: $(uname -m)"
      return 1
      ;;
  esac

  local url="https://github.com/fastfetch-cli/fastfetch/releases/download/${version}/fastfetch-linux-${arch}.deb"
  local tmp="/tmp/fastfetch.deb"

  info "Downloading Fastfetch ${version} for ${arch}..."
  if ! curl -fsSL "$url" -o "$tmp"; then
    error "Download failed: $url"
    return 1
  fi

  info "Installing fastfetch..."
  sudo dpkg -i "$tmp" || sudo apt -f install -y

  setup_fastfetch_config
}

setup_fastfetch_config() {
  local conf="$HOME/.config/fastfetch/config.conf"
  mkdir -p "$(dirname "$conf")"
  if [ ! -f "$conf" ]; then
    info "Creating fastfetch config..."
    cat > "$conf" << 'EOF'
show_cpu=true
show_gpu=true
show_memory=true
show_disk=true
EOF
  else
    info "fastfetch config already exists"
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
  setup_neovim_nvchad
  setup_fastfetch

  echo ""
  info "Setup complete!"
  echo "Restart your terminal or run 'zsh' to start your new shell."
  echo "Neovim now uses NvChad Starter — open it and wait for plugin installation."
}
main "$@"

