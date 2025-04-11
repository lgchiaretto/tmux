#!/usr/bin/env bash

content=$(timeout 2s oc get routes -A -o custom-columns=NAME:.spec.host --no-headers | grep -v '<none>')

if [ -z "$content" ]; then
    tmux display -d 5000 'No routes found. Are you connected on any OpenShift cluster?'
    exit 0
fi

chosen=$(echo "$content" | fzf-tmux  --header="Select and Open th OpenShift route:" --layout=reverse  -h 40 -p "50%,50%" --exact)

if [ -n "$chosen" ]; then
  firefox "$chosen"
fi
