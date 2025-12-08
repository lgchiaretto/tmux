#!/usr/bin/env bash

# fzf-url.sh - Extract and open URLs from tmux pane
# This script extracts URLs from the current tmux pane and lets you select one with fzf

set -e

# URL regex pattern
URL_REGEX='(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]*[-A-Za-z0-9+&@#/%=~_|]'

# Capture tmux pane content
capture_urls() {
    tmux capture-pane -J -p | grep -oE "$URL_REGEX" | sort -u
}

# Main function
main() {
    local action="${1:-echo}"
    local urls
    
    urls=$(capture_urls)
    
    if [ -z "$urls" ]; then
        tmux display-message "No URLs found in pane"
        exit 0
    fi
    
    local selected
    selected=$(echo "$urls" | fzf-tmux -p 80%,60% \
        --prompt="Select URL > " \
        --header="URLs found in tmux pane" \
        --preview='echo {}' \
        --preview-window=down:1:wrap)
    
    if [ -n "$selected" ]; then
        case "$action" in
            open)
                # Try different methods to open URL
                if command -v xdg-open &>/dev/null; then
                    xdg-open "$selected" &>/dev/null &
                elif command -v open &>/dev/null; then
                    open "$selected" &>/dev/null &
                else
                    echo "$selected" | tmux load-buffer -
                    tmux display-message "URL copied to buffer: $selected"
                fi
                ;;
            copy)
                echo -n "$selected" | xclip -selection clipboard 2>/dev/null || \
                echo "$selected" | tmux load-buffer -
                tmux display-message "URL copied: $selected"
                ;;
            *)
                echo "$selected"
                ;;
        esac
    fi
}

main "$@"
