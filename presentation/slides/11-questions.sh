#!/bin/bash
# Slide 11: QUESTIONS

# Source centering helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/center-content.sh"

clear

{
echo -e "    ┌───────────────────────────────────────────────────────────────────────────┐"
echo -e "    │                                                                           │"
echo -e "    │        \033[38;5;214m┌───────────────────────────────────────────────────────┐\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│               \033[38;5;142mQuestions/Comments/Feedback\033[38;5;214m             │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m│                    \033[38;5;214mSlack: \033[38;5;223m@chiaretto\033[38;5;214m                  │\033[38;5;223m          │"
echo -e "    │        \033[38;5;214m└───────────────────────────────────────────────────────┘\033[38;5;223m          │"
echo -e "    │                                                                           │"
echo -e "    └───────────────────────────────────────────────────────────────────────────┘"
} | center_content

PS1="" exec bash --norc --noprofile


