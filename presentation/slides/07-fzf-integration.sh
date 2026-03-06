#!/usr/bin/env bash
# Slide 7: FZF Integration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "FZF INTEGRATION"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_highlight "What is FZF?" 4
    slide_blank
    slide_text "FZF is an interactive command-line fuzzy finder that can filter any" "" 4
    slide_text "list: files, command history, processes, hostnames, bookmarks, git" "" 4
    slide_text "commits, and more." "" 4
    slide_blank
    slide_blank
    slide_highlight "Key Features" 4
    slide_blank
    slide_bullet "Interactive fuzzy searching - type to filter results in real-time" 6
    slide_bullet "Multi-select support - select multiple items with Tab" 6
    slide_bullet "Preview windows - see content before selecting" 6
    slide_bullet "Tmux integration - run FZF in tmux popups and panes" 6
    slide_blank
    slide_blank
    slide_highlight "How We Use It" 4
    slide_blank
    slide_text "We integrate FZF with tmux keybindings to create interactive menus" "" 4
    slide_text "for OpenShift resource management. Each script creates new tmux" "" 4
    slide_text "windows with descriptive names like \"logs:podname\" or \"desc:node\"." "" 4
    slide_blank
    slide_text "This allows quick navigation and multi-tasking across cluster" "" 4
    slide_text "resources without leaving the terminal." "" 4
    slide_blank
    slide_bottom
}

slide_present build_slide
