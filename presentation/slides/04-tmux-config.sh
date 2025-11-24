#!/bin/bash
# Slide 4: Tmux Configuration

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear


{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│               CUSTOM TMUX CONFIGURATION               │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  dotfiles/tmux.conf - Key Customizations                          \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mPrefix Key:\033[38;5;223m                                                            │"
echo -e "    │      \033[38;5;214mset-option -g prefix C-s       \033[38;5;109m# Change from C-b to C-s\033[38;5;223m              │"
echo -e "    │      \033[38;5;214munbind-key C-b                 \033[38;5;109m# Remove default binding\033[38;5;223m              │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mWindow Management:\033[38;5;223m                                                     │"
echo -e "    │      \033[38;5;214mbind-key -n C-t new-window     \033[38;5;109m# Create window\033[38;5;223m                       │"
echo -e "    │      \033[38;5;214mbind-key -n S-Left/Right       \033[38;5;109m# Navigate windows\033[38;5;223m                    │"
echo -e "    │      \033[38;5;214mbind-key -n C-S-Left/Right     \033[38;5;109m# Move window position\033[38;5;223m                │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mPane Management:\033[38;5;223m                                                       │"
echo -e "    │      \033[38;5;214mbind-key -n C-\                \033[38;5;109m# Split horizontal (no prefix)\033[38;5;223m        │"
echo -e "    │      \033[38;5;214mbind-key - split-window -v     \033[38;5;109m# Split vertical (C-s)\033[38;5;223m                │"
echo -e "    │      \033[38;5;214mbind-key -n C-Arrow            \033[38;5;109m# Navigate panes (no prefix)\033[38;5;223m          │"
echo -e "    │      \033[38;5;214mbind-key a synchronize-panes   \033[38;5;109m# Sync panes (needs C-s)\033[38;5;223m              │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142m┌───────────────────────────────────────────────────────────────────┐\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m│\033[38;5;223m  Dynamic Status Bar (ocp-cluster.tmux)                            \033[38;5;142m│\033[38;5;223m    │"
echo -e "    │  \033[38;5;142m└───────────────────────────────────────────────────────────────────┘\033[38;5;223m    │"
echo -e "    │                                                                           │"
echo -e "    │    Auto-detects cluster context:                                          │"
echo -e "    │      1. Check \$CLUSTERS_BASE_PATH/\$SESSION_NAME/auth/kubeconfig                         │"
echo -e "    │      2. Fallback to 'oc whoami' for active context                        │"
echo -e "    │                                                                           │"
echo -e "    │    Display format:                                                        │"
echo -e "    │      4.19.19:(k):openshift-config                                         │"
echo -e "    │      └─ version ─┘└ user ┘└── project ──┘                                 │"
echo -e "    │                                                                           │"
echo -e "    │    Error states: N/A | <no-project> | <deleted>                           │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
