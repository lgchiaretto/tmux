#!/bin/bash
# Slide 1: Introduction

clear

echo -e "\033[38;5;223m"
cat << 'INNER'
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                                                                           │
INNER
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                                                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│\033[0m                        \033[1;38;5;214mTMUX\033[0m\033[38;5;223m                           \033[38;5;214m│\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                                                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│\033[0m             \033[38;5;142mInteractive Management System\033[0m\033[38;5;223m             \033[38;5;214m│\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                                                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │                    \033[38;5;142m┌─────────────────────────────┐\033[38;5;223m                        │"
echo -e "    │                    \033[38;5;142m│\033[38;5;223m   What You'll Learn Today   \033[38;5;142m│\033[38;5;223m                        │"
echo -e "    │                    \033[38;5;142m└─────────────────────────────┘\033[38;5;223m                        │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │                    \033[38;5;208m✓\033[38;5;223m What is tmux and why use it                          │"
echo -e "    │                    \033[38;5;208m✓\033[38;5;223m Core tmux concepts and features                      │"
echo -e "    │                    \033[38;5;208m✓\033[38;5;223m FZF-powered cluster management                       │"
echo -e "    │                    \033[38;5;208m✓\033[38;5;223m OpenShift automation integration                     │"
echo -e "    │                    \033[38;5;208m✓\033[38;5;223m Real-world workflows                                 │"
echo -e "    │                    \033[38;5;208m✓\033[38;5;223m Live demonstration                                   │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │                        \033[38;5;142mLuiz Gustavo Chiaretto\033[38;5;223m                             │"
echo -e "    │                         \033[38;5;109mchiarettolabs.com.br\033[38;5;223m                              │"
cat << 'INNER'
    │                                                                           │
INNER
cat << 'INNER'
    └───────────────────────────────────────────────────────────────────────────┘
INNER
echo -e "\033[0m"

PS1="" exec bash --norc --noprofile
