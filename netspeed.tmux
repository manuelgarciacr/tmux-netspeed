#!/usr/bin/env bash

# Set a default option (if not set by user)
tmux set -g @netspeed-option 'default_value'

# Bind a key example
tmux bind-key m run-shell '~/.tmux/plugins/tmux-netspeed/scripts/netspeed.sh'