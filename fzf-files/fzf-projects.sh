#!/usr/bin/env bash

projects=$(timeout 2s oc get namespaces -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$projects" ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_project=$(echo "$projects" | fzf-tmux \
     --header=$'-------------------------- Help --------------------------
[Enter]           Print project name
[Tab]             Print project name
[Ctrl-p] - Esc    Run "oc project <project>"
[Esc]             Exit
----------------------------------------------------------\n\n' \
    --layout=reverse \
    --border-label=" chiaret.to " \
    --border-label-pos=center \
    -h 40 \
    -p "100%,50%" \
    --exact \
    --bind 'tab:accept' \
    --bind "ctrl-p:execute-silent(tmux send-keys 'oc project {}' C-m)+abort" \
    --expect=enter \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
)

if [ -n "$selected_project" ]; then
    tmux send-keys $(echo "$selected_project" | tail -n1 | awk '{print $1}')
fi
