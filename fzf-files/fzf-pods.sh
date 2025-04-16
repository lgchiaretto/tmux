#!/usr/bin/env bash

pods=$(timeout 2s oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase --no-headers)

if [ -z "$pods" -a $? -eq 0 ]; then
    tmux display -d 5000 'No pod found'
    exit 0
elif [ -z "$pods" -a $? -eq 1 ]; then
    tmux display -d 5000 'No pod found. Are you connected on any OpenShift cluster?'
    exit 0
fi

colored_pods=$(echo "$pods" | awk '{
    if ($2 != "Running" && $2 != "Succeeded" && $2 != "Completed") {
        printf "\033[31m%s\t%s\033[0m\n", $1, $2  # Red for error or non-Running statuses
    } else {
        printf "%s\t%s\n", $1, $2
    }
}' | column -t) 

selected_pod=$(
    echo -e "$colored_pods" | fzf-tmux \
        --header=$'-------------------------- Help --------------------------
[Enter]     Print pod name
[TAB]       Print pod name
[Ctrl-d]    Run "oc describe <pod> | less"
[Ctrl-e]    Run "oc edit <pod>"
[Ctrl-l]    Run "oc logs <pod>"
[Esc]       Exit
----------------------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "23%,40%" \
        --exact \
        --with-nth=1,2 \
        --ansi \
        --bind 'tab:accept' \
        --bind 'ctrl-l:execute-silent(
            tmux new-window -n "logs pod {1}" "/usr/local/bin/oc-logs-fzf.sh {1}"
        )+abort' \
        --bind 'ctrl-d:execute-silent(
            tmux new-window -n "describe pod {1}" "oc describe pod {1} | less; tmux select-window -t \"describe pod {1}\""
        )+abort' \
        --bind 'ctrl-e:execute-silent(
            tmux new-window -n "edit pod {1}" "oc edit pod {1}; tmux select-window -t \"edit pod {1}\""
        )+abort' \
        --expect=enter \
)

if [ "$selected_pod" ]; then
    pod_name=
    tmux send-keys $(echo "$selected_pod" | tail -n1 | awk '{print $1}')
fi

if [ $? -ne 0 ]; then
    exit 0
fi
