#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi

projects=$(timeout 2s oc get namespaces -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$projects" ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_project=$(echo "$projects" | fzf-tmux \
     --header=$'-------------------------- Help --------------------------
[Enter]           Change to project
[Tab]             Print project name
[Esc]             Exit
----------------------------------------------------------\n\n' \
    --layout=reverse \
    --border-label=" $FZF_BORDER_LABEL " \
    --border-label-pos=center \
    -h 40 \
    -p "100%,50%" \
    --exact \
    --bind "tab:execute-silent(tmux send-keys '{}')+abort" \
    --bind "ctrl-p:execute-silent(tmux send-keys 'oc project {}' C-m)+abort" \
    --expect=enter \
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
)

if [ -n "$selected_project" ]; then
    project=$(echo "$selected_project" | tail -n1 | awk '{print $1}')
    oc project $project > /dev/null 2>&1
fi
