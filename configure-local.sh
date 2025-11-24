#!/usr/bin/env bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1"
}

# Function to copy dotfiles to a user home directory
copy_dotfiles_to_user() {
    local target_home="$1"
    local target_user="$2"
    
    log "Updating configuration for user: $target_user"
    
    # Copy dotfiles from /etc/skel (which is our source of truth)
    sudo cp /etc/skel/.bashrc "$target_home/.bashrc" > /dev/null 2>&1
    sudo cp /etc/skel/.tmux.conf "$target_home/.tmux.conf" > /dev/null 2>&1
    sudo cp /etc/skel/.vimrc "$target_home/.vimrc" > /dev/null 2>&1
    sudo cp /etc/skel/.dircolors "$target_home/.dircolors" > /dev/null 2>&1
    sudo cp /etc/skel/.inputrc "$target_home/.inputrc" > /dev/null 2>&1
    sudo cp /etc/skel/.bash_functions "$target_home/.bash_functions" > /dev/null 2>&1
    sudo cp /etc/skel/.ansible.cfg "$target_home/.ansible.cfg" > /dev/null 2>&1
    
    # Copy vim-plug
    sudo mkdir -p "$target_home/.vim/autoload" > /dev/null 2>&1
    sudo cp /etc/skel/.vim/autoload/plug.vim "$target_home/.vim/autoload/plug.vim" > /dev/null 2>&1
    
    # Create .tmux directory and copy config.sh if it doesn't exist
    sudo mkdir -p "$target_home/.tmux" > /dev/null 2>&1
    if [ ! -f "$target_home/.tmux/config.sh" ]; then
        sudo cp /etc/skel/.tmux/config.sh "$target_home/.tmux/config.sh" > /dev/null 2>&1
        sudo chmod 600 "$target_home/.tmux/config.sh" > /dev/null 2>&1
        log "Created config at $target_home/.tmux/config.sh"
    fi
    
    # Fix ownership
    sudo chown -R "$target_user:$target_user" "$target_home/.bashrc" "$target_home/.tmux.conf" \
        "$target_home/.vimrc" "$target_home/.dircolors" "$target_home/.inputrc" \
        "$target_home/.bash_functions" "$target_home/.ansible.cfg" \
        "$target_home/.vim" "$target_home/.tmux" > /dev/null 2>&1
}

show_help() {
    cat << 'EOF'
Tmux OpenShift Tools - Global Configuration Installer
======================================================

This script installs and configures the Tmux OpenShift environment globally
for all users on the system. It creates a shared configuration that provides
a consistent experience across all user accounts.

USAGE:
    sudo ./configure-local.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message and exit
    
    --download-tmux         Download and install the Tmux binary to /usr/local/bin/
                           (automatically enabled if tmux is not found)
    
    --download-oc           Download and install the OpenShift CLI (oc) to /usr/local/bin/
                           (automatically enabled if oc is not found)
    
    --update-users          Install dotfiles in /etc/skel/ for ALL users (system-wide)
                           This will:
                           • Copy dotfiles to /etc/skel/ (template for new users)
                           • Update ALL existing users with dotfiles from /etc/skel/
                           • New users will automatically get the configuration
                           (by default, installs ONLY for current user)

WHAT THIS SCRIPT DOES:
    
    Global Installation (always performed):
    ---------------------------------------
    • Creates /usr/local/share/tmux-ocp/ directory for shared scripts
    • Installs all scripts to /usr/local/bin/ (ocpcreatecluster, fzf-*, etc.)
    • Installs shared resources to /usr/local/share/tmux-ocp/
    • Installs fzf globally
    • Installs Python packages globally (tmuxp, yq, bat)
    • Installs and enables systemd services (update-ocp-cache, updatedb, generate-graph)
    
    Without --update-users (default):
    ---------------------------------
    • Installs dotfiles ONLY for current user
    • Creates ~/.tmux/config.sh for current user
    • Other users are NOT affected
    • /etc/skel/ is NOT modified
    
    With --update-users:
    --------------------
    • Installs dotfiles to /etc/skel/ (system-wide template)
    • Updates ALL existing users with dotfiles from /etc/skel/
    • New users automatically inherit the configuration
    • Root user is also updated

INSTALLATION LOCATIONS:
    
    ~/.tmux/config.sh                    User configuration (independent per user)
    /usr/local/bin/                      Executable scripts (global)
    /usr/local/share/tmux-ocp/           Shared resources (fzf-files, tmux-sessions)
    /etc/skel/                           Template for new users
    /etc/systemd/system/                 System services

EXAMPLES:
    
    Basic installation (recommended for first-time setup):
        ./configure-local.sh
    
    Install and update all existing users:
        ./configure-local.sh --update-users
    
    Install with tmux and oc downloads:
        ./configure-local.sh --download-tmux --download-oc
    
    Full installation updating everything:
        ./configure-local.sh --update-users --download-tmux --download-oc

EOF
    exit 0
}

