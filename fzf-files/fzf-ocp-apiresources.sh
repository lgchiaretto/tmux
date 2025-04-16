#!/usr/bin/env bash

project_name=$(oc project -q)

if [ -z "$project_name" -a $? -eq 0 ]; then
  tmux display -d 5000 'No resource found'
  exit 0
elif [ -z "$project_name" -a $? -eq 1 ]; then
  tmux display -d 5000 'No resource found. Are you connected on any OpenShift cluster?'
  exit 0
fi

action=$(oc api-resources --sort-by=name -o name | fzf-tmux --layout=reverse -h 40 -p "50%,50%" --prompt="Choose a resource: ")

tmux send-keys $action

# if [ -z "$action" ]; then
#   tmux display -d 5000 'No action selected'
#   exit 0
# fi