#!/usr/bin/env bash

selected_file=$(
    locate -i "" | fzf-tmux \
        --header=$'---------------------------------- Help ----------------------------------
[Enter]     Open file or directory
[Ctrl-c]    Copy the content of the file to clipboard
[Esc]       Exit
--------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        -p "70%,70%" \
        --exact \
        --bind 'tab:accept' \
        --bind 'ctrl-c:execute-silent([[ -f {} ]] && xclip -selection clipboard -i < {} && tmux display-message -d 1000 "Copied")+abort' \
        --preview '[[ -f {} ]] && bat --color=always --theme="gruvbox-dark" {} || ls --color=always -l {}' \
        --preview-window=right:60% \
        --query ""
)

if [ -n "$selected_file" ]; then
    if [ -f "$selected_file" ]; then
        if [ -w "$selected_file" ]; then
            tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s \"vim $selected_file\"" C-m
            tmux new-window "vim $selected_file"
        else
            tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s \"sudo -E vim $selected_file\"" C-m
            tmux new-window "sudo -E vim $selected_file"
        fi
    else
        tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s \"cd $selected_file\"" C-m
        tmux new-window "cd $selected_file; bash"
    fi
fi
