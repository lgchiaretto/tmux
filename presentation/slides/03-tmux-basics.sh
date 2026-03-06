#!/usr/bin/env bash
# Slide 3: Tmux Basics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "TMUX BASIC CONCEPTS"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_section "Hierarchy: Session > Window > Pane"
    slide_blank
    slide_text "${C_HI}Session${C_TEXT} (live-demo)" "" 6
    slide_text "├── ${C_HI}Window 1:${C_TEXT} watch-cluster" "" 6
    slide_text "│   ├── ${C_CODE}Pane 1: watch oc get pods" "" 6
    slide_text "│   └── ${C_CODE}Pane 2: watch oc get clusteroperators" "" 6
    slide_text "├── ${C_HI}Window 2:${C_TEXT} logs:etcd-pod" "" 6
    slide_text "│   └── ${C_CODE}Pane 1: oc logs -f" "" 6
    slide_text "└── ${C_HI}Window 3:${C_TEXT} bash" "" 6
    slide_text "    └── ${C_CODE}Pane 1: interactive shell" "" 6
    slide_blank
    slide_blank
    slide_section "Custom Prefix: C-s (NOT default C-b)"
    slide_blank
    slide_label "Session Management:" "" 6
    slide_key "C-s d" "Detach session"
    slide_key "C-s N" "Create new session"
    slide_key "tmux attach" "Reattach to session"
    slide_blank
    slide_label "Window Management:" "" 6
    slide_key "C-t" "Create new window"
    slide_key "S-Left/Right" "Navigate between windows"
    slide_key "C-s ," "Rename window"
    slide_key "C-S-Left/Right" "Move window left/right"
    slide_blank
    slide_label "Pane Management:" "" 6
    slide_key "C-\\" "Split horizontal"
    slide_key "C-s -" "Split vertical"
    slide_key "C-Arrow" "Navigate between panes"
    slide_key "M-S-Arrow" "Resize pane"
    slide_key "C-s z" "Zoom/unzoom pane"
    slide_key "C-s a" "Toggle synchronized panes"
    slide_blank
    slide_blank
    slide_bottom
}

slide_present build_slide
