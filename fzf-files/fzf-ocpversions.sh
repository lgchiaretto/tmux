#!/bin/bash

CACHE_FILE="/data/.ocp_versions_cache"

if [ -f "$CACHE_FILE" ]; then
    selected_version=$(cat "$CACHE_FILE" | fzf-tmux \
                       --header=$'-----------------------------------------------
Version             Release Date
-----------------------------------------------\n' \
                       --layout=reverse \
                       -h 40 \
                       -p "40%,62%" \
                       --with-nth=1,2,3,4,5,6,7,8 \
                       --bind enter:accept | \
                       awk '{print $1}')
    [ -n "$selected_version" ] && tmux send-keys "$selected_version" || exit 0
else
    exit 0
fi


