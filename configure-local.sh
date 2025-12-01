#!/usr/bin/env bash

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths and Constants
TMUX_SHARE_DIR="/usr/local/share/tmux-ocp"
BIN_DIR="/usr/local/bin"
TMUX_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

### Helper Functions
log() { echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS:${NC} $1"; }
error() { echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"; }

# Install dependencies silently
check_dependencies() {
    for cmd in git wget curl tar python3; do
        command -v "$cmd" &>/dev/null || sudo dnf install -y "$cmd" &>/dev/null
    done
    command -v pip3 &>/dev/null || warn "pip3 not found. Will try to use system packages only."
}

# Copy dotfiles to user's home directory
copy_dotfiles_to_user() {
    local target_home="$1"
    local target_user="$2"
    
    log "Updating configuration for user: $target_user"
    
    # Copy dotfiles from /etc/skel
    for file in .bashrc .tmux.conf .vimrc .dircolors .inputrc .bash_functions .ansible.cfg; do
        [ -f "/etc/skel/$file" ] && sudo install -m 644 -o "$target_user" -g "$target_user" "/etc/skel/$file" "$target_home/$file"
    done
    
    # Install vim-plug
    sudo install -d -m 755 -o "$target_user" -g "$target_user" "$target_home/.vim/autoload"
    [ -f "/etc/skel/.vim/autoload/plug.vim" ] && sudo install -m 644 -o "$target_user" -g "$target_user" "/etc/skel/.vim/autoload/plug.vim" "$target_home/.vim/autoload/plug.vim"
    
    # Create config.sh if it doesn't exist (NEVER overwrite)
    sudo install -d -m 755 -o "$target_user" -g "$target_user" "$target_home/.tmux"
    if [ -f "$target_home/.tmux/config.sh" ]; then
        warn "Configuration already exists at $target_home/.tmux/config.sh (preserving)"
    elif [ -f "$TMUX_DIR/config.sh.example" ]; then
        sudo install -m 600 -o "$target_user" -g "$target_user" "$TMUX_DIR/config.sh.example" "$target_home/.tmux/config.sh"
        log "Configuration created at $target_home/.tmux/config.sh"
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
    sudo git clone --depth 1 -q https://github.com/junegunn/fzf.git /usr/local/share/fzf &>/dev/null
    sudo /usr/local/share/fzf/install --bin --no-update-rc --no-bash --no-zsh --no-fish &>/dev/null
else
    log "Updating fzf repository..."
    (cd /usr/local/share/fzf && sudo git pull -q &>/dev/null)
fi
sudo install -m 755 /usr/local/share/fzf/bin/fzf "$BIN_DIR/fzf"
sudo install -m 755 /usr/local/share/fzf/bin/fzf-tmux "$BIN_DIR/fzf-tmux"

# User Configuration
CURRENT_USER="${SUDO_USER:-$USER}"
CURRENT_USER_HOME=$(eval echo ~$CURRENT_USER)

# Prepare dotfiles in /etc/skel
for file in bashrc::.bashrc tmux.conf::.tmux.conf vimrc::.vimrc dircolors::.dircolors inputrc::.inputrc bash_functions::.bash_functions ansible.cfg::.ansible.cfg; do
    src="${file%%::*}"
    dst="${file##*::}"
    sudo install -m 644 "$TMUX_DIR/dotfiles/$src" "/etc/skel/$dst"
done
sudo install -d -m 755 /etc/skel/.vim/autoload
sudo install -m 644 "$TMUX_DIR/dotfiles/plug.vim" /etc/skel/.vim/autoload/plug.vim

# Update users
if [ "$UPDATE_USERS" = true ]; then
    log "Updating ALL system users..."
    for user_home in /home/* /root; do
        [ -d "$user_home" ] && copy_dotfiles_to_user "$user_home" "$(basename "$user_home")"
    done
else
    log "Updating only current user: $CURRENT_USER"
    copy_dotfiles_to_user "$CURRENT_USER_HOME" "$CURRENT_USER"
fi

# Download binaries if needed
if [ "$DOWNLOAD_TMUX" = true ] || [ ! -f "$BIN_DIR/tmux" ]; then
    log "Downloading tmux binary from GitHub releases..."
    ARCH=$(uname -m)
    TMUX_ARCH="${ARCH/x86_64/amd64}"; TMUX_ARCH="${TMUX_ARCH/aarch64/arm64}"
    TMUX_RELEASE_URL="https://github.com/lgchiaretto/build-static-tmux/releases/latest/download/tmux.linux-${TMUX_ARCH}.stripped.gz"
    TEMP_DIR=$(mktemp -d)
    if wget -q "$TMUX_RELEASE_URL" -O "$TEMP_DIR/tmux.gz" &>/dev/null; then
        gunzip "$TEMP_DIR/tmux.gz"
        sudo install -m 755 "$TEMP_DIR/tmux" "$BIN_DIR/tmux"
        log "Installed tmux from GitHub release"
    else
        warn "Failed to download tmux from GitHub releases, trying alternative URL..."
        # Fallback to artifact download via gh CLI if available
        if command -v gh &>/dev/null; then
            gh release download --repo lgchiaretto/build-static-tmux -p "tmux.linux-${TMUX_ARCH}.stripped.gz" -D "$TEMP_DIR" &>/dev/null && {
                gunzip "$TEMP_DIR/tmux.linux-${TMUX_ARCH}.stripped.gz"
                sudo install -m 755 "$TEMP_DIR/tmux.linux-${TMUX_ARCH}.stripped" "$BIN_DIR/tmux"
                log "Installed tmux via gh CLI"
            }
        else
            error "Could not download tmux binary. Install 'gh' CLI or check network connectivity."
        fi
    fi
    rm -rf "$TEMP_DIR"
fi

if [ "$DOWNLOAD_OC" = true ] || [ ! -f "$BIN_DIR/oc" ]; then
    log "Downloading OpenShift CLI..."
    TEMP_DIR=$(mktemp -d)
    wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.13/openshift-client-linux.tar.gz -P "$TEMP_DIR" &>/dev/null
    tar xzf "$TEMP_DIR/openshift-client-linux.tar.gz" -C "$TEMP_DIR" &>/dev/null
    sudo install -m 755 "$TEMP_DIR/oc" "$BIN_DIR/oc"
    [ -f "$TEMP_DIR/kubectl" ] && sudo install -m 755 "$TEMP_DIR/kubectl" "$BIN_DIR/kubectl"
    rm -rf "$TEMP_DIR"
fi

# Install utility scripts
log "Installing utility scripts to $BIN_DIR..."
sudo install -m 755 "$TMUX_DIR/fzf-files/oc-logs-fzf.sh" "$BIN_DIR/"
[ -d "$TMUX_DIR/ocpscripts" ] && sudo install -m 755 "$TMUX_DIR/ocpscripts/"* "$BIN_DIR/"

# Install Python packages
log "Installing Python packages..."
command -v pip3 &>/dev/null || sudo dnf install -y python3-pip &>/dev/null

if dnf list available python3-tmuxp &>/dev/null; then
    sudo dnf install -y python3-tmuxp python3-magic &>/dev/null
    log "Installed python3-tmuxp and python3-magic from system packages"
else
    warn "python3-tmuxp not available in system repos, installing via pip3"
    sudo pip3 install --prefix=/usr/local tmuxp python-magic &>/dev/null && log "Installed tmuxp and python-magic to /usr/local"
fi

# Install yq
if ! command -v yq &>/dev/null; then
    log "Installing yq from GitHub releases..."
    ARCH=$(uname -m)
    YQ_ARCH="${ARCH/x86_64/amd64}"; YQ_ARCH="${YQ_ARCH/aarch64/arm64}"
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -n "$YQ_VERSION" ]; then
        sudo wget -q "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${YQ_ARCH}" -O "$BIN_DIR/yq" &>/dev/null && sudo chmod +x "$BIN_DIR/yq"
        log "Installed yq ${YQ_VERSION}"
    else
        warn "Could not determine yq version"
    fi
fi

# Install bat
if ! command -v bat &>/dev/null; then
    if dnf list available bat &>/dev/null; then
        sudo dnf install -y bat &>/dev/null && log "Installed bat from system packages"
    else
        log "Installing bat from GitHub releases..."
        ARCH=$(uname -m)
        BAT_ARCH="${ARCH/aarch64/aarch64}"; BAT_ARCH="${ARCH/x86_64/x86_64}"
        BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [ -n "$BAT_VERSION" ]; then
            TEMP_DIR=$(mktemp -d)
            wget -q "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat-${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl.tar.gz" -P "$TEMP_DIR" &>/dev/null
            [ -f "$TEMP_DIR/bat-${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl.tar.gz" ] && {
                tar xzf "$TEMP_DIR/bat-${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl.tar.gz" -C "$TEMP_DIR" &>/dev/null
                sudo install -m 755 "$TEMP_DIR/bat-${BAT_VERSION}-${BAT_ARCH}-unknown-linux-musl/bat" "$BIN_DIR/bat"
                log "Installed bat ${BAT_VERSION}"
            }
            rm -rf "$TEMP_DIR"
        else
            warn "Could not determine bat version"
        fi
    fi
fi

# Configure systemd services
install_systemd_service() {
    local name=$1 path=$2 script=$3
    log "Configuring systemd service: $name"
    [ -n "$script" ] && [ -f "$script" ] && sudo install -m 755 "$script" "$BIN_DIR/"
    if [ -f "$path/$name.service" ]; then
        sudo install -m 644 "$path/$name.service" "$path/$name.timer" /etc/systemd/system/
        sudo systemctl enable --now "$name.timer" &>/dev/null
    else
        warn "Service definition for $name not found"
    fi
}

sudo systemctl daemon-reload &>/dev/null

install_systemd_service "update-ocp-cache" "$TMUX_DIR/update-ocp-cache/systemd" "$TMUX_DIR/update-ocp-cache/scripts/update_ocp_cache.py"
install_systemd_service "updatedb" "$TMUX_DIR/updatedb/systemd" ""
install_systemd_service "generate-graph" "$TMUX_DIR/generate-ocp-graph/systemd" "$TMUX_DIR/generate-ocp-graph/scripts/ocpgenerate-graph.py"

# Run initial services if needed
if [ ! -e "/opt/.ocpgraph" ]; then
    log "Running initial services..."
    sudo systemctl start update-ocp-cache.service updatedb.service generate-graph.service &>/dev/null
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