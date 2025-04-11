#!/usr/bin/env bash

pods=$(timeout 2s oc get pods -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$pods" -a $? -eq 0 ]; then
    tmux display -d 5000 'No pod found'
    exit 0
elif [ -z "$pods" -a $? -eq 1 ]; then
    tmux display -d 5000 'No pod found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_pod=$(echo "$pods" | fzf-tmux  --header="Select the OpenShift pod:" --layout=reverse -h 40 -p "50%,50%" --exact)

if [ -n "$selected_pod" ]; then
    tmux send-keys "$selected_pod"
else
    tmux display -d 3000 "No pod selected"
    exit 0
fi