# Parse command line arguments
UPDATE_USERS=false
DOWNLOAD_TMUX=false
DOWNLOAD_OC=false

for arg in "$@"; do
    case "$arg" in
        --help|-h)
            show_help
            ;;
        --download-tmux)
            DOWNLOAD_TMUX=true
            ;;
        --download-oc)
            DOWNLOAD_OC=true
            ;;
        --update-users)
            UPDATE_USERS=true
            ;;
        *)
            echo "Error: Invalid option '$arg'"
            echo "Use './configure-local.sh --help' to see available options."
            exit 1
            ;;
    esac
done

CALLER_PATH="${BASH_SOURCE[1]}"
TMUX_DIR="$(dirname "$CALLER_PATH")"

log "Configuring Tmux environment for all users"

# Create directory for global fzf scripts and tmux sessions
log "Creating /usr/local/share/tmux-ocp directory"
sudo mkdir -p /usr/local/share/tmux-ocp/{fzf-files,tmux-sessions,common} > /dev/null 2>&1

# Install common scripts
log "Installing common scripts"
sudo cp $TMUX_DIR/common/* /usr/local/share/tmux-ocp/common/ > /dev/null 2>&1
sudo chmod +x /usr/local/share/tmux-ocp/common/*.sh > /dev/null 2>&1

# Create directory for global fzf scripts and tmux sessions
log "Creating /usr/local/share/tmux-ocp directory"
sudo mkdir -p /usr/local/share/tmux-ocp/{fzf-files,tmux-sessions} > /dev/null 2>&1

log "Installing fzf globally for all users"
if [ ! -d "/usr/local/share/fzf" ]; then
    log "Cloning fzf repository"
    sudo git clone https://github.com/junegunn/fzf.git /usr/local/share/fzf > /dev/null 2>&1
    log "Installing fzf binary and shell integration"
    cd /usr/local/share/fzf > /dev/null 2>&1
    sudo ./install --bin --no-update-rc --no-bash --no-zsh --no-fish > /dev/null 2>&1
    cd - > /dev/null 2>&1
    sudo cp /usr/local/share/fzf/bin/fzf /usr/local/bin/ > /dev/null 2>&1
    sudo cp /usr/local/share/fzf/bin/fzf-tmux /usr/local/bin/ > /dev/null 2>&1
    sudo chmod +x /usr/local/bin/fzf > /dev/null 2>&1
    sudo chmod +x /usr/local/bin/fzf-tmux > /dev/null 2>&1
    log "fzf and fzf-tmux installed globally at /usr/local/bin/"
else
    log "fzf already installed globally"
fi

CURRENT_USER="${SUDO_USER:-$USER}"
CURRENT_USER_HOME=$(eval echo ~$CURRENT_USER)

if [ "$UPDATE_USERS" = true ]; then
    log "Installing dotfiles to /etc/skel/ for all users (--update-users enabled)"
    
    log "Copying dotfiles to /etc/skel"
    sudo cp $TMUX_DIR/dotfiles/bashrc /etc/skel/.bashrc > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/tmux.conf /etc/skel/.tmux.conf > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/vimrc /etc/skel/.vimrc > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/dircolors /etc/skel/.dircolors > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/inputrc /etc/skel/.inputrc > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/bash_functions /etc/skel/.bash_functions > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/ansible.cfg /etc/skel/.ansible.cfg > /dev/null 2>&1
    
    log "Installing vim-plug for all users"
    sudo mkdir -p /etc/skel/.vim/autoload > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/plug.vim /etc/skel/.vim/autoload/plug.vim > /dev/null 2>&1
    
    log "Setting up .tmux/config.sh template in /etc/skel"
    sudo mkdir -p /etc/skel/.tmux > /dev/null 2>&1
    sudo cp "$TMUX_DIR/config.sh.example" /etc/skel/.tmux/config.sh > /dev/null 2>&1
    sudo chmod 600 /etc/skel/.tmux/config.sh > /dev/null 2>&1
    
    log "Updating all existing users from /etc/skel/"
    # Update all users in /home
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            copy_dotfiles_to_user "$user_home" "$username"
        fi
    done
    
    # Also update root user
    if [ -d "/root" ]; then
        copy_dotfiles_to_user "/root" "root"
    fi
    
    log "All users updated. New users will inherit from /etc/skel/"
else
    log "Installing dotfiles only for current user: $CURRENT_USER"
    
    # Copy directly to current user (no /etc/skel/)
    log "Copying dotfiles to $CURRENT_USER_HOME"
    sudo cp $TMUX_DIR/dotfiles/bashrc "$CURRENT_USER_HOME/.bashrc" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/tmux.conf "$CURRENT_USER_HOME/.tmux.conf" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/vimrc "$CURRENT_USER_HOME/.vimrc" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/dircolors "$CURRENT_USER_HOME/.dircolors" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/inputrc "$CURRENT_USER_HOME/.inputrc" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/bash_functions "$CURRENT_USER_HOME/.bash_functions" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/ansible.cfg "$CURRENT_USER_HOME/.ansible.cfg" > /dev/null 2>&1
    
    log "Installing vim-plug for current user"
    sudo mkdir -p "$CURRENT_USER_HOME/.vim/autoload" > /dev/null 2>&1
    sudo cp $TMUX_DIR/dotfiles/plug.vim "$CURRENT_USER_HOME/.vim/autoload/plug.vim" > /dev/null 2>&1
    
    log "Creating config file for current user"
    sudo mkdir -p "$CURRENT_USER_HOME/.tmux" > /dev/null 2>&1
    if [ ! -f "$CURRENT_USER_HOME/.tmux/config.sh" ]; then
        sudo cp "$TMUX_DIR/config.sh.example" "$CURRENT_USER_HOME/.tmux/config.sh" > /dev/null 2>&1
        sudo chmod 600 "$CURRENT_USER_HOME/.tmux/config.sh" > /dev/null 2>&1
        log "Created config at $CURRENT_USER_HOME/.tmux/config.sh"
    fi
    
    # Fix ownership
    sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$CURRENT_USER_HOME/.bashrc" "$CURRENT_USER_HOME/.tmux.conf" \
        "$CURRENT_USER_HOME/.vimrc" "$CURRENT_USER_HOME/.dircolors" "$CURRENT_USER_HOME/.inputrc" \
        "$CURRENT_USER_HOME/.bash_functions" "$CURRENT_USER_HOME/.ansible.cfg" \
        "$CURRENT_USER_HOME/.vim" "$CURRENT_USER_HOME/.tmux" > /dev/null 2>&1
    
    log "Current user updated. Other users NOT affected (use --update-users to install for all)"
fi

log "Copying fzf-files to global location"
sudo cp $TMUX_DIR/fzf-files/* /usr/local/share/tmux-ocp/fzf-files/ > /dev/null 2>&1
sudo chmod +x /usr/local/share/tmux-ocp/fzf-files/*.sh > /dev/null 2>&1

log "Copying tmux-sessions to global location"
sudo cp -R $TMUX_DIR/tmux-sessions/* /usr/local/share/tmux-ocp/tmux-sessions/ > /dev/null 2>&1

# Check if we should download tmux (flag or binary doesn't exist)
if [ "$DOWNLOAD_TMUX" = true ] || [ ! -f "/usr/local/bin/tmux" ]; then
    log "Downloading tmux binary"
    wget -q --no-check-certificate 'https://gpte-public-documents.s3.us-east-1.amazonaws.com/rh1_2025_lab17/rh1-lab17-tmux-binary' -O tmux > /dev/null 2>&1
    log "Copying tmux binary to /usr/local/bin"
    sudo cp tmux /usr/local/bin/ > /dev/null 2>&1
    sudo chmod +x /usr/local/bin/tmux > /dev/null 2>&1
    rm -f tmux > /dev/null 2>&1
fi

# Check if we should download oc (flag or binary doesn't exist)
if [ "$DOWNLOAD_OC" = true ] || [ ! -f "/usr/local/bin/oc" ]; then
    log "Downloading OpenShift CLI client"
    wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.13/openshift-client-linux.tar.gz > /dev/null 2>&1
    log "Extracting OpenShift CLI client"
    tar xzf openshift-client-linux.tar.gz > /dev/null 2>&1
    log "Copying oc binary to /usr/local/bin"
    sudo cp oc /usr/local/bin/ > /dev/null 2>&1
    log "Setting executable permissions for oc"
    sudo chmod +x /usr/local/bin/oc > /dev/null 2>&1
    rm -f oc kubectl openshift-client-linux.tar.gz > /dev/null 2>&1
fi

log "Creating oc-logs-fzf.sh script"
sudo cp oc-logs-fzf.sh /usr/local/bin/ > /dev/null 2>&1

log "Creating OCP scripts to /usr/local/bin"
sudo cp ocpscripts/* /usr/local/bin/ > /dev/null 2>&1

log "Setting executable permissions for oc-logs-fzf.sh"
sudo chmod +x /usr/local/bin/oc-logs-fzf.sh > /dev/null 2>&1

log "Installing tmuxp, bat and yq"
sudo dnf install -y python3-pip -q > /dev/null 2>&1
sudo pip3 install tmuxp yq bat -q > /dev/null 2>&1

log "Installing update-ocp-cache systemd configuration"
sudo cp update-ocp-cache/systemd/update-ocp-cache.service /etc/systemd/system/ > /dev/null 2>&1
sudo cp update-ocp-cache/systemd/update-ocp-cache.timer /etc/systemd/system/ > /dev/null 2>&1
sudo cp update-ocp-cache/scripts/update_ocp_cache.py /usr/local/bin/ > /dev/null 2>&1
sudo chmod +x /usr/local/bin/update_ocp_cache.py > /dev/null 2>&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl enable update-ocp-cache.timer > /dev/null 2>&1
sudo systemctl start update-ocp-cache.timer > /dev/null 2>&1

log "Installing updatedb systemd configuration"
sudo cp updatedb/systemd/updatedb.service /etc/systemd/system/ > /dev/null 2>&1
sudo cp updatedb/systemd/updatedb.timer /etc/systemd/system/ > /dev/null 2>&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl enable updatedb.timer > /dev/null 2>&1
sudo systemctl start updatedb.timer > /dev/null 2>&1

log "Installing generate-graph systemd configuration"
sudo cp generate-ocp-graph/systemd/generate-graph.service /etc/systemd/system/ > /dev/null 2>&1
sudo cp generate-ocp-graph/systemd/generate-graph.timer /etc/systemd/system/ > /dev/null 2>&1
sudo cp generate-ocp-graph/scripts/ocpgenerate-graph.py /usr/local/bin/ > /dev/null 2>&1
sudo systemctl daemon-reload > /dev/null 2>&1
sudo systemctl enable generate-graph.timer > /dev/null 2>&1
sudo systemctl start generate-graph.timer > /dev/null 2>&1

if [[ ! -e "/opt/.ocpgraph" ]]; then
    log "Starting initial runs of update-ocp-cache, updatedb, and generate-graph services"
    sudo systemctl start update-ocp-cache.service > /dev/null 2>&1
    sudo systemctl start updatedb.service > /dev/null 2>&1
    sudo systemctl start generate-graph.service > /dev/null 2>&1
fi  

log "Configuration complete"
echo ""
echo "========================================================================"
echo "  Installation Complete!"
echo "========================================================================"
echo ""
echo "Configuration file: ~/.tmux/config.sh (independent per user)"
echo "Scripts installed at: /usr/local/bin/"
echo "Shared resources at: /usr/local/share/tmux-ocp/"
echo ""
if [ "$UPDATE_USERS" = true ]; then
    echo "Installation mode: SYSTEM-WIDE (all users)"
    echo "  • /etc/skel/ updated (template for new users)"
    echo "  • All existing users updated"
    echo "  • New users will automatically inherit configuration"
else
    echo "Installation mode: LOCAL (current user only)"
    echo "  • Only $CURRENT_USER updated"
    echo "  • Other users NOT affected"
    echo "  • Use --update-users for system-wide installation"
fi
echo ""
echo "CONFIGURATION:"
echo "  Current user config: \$HOME/.tmux/config.sh"
echo "  Edit with: vim \$HOME/.tmux/config.sh"
echo ""
echo "DOCUMENTATION:"
echo "  See GLOBAL-CONFIGURATION.md for complete documentation"
echo "  Run: ./configure-local.sh --help for all options"
echo ""
echo "========================================================================"
