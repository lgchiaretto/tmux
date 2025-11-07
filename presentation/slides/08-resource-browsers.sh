#!/bin/bash
# Slide 08: RESOURCE BROWSERS

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

# Generate slide content and pipe to center function
{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│              RESOURCE BROWSERS                        │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mTmux FZF Bindings & Actions\033[38;5;223m                                              │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mPods (C-s p):\033[38;5;223m                                                          │"
echo -e "    │      Multi-select: Ctrl-a to toggle all                                   │"
echo -e "    │      \033[38;5;214mCtrl-l: Logs     → Creates window: \"logs:podname\"\033[38;5;223m                    │"
echo -e "    │      \033[38;5;214mCtrl-d: Describe → Creates window: \"desc:podname\"\033[38;5;223m                    │"
echo -e "    │      \033[38;5;214mCtrl-e: Edit     → Creates window: \"edit:podname\"\033[38;5;223m                    │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mNodes (C-s n):\033[38;5;223m                                                         │"
echo -e "    │      \033[38;5;214mCtrl-d: Describe node\033[38;5;223m                                                │"
echo -e "    │      \033[38;5;214mCtrl-e: Edit node\033[38;5;223m                                                    │"
echo -e "    │      \033[38;5;214mCtrl-s: SSH to node (oc debug pod)\033[38;5;223m                                   │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208mOperators (C-s O):\033[38;5;223m                                                     │"
echo -e "    │      \033[38;5;214mCtrl-d: Describe cluster operator\033[38;5;223m                                    │"
echo -e "    │      \033[38;5;214mCtrl-e: Edit cluster operator\033[38;5;223m                                        │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mMulti-Host SSH Synchronization\033[38;5;223m                                           │"
echo -e "    │                                                                           │"
echo -e "    │      \033[38;5;214mtmux-sync-ssh host1 host2 host3   # 3 synchronized panes\033[38;5;223m             │"
echo -e "    │      \033[38;5;214mtmux-sync-ssh hostname 4           # 4 panes to same host\033[38;5;223m            │"
echo -e "    │      \033[38;5;214mtmux-sync-ossh master-0 master-1   # oc debug pods\033[38;5;223m                   │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
