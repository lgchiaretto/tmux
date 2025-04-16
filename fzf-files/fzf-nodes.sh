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

selected_node=$(
    echo -e "$colored_nodes" | fzf-tmux \
        --header=$'------------------- Help -------------------
[Enter]     Print node name
[TAB]       Print node name
[Ctrl-d]    Run "oc describe <node> | less"
[Ctrl-e]    Run "oc edit <node>"
[Esc]       Exit
--------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "18%,30%" \
        --exact \
        --with-nth=1,2 \
        --ansi \
        --bind 'tab:accept' \
        --bind 'ctrl-d:execute-silent(
            tmux new-window -n "describe node {1}" "oc describe node {1} | less; tmux select-window -t \"describe node {1}\""
        )+abort' \
        --bind 'ctrl-e:execute-silent(
            tmux new-window -n "edit node {1}" "oc edit node {1}; tmux select-window -t \"edit node {1}\""
        )+abort' \
        --expect=enter \
)

if [ "$selected_node" ]; then
    node_name=
    tmux send-keys $(echo "$selected_node" | tail -n1 | awk '{print $1}')
fi

if [ $? -ne 0 ]; then
    exit 0
fi
