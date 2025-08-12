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
set -g status-interval 5                      # Refresh every 5 seconds

set -g status-left-length 60
set -g status-right-length 150

# Status left: hostname and user with colors
set -g status-left '#[fg=green,bold]#H #[fg=yellow]#(whoami) '

# Status right: date/time, battery, CPU load, network, git branch
set -g status-right '#[fg=cyan]#(date +"%Y-%m-%d %H:%M") ' \
                    '#[fg=colour39]#{battery_percentage}%% #[fg=colour241]⚡ ' \
                    '#[fg=colour45]#(uptime | cut -d "," -f 1) ' \
                    '#[fg=colour208]#(if [ -d .git ]; then git branch --show-current 2>/dev/null; fi) ' \
                    '#[fg=colour39]#(ifconfig $(ip route get 8.8.8.8 | awk '\''NR==1{print $5}'\'') 2>/dev/null | grep "inet " | awk '\''{print $2}'\'') '

# Plugins
set -g @plugin 'tmux-plugins/tpm'                     # TPM itself
set -g @plugin 'tmux-plugins/tmux-sensible'           # Sensible defaults
set -g @plugin 'tmux-plugins/tmux-resurrect'          # Save/restore sessions
set -g @plugin 'tmux-plugins/tmux-continuum'          # Automatic restore and saving
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'   # Highlights prefix key

# Additional useful plugins:
set -g @plugin 'tmux-plugins/tmux-copycat'            # Enhanced searching
set -g @plugin 'tmux-plugins/tmux-yank'               # Clipboard integration
set -g @plugin 'tmux-plugins/tmux-open'               # Open highlighted URLs/files
set -g @plugin 'tmux-plugins/tmux-cpu'                # Show CPU load in status bar

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
