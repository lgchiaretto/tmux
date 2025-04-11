#!/usr/bin/env bash

files=$(find /vms/clusters/variables-files/ -type f -exec basename {} \; | sed 's/^ansible-vars-//' | sed 's/\.json$//')

selected_file=$(echo "$files" | sort | fzf-tmux --header="Select a variable file:" --layout=reverse  -h 40 -p "50%,50%" --exact)

if [ -n "$selected_file" ]; then
    tmux send-keys "/vms/clusters/variables-files/ansible-vars-$selected_file.json"
else
    tmux display -d 3000 "No file selected"
    exit 0
fi