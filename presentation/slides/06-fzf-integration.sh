#!/bin/bash
# Slide 06: FZF INTEGRATION

clear

echo -e "\033[38;5;223m"
cat << 'INNER'
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                                                                           │
INNER
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                 FZF INTEGRATION                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mWhat is FZF?\033[38;5;223m                                                             │"
cat << 'INNER'
    │                                                                           │
    │  FZF is an interactive command-line fuzzy finder that can filter any      │
    │  list: files, command history, processes, hostnames, bookmarks, git       │
    │  commits, and more.                                                       │
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mKey Features\033[38;5;223m                                                             │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m•\033[38;5;223m Interactive fuzzy searching - type to filter results in real-time    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Multi-select support - select multiple items with Tab                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Preview windows - see content before selecting                       │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Tmux integration - run FZF in tmux popups and panes                  │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mHow We Use It\033[38;5;223m                                                            │"
cat << 'INNER'
    │                                                                           │
    │  We integrate FZF with tmux keybindings to create interactive menus       │
    │  for OpenShift resource management. Each script creates new tmux          │
    │  windows with descriptive names like "logs:podname" or "desc:node".       │
    │                                                                           │
    │  This allows quick navigation and multi-tasking across cluster            │
    │  resources without leaving the terminal.                                  │
    │                                                                           │
    └───────────────────────────────────────────────────────────────────────────┘
INNER
echo -e "\033[0m"

PS1="" exec bash --norc --noprofile
