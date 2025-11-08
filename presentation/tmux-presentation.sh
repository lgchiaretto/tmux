#!/bin/bash

SESSION_NAME="talks-tmux"
SLIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/slides" && pwd)"

# Color definitions (Gruvbox theme)
COLOR_RESET="\033[0m"
COLOR_TITLE="\033[1;33m"      # Yellow bold
COLOR_SUBTITLE="\033[36m"     # Cyan
COLOR_TEXT="\033[37m"         # White
COLOR_HIGHLIGHT="\033[1;32m"  # Green bold
COLOR_CODE="\033[35m"         # Magenta

SLIDES=(
    "01-intro.sh"
    "02-what-is-tmux.sh"
    "03-tmux-basics.sh"
    "04-tmux-config.sh"
    "05-project-overview.sh"
    "06-fzf-integration.sh"
    "07-bash-customization.sh"
    "08-resource-browsers.sh"
    "09-live-demo.sh"
    "10-conclusion.sh"
    "11-questions.sh"
)

TOTAL_SLIDES=${#SLIDES[@]}

create_presentation_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
    fi

    tmux new-session -d -s "$SESSION_NAME"
    
    tmux set-option -t "$SESSION_NAME" status-justify centre
    tmux set-option -t "$SESSION_NAME" status-position top
    tmux set-option -t "$SESSION_NAME" status-left ""
    tmux set-option -t "$SESSION_NAME" status-right ""
    tmux set-option -t "$SESSION_NAME" status-style "bg=default,fg=colour245"
    #tmux set-option -t "$SESSION_NAME" -gw window-status-current-format '#[fg=colour223,  nobold, noitalics, nounderscore]#W #[fg=colour214] |'
    #tmux set-option -t "$SESSION_NAME" -gw window-status-format '#[fg=colour244,  nobold, noitalics, nounderscore]#W #[fg=colour214] |'


    for i in "${!SLIDES[@]}"; do
        local slide_script="${SLIDES[$i]}"
        local window_index=$i
        
        local window_name=$(echo "$slide_script" | sed 's/^[0-9]*-//' | sed 's/.sh$//' | sed 's/-/ /g')
        
        if [[ -f "$SLIDES_DIR/$slide_script" ]]; then
            if [[ $i -eq 0 ]]; then
                tmux rename-window -t "$SESSION_NAME:0" "$window_name"
                tmux send-keys -t "$SESSION_NAME:0" "PS1=\"\" bash $SLIDES_DIR/$slide_script" C-m
            else
                tmux new-window -t "$SESSION_NAME:$window_index" -n "$window_name"
                tmux send-keys -t "$SESSION_NAME:$window_index" "PS1=\"\" bash $SLIDES_DIR/$slide_script" C-m
            fi
        fi
    done

    tmux select-window -t "$SESSION_NAME:0"

    if [ -z "$TMUX" ]; then
        tmux attach-session -t "$SESSION_NAME"
    else
        tmux switch-client -t "$SESSION_NAME"
    fi
}

main() {
    if [[ "$1" == "--cleanup" ]]; then
        tmux kill-session -t "$SESSION_NAME" 2>/dev/null
        echo "Presentation session cleaned up"
        exit 0
    fi

    create_presentation_session
}

main "$@"
