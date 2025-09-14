#!/bin/bash

# Exit if not running on bastion.chiaret.to
if [ "$(hostname)" != "bastion.chiaret.to" ]; then
    echo "This script must be run on bastion.chiaret.to. Exiting."
    exit 0
fi

set -e

#Read DIRECTORIES from a file
DIRECTORIES=(
$(cat /home/lchiaret/quay-files/directories.txt | grep -vE '^\s*#' | grep -vE '^\s*$')
)

TMUX_SESSION="oc-mirror-session"
BASE_DIR="/home/lchiaret/quay-files"

display_release_versions() {
    echo "Release versions to be mirrored:"
    echo "================================"
    
    for dir in "${DIRECTORIES[@]}"; do
        config_file="$BASE_DIR/$dir/imageset-config.yaml"
        if [ -f "$config_file" ]; then
            echo "Directory: $dir"
            
            # Check if it's a platform config (has minVersion/maxVersion)
            if grep -q "minVersion\|maxVersion" "$config_file"; then
                channel=$(grep -A5 "channels:" "$config_file" | grep "name:" | head -1 | sed 's/.*name: //' | tr -d '"')
                min_version=$(grep "minVersion:" "$config_file" | sed 's/.*minVersion: //' | tr -d '"')
                max_version=$(grep "maxVersion:" "$config_file" | sed 's/.*maxVersion: //' | tr -d '"')
                echo "  Min Version: $min_version"
                echo "  Max Version: $max_version"
            # Check if it's an operators config
            elif grep -q "operators:" "$config_file"; then
                catalog=$(grep "catalog:" "$config_file" | sed 's/.*catalog: //' | tr -d '"')
                echo "  Catalog: $catalog"
                # Extract operator package names (lines with '- name:' under packages section)
                operators=$(sed -n '/packages:/,/additionalImages:\|^[^ ]/p' "$config_file" | grep "^    - name:" | sed 's/.*name: //' | tr -d '"' | sort -u)
                if [ -n "$operators" ]; then
                    echo "  Operators:"
                    echo "$operators" | while read -r op; do
                        echo "    - $op"
                    done
                fi
            fi
            echo ""
        fi
    done
}

display_release_versions

read -p "Would you like to proceed with oc-mirror operations? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

IFS=$'\n'

# Check if we're already in the target tmux session
if [ "$TMUX" ] && [ "$(tmux display-message -p '#S')" = "$TMUX_SESSION" ]; then
    # Kill all windows except the current one
    tmux list-windows -t $TMUX_SESSION -F '#{window_index}' | grep -v "^$(tmux display-message -p '#I')$" | xargs -I {} tmux kill-window -t $TMUX_SESSION:{}
else
    # Kill existing session if it exists and create new one
    tmux has-session -t $TMUX_SESSION 2>/dev/null && tmux kill-session -t $TMUX_SESSION
    tmux new-session -d -s $TMUX_SESSION -c $BASE_DIR
fi

# Check if we're already in the target tmux session
if [ "$TMUX" ] && [ "$(tmux display-message -p '#S')" = "$TMUX_SESSION" ]; then
    # Kill all windows except the current one
    tmux list-windows -t $TMUX_SESSION -F '#{window_index}' | grep -v "^$(tmux display-message -p '#I')$" | xargs -I {} tmux kill-window -t $TMUX_SESSION:{}
else
    # Kill existing session if it exists and create new one
    tmux has-session -t $TMUX_SESSION 2>/dev/null && tmux kill-session -t $TMUX_SESSION
    tmux new-session -d -s $TMUX_SESSION -c $BASE_DIR
fi

# Get current window index
current_window=$(tmux display-message -p '#I' 2>/dev/null || echo "0")

tmux rename-window -t $TMUX_SESSION:$current_window 'script-running'

echo "Copying ~/auth.json to /run/user/1000/containers/auth.json"
tmux send-keys -t $TMUX_SESSION:$current_window "cp ~/auth.json /run/user/1000/containers/auth.json" Enter
sleep 2

echo "Registry logins completed"

# Start window index after current window
window_index=$((current_window + 1))

for dir in "${DIRECTORIES[@]}"; do
    if [ -f "$BASE_DIR/$dir/imageset-config.yaml" ]; then
        echo "Processing directory: $dir"
        
        window_name="mirror-${dir//\//-}"
        tmux new-window -t $TMUX_SESSION -n "${window_name}-running" -c "$BASE_DIR/$dir"
        
        tmux send-keys -t $TMUX_SESSION:$window_index "echo 'Starting oc-mirror for $dir'" Enter
        tmux send-keys -t $TMUX_SESSION:$window_index "oc mirror --config imageset-config.yaml docker://quay.chiaret.to" Enter
        tmux send-keys -t $TMUX_SESSION:$window_index "echo 'MIRROR_EXIT_CODE:'\$?" Enter
        
        echo "Waiting for completion of $dir..."
        # Wait for the oc-mirror process to start
        sleep 5
        # Monitor the process more carefully
        while true; do
            current_command=$(tmux list-panes -t $TMUX_SESSION:$window_index -F '#{pane_current_command}' 2>/dev/null || echo "")
            if [[ "$current_command" == "oc-mirror" ]]; then
                echo "  oc-mirror still running for $dir..."
                sleep 15
            else
                echo "  oc-mirror process completed for $dir"
                break
            fi
        done
        
        sleep 3
        # Wait for exit code to appear in output
        echo "  Checking exit code for $dir..."
        for i in {1..10}; do
            exit_code=$(tmux capture-pane -t $TMUX_SESSION:$window_index -p | grep "MIRROR_EXIT_CODE:" | tail -1 | cut -d: -f2 | tr -d ' ')
            if [[ -n "$exit_code" ]]; then
                break
            fi
            echo "  Waiting for exit code... (attempt $i)"
            sleep 2
        done
        
        if [ "$exit_code" = "0" ]; then
            tmux rename-window -t $TMUX_SESSION:$window_index "${window_name}-success"
            echo "Completed successfully: $dir (exit code: $exit_code)"
        else
            tmux rename-window -t $TMUX_SESSION:$window_index "${window_name}-failed"
            echo "Failed: $dir (exit code: $exit_code)"
            # Show last few lines for debugging
            echo "Last output from $dir:"
            tmux capture-pane -t $TMUX_SESSION:$window_index -p | tail -5
            exit 1
        fi
        
        window_index=$((window_index + 1))
    else
        echo "Skipping $dir - no imageset-config.yaml found"
    fi
done
tmux rename-window -t $TMUX_SESSION:$current_window 'script-success'
echo "All oc-mirror operations completed"
echo "Tmux session: $TMUX_SESSION"
