#!/data/data/com.termux/files/usr/bin/bash
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
  info "Updating Termux packages..."
  pkg update -y && pkg upgrade -y
  info "Installing core packages..."
  pkg install -y python nodejs rust neovim zsh openssh htop fastfetch bat fzf ripgrep fd tmux tig curl wget proot-distro git
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
  current_shell=$(grep "^$(whoami):" /data/data/com.termux/files/usr/etc/passwd | cut -d: -f7 || echo "")
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
alias update='pkg update && pkg upgrade -y'
alias h='htop'
alias vi='nvim'
alias c='clear'
alias venv='python -m venv .venv && source .venv/bin/activate'
alias batcat='bat' # alias batcat to bat for convenience
alias ports='netstat -tulanp'
alias df='df -h'
alias du='du -h --max-depth=1'
alias startubuntu='$HOME/bin/enter-ubuntu.sh'

export EDITOR=nvim
export PAGER=bat

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -s /data/data/com.termux/files/usr/etc/profile.d/autojump.sh ]] && source /data/data/com.termux/files/usr/etc/profile.d/autojump.sh
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
  pip install --upgrade pip setuptools wheel virtualenv requests flask
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

setup_proot_distro() {
  info "Setting up proot-distro for Ubuntu..."

  read -rp "Enter desired Ubuntu username: " ubuntu_user
  while true; do
    read -rsp "Enter password for user '$ubuntu_user': " ubuntu_pass
    echo
    read -rsp "Confirm password: " ubuntu_pass_confirm
    echo
    if [[ "$ubuntu_pass" == "$ubuntu_pass_confirm" ]]; then
      break
    else
      echo "Passwords do not match. Try again."
    fi
  done

  if proot-distro list | grep -q "^ubuntu$"; then
    info "Ubuntu distro already installed"
  else
    info "Installing Ubuntu distro..."
    proot-distro install ubuntu
  fi

  info "Configuring Ubuntu user, repo, and nala..."

  local setup_script="$HOME/.setup_ubuntu.sh"
  cat > "$setup_script" << EOF
#!/bin/bash
set -e

sed -i.bak -r 's|http://archive.ubuntu.com/ubuntu/|http://lt.archive.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

apt update

apt install -y sudo nala

nala upgrade -y

if ! id -u $ubuntu_user >/dev/null 2>&1; then
  useradd -m -s /bin/bash $ubuntu_user
  echo "$ubuntu_user:$ubuntu_pass" | chpasswd
  usermod -aG sudo $ubuntu_user
fi

echo "Ubuntu base setup done."
EOF
  chmod +x "$setup_script"

  proot-distro login ubuntu -- mkdir -p /root
  proot-distro login ubuntu -- sh -c "cat > /root/.setup_ubuntu.sh" < "$setup_script"
  proot-distro login ubuntu -- bash /root/.setup_ubuntu.sh || warn "Failed to run Ubuntu setup script inside proot"
  rm -f "$setup_script"

  read -rp "Install XFCE desktop + VNC server inside Ubuntu? (y/N): " xfce_choice
  if [[ "$xfce_choice" =~ ^[Yy]$ ]]; then
    info "Installing XFCE + VNC inside Ubuntu..."

    local xfce_script="$HOME/.setup_ubuntu_xfce.sh"
    cat > "$xfce_script" << EOF
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y xfce4 tigervnc-standalone-server dbus-x11

mkdir -p /home/$ubuntu_user/.vnc
echo "termux" | vncpasswd -f > /home/$ubuntu_user/.vnc/passwd
chmod 600 /home/$ubuntu_user/.vnc/passwd
chown -R $ubuntu_user:$ubuntu_user /home/$ubuntu_user/.vnc

cat > /home/$ubuntu_user/startxfce.sh << 'EOL'
#!/bin/bash
export DISPLAY=":1"
vncserver -kill :1 > /dev/null 2>&1 || true
vncserver :1 -geometry 1280x720 -depth 24 -localhost no
echo "VNC server started at :1"
echo "Connect your VNC client to <device-ip>:5901"
echo "Default password is 'termux' (change in ~/.vnc/passwd)"
echo "Stop the server with: vncserver -kill :1"
EOL

chown $ubuntu_user:$ubuntu_user /home/$ubuntu_user/startxfce.sh
chmod +x /home/$ubuntu_user/startxfce.sh

echo "XFCE + VNC setup inside Ubuntu complete."
EOF
    chmod +x "$xfce_script"
    proot-distro login ubuntu -- mkdir -p /root
    proot-distro login ubuntu -- sh -c "cat > /root/.setup_ubuntu_xfce.sh" < "$xfce_script"
    proot-distro login ubuntu -- bash /root/.setup_ubuntu_xfce.sh || warn "XFCE setup failed"
    rm -f "$xfce_script"
  else
    info "Skipping XFCE desktop setup inside Ubuntu."
  fi

  local ubuntu_enter_script="$HOME/bin/enter-ubuntu.sh"
  mkdir -p "$HOME/bin"
  cat > "$ubuntu_enter_script" << EOF
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu --user $ubuntu_user --shared-tmp
EOF
  chmod +x "$ubuntu_enter_script"
  info "Ubuntu entry script created: startubuntu"
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
  setup_proot_distro

  echo ""
  info "Setup complete!"
  echo "Restart Termux or run 'zsh' to start your new shell."
  echo "Use 'htop' to monitor system processes."
  echo "Use 'fastfetch' for quick system info."
  echo "Use 'bat' as an enhanced 'cat' with syntax highlighting."
  echo "Neovim installed with vim-plug for plugin management."
  echo "Rust, Python, Node.js toolchains installed and ready."
  echo "Enter Ubuntu with: startubuntu"
  echo "Inside Ubuntu, run './startxfce.sh' (if installed) to start XFCE VNC desktop."
}

main "$@"
