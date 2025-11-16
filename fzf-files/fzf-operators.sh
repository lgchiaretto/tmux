#!/usr/bin/env bash

# Load configuration
if [ -f "$HOME/.tmux/config.sh" ]; then
    source "$HOME/.tmux/config.sh"
fi

operators=$(timeout 2s oc get clusteroperators -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .status.conditions[?(@.type=="Available")]}{.status}{"\t"}{end}{range .status.conditions[?(@.type=="Progressing")]}{.status}{"\t"}{end}{range .status.conditions[?(@.type=="Degraded")]}{.status}{"\n"}{end}{end}' | awk -F'\t' '{if ($3=="True" || $4=="True") print "\033[31m"$0"\033[0m"; else print $0}' | column -t -s $'\t' 2>/dev/null)

if [ -z "$operators" ]; then
    tmux display -d 5000 'No operator found. Are you connected on any OpenShift cluster?'
    exit 0
fi

selected_operator=$(
    echo "$operators" | fzf-tmux \
        --ansi \
        --header=$'┌───────────────────────── Help ───────────────────────────┐
│                                                          │
│  [Enter]     Print cluster operator name                 │
│  [Tab]       Print cluster operator name                 │
│  [Ctrl-d]    Run "oc describe <cluster operator>"        │
│  [Ctrl-e]    Run "oc edit <cluster operator>"            │
│  [Esc]       Exit                                        │
│                                                          │
└──────────────────────────────────────────────────────────┘\n\n' \
        --layout=reverse \
        --border-label=" $FZF_BORDER_LABEL " \
        --border-label-pos=center \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
        -h 40 \
        -p "32%,45" \
        --exact \
        --bind 'tab:accept' \
        --bind 'ctrl-d:execute-silent(
            tmux send-keys "oc describe co {1}" C-m;
        )+abort' \
        --bind 'ctrl-e:execute-silent(
            tmux send-keys "oc edit co {1}" C-m;
        )+abort' | awk '{print $1}'
)

if [ -n "$selected_operator" ]; then
    tmux send-keys "$selected_operator"
fi
