#!/usr/bin/env bash

selected_file=$(
    ls -1r "$1" | grep -e journal$ | fzf-tmux \
        --layout=reverse \
        --border-label=" chiaret.to " \
        --border-label-pos=center \
        -p "100%,100%" \
        --exact \
        --wrap \
        --preview 'journalctl --file {}' \
        --preview-window=up:80%:wrap \
        --query "" \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
)

exit 0