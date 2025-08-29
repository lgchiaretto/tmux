#!/usr/bin/env bash

selected_file=$(
    locate -i "" | fzf-tmux \
        --header=$'---------------------------------- Help ----------------------------------
[Enter]     Open file or directory
[Ctrl-c]    Copy the content of the file to clipboard
[Ctrl-a]    Execute oc apply -f on the file
[Ctrl-p]    Print the file or directory name in the terminal
[Tab]       Open using Visual Studio Code
[Esc]       Exit
--------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        --border-label=" chiarettolabs.com.br " \
        --border-label-pos=center \
        -p "100%,50%" \
        --exact \
        --wrap \
        --bind 'tab:accept' \
        --bind 'ctrl-c:execute-silent([[ -f {} ]] && xclip -selection clipboard -i < {} && tmux display-message -d 1000 "Copied")+abort' \
        --bind 'ctrl-p:execute-silent(tmux send-keys -l {})+abort' \
        --bind 'tab:execute-silent(tmux send-keys "code -n " {} C-m)+abort' \
        --bind 'ctrl-a:execute-silent([[ -f {} ]] && tmux send-keys "oc apply -f " {} C-m)+abort' \
        --preview '[[ -f {} ]] && bat --color=always --theme="gruvbox-dark" {} || ls --color=always -ltra {}' \
        --preview-window=right:60%:wrap \
        --query "" \
        --color=fg:#ffffff,bg:#1d2021,hl:#d8a657 \
        --color=fg+:#a9b665,bg+:#1d2021,hl+:#a9b665
)

if [ -n "$selected_file" ]; then
    if [ -f "$selected_file" ]; then
        if [ -w "$selected_file" ]; then
            tmux send-keys "vim $selected_file" C-m
        else
            tmux send-keys "sudo -E vim $selected_file" C-m
        fi
    else
        tmux send-keys "cd $selected_file" C-m
    fi
fi
