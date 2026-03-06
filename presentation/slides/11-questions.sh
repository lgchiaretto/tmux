#!/usr/bin/env bash
# Slide 11: Questions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "Questions/Comments/Feedback" "$C_GREEN"
    slide_title_blank
    slide_title_rich "${C_TITLE_BD}Slack: ${C_TEXT}@chiaretto"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_bottom
}

slide_present build_slide
