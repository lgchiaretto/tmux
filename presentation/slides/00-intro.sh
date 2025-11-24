#!/bin/bash
# Slide 0: Introduction

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                                                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│\033[0m                        \033[1;38;5;214mTMUX\033[0m\033[38;5;223m                           \033[38;5;214m│\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                                                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│\033[0m              \033[38;5;142mEmpowering Your Terminal\033[0m\033[38;5;223m                 \033[38;5;214m│\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                                                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │                    \033[38;5;142m┌─────────────────────────────┐\033[38;5;223m                        │"
echo -e "    │                    \033[38;5;142m│\033[38;5;223m   What You'll Learn Today   \033[38;5;142m│\033[38;5;223m                        │"
echo -e "    │                    \033[38;5;142m└─────────────────────────────┘\033[38;5;223m                        │"
echo -e "    │                                                                           │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m Productivity                                            │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m What is tmux, why and how to use it                     │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m Core tmux concepts and features                         │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m About this project                                      │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m FZF Fuzzy Finder integration                            │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m OpenShift integration                                   │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m Live demonstration                                      │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │                    \033[38;5;142m┌─────────────────────────────┐\033[38;5;223m                        │"
echo -e "    │                    \033[38;5;142m│\033[38;5;223m   What I expect from you    \033[38;5;142m│\033[38;5;223m                        │"
echo -e "    │                    \033[38;5;142m└─────────────────────────────┘\033[38;5;223m                        │"
echo -e "    │                                                                           │"
echo -e "    │                 \033[38;5;208m✓\033[38;5;223m Open Your Mind!                                         │"
echo -e "    │                                                                           │"
echo -e "    │                       \033[38;5;142mLuiz Gustavo Chiaretto\033[38;5;223m                              │"
echo -e "    │                        \033[38;5;109mchiarettolabs.com.br\033[38;5;223m                               │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
