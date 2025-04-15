#!/usr/bin/env bash

operators=$(timeout 2s oc get clusteroperators -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .status.conditions[?(@.type=="Available")]}{.status}{"\t"}{end}{range .status.conditions[?(@.type=="Progressing")]}{.status}{"\t"}{end}{range .status.conditions[?(@.type=="Degraded")]}{.status}{"\n"}{end}{end}' | awk -F'\t' '{if ($3=="True" || $4=="True") print "\033[31m"$0"\033[0m"; else print $0}' | column -t -s $'\t' 2>/dev/null)

if [ -z "$operators" ]; then
    tmux display -d 5000 'No operator found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_operator=$(
    echo "$operators" | fzf-tmux \
        --ansi \
        --header=$'Select the OpenShift Cluster Operator:\n\n[Enter] Select Cluster Operator name [Ctrl-D] Describe  [Ctrl-E] Edit\n\n' \
        --layout=reverse \
        -h 40 \
        -p "50%,40" \
        --exact \
        --bind 'ctrl-d:execute-silent(
            echo {} | awk "{print \$1}" | xargs -I {} tmux new-window -n "oc describe co {}" "oc describe co {} | less; tmux select-window -t \"oc describe co {}\""
        )' \
        --bind 'ctrl-e:execute-silent(
            echo {} | awk "{print \$1}" | xargs -I {} tmux new-window -n "oc edit co {}" "oc edit co {}; tmux select-window -t \"oc edit co {}\""
        )' | awk '{print $1}'
)

if [ -n "$selected_operator" ]; then
    tmux send-keys "$selected_operator"
fi
