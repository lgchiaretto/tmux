#!/usr/bin/env bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1"
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
    
    --update-users          Update existing user home directories with new dotfiles
                           WARNING: This will overwrite existing .bashrc, .tmux.conf,
                           .vimrc, and other dotfiles for ALL existing users
                           (by default, existing users are NOT modified)

WHAT THIS SCRIPT DOES:
    
    Global Installation (always performed):
    ---------------------------------------
    • Creates /etc/tmux-ocp/ directory for global configuration
    • Installs config.sh to /etc/tmux-ocp/config.sh (shared by all users)
    • Installs all scripts to /usr/local/bin/ (ocpcreatecluster, fzf-*, etc.)
    • Installs shared resources to /usr/local/share/tmux-ocp/
    • Sets up /etc/skel/ with dotfiles for NEW users
    • Installs fzf globally
    • Installs Python packages globally (tmuxp, yq, bat)
    • Installs and enables systemd services (update-ocp-cache, updatedb, generate-graph)
    
    User Updates (only with --update-users):
    ----------------------------------------
    • Updates all existing user home directories with new dotfiles
    • Installs fzf per-user if not already installed
    • Installs vim-plug per-user if not already installed
    • Updates root user configuration

INSTALLATION LOCATIONS:
    
    /etc/tmux-ocp/config.sh              Global configuration (all users)
    /usr/local/bin/                      Executable scripts (global)
    /usr/local/share/tmux-ocp/           Shared resources (fzf-files, tmux-sessions)
    /etc/skel/                           Template for new users
    /etc/systemd/system/                 System services

REQUIREMENTS:
    
    • Root privileges (use sudo)
    • Internet connection (for downloading dependencies)
    • Git, wget, curl installed
    • Python 3 and pip

EXAMPLES:
    
    Basic installation (recommended for first-time setup):
        ./configure-local.sh
    
    Install and update all existing users:
        ./configure-local.sh --update-users
    
    Install with tmux and oc downloads:
        ./configure-local.sh --download-tmux --download-oc
    
    Full installation updating everything:
        ./configure-local.sh --update-users --download-tmux --download-oc

NEW USER CREATION:
    
    After installation, new users automatically get the correct configuration:
        sudo useradd -m newuser
    
    The new user will have all dotfiles and access to global configuration.

CONFIGURATION:
    
    Global configuration (all users):
        sudo vim /etc/tmux-ocp/config.sh
    
    User-specific override (optional):
        cp /etc/tmux-ocp/config.sh $HOME/.tmux/config.sh
        vim $HOME/.tmux/config.sh

NOTES:
    
    • Existing user configurations are preserved by default
    • Use --update-users only when you want to update existing users
    • Global configuration is shared and readable by all users
    • Individual users can still override settings in $HOME/.tmux/config.sh

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

TMUX_DIR=$(pwd)

log "Configuring global Tmux environment for all users"

# Create global configuration directory
log "Creating /etc/tmux-ocp directory for global configuration"
sudo mkdir -p /etc/tmux-ocp > /dev/null 2>&1

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

log "Setting up skeleton files for new users"
log "Copying dotfiles to /etc/skel"
sudo cp $TMUX_DIR/dotfiles/bashrc /etc/skel/.bashrc > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/tmux.conf /etc/skel/.tmux.conf > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/vimrc /etc/skel/.vimrc > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/dircolors /etc/skel/.dircolors > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/inputrc /etc/skel/.inputrc > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/bash_functions /etc/skel/.bash_functions > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/ansible.cfg /etc/skel/.ansible.cfg > /dev/null 2>&1

log "Installing vim-plug for new users"
sudo mkdir -p /etc/skel/.vim/autoload > /dev/null 2>&1
sudo cp $TMUX_DIR/dotfiles/plug.vim /etc/skel/.vim/autoload/plug.vim > /dev/null 2>&1

