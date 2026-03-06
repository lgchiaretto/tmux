#!/usr/bin/env bash
# Slide 8: Resource Browsers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "RESOURCE BROWSERS"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_section "Tmux FZF Bindings & Actions"
    slide_blank
    slide_label "Pods (C-s p):" "" 6
    slide_text "Multi-select: Ctrl-a to toggle all" "" 8
    slide_key "Ctrl-l: Logs" "Creates window: \"logs:podname\"" 8
    slide_key "Ctrl-d: Describe" "Creates window: \"desc:podname\"" 8
    slide_key "Ctrl-e: Edit" "Creates window: \"edit:podname\"" 8
    slide_blank
    slide_label "Nodes (C-s n):" "" 6
    slide_key "Ctrl-d" "Describe node" 8
    slide_key "Ctrl-e" "Edit node" 8
    slide_key "Ctrl-s" "SSH to node (oc debug pod)" 8
    slide_blank
    slide_label "Operators (C-s O):" "" 6
    slide_key "Ctrl-d" "Describe cluster operator" 8
    slide_key "Ctrl-e" "Edit cluster operator" 8
    slide_blank
    slide_blank
    slide_bottom
}

slide_present build_slide
