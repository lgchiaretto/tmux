#!/usr/bin/env bash

projects=$(timeout 2s oc get namespaces -o custom-columns=NAME:.metadata.name --no-headers)

if [ -z "$projects" ]; then
    tmux display -d 5000 'No project found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_project=$(echo "$projects" | fzf-tmux  --header="Select the OpenShift project:" --layout=reverse -h 40 -p "50%,50%" --exact)

if [ -n "$selected_project" ]; then
    tmux send-keys "$selected_project"
else
    tmux display -d 3000 "No project selected"
    exit 0
fi
