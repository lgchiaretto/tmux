#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../common" && pwd)/fzf-header.sh"

project_name=$(timeout 0.2 oc project -q)

if [ -z "$project_name" ] && [ $? -eq 0 ]; then
  tmux display -d 5000 'No resource found'
  exit 0
elif [ -z "$project_name" ] && [ $? -eq 1 ]; then
  tmux display -d 5000 'No resource found. Are you connected on any OpenShift cluster?'
  exit 0
fi

_hdr=$(fzf_header "" \
  "[Enter]     Print API resource name" \
  "[Tab]       Print API resource name" \
  "[Esc]       Exit"
)
_api_data=$(oc api-resources --cached=true | tail -n +2)
_pw=$(fzf_header_popup_width "$_hdr" "$_api_data")
_ph=$(fzf_header_popup_height "$_hdr" "$_api_data")
action=$(echo "$_api_data" | 
    fzf-tmux \
    --header="$_hdr" \
    --exact \
    --layout=reverse \
    --border-label=" $FZF_BORDER_LABEL " \
    --border-label-pos=center \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
    -p "${_pw},${_ph}" \
    --bind 'tab:accept' | awk '{print $1}'
)

tmux send-keys "$action"
