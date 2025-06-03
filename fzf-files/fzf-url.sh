#!/usr/bin/env bash

content=$(tmux capture-pane -J -p -e -S - | \
    sed -r 's/\x1B\[[0-9;]*[mK]//g' | \
    grep -oE '\b((http|https)://[a-z0-9.-]+(/\S*)?|[a-z0-9.-]+\.[a-z]{2,}(/\S*)?|([0-9]{1,3}\.){3}[0-9]{1,3})\b' | \
    sort | uniq)

if [ -z "$content" ]; then
    tmux display 'No URLs or IPs found'
    exit
fi

chosen=$(echo "$content" | fzf-tmux \
  --header=$'--------------------------------- Help ---------------------------------
[Enter]     Print the URL or IP
[Tab]       Print the URL or IP
[Ctrl-o]    Open the URL in Firefox
[Ctrl-c]    Copy the URL or IP to clipboard
[Esc]       Exit
-----------------------------------------------------------------------\n\n' \
  --layout=reverse \
  --border-label=" chiaret.to " \
  --border-label-pos=center \
  -h 40 \
  -p "100%,50%" \
  --exact \
  --bind 'ctrl-c:execute-silent(echo -n {} | wl-copy && tmux set-buffer {} && tmux display "Copied")+abort' \
  --bind 'ctrl-o:execute-silent(firefox {})+abort' \
  --bind 'tab:accept' \
  --expect=enter \
  --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
  --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665 \
)
if [ -n "$chosen" ]; then
    tmux send-keys "$(echo "$chosen" | tail -n1)"
fi