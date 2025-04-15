#!/usr/bin/env bash

# Get pods with their status
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
        --header=$'Select the OpenShift pod:\n\n[Enter] Select pod name  [Ctrl-d] Describe  [Ctrl-e] Edit  [Esc] Exit\n\n' \
        --layout=reverse \
        -h 40 \
        -p "50%,50%" \
        --exact \
        --with-nth=1,2 \
        --ansi \
        --bind 'ctrl-d:execute-silent(
            echo {} | awk "{print \$1}" | xargs -I {} tmux new-window -n "oc describe pod {}" "oc describe pod {} | less; tmux select-window -t \"oc describe pod {}\""
        )' \
        --bind 'ctrl-e:execute-silent(
            echo {} | awk "{print \$1}" | xargs -I {} tmux new-window -n "oc edit pod {}" "oc edit pod {}; tmux select-window -t \"oc edit pod {}\""
        )' | awk '{print $1}'\
)

if [ -n "$selected_pod" ]; then
    tmux send-keys "$selected_pod"
else
    tmux display -d 3000 "No pod selected"
    exit 0
fi
