#!/usr/bin/env bash

content=$(tmux capture-pane -J -p -e -S - | \
    sed -r 's/\x1B\[[0-9;]*[mK]//g' | \
    grep -oE '\b((http|https):\/\/[a-z0-9.-]+(\/\S*)?|[a-z0-9.-]+\.[a-z]{2,}(\/\S*)?)\b' | \
    sort | uniq)

if [ -z "$content" ]; then
    tmux display 'No URLs found'
    exit
fi

chosen=$(echo "$content" | fzf-tmux  --header="Select the URL" --layout=reverse -h 40 -p "50%,50%" --exact)

if [ -n "$chosen" ]; then
  case "$1" in
    copy)
      echo -n "$chosen" | wl-copy
      if ! tmux list-buffers | grep -qF "$chosen"; then
          tmux set-buffer "$chosen"
      fi
      tmux display "Copied"
      ;;
    open)
      firefox "$chosen"
      ;;
  esac
fi
