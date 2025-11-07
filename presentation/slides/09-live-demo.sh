#!/bin/bash
# Slide 09: LIVE DEMO

clear

echo -e "\033[38;5;223m"
cat << 'INNER'
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                                                                           │
INNER
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                   LIVE DEMO                           │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mDemo Scenarios\033[38;5;223m                                                           │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m1. Basic Tmux Navigation\033[38;5;223m                                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-t to create windows (no prefix!)                                   │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-\\ to split horizontal (no prefix!)                                 │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-Arrow to navigate panes (no prefix!)                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m S-Left/Right to switch windows                                       │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m2. FZF Pod Browser (C-s p)\033[38;5;223m                                             │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m View failing pods in red                                             │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Ctrl-l to tail logs in new window                                    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Multi-select with Ctrl-a                                             │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m3. Cluster Management (C-s m)\033[38;5;223m                                          │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m View cluster metadata                                                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Press 'k' to switch to cluster session                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Observe KUBECONFIG auto-configuration                                │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m4. Dynamic Status Bar\033[38;5;223m                                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Show cluster version/user/project                                    │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m C-s P to switch projects and observe updates                         │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Disconnect and show error states                                     │"
cat << 'INNER'
    │                                                                           │
    └───────────────────────────────────────────────────────────────────────────┘
INNER
echo -e "\033[0m"

PS1="" exec bash --norc --noprofile
