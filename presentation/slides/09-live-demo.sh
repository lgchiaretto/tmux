#!/bin/bash
# Slide 09: LIVE DEMO

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                      LIVE DEMO                        │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mDemo Scenarios\033[38;5;223m                                                           │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m1. Basic Tmux Navigation\033[38;5;223m                                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s N to create session                                              │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-t to create windows                                                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-\\ to split horizontal                                              │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-Arrow to navigate panes                                            │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m S-Left/Right to switch windows                                       │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m2. Advanced Navigation\033[38;5;223m                                                 │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s w - Interactive window selector                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s s - Interactive session browser                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s f - Find window by name                                          │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s z - Zoom/unzoom current pane                                     │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m3. FZF Pod Browser\033[38;5;223m                                                     │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s p Manage pods                                                    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s n Manage nodes                                                   │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s r Manage routes                                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Ctrl-l to tail logs in new window                                    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m4. Dynamic Status Bar\033[38;5;223m                                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Show cluster version/user/project                                    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s P to switch projects and observe updates                         │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
