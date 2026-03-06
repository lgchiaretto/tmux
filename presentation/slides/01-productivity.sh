#!/usr/bin/env bash
# Slide 1: Productivity

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "Productivity"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_highlight "Our day-to-day with the terminal" 4
    slide_bullet "Do you know how much time do you spend using terminal?" 6
    slide_bullet "Have you ever thought about the number of repetitive tasks" 6
    slide_text "that are executed in the terminal?" "" 8
    slide_blank
    slide_blank
    slide_section "Common problems"
    slide_blank
    slide_highlight "Easy Window & Pane Management" 4
    slide_bullet "Too much time to open a new terminal" 6
    slide_blank
    slide_highlight "Shared Bash History" 4
    slide_bullet "Where is my command?" 6
    slide_blank
    slide_highlight "Session Persistence" 4
    slide_bullet "The script I was executing has finished because I lost the VPN" 6
    slide_blank
    slide_bottom
}

slide_present build_slide
