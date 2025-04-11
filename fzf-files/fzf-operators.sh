#!/usr/bin/env bash

operators=$(timeout 2s oc get clusteroperators -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$operators" ]; then
    tmux display -d 5000 'No operator found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_operator=$(echo "$operators" | fzf-tmux --header="Select the OpenShift Cluster Operator:" --layout=reverse -h 40 -p "50%,40" --exact )

if [ -n "$selected_operator" ]; then
    tmux send-keys "$selected_operator"
else
    tmux display -d 3000 "No operator selected"
    exit 0
fi
