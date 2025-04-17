#!/usr/bin/env bash

selected_file=$(
    locate -i "" | fzf-tmux \
        --header="Type to search for a file or directory:" \
        --layout=reverse \
        -p "70%,70%" \
        --exact \
        --bind 'tab:accept' \
        --preview '[[ -f {} ]] && cat {} || ls -l {}' \
        --preview-window=right:60% \
        --bind 'change:reload(locate -i "" || true)' \
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
