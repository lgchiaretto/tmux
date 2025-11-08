#!/usr/bin/env bash

oc_logs_fzf() {
    local pod="$1"
    tmux new-window -n "logs:$pod" "/usr/local/bin/oc-logs-fzf.sh \"$pod\""
}

oc_describe_fzf() {
    local pod="$1"
    tmux new-window -n "desc:$pod" "oc describe pod \"$pod\"; bash"
}

oc_edit_fzf() {
    local pod="$1"
    tmux new-window -n "edit:$pod" "oc edit pod \"$pod\""
}

if [[ "$1" == "--action-wrapper" ]]; then
    action="$2"
    shift 2

    for pod in "$@"; do
        case "$action" in
            logs)
                oc_logs_fzf "$pod"
                ;;
            describe)
                oc_describe_fzf "$pod"
                ;;
            edit)
                oc_edit_fzf "$pod"
                ;;
        esac
    done
    exit 0
fi

pods=$(timeout 2s oc get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --no-headers)

if [ -z "$pods" ] && [ $? -eq 0 ]; then
    tmux display -d 5000 'No pod found'
    exit 0
elif [ -z "$pods" ] && [ $? -eq 1 ]; then
    tmux display -d 5000 'No pod found. Are you connected on any OpenShift cluster?'
    exit 0
fi

colored_pods=$(echo "$pods" | awk '{
    if ($2 != "Running" && $2 != "Succeeded" && $2 != "Completed") {
        printf "\033[31m%s\t%s\t%s\033[0m\n", $1, $2, $3
    } else {
        printf "%s\t%s\t%s\n", $1, $2, $3
    }
}' | column -t)

selected_pod=$(
    echo -e "$colored_pods" | fzf-tmux \
        --header=$'----------------------------------------------------------------- Help -----------------------------------------------------------------
[Enter]     Print pod name
[Tab]       Print pod name
[Ctrl-d]    Run "oc describe <pod>" in new tmux window
[Ctrl-e]    Run "oc edit <pod>" in new tmux window
[Ctrl-l]    Run "oc logs <pod>" in new tmux window
[Esc]       Exit
----------------------------------------------------------------------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        --border-label=" chiarettolabs.com.br " \
        --border-label-pos=center \
        -h 40 \
        -p "100%,50%" \
        --exact \
        --with-nth=1,2,3 \
        --ansi \
        --wrap \
        --multi \
        --bind 'ctrl-l:execute-silent('"$0"' --action-wrapper logs {+1})+abort' \
        --bind 'ctrl-d:execute-silent('"$0"' --action-wrapper describe {+1})+abort' \
        --bind 'ctrl-e:execute-silent('"$0"' --action-wrapper edit {+1})+abort' \
        --bind 'ctrl-a:toggle-all' \
        --expect=enter \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
)

if [ -n "$selected_pod" ]; then
    pressed_key=$(head -n1 <<< "$selected_pod")
    nodes=$(tail -n +2 <<< "$selected_pod")

    while IFS= read -r line; do
        pod_name=$(awk '{print $1 " "}' <<< "$line")
        tmux send-keys "$pod_name"
    done <<< "$nodes"
fi

exit 0
