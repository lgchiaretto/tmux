#!/bin/bash
# Slide 09: LIVE DEMO

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

# Generate slide content and pipe to center function
{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                   LIVE DEMO                           │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mDemo Scenarios\033[38;5;223m                                                           │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m1. Basic Tmux Navigation\033[38;5;223m                                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-t to create windows (no prefix!)                                   │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-\\ to split horizontal (no prefix!)                                 │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-Arrow to navigate panes (no prefix!)                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m S-Left/Right to switch windows                                       │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m2. FZF Pod Browser (C-s p)\033[38;5;223m                                             │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m View failing pods in red                                             │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Ctrl-l to tail logs in new window                                    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Multi-select with Ctrl-a                                             │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m3. Cluster Management (C-s m)\033[38;5;223m                                          │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m View cluster metadata                                                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Press 'k' to switch to cluster session                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Observe KUBECONFIG auto-configuration                                │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m4. Dynamic Status Bar\033[38;5;223m                                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Show cluster version/user/project                                    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s P to switch projects and observe updates                         │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Disconnect and show error states                                     │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
