#!/usr/bin/env bash

nodes=$(timeout 2s oc get nodes -o json | jq -r '.items[] | "\(.metadata.name) \(.status.conditions[] | select(.reason == "KubeletReady").type)"')

if [ -z "$nodes" -a $? -eq 0 ]; then
    tmux display -d 5000 'No node found'
    exit 0
elif [ -z "$nodes" -a $? -eq 1 ]; then
    tmux display -d 5000 'No node found. Are you connected on any OpenShift cluster?'
    exit 0
fi

colored_nodes=$(echo "$nodes" | awk '{
    if ($2 != "Ready") {
        printf "\033[31m%s\t%s\033[0m\n", $1, $2  # Red for error or non-Running statuses
    } else {
        printf "%s\t%s\n", $1, $2
    }
}' | column -t) 

selected_nodes=$(
    echo -e "$colored_nodes" | fzf-tmux \
        --header=$'------------------- Help -------------------
[Enter]     Print node name
[Tab]       Print node name
[Ctrl-a]    Select all nodes
[Ctrl-d]    Run "oc describe <node>"
[Ctrl-e]    Run "oc edit <node>"
[Esc]       Exit
--------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "100%,50%"  \
        --exact \
        --with-nth=1,2 \
        --ansi \
        --multi \
        --bind 'ctrl-d:execute-silent(
            tmux send-keys "oc describe node {1}" C-m;
        )+abort' \
        --bind 'ctrl-e:execute-silent(
            tmux send-keys "oc edit node {1}" C-m;
        )+abort' \
        --bind 'ctrl-a:toggle-all' \
        --expect=enter \
)

if [ -n "$selected_nodes" ]; then
    pressed_key=$(head -n1 <<< "$selected_nodes")
    nodes=$(tail -n +2 <<< "$selected_nodes")

    while IFS= read -r line; do
        node_name=$(awk '{print $1 " "}' <<< "$line")
        tmux send-keys "$node_name" 
    done <<< "$nodes"
fi

if [ $? -ne 0 ]; then
    exit 0
fi
