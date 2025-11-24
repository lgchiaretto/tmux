#!/usr/bin/env bash
# Common configuration loader for all tmux-ocp scripts
# This script loads configuration in the following order:
# 1. Global configuration: /etc/tmux-ocp/config.sh
# 2. User override (optional): $HOME/.tmux/config.sh
# 3. Development override (optional): $HOME/git/tmux/config.sh

# Load global configuration first
if [ -f "/etc/tmux-ocp/config.sh" ]; then
    source "/etc/tmux-ocp/config.sh"
fi

# Allow user-specific overrides
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi

# Allow development overrides (for developers working on the project)
if [ -f "$HOME/git/tmux/config.sh" ]; then
    source "$HOME/git/tmux/config.sh"
fi
