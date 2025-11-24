#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi

CACHE_FILE="/opt/.ocp_versions_cache"

if [ -f "$CACHE_FILE" ]; then
    selected_version=$(cat "$CACHE_FILE" | fzf-tmux \
                       --header=$'┌──────────────────────────────────────┐
│                                      │
│  [r]       Release notes             │
│  [d]       Documentation             │
│  [m]       Mirror to quay.chiaret.to │
│  [Enter]   Print release name        │
│  [Esc]     Exit                      │
│                                      │
│  Version             Release Date    │
│                                      │
└──────────────────────────────────────┘\n' \
                       --layout=reverse \
                       --border-label=" $FZF_BORDER_LABEL " \
                       --border-label-pos=center \
                       -h 40 \
                       -p "23%,90%" \
                       --with-nth=1,2,3,4,5,6,7,8 \
                       --no-input \
                       --bind "r:execute-silent(/usr/local/bin/ocpreleasenotes {1})" \
                       --bind "d:execute-silent(/usr/local/bin/ocpdocumentation {1})" \
                       --bind "m:execute-silent(tmux new-session -d -s imageset-{1} '/home/lchiaret/git/tmux/ocpscripts/ocp-createimageset {1}'; tmux attach-session -t imageset-{1})+abort" \
                       --bind "enter:ignore" \
                       --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
                       --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
                       )
else
    exit 0
fi

exit 0
