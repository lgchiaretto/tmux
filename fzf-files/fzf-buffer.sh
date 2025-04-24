#!/bin/bash
buffer=$(tmux list-buffers -F "#{buffer_name}: #{buffer_sample}" | fzf-tmux --wrap --reverse --height=40 -p80%,50% --preview "echo {} | fold -s -w 100" | awk -F': ' '{print $2}')


# bind b display-popup  -w 80% -h 50% -E "sh -c '
# tmux list-buffers -F \"#{buffer_sample}\" | fzf --wrap --reverse --height=100% --border=none --preview \"echo {} | fold -s -w 100\" |
# xargs -r -I {} sh -c \"tmux paste-buffer -b {} && echo {} | fold -s -w 100\"
# '"

# Check if a buffer was selected
if [ -n "$buffer" ]; then
  tmux send-keys "$(echo "$buffer" | tail -n1)"
fi
