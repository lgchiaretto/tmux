#!/usr/bin/env bash

nodes=$(timeout 2s oc get nodes -o json | jq -r '.items[] | "\(.metadata.name) \(.status.conditions[] | select(.reason == "KubeletReady").type)"')

if [ -z "$nodes" -a $? -eq 0 ]; then
    tmux display -d 5000 'No node found'
    exit 0
elif [ -z "$nodes" -a $? -eq 1 ]; then
    tmux display -d 5000 'No node found. Are you connected on any OpenShift cluster?'
    exit 0
fi

oc_describe_fzf() {
    local node="$1"
    tmux new-window -n "desc:$node" "oc describe node \"$node\"; bash"
}

oc_edit_fzf() {
    local node="$1"
    tmux new-window -n "edit:$node" "oc edit node \"$node\""
}

ossh_fzf() {
    local node="$1"
    tmux new-window -n "ssh:$node" "source ~/.bash_functions && ossh \"$node\""
}

if [[ "$1" == "--action-wrapper" ]]; then
    action="$2"
    shift 2

    for node in "$@"; do
        case "$action" in
            logs)
                oc_logs_fzf "$node"
                ;;
            describe)
                oc_describe_fzf "$node"
                ;;
            edit)
                oc_edit_fzf "$node"
                ;;
            ossh)
                ossh_fzf "$node"
                ;;
        esac
    done
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
        --header=$'----------------------------------------------------------------- Help -----------------------------------------------------------------
[Enter]     Print node name
[Tab]       Select node
[Ctrl-a]    Select all nodes
[Ctrl-d]    Run "oc describe <node>" in new tmux window
[Ctrl-e]    Run "oc edit <node>" in new tmux window
[Ctrl-s]    SSH to node in new tmux window
[Esc]       Exit
----------------------------------------------------------------------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        --border-label=" chiaret.to " \
        --border-label-pos=center \
        -h 40 \
        -p "100%,50%" \
        --exact \
        --with-nth=1,2 \
        --ansi \
        --wrap \
        --multi \
        --bind 'ctrl-d:execute-silent('"$0"' --action-wrapper describe {+1})+abort' \
        --bind 'ctrl-e:execute-silent('"$0"' --action-wrapper edit {+1})+abort' \
        --bind 'ctrl-s:execute-silent('"$0"' --action-wrapper ossh {+1})+abort' \
        --bind 'ctrl-a:toggle-all' \
        --expect=enter \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
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
