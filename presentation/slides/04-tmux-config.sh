#!/usr/bin/env bash
# Slide 4: Tmux Configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "CUSTOM TMUX CONFIGURATION"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_section "dotfiles/tmux.conf - Key Customizations"
    slide_blank
    slide_label "Prefix Key:" "" 6
    slide_code "set-option -g prefix C-s" "Change from C-b to C-s"
    slide_code "unbind-key C-b" "Remove default binding"
    slide_blank
    slide_label "Window Management:" "" 6
    slide_code "bind-key -n C-t new-window" "Create window"
    slide_code "bind-key -n S-Left/Right" "Navigate windows"
    slide_code "bind-key -n C-S-Left/Right" "Move window position"
    slide_blank
    slide_label "Pane Management:" "" 6
    slide_code "bind-key -n C-\\" "Split horizontal (no prefix)"
    slide_code "bind-key - split-window -v" "Split vertical (C-s)"
    slide_code "bind-key -n C-Arrow" "Navigate panes (no prefix)"
    slide_code "bind-key a synchronize-panes" "Sync panes (needs C-s)"
    slide_blank
    slide_blank
    slide_section "Dynamic Status Bar (ocp-cluster.tmux)"
    slide_blank
    slide_text "Auto-detects cluster context:" "" 6
    slide_text "1. Check \$CLUSTERS_BASE_PATH/\$SESSION_NAME/auth/kubeconfig" "" 8
    slide_text "2. Fallback to 'oc whoami' for active context" "" 8
    slide_blank
    slide_text "Display format:" "" 6
    slide_text "4.19.19:(k):openshift-config" "$C_CODE" 8
    slide_text "└─ version ─┘└ user ┘└── project ──┘" "" 8
    slide_blank
    slide_text "Error states: N/A | <no-project> | <deleted>" "" 6
    slide_blank
    slide_bottom
}

slide_present build_slide
