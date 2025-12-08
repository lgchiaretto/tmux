#!/usr/bin/env bash

# fzf-buffer.sh - Manage tmux buffers with fzf
# This script allows selecting and managing tmux paste buffers

set -e

# Main function
main() {
    local action="${1:-paste}"
    
    # Check if there are any buffers
    if ! tmux list-buffers 2>/dev/null | head -1 &>/dev/null; then
        tmux display-message "No buffers available"
        exit 0
    fi
    
    local selected
    selected=$(tmux list-buffers -F "#{buffer_name}: #{buffer_sample}" | \
        fzf-tmux -p 80%,60% \
            --prompt="Select buffer > " \
            --header="tmux Paste Buffers" \
            --preview='tmux show-buffer -b $(echo {} | cut -d: -f1)' \
            --preview-window=down:50%:wrap | \
        cut -d: -f1)
    
    if [ -n "$selected" ]; then
        case "$action" in
            paste)
                tmux paste-buffer -b "$selected"
                ;;
            delete)
                tmux delete-buffer -b "$selected"
                tmux display-message "Buffer deleted: $selected"
                ;;
            show)
                tmux show-buffer -b "$selected"
                ;;
            *)
                tmux paste-buffer -b "$selected"
                ;;
        esac
    fi
}

main "$@"
