#!/usr/bin/env bash

project_name=$(timeout 0.2 oc project -q)

if [ -z "$project_name" ] && [ $? -eq 0 ]; then
  tmux display -d 5000 'No resource found'
  exit 0
elif [ -z "$project_name" ] && [ $? -eq 1 ]; then
  tmux display -d 5000 'No resource found. Are you connected on any OpenShift cluster?'
  exit 0
fi

action=$(oc api-resources --cached=true | tail -n +2 | 
    fzf-tmux \
    --exact \   
    --layout=reverse \
    --border-label=" chiaret.to " \
    --border-label-pos=center \
    -h 40 -p "100%,50%" \
    --bind 'tab:accept' | awk '{print $1}'\ 
    --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
    --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
)

tmux send-keys "$action"
