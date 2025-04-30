#!/usr/bin/env bash

pods=$(timeout 2s oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --no-headers)

if [ -z "$pods" -a $? -eq 0 ]; then
    tmux display -d 5000 'No pod found'
    exit 0
elif [ -z "$pods" -a $? -eq 1 ]; then
    tmux display -d 5000 'No pod found. Are you connected on any OpenShift cluster?'
    exit 0
fi

colored_pods=$(echo "$pods" | awk '{
    if ($2 != "Running" && $2 != "Succeeded" && $2 != "Completed") {
        printf "\033[31m%s\t%s\t%s\033[0m\n", $1, $2, $3  # Red for error or non-Running statuses
    } else {
        printf "%s\t%s\t%s\n", $1, $2, $3
    }
}' | column -t) 

selected_pod=$(
    echo -e "$colored_pods" | fzf-tmux \
        --header=$'----------------------------------------------------------------- Help -----------------------------------------------------------------
[Enter]     Print pod name
[Tab]       Print pod name
[Ctrl-d]    Run "oc describe <pod>"
[Ctrl-e]    Run "oc edit <pod>"
[Ctrl-l]    Run "oc logs <pod>"
[Esc]       Exit
----------------------------------------------------------------------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "100%,50%" \
        --exact \
        --with-nth=1,2,3 \
        --ansi \
        --wrap \
        --multi \
        --bind 'ctrl-l:execute-silent(
            tmux send-keys "/usr/local/bin/oc-logs-fzf.sh {1}" C-m;
        )+abort' \
        --bind 'ctrl-d:execute-silent(
            tmux send-keys "oc describe pod {1}" C-m;
        )+abort' \
        --bind 'ctrl-e:execute-silent(
            tmux send-keys "oc edit pod {1}" C-m;
        )+abort' \
        --bind 'ctrl-a:toggle-all' \
        --expect=enter \
)

#if [ "$selected_pod" ]; then
#    pod_name=
#    tmux send-keys $(echo "$selected_pod" | tail -n1 | awk '{print $1}')
#fi


if [ -n "$selected_pod" ]; then
    pressed_key=$(head -n1 <<< "$selected_pod")
    nodes=$(tail -n +2 <<< "$selected_pod")

    while IFS= read -r line; do
        node_name=$(awk '{print $1 " "}' <<< "$line")
        tmux send-keys "$node_name" 
    done <<< "$nodes"
fi


if [ $? -ne 0 ]; then
    exit 0
fi
