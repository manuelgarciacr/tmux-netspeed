#!/usr/bin/env bash

# Example: Print the value of a tmux option
option_value="$(tmux show-option -gqv '@netspeed-option')"
tmux display-message "My plugin option: $option_value"
