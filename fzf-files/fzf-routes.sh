#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../common" && pwd)/fzf-header.sh"


content=$(timeout 2s oc get routes -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,URL:.spec.host --no-headers | grep -v '<none>')

if [ -z "$content" ]; then
    tmux display -d 5000 'No routes found. Are you connected on any OpenShift cluster?'
    exit 0
fi

_hdr=$(fzf_header "" \
  "[Enter]     Open route on Chrome" \
  "[Tab]       Print route hostname" \
  "[Ctrl-e]    Run \"oc edit <route>\"" \
  "[Ctrl-d]    Run \"oc describe <route>\"" \
  "[Ctrl-o]    open the route on Chrome" \
  "[Esc]       Exit"
)
_pw=$(fzf_header_popup_width "$_hdr" "$content")
_ph=$(fzf_header_popup_height "$_hdr" "$content")
chosen=$(echo "$content" | fzf-tmux \
     --header="$_hdr" \
    --layout=reverse \
    --border-label=" $FZF_BORDER_LABEL " \
    --border-label-pos=center \
    -p "${_pw},${_ph}" \
    --exact \
    --with-nth=1,2,3 \
    --bind 'tab:execute-silent(
        tmux send-keys {3};
    )+abort' \
    --bind 'ctrl-e:execute-silent(
        tmux send-keys "oc edit -n {1} {2}" C-m;
    )+abort' \
    --bind 'ctrl-d:execute-silent(
        tmux send-keys "oc describe route -n {1} {2}" C-m;
    )+abort' \
    --bind 'ctrl-o:execute-silent(
         echo {3} | xargs $BROWSER &>/dev/null &
    )+abort' \
    --expect=enter \
    --color=fg:#d4be98,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
)
if [ -n "$chosen" ]; then
  $BROWSER "https://$(echo "$chosen" | tail -n1 | awk '{print $3}')" &>/dev/null &
fi
