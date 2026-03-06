#!/usr/bin/env bash
# Slide 2: What is tmux?

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "WHAT IS TMUX?"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_highlight "Terminal Multiplexer" 4
    slide_bullet "Manage multiple windows in one terminal" 6
    slide_bullet "Allows multiple terminals within a single SSH connection" 6
    slide_bullet "Can be detached and reattached later" 6
    slide_bullet "Split windows into multiple panes" 6
    slide_bullet "FZF integration for interactive resource browsing" 6
    slide_blank
    slide_blank
    slide_section "Key Capabilities"
    slide_blank
    slide_label "Session Management" "" 6
    slide_bullet "Detach/reattach sessions - survive SSH disconnects" 8
    slide_bullet "Background processes continue running" 8
    slide_bullet "Named sessions for different projects" 8
    slide_blank
    slide_label "Window Management" "" 6
    slide_bullet "Multiple windows in one session (like browser tabs)" 8
    slide_bullet "Split windows into panes (horizontal/vertical)" 8
    slide_bullet "Navigate between windows/panes with keybindings" 8
    slide_blank
    slide_label "Scriptability" "" 6
    slide_bullet "Create complex layouts programmatically" 8
    slide_bullet "Automate terminal workflows" 8
    slide_bullet "Integration with other tools (FZF, scripts, automation)" 8
    slide_blank
    slide_blank
    slide_bottom
}

slide_present build_slide
