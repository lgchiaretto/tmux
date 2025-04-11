#!/usr/bin/bash -x

selected_file=$(locate -i "" | fzf-tmux --header="Type to search for a file:" --layout=reverse -p "50%,50%" --exact )

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
else
    tmux display -d 3000 "No file selected"
    exit 0
fi
