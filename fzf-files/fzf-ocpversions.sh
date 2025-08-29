#!/usr/bin/env bash

CACHE_FILE="/data/.ocp_versions_cache"

if [ -f "$CACHE_FILE" ]; then
    selected_version=$(cat "$CACHE_FILE" | fzf-tmux \
                       --header=$'---------------------------------------

[r]       Release notes
[d]       Documentation
[Enter]   Print release name
[Esc]     Exit

Version             Release Date
---------------------------------------\n' \
                       --layout=reverse \
                       --border-label=" chiarettolabs.com.br " \
                       --border-label-pos=center \
                       -h 40 \
                       -p "23%,86%" \
                       --with-nth=1,2,3,4,5,6,7,8 \
                       --no-input \
                       --bind "r:execute-silent(/usr/local/bin/ocpreleasenotes {1})" \
                       --bind "d:execute-silent(/usr/local/bin/ocpdocumentation {1})" \
                       --bind "enter:ignore" \
                       --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
                       --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
                       )
else
    exit 0
fi

exit 0
