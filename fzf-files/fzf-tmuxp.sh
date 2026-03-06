#!/bin/bash

# Load configuration (global first, then user override)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$SCRIPT_DIR/../common/fzf-header.sh"

error_exit() {
    echo -e "ERROR: $1" >&2
    exit 1
}

clustername=$1

_hdr=$(fzf_header "" \
  "[Enter]     Open tmuxp sessions file" \
  "[Esc]       Exit"
)
_tmuxp_data="$CLUSTERS_BASE_PATH/$clustername/create-tmuxp.yaml
$CLUSTERS_BASE_PATH/$clustername/upgrade-tmuxp.yaml"
_pw=$(fzf_header_popup_width "$_hdr" "$_tmuxp_data")
_ph=$(fzf_header_popup_height "$_hdr" "$_tmuxp_data")
tmuxpfile=$(echo -e "$_tmuxp_data" | fzf-tmux \
  --layout=reverse -p "${_pw},${_ph}" \
  --no-input \
  --header="$_hdr" \
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