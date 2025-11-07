#!/bin/bash
# Slide 2: What is tmux?

clear

echo -e "\033[38;5;223m"
cat << 'INNER'
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                                                                           │
INNER
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                   WHAT IS TMUX?                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mTerminal Multiplexer\033[38;5;223m                                                     │"
cat << 'INNER'
    │    • Allows multiple terminals within a single connection                 │
    │    • Can be detached and reattached later                                 │
    │    • Split windows into multiple panes                                    │
    │    • Manage multiple windows in one terminal                              │
    │    • FZF integration for interactive resource browsing                    │
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Key Capabilities                                                 \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208mSession Management\033[38;5;223m                                                     │"
cat << 'INNER'
    │      • Detach/reattach sessions - survive SSH disconnects                 │
    │      • Background processes continue running                              │
    │      • Named sessions for different projects                              │
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208mWindow Management\033[38;5;223m                                                      │"
cat << 'INNER'
    │      • Multiple windows in one session (like browser tabs)                │
    │      • Split windows into panes (horizontal/vertical)                     │
    │      • Navigate between windows/panes with keybindings                    │
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208mScriptability\033[38;5;223m                                                          │"
cat << 'INNER'
    │      • Create complex layouts programmatically                            │
    │      • Automate terminal workflows                                        │
    │      • Integration with other tools (FZF, scripts, automation)            │
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Why tmux for OpenShift Management?                               \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Monitor multiple clusters simultaneously                             │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Persistent sessions for long-running operations                      │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Synchronized execution across multiple nodes                         │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Organized workspace for complex operations                           │"
cat << 'INNER'
    │                                                                           │
    └───────────────────────────────────────────────────────────────────────────┘
INNER
echo -e "\033[0m"

PS1="" exec bash --norc --noprofile
