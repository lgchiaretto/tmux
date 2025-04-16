#!/usr/bin/env bash

projects=$(timeout 2s oc get namespaces -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$projects" ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_project=$(echo "$projects" | fzf-tmux \
     --header=$'-------------------------- Help --------------------------
[Enter]           Print project name
[Ctrl-p] - Esc    Run "oc project <project>"
[Esc]             Exit
----------------------------------------------------------\n\n' \
    --layout=reverse \
    -h 40 \
    -p "23%,50%" \
    --exact \
    --bind "ctrl-p:execute-silent(tmux send-keys 'oc project {}' C-m)+abort" \
    --expect=enter \
)

if [ -n "$selected_project" ]; then
    tmux send-keys "$selected_project"
fi
