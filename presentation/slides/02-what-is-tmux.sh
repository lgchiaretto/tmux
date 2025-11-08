#!/bin/bash
# Slide 2: What is tmux?

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                   WHAT IS TMUX?                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mTerminal Multiplexer\033[38;5;223m                                                     │"
echo -e "    │    • Allows multiple terminals within a single connection                 │"
echo -e "    │    • Can be detached and reattached later                                 │"
echo -e "    │    • Split windows into multiple panes                                    │"
echo -e "    │    • Manage multiple windows in one terminal                              │"
echo -e "    │    • FZF integration for interactive resource browsing                    │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Key Capabilities                                                 \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mSession Management\033[38;5;223m                                                     │"
echo -e "    │      • Detach/reattach sessions - survive SSH disconnects                 │"
echo -e "    │      • Background processes continue running                              │"
echo -e "    │      • Named sessions for different projects                              │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mWindow Management\033[38;5;223m                                                      │"
echo -e "    │      • Multiple windows in one session (like browser tabs)                │"
echo -e "    │      • Split windows into panes (horizontal/vertical)                     │"
echo -e "    │      • Navigate between windows/panes with keybindings                    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mScriptability\033[38;5;223m                                                          │"
echo -e "    │      • Create complex layouts programmatically                            │"
echo -e "    │      • Automate terminal workflows                                        │"
echo -e "    │      • Integration with other tools (FZF, scripts, automation)            │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Why tmux for OpenShift Management?                               \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Monitor multiple clusters simultaneously                             │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Persistent sessions for long-running operations                      │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Synchronized execution across multiple nodes                         │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Organized workspace for complex operations                           │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
