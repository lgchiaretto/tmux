#!/bin/bash
# Slide 10: CONCLUSION

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                   CONCLUSION                          │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mWhat We Covered\033[38;5;223m                                                          │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Tmux fundamentals and custom configuration                           │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m FZF integration for interactive resource browsing                    │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m OpenShift integration                                                │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Dynamic status bar with context awareness                            │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mGetting Started\033[38;5;223m                                                          │"
echo -e "    │                                                                           │"
echo -e "    │  1. Clone repository: git clone https://github.com/lgchiaretto/tmux.git   │"
echo -e "    │  2. Explore the configuration files                                       │"
echo -e "    │  3. Run: ./configure-local.sh                                             │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
