#!/bin/bash

# Update and upgrade packages
pkg update -y && pkg upgrade -y

# Install tmux
pkg install tmux -y

# Create a basic tmux configuration file
TMUX_CONF="$HOME/.tmux.conf"

cat > "$TMUX_CONF" <<EOL
# Enable mouse support
set -g mouse on

# Set the prefix to Ctrl-a (like screen)
unbind C-b
set-option -g prefix C-a
bind C-a send-prefix

# Set the base index for windows and panes to 1 instead of 0
set -g base-index 1
setw -g pane-base-index 1

# Reload the config file with r
bind r source-file ~/.tmux.conf \; display "Reloaded ~/.tmux.conf"

# Split panes using | and -
bind | split-window -h
bind - split-window -v

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable vi mode for copy mode
setw -g mode-keys vi

# Set the default terminal mode to 256 colors
set -g default-terminal "screen-256color"

# Increase scrollback buffer size
set -g history-limit 10000

# Automatically renumber windows when a window is closed
set -g renumber-windows on

# DESIGN TWEAKS

# Disable visual notifications for activity, bells, and silence
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

# Clock mode
setw -g clock-mode-colour yellow

# Copy mode style
setw -g mode-style 'fg=black bg=red bold'

# Pane borders
set -g pane-border-style 'fg=red'
set -g pane-active-border-style 'fg=yellow'

# Status bar
set -g status-position bottom
set -g status-justify left
set -g status-style 'fg=red'

# Left status
set -g status-left ''
set -g status-left-length 10

# Right status
set -g status-right-style 'fg=black bg=yellow'
set -g status-right '%Y-%m-%d %H:%M '
set -g status-right-length 50

# Window status
setw -g window-status-current-style 'fg=black bg=red'
setw -g window-status-current-format ' #I #W #F '

setw -g window-status-style 'fg=red bg=black'
setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '

setw -g window-status-bell-style 'fg=yellow bg=red bold'

# Message style
set -g message-style 'fg=yellow bg=red bold'
EOL

# Print success message
echo "tmux has been installed and configured successfully!"
echo "You can start tmux by typing 'tmux' in your terminal."

# Print keybinds
echo -e "\n\033[1;32mEssential tmux keybinds:\033[0m"
cat <<EOL
Prefix key: Ctrl-a (instead of the default Ctrl-b)

- Split pane horizontally: Prefix + |
- Split pane vertically: Prefix + -
- Switch panes: Alt + Arrow keys (no prefix needed)
- Move between panes: Prefix + Arrow keys
- Close pane: Ctrl-d or type 'exit'
- Reload config: Prefix + r
- Enter copy mode: Prefix + [
- Paste from copy mode: Prefix + ]
- Detach from session: Prefix + d
- List sessions: tmux ls
- Attach to last session: tmux attach
- Rename window: Prefix + ,
- New window: Prefix + c
- Next window: Prefix + n
- Previous window: Prefix + p
- Kill window: Prefix + &
- Scroll with mouse: Enabled by default
EOL

echo -e "\nFor more details, check the tmux manual: \033[1;34mman tmux\033[0m"
