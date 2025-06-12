#!/usr/bin/env bash

CACHE_FILE="/data/.ocp_versions_cache"

if [ -f "$CACHE_FILE" ]; then
    selected_version=$(cat "$CACHE_FILE" | fzf-tmux \
                       --header=$'-----------------------------------------------

[r]       Release notes
[Enter]   Print release name
[Esc]     Exit

Version             Release Date
-----------------------------------------------\n' \
                       --layout=reverse \
                       --border-label=" chiaret.to " \
                       --border-label-pos=center \
                       -h 40 \
                       -p "25%,68%" \
                       --with-nth=1,2,3,4,5,6,7,8 \
                       --no-input \
                       --bind "r:execute-silent(/usr/local/bin/ocpreleasenotes {1})" \
                       --bind "enter:ignore" \
                       --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
                       --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
                       )
else
    exit 0
fi

exit 0
