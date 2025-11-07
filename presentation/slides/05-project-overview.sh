#!/bin/bash
# Slide 5: Project Overview

clear

echo -e "\033[38;5;223m"
cat << 'INNER'
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                                                                           │
INNER
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│            PROJECT ARCHITECTURE OVERVIEW              │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Component Layers                                                 \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m1. Core Configuration\033[38;5;223m \033[38;5;109m(dotfiles/, configure-local.sh)\033[38;5;223m                  │"
cat << 'INNER'
    │       • Tmux config with C-s prefix                                       │
    │       • Bashrc with Gruvbox theme + GOVC_* variables                      │
    │       • Bash functions: tmux-sync-ssh, tmux-sync-ossh                     │
    │       • Installation script with dependencies                             │
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m2. FZF Integration Layer\033[38;5;223m \033[38;5;109m(fzf-files/)\033[38;5;223m                                  │"
cat << 'INNER'
    │       • Interactive menus for resources                                   │
    │       • Multi-select operations (Ctrl-a toggle all)                       │
    │       • Action wrappers for batch operations                              │
    │       • Consistent color scheme (Gruvbox)                                 │
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m3. Session Templates\033[38;5;223m \033[38;5;109m(tmux-sessions/*.yaml)\033[38;5;223m                            │"
cat << 'INNER'
    │       • Tmuxp YAML for cluster monitoring layouts                         │
    │       • 4-pane standard layout                                            │
    │       • Auto-loaded during cluster creation                               │
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m4. Dynamic Status Bar\033[38;5;223m \033[38;5;109m(ocp-cluster.tmux, ocp-project.tmux)\033[38;5;223m             │"
cat << 'INNER'
    │       • Context-aware cluster detection                                   │
    │       • Live version/user/project display                                 │
    │                                                                           │
    └───────────────────────────────────────────────────────────────────────────┘
INNER
echo -e "\033[0m"

PS1="" exec bash --norc --noprofile
