#!/usr/bin/env bash
# Slide 9: Live Demo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "LIVE DEMO"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_highlight "Demo Scenarios" 4
    slide_blank
    slide_label "1. Basic Tmux Navigation" "" 6
    slide_bullet "C-s N to create session" 6
    slide_bullet "C-t to create windows" 6
    slide_bullet "C-\\ to split horizontal" 6
    slide_bullet "C-Arrow to navigate panes" 6
    slide_bullet "S-Left/Right to switch windows" 6
    slide_blank
    slide_label "2. Advanced Navigation" "" 6
    slide_bullet "C-s w - Interactive window selector" 6
    slide_bullet "C-s s - Interactive session browser" 6
    slide_bullet "C-s f - Find window by name" 6
    slide_bullet "C-s z - Zoom/unzoom current pane" 6
    slide_blank
    slide_label "3. FZF Pod Browser" "" 6
    slide_bullet "C-s p Manage pods" 6
    slide_bullet "C-s n Manage nodes" 6
    slide_bullet "C-s r Manage routes" 6
    slide_bullet "C-s l to tail logs in new window" 6
    slide_blank
    slide_label "4. Dynamic Status Bar" "" 6
    slide_bullet "Show cluster version/user/project" 6
    slide_bullet "C-s P to switch projects and observe updates" 6
    slide_blank
    slide_bottom
}

slide_present build_slide
