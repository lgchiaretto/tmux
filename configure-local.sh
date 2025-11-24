#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths and Constants
TMUX_SHARE_DIR="/usr/local/share/tmux-ocp"
BIN_DIR="/usr/local/bin"
# Resolve absolute path to the directory containing this script
CALLER_PATH="${BASH_SOURCE[0]}"
TMUX_DIR="$(dirname "$(readlink -f "$CALLER_PATH")")"

# Helper Functions
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] - $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

# Basic Dependency Check
check_dependencies() {
    local deps=(git wget tar python3 pip3)
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            warn "Dependency '$cmd' not found. Attempting to install..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y "$cmd"
            elif command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y "$cmd"
            else
                error "Could not install '$cmd'. Please install it manually."
            fi
        fi
    done
}

# Function to copy dotfiles to a user's home directory
copy_dotfiles_to_user() {
    local target_home="$1"
    local target_user="$2"
    
    log "Updating configuration for user: $target_user"
    
    # List of files to copy from /etc/skel (source of truth)
    local files=(.bashrc .tmux.conf .vimrc .dircolors .inputrc .bash_functions .ansible.cfg)
    
    for file in "${files[@]}"; do
        if [ -f "/etc/skel/$file" ]; then
            sudo install -m 644 -o "$target_user" -g "$target_user" "/etc/skel/$file" "$target_home/$file"
        fi
    done
    
    # Install vim-plug
    sudo install -d -m 755 -o "$target_user" -g "$target_user" "$target_home/.vim/autoload"
    if [ -f "/etc/skel/.vim/autoload/plug.vim" ]; then
        sudo install -m 644 -o "$target_user" -g "$target_user" "/etc/skel/.vim/autoload/plug.vim" "$target_home/.vim/autoload/plug.vim"
    fi
    
    # Tmux Configuration (config.sh) - Do not overwrite if exists
    sudo install -d -m 755 -o "$target_user" -g "$target_user" "$target_home/.tmux"
    if [ ! -f "$target_home/.tmux/config.sh" ]; then
        if [ -f "/etc/skel/.tmux/config.sh" ]; then
            sudo install -m 600 -o "$target_user" -g "$target_user" "/etc/skel/.tmux/config.sh" "$target_home/.tmux/config.sh"
            log "Configuration created at $target_home/.tmux/config.sh"
        fi
    else
        warn "Configuration already exists at $target_home/.tmux/config.sh (kept as is)"
    fi
}

show_help() {
    cat << 'EOF'
Tmux OpenShift Tools - Global Configuration Installer
======================================================

USAGE:
    sudo ./configure-local.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    --download-tmux         Force download and install Tmux binary
    --download-oc           Force download and install OpenShift CLI (oc)
    --update-users          Install dotfiles in /etc/skel/ and update ALL users
                            (Default: updates current user only)

EOF
    exit 0
}

# Argument Parsing
UPDATE_USERS=false
DOWNLOAD_TMUX=false
DOWNLOAD_OC=false

for arg in "$@"; do
    case "$arg" in
        --help|-h) show_help ;;
        --download-tmux) DOWNLOAD_TMUX=true ;;
        --download-oc) DOWNLOAD_OC=true ;;
        --update-users) UPDATE_USERS=true ;;
        *) error "Invalid option '$arg'. Use --help." ;;
    esac
done

# Start Installation
log "Starting Tmux environment configuration..."
check_dependencies

# Create global directory structure
log "Creating directories in $TMUX_SHARE_DIR"
sudo install -d -m 755 "$TMUX_SHARE_DIR"/{fzf-files,tmux-sessions,common}

# Install shared scripts and FZF Files
log "Installing shared scripts..."
if [ -d "$TMUX_DIR/common" ]; then
    sudo install -m 755 "$TMUX_DIR/common/"* "$TMUX_SHARE_DIR/common/"
fi
if [ -d "$TMUX_DIR/fzf-files" ]; then
    sudo install -m 755 "$TMUX_DIR/fzf-files/"* "$TMUX_SHARE_DIR/fzf-files/"
fi

# Install Tmux Sessions
log "Installing tmux sessions..."
if [ -d "$TMUX_DIR/tmux-sessions" ]; then
    sudo cp -R "$TMUX_DIR/tmux-sessions/"* "$TMUX_SHARE_DIR/tmux-sessions/"
    sudo chmod -R 644 "$TMUX_SHARE_DIR/tmux-sessions/"* # YAML files don't need exec permissions
fi

# Global FZF Installation
if [ ! -d "/usr/local/share/fzf" ]; then
    log "Cloning fzf repository..."
    sudo git clone --depth 1 https://github.com/junegunn/fzf.git /usr/local/share/fzf
    log "Running fzf installer..."
    sudo /usr/local/share/fzf/install --bin --no-update-rc --no-bash --no-zsh --no-fish
else
    log "FZF already installed. Updating repository..."
    (cd /usr/local/share/fzf && sudo git pull)
fi
# Link FZF binaries
sudo install -m 755 /usr/local/share/fzf/bin/fzf "$BIN_DIR/fzf"
sudo install -m 755 /usr/local/share/fzf/bin/fzf-tmux "$BIN_DIR/fzf-tmux"

# User Configuration
CURRENT_USER="${SUDO_USER:-$USER}"
CURRENT_USER_HOME=$(eval echo ~$CURRENT_USER)

