#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi

error_exit() {
    echo -e "ERROR: $1" >&2
    exit 1
}

clustername=$1

tmuxpfile=$(echo -e "$CLUSTERS_BASE_PATH/$clustername/create-tmuxp.yaml\n$CLUSTERS_BASE_PATH/$clustername/upgrade-tmuxp.yaml" | fzf-tmux \
  --layout=reverse -p "55%,50%" \
  --no-input \
  --header=$'┌────────────────────────────────────────────────── Help ───────────────────────────────────────────────────┐
│                                                                                                           │
│  [Enter]     Open tmuxp sessions file                                                                     │
│  [Esc]       Exit                                                                                         │
│                                                                                                           │
└───────────────────────────────────────────────────────────────────────────────────────────────────────────┘\n\n' \
  --height=40% --border \
  --border-label=" $FZF_BORDER_LABEL " \
  --border-label-pos=center \
  --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
  --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
  )

if [ -z "$tmuxpfile" ]; then
  exit 0
fi

case "$tmuxpfile" in
  "$CLUSTERS_BASE_PATH/$clustername/create-tmuxp.yaml")
    tmuxp load $CLUSTERS_BASE_PATH/$clustername/create-tmuxp.yaml -y
    ;;
  "$CLUSTERS_BASE_PATH/$clustername/upgrade-tmuxp.yaml")
    connected_cluster=$(oc whoami --show-server | awk -F'.' '{print $2}')
    [ "$connected_cluster" != "$clustername" ] && error_exit "The connected cluster '$connected_cluster' does not match the selected cluster '$clustername'"

    tmuxp load $CLUSTERS_BASE_PATH/$clustername/upgrade-tmuxp.yaml -y
    ;;
esac