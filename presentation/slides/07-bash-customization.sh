#!/bin/bash
# Slide 07: BASH CUSTOMIZATION

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

# Generate slide content and pipe to center function
{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│              BASH CUSTOMIZATION                       │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mCustom Prompt (Gruvbox Theme)\033[38;5;223m                                            │"
echo -e "    │                                                                           │"
echo -e "    │  PS1 with color-coded elements: user@host:path (git-branch)$              │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m User in green (#142)                                                 │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Host in orange (#214)                                                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Path in blue (#109)                                                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Git branch in purple (#175)                                          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mEnvironment Variables\033[38;5;223m                                                    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m GOVC_* variables for VMware automation                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m KUBECONFIG auto-detection from tmux session context                  │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m FZF_DEFAULT_OPTS with Gruvbox color scheme                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Unlimited history (HISTSIZE & HISTFILESIZE empty)                    │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