if [ "$UPDATE_USERS" = true ]; then
    log "Updating existing user home directories (--update-users flag enabled)"
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            log "Updating configuration for user: $username"
            sudo -u "$username" cp $TMUX_DIR/dotfiles/bashrc "$user_home/.bashrc" > /dev/null 2>&1
            sudo -u "$username" cp $TMUX_DIR/dotfiles/tmux.conf "$user_home/.tmux.conf" > /dev/null 2>&1
            sudo -u "$username" cp $TMUX_DIR/dotfiles/vimrc "$user_home/.vimrc" > /dev/null 2>&1
            sudo -u "$username" cp $TMUX_DIR/dotfiles/dircolors "$user_home/.dircolors" > /dev/null 2>&1
            sudo -u "$username" cp $TMUX_DIR/dotfiles/inputrc "$user_home/.inputrc" > /dev/null 2>&1
            sudo -u "$username" cp $TMUX_DIR/dotfiles/bash_functions "$user_home/.bash_functions" > /dev/null 2>&1
            sudo -u "$username" cp $TMUX_DIR/dotfiles/ansible.cfg "$user_home/.ansible.cfg" > /dev/null 2>&1
            
            # Install vim-plug for existing users
            if [ ! -f "$user_home/.vim/autoload/plug.vim" ]; then
                log "Installing vim-plug for user: $username"
                sudo -u "$username" mkdir -p "$user_home/.vim/autoload" > /dev/null 2>&1
                sudo -u "$username" cp $TMUX_DIR/dotfiles/plug.vim "$user_home/.vim/autoload/plug.vim" > /dev/null 2>&1
                sudo -u "$username" vim -E -s -u "$user_home/.vimrc" +PlugInstall +qall > /dev/null 2>&1
            fi
        fi
    done

    # Also update root user
    if [ -d "/root" ]; then
        log "Updating configuration for root user"
        sudo cp $TMUX_DIR/dotfiles/bashrc /root/.bashrc > /dev/null 2>&1
        sudo cp $TMUX_DIR/dotfiles/tmux.conf /root/.tmux.conf > /dev/null 2>&1
        sudo cp $TMUX_DIR/dotfiles/vimrc /root/.vimrc > /dev/null 2>&1
        sudo cp $TMUX_DIR/dotfiles/dircolors /root/.dircolors > /dev/null 2>&1
        sudo cp $TMUX_DIR/dotfiles/inputrc /root/.inputrc > /dev/null 2>&1
        sudo cp $TMUX_DIR/dotfiles/bash_functions /root/.bash_functions > /dev/null 2>&1
        sudo cp $TMUX_DIR/dotfiles/ansible.cfg /root/.ansible.cfg > /dev/null 2>&1
        
        if [ ! -f "/root/.vim/autoload/plug.vim" ]; then
            log "Installing vim-plug for root user"
            sudo cp $TMUX_DIR/dotfiles/plug.vim /root/.vim/autoload/plug.vim > /dev/null 2>&1
            sudo vim -E -s -u /root/.vimrc +PlugInstall +qall > /dev/null 2>&1
        fi
    fi
else
    log "Skipping existing user updates (use --update-users to update existing users)"
fi

log "Setting up global configuration file"
if [ ! -f "/etc/tmux-ocp/config.sh" ]; then
    sudo cp "$TMUX_DIR/config.sh.example" "/etc/tmux-ocp/config.sh" > /dev/null 2>&1
    sudo chmod 644 /etc/tmux-ocp/config.sh > /dev/null 2>&1
    log "Created global configuration at /etc/tmux-ocp/config.sh"
else
    log "Global configuration file already exists, skipping"
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
echo "Global configuration installed at: /etc/tmux-ocp/config.sh"
echo "Scripts installed at: /usr/local/bin/"
echo "Shared resources at: /usr/local/share/tmux-ocp/"
echo ""
if [ "$UPDATE_USERS" = true ]; then
    echo "✓ Existing user home directories have been updated"
else
    echo "ℹ Existing users were NOT updated (use --update-users to update them)"
fi
echo ""
echo "NEW USERS:"
echo "  Create new users with: sudo useradd -m username"
echo "  They will automatically get the correct configuration"
echo ""
echo "CONFIGURATION:"
echo "  Edit global config (all users): sudo vim /etc/tmux-ocp/config.sh"
echo "  User-specific override:         vim \$HOME/.tmux/config.sh"
echo ""
echo "DOCUMENTATION:"
echo "  See GLOBAL-CONFIGURATION.md for complete documentation"
echo "  Run: ./configure-local.sh --help for all options"
echo ""
echo "========================================================================"
