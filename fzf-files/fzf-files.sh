#!/usr/bin/env bash

selected_file=$(
    locate -i "" | fzf-tmux \
        --header=$'---------------------------------- Help ----------------------------------
[Enter]     Open file or directory
[Ctrl-c]    Copy the content of the file to clipboard
[Tab]       Print the file or directory in the terminal
[Esc]       Exit
--------------------------------------------------------------------------\n\n' \
        --layout=reverse \
        -p "100%,70%" \
        --exact \
        --wrap \
        --bind 'tab:accept' \
        --bind 'ctrl-c:execute-silent([[ -f {} ]] && xclip -selection clipboard -i < {} && tmux display-message -d 1000 "Copied")+abort' \
        --bind 'tab:execute-silent(tmux send-keys -l {})+abort' \
        --preview '[[ -f {} ]] && bat --color=always --theme="gruvbox-dark" {} || ls --color=always -ltra {}' \
        --preview-window=right:60%:wrap \
        --query ""
)

if [ -n "$selected_file" ]; then
    if [ -f "$selected_file" ]; then
        if [ -w "$selected_file" ]; then
            tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s \"vim $selected_file\"" C-m
            tmux send-keys "vim $selected_file" C-m
        else
            tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s \"sudo -E vim $selected_file\"" C-m
            tmux send-keys "sudo -E vim $selected_file" C-m
        fi
    else
        tmux send-keys -t "$(tmux display-message -p '#{pane_id}')" "history -s \"cd $selected_file\"" C-m
        tmux send-keys "cd $selected_file" C-m
    fi
fi
