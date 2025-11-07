#!/bin/bash
# Slide 5: Project Overview

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

# Generate slide content and pipe to center function
{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│            PROJECT ARCHITECTURE OVERVIEW              │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Component Layers                                                 \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m1. Core Configuration\033[38;5;223m \033[38;5;109m(dotfiles/, configure-local.sh)\033[38;5;223m                  │"
echo -e "    │       • Tmux config with C-s prefix                                       │"
echo -e "    │       • Bashrc with Gruvbox theme + GOVC_* variables                      │"
echo -e "    │       • Bash functions: tmux-sync-ssh, tmux-sync-ossh                     │"
echo -e "    │       • Installation script with dependencies                             │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m2. FZF Integration Layer\033[38;5;223m \033[38;5;109m(fzf-files/)\033[38;5;223m                                  │"
echo -e "    │       • Interactive menus for resources                                   │"
echo -e "    │       • Multi-select operations (Ctrl-a toggle all)                       │"
echo -e "    │       • Action wrappers for batch operations                              │"
echo -e "    │       • Consistent color scheme (Gruvbox)                                 │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m3. Session Templates\033[38;5;223m \033[38;5;109m(tmux-sessions/*.yaml)\033[38;5;223m                            │"
echo -e "    │       • Tmuxp YAML for cluster monitoring layouts                         │"
echo -e "    │       • 4-pane standard layout                                            │"
echo -e "    │       • Auto-loaded during cluster creation                               │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m4. Dynamic Status Bar\033[38;5;223m \033[38;5;109m(ocp-cluster.tmux, ocp-project.tmux)\033[38;5;223m             │"
echo -e "    │       • Context-aware cluster detection                                   │"
echo -e "    │       • Live version/user/project display                                 │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
