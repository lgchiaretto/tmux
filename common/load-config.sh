#!/usr/bin/env bash
# Common configuration loader for all tmux-ocp scripts
# This script loads configuration in the following order:
# 1. User configuration: $HOME/.tmux/config.sh

# Load user configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi