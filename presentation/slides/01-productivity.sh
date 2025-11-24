#!/bin/bash
# Slide 1: Productivity

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                     Productivity                      │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mOur day-to-day with the terminal\033[38;5;223m                                         │"
echo -e "    │    • Do you know how much time do you spend using terminal?               │"
echo -e "    │    • Have you ever thought about the number of repetitive tasks           │"
echo -e "    │      that are executed in the terminal?                                   │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m                          Common problems                          \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mEasy Window & Pane Management\033[38;5;223m                                            │"
echo -e "    │    • Too much time to open a new terminal                                 │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mShared Bash History\033[38;5;223m                                                      │"
echo -e "    │    • Where is my command?                                                 │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mSession Persistence\033[38;5;223m                                                      │"
echo -e "    │    • The script I was executing has finished because I lost the VPN       │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
