#!/usr/bin/env bash
# Slide 5: Project Overview

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/render-slide.sh"

build_slide() {
    slide_init
    slide_top
    slide_blank
    slide_title_open
    slide_title_blank
    slide_title_text "PROJECT ARCHITECTURE OVERVIEW"
    slide_title_blank
    slide_title_close
    slide_blank
    slide_blank
    slide_section "Component Layers"
    slide_blank
    slide_label "1. Core Configuration" "" 6
    slide_accent "(dotfiles/, configure-local.sh)" 9
    slide_bullet "Customized Tmux config file" 9
    slide_bullet "Customized Bashrc with Gruvbox theme and persistent history" 9
    slide_bullet "Installation script with dependencies" 9
    slide_blank
    slide_label "2. FZF Integration Layer" "" 6
    slide_accent "(fzf-files/)" 9
    slide_bullet "Seamless integration for managing and navigating resources" 9
    slide_bullet "Interactive menus for resources using fzf-tmux" 9
    slide_bullet "Action wrappers for batch operations" 9
    slide_blank
    slide_label "3. Session Templates" "" 6
    slide_accent "(tmux-sessions/*.yaml)" 9
    slide_bullet "Tmuxp YAML for cluster monitoring layouts" 9
    slide_blank
    slide_label "4. Dynamic Status Bar" "" 6
    slide_accent "(ocp-cluster.tmux, ocp-project.tmux)" 9
    slide_bullet "Context-aware cluster detection" 9
    slide_bullet "Live version/user/project display" 9
    slide_blank
    slide_bottom
}

slide_present build_slide
