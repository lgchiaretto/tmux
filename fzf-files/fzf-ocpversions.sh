#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../common" && pwd)/fzf-header.sh"

CACHE_FILE="/opt/.ocp_versions_cache"

if [ -f "$CACHE_FILE" ]; then
    _hdr=$(fzf_header "" \
      "[r]       Release notes" \
      "[d]       Documentation" \
      "[m]       Mirror to quay.chiaret.to" \
      "[Enter]   Print release name" \
      "[Esc]     Exit" \
      "" \
      "Version             Release Date"
    )
    _pw=$(fzf_header_popup_width "$_hdr")
    _ver_data=$(cat "$CACHE_FILE")
    [[ -z "$_ver_data" ]] && exit 0
    _ph=$(fzf_header_popup_height "$_hdr" "$_ver_data")
    selected_version=$(echo "$_ver_data" | fzf-tmux \
                       --header="$_hdr" \
                       --layout=reverse \
                       --border-label=" $FZF_BORDER_LABEL " \
                       --border-label-pos=center \
                       -p "${_pw},${_ph}" \
                       --with-nth=1,2,3,4,5,6,7,8 \
                       --bind "r:execute-silent(/usr/local/bin/ocpreleasenotes {1})" \
                       --bind "d:execute-silent(/usr/local/bin/ocpdocumentation {1})" \
                       --bind "m:execute-silent(tmux new-session -d -s imageset-{1} '/usr/local/bin/ocp-createimageset {1}'; tmux attach-session -t imageset-{1})+abort" \
                       --bind "enter:ignore" \
                       --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
                       --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
                       )
else
    exit 0
fi

exit 0
