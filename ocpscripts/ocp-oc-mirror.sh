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
vim /home/lchiaret/quay-files/versions.txt

#Read DIRECTORIES from a file
PLATFORM_DIRECTORIES=(
$(cat /home/lchiaret/quay-files/versions.txt | grep -vE '^\s*#' | grep -vE '^\s*$' | grep -vE '^operators/' | sort -u)
)

TMUX_SESSION="oc-mirror-session"
BASE_DIR="/home/lchiaret/quay-files"

get_operator_directories() {
    # Find operators directories in versions.txt
    OPERATOR_DIRS=()
    while IFS= read -r line; do
        if [[ "$line" == operators/* ]]; then
            OPERATOR_DIRS+=("$line")
        fi
    done < /home/lchiaret/quay-files/versions.txt
}

display_release_versions() {
    echo "Release versions to be mirrored:"
    echo "================================"
    
    for version in "${PLATFORM_DIRECTORIES[@]}"; do
        echo "Directory: $version"
        echo "  Channel: stable-$(echo $version | cut -d'.' -f1,2)"
        echo "  Target registry: quay.chiaret.to/ocp4/oc-mirror-$version"
        echo ""
    done
    
    if [ ${#OPERATOR_DIRS[@]} -gt 0 ]; then
        echo "Operator versions to be mirrored:"
        echo "================================="
        for version in "${OPERATOR_DIRS[@]}"; do
            version=$(basename "$version")
            echo "Directory: $version"
            echo "  Target registry: quay.chiaret.to/ocp4/oc-mirror-operators-$version"
            echo ""
        done
    fi
}

create_imagesets() {
    echo "Creating imageset configurations for all directories..."
    echo "====================================================="
    
    for version in "${PLATFORM_DIRECTORIES[@]}"; do
        echo "Creating imageset config for: $version"
        
        mkdir -p "$BASE_DIR/$version"
        
        channel=$(echo $version | cut -d'.' -f1,2)
        
        cat > "$BASE_DIR/$version/imageset-config.yaml" <<EOF
kind: ImageSetConfiguration
apiVersion: mirror.openshift.io/v2alpha1
mirror:
  platform:
    architectures:
    - "amd64"
    channels:
      - name: stable-$channel
        minVersion: $version
        maxVersion: $version
EOF
        
        echo "  Created imageset config for OpenShift $version"
        echo "  Channel: stable-$channel"
        echo "  Target registry: quay.chiaret.to/ocp4/oc-mirror-$version"
        echo ""
    done
    
    echo "All imageset configurations created successfully"
    echo ""
}

get_operator_directories

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

# Process platform releases
for version in "${PLATFORM_DIRECTORIES[@]}"; do
    echo "Processing platform release: $version"
    
    window_name="platform-$version"
    tmux new-window -t $TMUX_SESSION -n "${window_name}-running" -c "$BASE_DIR/$version"
    
    tmux send-keys -t $TMUX_SESSION:$window_index "echo 'Starting oc-mirror for platform $version'" Enter
    tmux send-keys -t $TMUX_SESSION:$window_index "cd $BASE_DIR/$version && oc mirror --v2 --config imageset-config.yaml --workspace file://\$(pwd) docker://quay.chiaret.to" Enter
    tmux send-keys -t $TMUX_SESSION:$window_index "echo 'EXIT_CODE:'\$?" Enter
    
    echo "Waiting for completion of platform $version..."
    sleep 5
    while true; do
        current_command=$(tmux list-panes -t $TMUX_SESSION:$window_index -F '#{pane_current_command}' 2>/dev/null || echo "")
        if [[ "$current_command" == "oc-mirror" ]]; then
            echo "  oc-mirror still running for platform $version..."
            sleep 15
        else
            echo "  oc-mirror process completed for platform $version"
            break
        fi
    done
    
    sleep 3
    echo "  Checking exit code for platform $version..."
    pane_output=$(tmux capture-pane -t $TMUX_SESSION:$window_index -p)
    exit_code_line=$(echo "$pane_output" | grep "EXIT_CODE:" | tail -1)
    has_error=$(echo "$pane_output" | grep -i "\[ERROR\]" | wc -l)
    
    if [[ "$exit_code_line" == *"EXIT_CODE:0"* ]] && [[ "$has_error" -eq 0 ]]; then
        exit_code=0
    else
        exit_code=1
    fi
    
    if [ "$exit_code" = "0" ]; then
        tmux rename-window -t $TMUX_SESSION:$window_index "${window_name}-success"
        echo "Completed successfully: platform $version (exit code: $exit_code)"
    else
        tmux rename-window -t $TMUX_SESSION:$window_index "${window_name}-failed"
        echo "Failed: platform $version (exit code: $exit_code)"
        echo "Last output from platform $version:"
        tmux capture-pane -t $TMUX_SESSION:$window_index -p | tail -5
        # exit 1
    fi
    
    window_index=$((window_index + 1))
done

# Process operator releases
for version in "${OPERATOR_DIRS[@]}"; do
    echo "Processing operators: $version"
    
    version=$(basename "$version")
    window_name="operators-${version}"
    tmux new-window -t $TMUX_SESSION -n "${window_name}-running" -c "$BASE_DIR/$version"
    
    tmux send-keys -t $TMUX_SESSION:$window_index "echo 'Starting oc-mirror for operators $version'" Enter
    tmux send-keys -t $TMUX_SESSION:$window_index "cd $BASE_DIR/operators/$version && oc mirror --v2 --config imageset-config.yaml --workspace file://\$(pwd) docker://quay.chiaret.to" Enter
    tmux send-keys -t $TMUX_SESSION:$window_index "echo 'EXIT_CODE:'\$?" Enter
    
    echo "Waiting for completion of operators $version..."
    sleep 5
    while true; do
        current_command=$(tmux list-panes -t $TMUX_SESSION:$window_index -F '#{pane_current_command}' 2>/dev/null || echo "")
        if [[ "$current_command" == "oc-mirror" ]]; then
            echo "  oc-mirror still running for operators $version..."
            sleep 15
        else
            echo "  oc-mirror process completed for operators $version"
            break
        fi
    done
    
    sleep 3
    echo "  Checking exit code for operators $version..."
    pane_output=$(tmux capture-pane -t $TMUX_SESSION:$window_index -p)
    exit_code_line=$(echo "$pane_output" | grep "EXIT_CODE:" | tail -1)
    has_error=$(echo "$pane_output" | grep -i "\[ERROR\]" | wc -l)
    has_goodbye=$(echo "$pane_output" | grep "Goodbye, thank you for using oc-mirror" | wc -l)
    
    if [[ "$exit_code_line" == *"EXIT_CODE:0"* ]] && [[ "$has_error" -eq 0 ]] && [[ "$has_goodbye" -gt 0 ]]; then
        exit_code=0
    else
        exit_code=1
    fi
    
    if [ "$exit_code" = "0" ]; then
        tmux rename-window -t $TMUX_SESSION:$window_index "${window_name}-success"
        echo "Completed successfully: operators $version (exit code: $exit_code)"
    else
        tmux rename-window -t $TMUX_SESSION:$window_index "${window_name}-failed"
        echo "Failed: operators $version (exit code: $exit_code)"
        echo "Last output from operators $version:"
        tmux capture-pane -t $TMUX_SESSION:$window_index -p | tail -5
        exit 1
    fi
    
    window_index=$((window_index + 1))
done
tmux rename-window -t $TMUX_SESSION:$current_window 'script-success'
echo "All oc-mirror operations completed (platform releases and operators)"
echo "Tmux session: $TMUX_SESSION"
