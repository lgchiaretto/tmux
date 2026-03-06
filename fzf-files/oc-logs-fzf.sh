#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../common" && pwd)/fzf-header.sh"

pod="$1"
project_name=$(oc project -q)
containers=$(oc get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
count=$(echo "$containers" | wc -w)

if [ "$count" -eq 1 ]; then
    tmux new-window -n "logs $pod" "bash -i -c 'history -s oc logs -n $project_name $pod ; oc logs $pod -n $project_name; exec bash'"
else
    _hdr=$(fzf_header "" \
      "[Enter]     Select container" \
      "[Tab]       Select container" \
      "[Esc]       Exit"
    )
    _cnt_data=$(echo "$containers" | tr ' ' '\n')
    _pw=$(fzf_header_popup_width "$_hdr" "$_cnt_data")
    _ph=$(fzf_header_popup_height "$_hdr" "$_cnt_data")
    container=$(echo "$_cnt_data" | fzf-tmux \
        --header="$_hdr" \
        --border-label=" $FZF_BORDER_LABEL " \
        --border-label-pos=center \
        --layout=reverse \
        -p "${_pw},${_ph}" \
        --exact \
        --bind 'tab:accept' \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 
        )
    if [ -n "$container" ]; then
        formatted_pod="${pod:0:15}..${container: -15}"
        tmux new-window -n "logs $formatted_pod" "bash -i -c 'history -s oc logs -n $project_name $pod -c $container; oc logs -n $project_name $pod -c $container; exec bash'"
    fi
fi
