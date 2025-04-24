#!/usr/bin/env bash

actions="1 - Create cluster\n2 - Destroy cluster\n3 - Edit install configs\n4 - Export 'kube:admin' kubeconfig\n5 - Login with 'kubeadmin' user\n6 - Start cluster\n7 - List OpenShift releases available on quay.chiaret.to"

selected_action=$(
    echo -e "$actions" | fzf-tmux \
        --header=$'-------------------------- Help --------------------------
[Enter]     Select the action
[Esc]       Exit
----------------------------------------------------------\n\n' \
        --layout=reverse \
        -h 40 \
        -p "38%,50%" \
        --ansi \
        --sort \
        --expect=enter
)

action=$(echo "$selected_action" | tail -n1)

if [ "$action" ]; then
    case "$action" in
        "6 - Start cluster")
            /usr/local/bin/ocpstartvms
            ;;
        "4 - Export 'kube:admin' kubeconfig")
            /usr/local/bin/ocpexportkubeconfig
            ;;
        "1 - Create cluster")
            /usr/local/bin/ocpcreatecluster
            ;;
        "2 - Destroy cluster")
            /usr/local/bin/ocpdestroycluster
            ;;
        "5 - Login with 'kubeadmin' user")
            /usr/local/bin/ocplogin
            ;;
        "3 - Edit install configs")
            /usr/local/bin/ocpvariablesfiles
            ;;
        "7 - List OpenShift releases available on quay.chiaret.to")/
            /usr/local/bin/ocpreleasesonquay
            ;;
    esac
fi

if [ $? -ne 0 ]; then
    exit 0
fi