# Prepare source files (using /etc/skel as template)
# First, copy files from repo to /etc/skel
sudo install -m 644 "$TMUX_DIR/dotfiles/bashrc" /etc/skel/.bashrc
sudo install -m 644 "$TMUX_DIR/dotfiles/tmux.conf" /etc/skel/.tmux.conf
sudo install -m 644 "$TMUX_DIR/dotfiles/vimrc" /etc/skel/.vimrc
sudo install -m 644 "$TMUX_DIR/dotfiles/dircolors" /etc/skel/.dircolors
sudo install -m 644 "$TMUX_DIR/dotfiles/inputrc" /etc/skel/.inputrc
sudo install -m 644 "$TMUX_DIR/dotfiles/bash_functions" /etc/skel/.bash_functions
sudo install -m 644 "$TMUX_DIR/dotfiles/ansible.cfg" /etc/skel/.ansible.cfg

sudo install -d -m 755 /etc/skel/.vim/autoload
sudo install -m 644 "$TMUX_DIR/dotfiles/plug.vim" /etc/skel/.vim/autoload/plug.vim

sudo install -d -m 755 /etc/skel/.tmux
sudo install -m 600 "$TMUX_DIR/config.sh.example" /etc/skel/.tmux/config.sh

if [ "$UPDATE_USERS" = true ]; then
    log "Updating ALL system users..."
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            copy_dotfiles_to_user "$user_home" "$username"
        fi
    done
    # Update root
    copy_dotfiles_to_user "/root" "root"
else
    log "Updating only current user: $CURRENT_USER"
    copy_dotfiles_to_user "$CURRENT_USER_HOME" "$CURRENT_USER"
fi

# Binary Installation (Tmux and OC)
if [ "$DOWNLOAD_TMUX" = true ] || [ ! -f "$BIN_DIR/tmux" ]; then
    log "Downloading tmux binary..."
    sudo wget -q --show-progress --no-check-certificate 'https://gpte-public-documents.s3.us-east-1.amazonaws.com/rh1_2025_lab17/rh1-lab17-tmux-binary' -O "$BIN_DIR/tmux"
    sudo chmod +x "$BIN_DIR/tmux"
fi

if [ "$DOWNLOAD_OC" = true ] || [ ! -f "$BIN_DIR/oc" ]; then
    log "Downloading OpenShift CLI..."
    TEMP_DIR=$(mktemp -d)
    wget -q --show-progress https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.13/openshift-client-linux.tar.gz -P "$TEMP_DIR"
    tar xzf "$TEMP_DIR/openshift-client-linux.tar.gz" -C "$TEMP_DIR"
    sudo install -m 755 "$TEMP_DIR/oc" "$BIN_DIR/oc"
    # Optional: install kubectl if included
    if [ -f "$TEMP_DIR/kubectl" ]; then
        sudo install -m 755 "$TEMP_DIR/kubectl" "$BIN_DIR/kubectl"
    fi
    rm -rf "$TEMP_DIR"
fi

# Utility Scripts Installation
log "Installing utility scripts to $BIN_DIR..."
sudo install -m 755 "$TMUX_DIR/fzf-files/oc-logs-fzf.sh" "$BIN_DIR/"
if [ -d "$TMUX_DIR/ocpscripts" ]; then
    sudo install -m 755 "$TMUX_DIR/ocpscripts/"* "$BIN_DIR/"
fi

# Python Packages
log "Installing Python packages (tmuxp, yq, bat, python-magic)..."
# Suppress pip warnings about root user action
export PIP_ROOT_USER_ACTION=ignore

# Check if pip3 is available and upgrade it
sudo -E pip3 install --upgrade pip -q

# Install packages.
# Added 'python-magic' to resolve conflicts with s3cmd that often occur on these systems
# Used --ignore-installed to ensure our required versions are present even if duplicates exist
sudo -E pip3 install tmuxp yq bat python-magic -q --ignore-installed

# Systemd Services Configuration
install_systemd_service() {
    local name=$1
    local path=$2
    local script=$3
    
    log "Configuring systemd service: $name"
    
    if [ -n "$script" ] && [ -f "$script" ]; then
        sudo install -m 755 "$script" "$BIN_DIR/"
    fi
    
    if [ -f "$path/$name.service" ]; then
        sudo install -m 644 "$path/$name.service" /etc/systemd/system/
        sudo install -m 644 "$path/$name.timer" /etc/systemd/system/
        sudo systemctl enable "$name.timer" > /dev/null
        sudo systemctl start "$name.timer" > /dev/null
    else
        warn "Service definition for $name not found at $path"
    fi
}

sudo systemctl daemon-reload

# Update OCP Cache Service
install_systemd_service "update-ocp-cache" \
    "$TMUX_DIR/update-ocp-cache/systemd" \
    "$TMUX_DIR/update-ocp-cache/scripts/update_ocp_cache.py"

# Update DB Service
install_systemd_service "updatedb" \
    "$TMUX_DIR/updatedb/systemd" \
    "" # updatedb uses system binary

# Generate Graph Service
install_systemd_service "generate-graph" \
    "$TMUX_DIR/generate-ocp-graph/systemd" \
    "$TMUX_DIR/generate-ocp-graph/scripts/ocpgenerate-graph.py"

# Initial Service Run (if needed)
if [[ ! -e "/opt/.ocpgraph" ]]; then
    log "Running initial services..."
    sudo systemctl start update-ocp-cache.service
    sudo systemctl start updatedb.service
    sudo systemctl start generate-graph.service
fi

echo ""
echo -e "${GREEN}========================================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================================================${NC}"
echo ""
echo "User config: $CURRENT_USER_HOME/.tmux/config.sh"
if [ "$UPDATE_USERS" = true ]; then
    echo "Mode: SYSTEM-WIDE (All users updated and /etc/skel configured)"
else
    echo "Mode: LOCAL (Only user $CURRENT_USER updated)"
fi
echo ""