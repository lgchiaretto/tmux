#!/bin/bash
# Tmux Control Plane Presentation - Interactive Slides
# Use C-s n/p to navigate between slides (next/previous)

SESSION_NAME="tmux-presentation"
SLIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/slides" && pwd)"

# Color definitions (Gruvbox theme)
COLOR_RESET="\033[0m"
COLOR_TITLE="\033[1;33m"      # Yellow bold
COLOR_SUBTITLE="\033[36m"     # Cyan
COLOR_TEXT="\033[37m"         # White
COLOR_HIGHLIGHT="\033[1;32m"  # Green bold
COLOR_CODE="\033[35m"         # Magenta

# Slides array - order matters
SLIDES=(
    "01-intro.sh"
    "02-what-is-tmux.sh"
    "03-tmux-basics.sh"
    "04-tmux-config.sh"
    "05-project-overview.sh"
    "06-fzf-integration.sh"
    "07-cluster-management.sh"
    "08-resource-browsers.sh"
    "09-automation-integration.sh"
    "10-live-demo.sh"
    "12-conclusion.sh"
)

TOTAL_SLIDES=${#SLIDES[@]}
CURRENT_SLIDE=0

# Create or attach to presentation session
create_presentation_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
    fi
    
    tmux new-session -d -s "$SESSION_NAME"
    
#    tmux set-option -t "$SESSION_NAME" status on
#    tmux set-option -t "$SESSION_NAME" status-position bottom
#    tmux set-option -t "$SESSION_NAME" status-style "bg=#1d2021,fg=#d8a657"
    tmux set-option -t "$SESSION_NAME" status-left-length 30
    tmux set-option -t "$SESSION_NAME" status-right-length 30
    tmux set-option -t "$SESSION_NAME" status-left "#[fg=#1d2021,bg=#d8a657,bold] ◀ Previous #[fg=#d8a657,bg=#1d2021]"
    tmux set-option -t "$SESSION_NAME" status-right "#[fg=#d8a657,bg=#1d2021]#[fg=#1d2021,bg=#d8a657,bold] Next ▶ "
    tmux set-option -t "$SESSION_NAME" status-justify centre
## Hide window list in center - only show buttons
#    # Use -gw to set the global-window option for this session
#    tmux set-option -t "$SESSION_NAME" -w window-status-format ""
#    tmux set-option -t "$SESSION_NAME" -w window-status-current-format ""
#    tmux set-option -t "$SESSION_NAME" -w window-status-separator ""
    
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
    
    tmux bind-key -n -T root MouseDown1StatusLeft select-window -p -t "$SESSION_NAME"
    tmux bind-key -n -T root MouseDown1StatusRight select-window -n -t "$SESSION_NAME"
        tmux attach-session -t "$SESSION_NAME"
}

# Main execution
main() {
    if [[ "$1" == "--cleanup" ]]; then
        tmux kill-session -t "$SESSION_NAME" 2>/dev/null
        echo "Presentation session cleaned up"
        exit 0
    fi
    
    create_presentation_session
}

main "$@"
