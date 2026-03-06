#!/usr/bin/env bash
# Slide 10: Conclusion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "CONCLUSION"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_highlight "What We Covered" 4
    slide_blank
    slide_check "Tmux fundamentals and custom configuration" 6
    slide_check "FZF integration for interactive resource browsing" 6
    slide_check "OpenShift integration" 6
    slide_check "Dynamic status bar with context awareness" 6
    slide_blank
    slide_blank
    slide_blank
    slide_blank
    slide_highlight "Getting Started" 4
    slide_blank
    slide_text "1. Clone repository: git clone https://github.com/lgchiaretto/tmux.git" "" 4
    slide_text "2. Explore the configuration files" "" 4
    slide_text "3. Run: ./configure-local.sh" "" 4
    slide_blank
    slide_bottom
}

slide_present build_slide
