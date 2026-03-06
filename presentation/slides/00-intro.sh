#!/usr/bin/env bash
# Slide 0: Introduction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "TMUX"
    slide_title_blank
    slide_title_text "Empowering Your Terminal" "$C_GREEN"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_section "What You'll Learn Today"
    slide_blank
    slide_check "Productivity" 5
    slide_check "What is tmux, why and how to use it" 5
    slide_check "Core tmux concepts and features" 5
    slide_check "About this project" 5
    slide_check "FZF Fuzzy Finder integration" 5
    slide_check "OpenShift integration" 5
    slide_check "Live demonstration" 5
    slide_blank
    slide_blank
    slide_section "What I expect from you"
    slide_blank
    slide_check "Open Your Mind!" 5
    slide_blank
    slide_center "Luiz Gustavo Chiaretto" "$C_GREEN"
    slide_center "chiarettolabs.com.br" "$C_CODE"
    slide_blank
    slide_bottom
}

slide_present build_slide
