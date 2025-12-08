#!/usr/bin/env bash

# fzf-files.sh - Find and open files with fzf in tmux popup
# Opens selected file in vim

set -e

# Configuration
EDITOR="${EDITOR:-vim}"

# Find files, excluding common non-essential directories
find_files() {
    find . -type f \
        ! -path './.git/*' \
        ! -path './node_modules/*' \
        ! -path './__pycache__/*' \
        ! -path './.venv/*' \
        ! -path './venv/*' \
        ! -path './.cache/*' \
        2>/dev/null | sort
}

# Main function
main() {
    local selected
    
    selected=$(find_files | fzf-tmux -p 80%,60% \
        --prompt="Open file > " \
        --header="Select a file to open in $EDITOR" \
        --preview='head -100 {}' \
        --preview-window=right:60%:wrap)
    
    if [ -n "$selected" ]; then
        # Send the command to open the file in the current pane
        tmux send-keys "$EDITOR '$selected'" Enter
    fi
}

main "$@"
