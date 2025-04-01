#!/usr/bin/env bash

content=$(tmux capture-pane -J -p -e | \
  sed -r 's/\x1B\[[0-9;]*[mK]//g' | \
  grep -oE '\b((http|https)://[a-zA-Z0-9.-]+|[a-zA-Z0-9-]+\.[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})\b' | \
  sort -u)

if [ -z "$content" ]; then
    tmux display 'No URLs found'
    exit
fi

chosen=$(echo "$content" | fzf-tmux)

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
