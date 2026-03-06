#!/usr/bin/env bash
# Slide 6: Bash Customization

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "BASH CUSTOMIZATION"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_highlight "Custom Prompt (Gruvbox Theme)" 4
    slide_blank
    slide_text "PS1 with color-coded elements: user@host:path (git-branch)\$" "" 4
    slide_blank
    slide_bullet "User in green (#142)" 6
    slide_bullet "Host in orange (#214)" 6
    slide_bullet "Path in blue (#109)" 6
    slide_bullet "Git branch in purple (#175)" 6
    slide_blank
    slide_blank
    slide_highlight "Environment Variables" 4
    slide_blank
    slide_bullet "GOVC_* variables for VMware automation" 6
    slide_bullet "Unlimited history (HISTSIZE & HISTFILESIZE empty)" 6
    slide_bullet "FZF_DEFAULT_OPTS with Gruvbox color scheme" 6
    slide_blank
    slide_blank
    slide_bottom
}

slide_present build_slide
