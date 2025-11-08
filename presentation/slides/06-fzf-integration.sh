#!/bin/bash
# Slide 06: FZF INTEGRATION

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

# Generate slide content and pipe to center function
{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                 FZF INTEGRATION                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mWhat is FZF?\033[38;5;223m                                                             │"
echo -e "    │                                                                           │"
echo -e "    │  FZF is an interactive command-line fuzzy finder that can filter any      │"
echo -e "    │  list: files, command history, processes, hostnames, bookmarks, git       │"
echo -e "    │  commits, and more.                                                       │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mKey Features\033[38;5;223m                                                             │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Interactive fuzzy searching - type to filter results in real-time    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Multi-select support - select multiple items with Tab                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Preview windows - see content before selecting                       │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Tmux integration - run FZF in tmux popups and panes                  │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mHow We Use It\033[38;5;223m                                                            │"
echo -e "    │                                                                           │"
echo -e "    │  We integrate FZF with tmux keybindings to create interactive menus       │"
echo -e "    │  for OpenShift resource management. Each script creates new tmux          │"
echo -e "    │  windows with descriptive names like "logs:podname" or "desc:node".       │"
echo -e "    │                                                                           │"
echo -e "    │  This allows quick navigation and multi-tasking across cluster            │"
echo -e "    │  resources without leaving the terminal.                                  │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
