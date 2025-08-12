#!/usr/bin/env bash
set -euo pipefail

info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

# Install tmux
install_tmux() {
  info "Installing tmux..."
  if command -v tmux >/dev/null 2>&1; then
    info "tmux already installed"
  else
    if command -v apt >/dev/null 2>&1; then
      sudo apt update && sudo apt install -y tmux
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y tmux
    else
      error "Unsupported package manager. Please install tmux manually."
      exit 1
    fi
  fi
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm_dir" ]; then
    info "Tmux Plugin Manager already installed"
  else
    info "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

# Write basic tmux.conf with plugins and theme
write_tmux_conf() {
  local conf="$HOME/.tmux.conf"
  info "Writing basic tmux config to $conf"

  cat > "$conf" << 'EOF'
# Set prefix to Ctrl+a instead of Ctrl+b (optional)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Basic options
set -g mouse on                       # Enable mouse support (click/select/resize)
set -g history-limit 10000            # Scrollback buffer size

# Status bar style and theme
set -g status-bg colour235
set -g status-fg colour136
set -g status-left-length 40
set -g status-right-length 100
set -g status-left '#[fg=green]#H #[fg=yellow]#(whoami)'
set -g status-right '#(date +"%Y-%m-%d %H:%M") #[fg=cyan]#(uptime | cut -d "," -f 1)'

# Plugins
set -g @plugin 'tmux-plugins/tpm'                     # TPM itself
set -g @plugin 'tmux-plugins/tmux-sensible'           # Sensible defaults
set -g @plugin 'tmux-plugins/tmux-resurrect'          # Save/restore sessions
set -g @plugin 'tmux-plugins/tmux-continuum'          # Automatic restore and saving
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'   # Highlights prefix key

# Initialize TPM (keep this line at the very bottom)
run '~/.tmux/plugins/tpm/tpm'
EOF
}

# Main
main() {
  install_tmux
  install_tpm
  write_tmux_conf

  echo
  info "Installation complete!"
  info "Start tmux by running 'tmux'."
  info "To install tmux plugins, inside tmux press prefix (Ctrl+a) then press I (capital i)."
  info "For more info visit https://github.com/tmux-plugins/tpm"
}

main
