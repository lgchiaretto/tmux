#!/bin/bash
# Slide 10: CONCLUSION

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

# Generate slide content and pipe to center function
{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                   CONCLUSION                          │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mWhat We Covered\033[38;5;223m                                                          │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Tmux fundamentals and custom configuration                           │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m FZF integration for interactive resource browsing                    │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Cluster lifecycle management workflows                               │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m OpenShift automation integration                                     │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Multi-host synchronized operations                                   │"
echo -e "    │    \033[38;5;208m✓\033[38;5;223m Dynamic status bar with context awareness                            │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mKey Takeaways\033[38;5;223m                                                            │"
echo -e "    │                                                                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Tmux provides powerful session/window/pane management                │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m FZF adds interactive, scriptable menus                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Consistent patterns across all scripts                               │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Deep integration with OpenShift automation                           │"
echo -e "    │    \033[38;5;208m•\033[38;5;223m Organized workflows for complex operations                           │"
echo -e "    │                                                                           │"
echo -e "    │                                                                           │"
echo -e "    │  \033[38;5;142mGetting Started\033[38;5;223m                                                          │"
echo -e "    │                                                                           │"
echo -e "    │  1. Clone repository: git clone <repo>                                    │"
echo -e "    │  2. Run: ./configure-local.sh --download-tmux --download-oc               │"
echo -e "    │  3. Explore FZF scripts in ~/.tmux/                                       │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile
