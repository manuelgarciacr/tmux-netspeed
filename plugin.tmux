#!/usr/bin/env bash

# Set a default option (if not set by user)
# tmux set -g @netspeed 'waiting...'

# Bind a key for killing executing procs
#mux bind-key -n C-n run-shell "bash ~/.tmux/plugins/tmux-netspeed/scripts/kill.sh"

# Remove executions of netspeed.sh
# tmux run-shell "sh ~/.tmux/plugins/tmux-netspeed/scripts/kill.sh"

# Executes netspeed.sh in background
# tmux run-shell -b "nohup ~/.tmux/plugins/tmux-netspeed/scripts/netspeed.sh &"
# set-hook -g status-line 'run-shell "~/.tmux/plugins/tmux-netspeed/scripts/netspeed.sh"'
set-hook client-attached "display-message 'Netspeed plugin loaded OK on client attach'"