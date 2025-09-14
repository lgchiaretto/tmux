#!/bin/bash

# Exit if not running on bastion.chiaret.to
if [ "$(hostname)" != "bastion.chiaret.to" ]; then
    echo "This script must be run on bastion.chiaret.to. Exiting."
    exit 0
fi

read -p "Would you like to proceed with oc-mirror operations? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

set -e

# Edit the DIRECTORIES variable to include the directories you want to process here
vim /home/lchiaret/quay-files/directories.txt

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
        echo "Directory: $dir"
        echo "  Channel: stable-$(echo $dir | cut -d'.' -f1,2)"
        echo "  Target registry: quay.chiaret.to/ocp4/oc-mirror-$dir"
        echo ""
    done
}

create_imagesets() {
    echo "Creating imageset configurations for all directories..."
    echo "====================================================="
    
    for dir in "${DIRECTORIES[@]}"; do
        echo "Creating imageset config for: $dir"
        
        mkdir -p "$BASE_DIR/$dir"
        
        channel=$(echo $dir | cut -d'.' -f1,2)
        
        cat > "$BASE_DIR/$dir/imageset-config.yaml" <<EOF
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v1alpha2
storageConfig:
  registry:
    imageURL: quay.chiaret.to/ocp4/oc-mirror-$dir
    skipTLS: false
mirror:
  platform:
    architectures:
    - "amd64"
    channels:
      - name: stable-$channel
        minVersion: $dir
        maxVersion: $dir
EOF
        
        echo "  Created imageset config for OpenShift $dir"
        echo "  Channel: stable-$channel"
        echo "  Target registry: quay.chiaret.to/ocp4/oc-mirror-$dir"
        echo ""
    done
    
    echo "All imageset configurations created successfully"
    echo ""
}

display_release_versions

create_imagesets

IFS=$'\n'

# Check if we're already in the target tmux session
if [ "$TMUX" ] && [ "$(tmux display-message -p '#S')" = "$TMUX_SESSION" ]; then
    tmux list-windows -t $TMUX_SESSION -F '#{window_index}' | grep -v "^$(tmux display-message -p '#I')$" | xargs -I {} tmux kill-window -t $TMUX_SESSION:{}
else
    tmux has-session -t $TMUX_SESSION 2>/dev/null && tmux kill-session -t $TMUX_SESSION
    tmux new-session -d -s $TMUX_SESSION -c $BASE_DIR
fi

if [ "$TMUX" ] && [ "$(tmux display-message -p '#S')" = "$TMUX_SESSION" ]; then
    tmux list-windows -t $TMUX_SESSION -F '#{window_index}' | grep -v "^$(tmux display-message -p '#I')$" | xargs -I {} tmux kill-window -t $TMUX_SESSION:{}
else
    tmux has-session -t $TMUX_SESSION 2>/dev/null && tmux kill-session -t $TMUX_SESSION
    tmux new-session -d -s $TMUX_SESSION -c $BASE_DIR
fi

current_window=$(tmux display-message -p '#I' 2>/dev/null || echo "0")

tmux rename-window -t $TMUX_SESSION:$current_window 'script-running'

# Create a dedicated window for auth copy
auth_window=$((current_window + 1))
tmux new-window -t $TMUX_SESSION -n 'auth-copy' -c $BASE_DIR

echo "Copying ~/auth.json to /run/user/1000/containers/auth.json in dedicated window"
tmux send-keys -t $TMUX_SESSION:$auth_window "mkdir -p /run/user/1000/containers" Enter
sleep 1
tmux send-keys -t $TMUX_SESSION:$auth_window "cp /home/lchiaret/auth.json /run/user/1000/containers/auth.json" Enter
sleep 1
tmux send-keys -t $TMUX_SESSION:$auth_window "echo 'Auth copy completed with exit code:'\$?" Enter
sleep 2

# Check if auth copy was successful
auth_status=$(tmux capture-pane -t $TMUX_SESSION:$auth_window -p | grep "Auth copy completed" | tail -1)
if [[ "$auth_status" == *"exit code:0"* ]]; then
    tmux rename-window -t $TMUX_SESSION:$auth_window 'auth-success'
    echo "Auth file copied successfully"
else
    tmux rename-window -t $TMUX_SESSION:$auth_window 'auth-failed'
    echo "Failed to copy auth file"
    echo "Check the auth-copy window for details"
fi

echo "Registry logins completed"

window_index=$((current_window + 2))  # Account for auth window

for dir in "${DIRECTORIES[@]}"; do
    echo "Processing directory: $dir"
    
    window_name="mirror-${dir//\//-}"
    tmux new-window -t $TMUX_SESSION -n "${window_name}-running" -c "$BASE_DIR/$dir"
    
    tmux send-keys -t $TMUX_SESSION:$window_index "echo 'Starting oc-mirror for $dir'" Enter
    tmux send-keys -t $TMUX_SESSION:$window_index "oc mirror --config imageset-config.yaml docker://quay.chiaret.to" Enter
    tmux send-keys -t $TMUX_SESSION:$window_index "echo 'MIRROR_EXIT_CODE:'\$?" Enter
    
    echo "Waiting for completion of $dir..."
    sleep 5
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
        echo "Last output from $dir:"
        tmux capture-pane -t $TMUX_SESSION:$window_index -p | tail -5
        exit 1
    fi
    
    window_index=$((window_index + 1))
done
tmux rename-window -t $TMUX_SESSION:$current_window 'script-success'
echo "All oc-mirror operations completed"
echo "Tmux session: $TMUX_SESSION"
