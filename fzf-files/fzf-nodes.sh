#!/usr/bin/env bash

nodes=$(timeout 2s oc get nodes -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$nodes" ]; then
    tmux display -d 5000 'No node found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_node=$(echo "$nodes" | fzf-tmux --header="Select the OpenShift Node:" --layout=reverse -p "50%,20"  --exact )

if [ -n "$selected_node" ]; then
    tmux send-keys "$selected_node"
else
    tmux display -d 3000 "No node selected"
    exit 0
fi
