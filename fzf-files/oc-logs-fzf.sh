#!/usr/bin/env bash
pod="$1"
project_name=$(oc project -q)
containers=$(oc get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
count=$(echo "$containers" | wc -w)

if [ "$count" -eq 1 ]; then
    tmux new-window -n "logs $pod" "bash -i -c 'history -s oc logs -n $project_name $pod ; oc logs $pod -n $project_name; exec bash'"
else
    container=$(echo "$containers" | tr ' ' '\n' | fzf-tmux \
        --header="Select container for pod $pod" \       
        --border-label=" chiaret.to " \
        --border-label-pos=center \
        --layout=reverse \
        -h 10 \
        --exact \
        --bind 'tab:accept' \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 
        )
    if [ -n "$container" ]; then
        formatted_pod="${pod:0:15}..${container: -15}"
        tmux new-window -n "logs $formatted_pod" "bash -i -c 'history -s oc logs -n $project_name $pod -c $container; oc logs -n $project_name $pod -c $container; exec bash'"
    fi
fi
