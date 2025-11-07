#!/bin/bash
# Slide 07: BASH CUSTOMIZATION

clear

echo -e "\033[38;5;223m"
cat << 'INNER'
    ┌───────────────────────────────────────────────────────────────────────────┐
    │                                                                           │
INNER
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│              BASH CUSTOMIZATION                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mCustom Prompt (Gruvbox Theme)\033[38;5;223m                                            │"
cat << 'INNER'
    │                                                                           │
    │  PS1 with color-coded elements: user@host:path (git-branch)$              │
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m•\033[38;5;223m User in green (#142)                                                 │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Host in orange (#214)                                                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Path in blue (#109)                                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Git branch in purple (#175)                                          │"
cat << 'INNER'
    │                                                                           │
    │                                                                           │
INNER
echo -e "    │  \033[38;5;142mEnvironment Variables\033[38;5;223m                                                    │"
cat << 'INNER'
    │                                                                           │
INNER
echo -e "    │    \033[38;5;208m•\033[38;5;223m GOVC_* variables for VMware automation                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m KUBECONFIG auto-detection from tmux session context                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m FZF_DEFAULT_OPTS with Gruvbox color scheme                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Unlimited history (HISTSIZE & HISTFILESIZE empty)                    │"
cat << 'INNER'
    │                                                                           │
INNER
cat << 'INNER'
    │                                                                           │
    └───────────────────────────────────────────────────────────────────────────┘
INNER
echo -e "\033[0m"

PS1="" exec bash --norc --noprofile
