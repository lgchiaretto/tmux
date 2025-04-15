#!/bin/bash
pod="$1"
containers=$(oc get pod "$pod" -o jsonpath='{.spec.containers[*].name}' 2>/dev/null)
count=$(echo "$containers" | wc -w)

if [ "$count" -eq 1 ]; then
    tmux new-window -n "oc logs $pod" "bash -i -c 'oc logs -f $pod; exec bash'"
else
    container=$(echo "$containers" | tr ' ' '\n' | fzf-tmux --header="Select container for pod $pod" --layout=reverse -h 10)
    if [ -n "$container" ]; then
        tmux new-window -n "oc logs $pod" "bash -i -c 'oc logs -f $pod -c $container; exec bash'"
    fi
fi
