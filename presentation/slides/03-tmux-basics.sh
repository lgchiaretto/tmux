#!/bin/bash
# Slide 3: Tmux Basics

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                  TMUX BASIC CONCEPTS                  │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Hierarchy: Session → Window → Pane                               \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │      \033[38;5;208mSession\033[38;5;223m (install-cluster1)                                           │"
echo -e "    │      ├── \033[38;5;208mWindow 1:\033[38;5;223m failing-pods                                           │"
echo -e "    │      │   ├── \033[38;5;109mPane 1: watch failing pods\033[38;5;223m                                   │"
echo -e "    │      │   └── \033[38;5;109mPane 2: watch cluster operators\033[38;5;223m                              │"
echo -e "    │      ├── \033[38;5;208mWindow 2:\033[38;5;223m logs:etcd-pod                                          │"
echo -e "    │      │   └── \033[38;5;109mPane 1: oc logs -f\033[38;5;223m                                           │"
echo -e "    │      └── \033[38;5;208mWindow 3:\033[38;5;223m bash                                                   │"
echo -e "    │          └── \033[38;5;109mPane 1: interactive shell\033[38;5;223m                                    │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Custom Prefix: C-s (NOT default C-b)                             \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mWindow Management:\033[38;5;223m                                                     │"
echo -e "    │      \033[38;5;214mC-t           \033[38;5;223m Create new window                                     │"
echo -e "    │      \033[38;5;214mS-Left/Right  \033[38;5;223m Navigate between windows                              │"
echo -e "    │      \033[38;5;214mC-s ,         \033[38;5;223m Rename window                                         │"
echo -e "    │      \033[38;5;214mC-S-Left/Right\033[38;5;223m Move window left/right                                │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mPane Management:\033[38;5;223m                                                       │"
echo -e "    │      \033[38;5;214mC-\           \033[38;5;223m Split horizontal                                      │"
echo -e "    │      \033[38;5;214mC-s -         \033[38;5;223m Split vertical                                        │"
echo -e "    │      \033[38;5;214mC-Arrow       \033[38;5;223m Navigate between panes                                │"
echo -e "    │      \033[38;5;214mM-S-Arrow     \033[38;5;223m Resize pane                                           │"
echo -e "    │      \033[38;5;214mC-s z         \033[38;5;223m Zoom/unzoom pane                                      │"
echo -e "    │      \033[38;5;214mC-s a         \033[38;5;223m Toggle synchronized panes                             │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mSession Management:\033[38;5;223m                                                    │"
echo -e "    │      \033[38;5;214mC-s d         \033[38;5;223m Detach session                                        │"
echo -e "    │      \033[38;5;214mtmux attach   \033[38;5;223m Reattach to session                                   │"
echo -e "    │      \033[38;5;214mtmux ls       \033[38;5;223m List sessions                                         │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
