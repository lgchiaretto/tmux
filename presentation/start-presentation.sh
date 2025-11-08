#!/bin/bash
# Quick launcher for Tmux Control Plane Presentation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make all slide scripts executable
chmod +x "$SCRIPT_DIR"/slides/*.sh
chmod +x "$SCRIPT_DIR"/tmux-presentation.sh

exec "$SCRIPT_DIR/tmux-presentation.sh"
