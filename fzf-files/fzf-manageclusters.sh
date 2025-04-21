#!/usr/bin/env bash

actions="Create cluster\nDestroy cluster\nExport 'kube:admin' kubeconfig\nStart cluster"

selected_action=$(
    echo -e "$actions" | fzf-tmux \
        --header=$'-------------------------- Help --------------------------
[Enter]     Select the action
[Esc]       Exit
----------------------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "23%,17%" \
        --ansi \
        --sort \
        --expect=enter
)

action=$(echo "$selected_action" | tail -n1)

if [ "$action" ]; then
    case "$action" in
        "Start cluster")
            /usr/local/bin/ocpstartvms
            ;;
        "Export 'kube:admin' kubeconfig")
            /usr/local/bin/ocpexportkubeconfig
            ;;
        "Create cluster")
            /usr/local/bin/ocpcreatecluster
            ;;
        "Destroy cluster")
            /usr/local/bin/ocpdestroycluster
            ;;
    esac
fi

if [ $? -ne 0 ]; then
    exit 0
fi
