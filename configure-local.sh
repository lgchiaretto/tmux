#!/usr/bin/env bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1"
}

show_help() {
    echo "Usage: ./configure-local.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help or -h       Show this help message and exit."
    echo "  --download-tmux    Download and install the Tmux binary."
    echo "  --download-oc      Download and install the OpenShift CLI (oc)."
    echo ""
    echo "This script sets up the Tmux environment by copying configuration files,"
    echo "installing dependencies, and optionally downloading additional binaries."
    exit 0
}

for arg in "$@"; do
    if [[ "$arg" != "--help" && "$arg" != "-h" && "$arg" != "--download-tmux" && "$arg" != "--download-oc" ]]; then
        echo "Error: Invalid option '$arg'"
        echo "Use './configure-local.sh --help' to see available options."
        exit 1
    fi
done

if [[ "$@" == *"--help"* || "$@" == *"-h"* ]]; then
    show_help
fi

if [[ -n "$SUDO_USER" ]]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    TARGET_GROUP=$(id -gn "$SUDO_USER")
else [[ $USER == "root" ]]; then
    TARGET_USER="root"
    TARGET_HOME="/root"
    TARGET_GROUP="root"
else
    TARGET_USER=$(id -un)
    TARGET_HOME="$HOME"
    TARGET_GROUP=$(id -gn)
fi

TMUX_DIR=$(pwd)

log "Configuring environment for user: $TARGET_USER (home: $TARGET_HOME)"
cd "$TARGET_HOME" > /dev/null 2>&1

log "Configuring environment for user: $TARGET_USER (home: $TARGET_HOME)"
cd "$TARGET_HOME" > /dev/null 2>&1

log "Cloning fzf repository"
git clone https://github.com/junegunn/fzf.git .fzf> /dev/null 2>&1
cd .fzf > /dev/null 2>&1
log "Installing fzf"
sudo -u "$TARGET_USER" ./install --key-bindings --completion --update-rc > /dev/null 2>&1
cd $TMUX_DIR > /dev/null 2>&1
log "Copying .bashrc, .vimrc, .dircolors, .inputrc and .tmux.conf files"
cp $TMUX_DIR/dotfiles/bashrc "$TARGET_HOME/.bashrc" > /dev/null 2>&1
cp $TMUX_DIR/dotfiles/tmux.conf "$TARGET_HOME/.tmux.conf" > /dev/null 2>&1
cp $TMUX_DIR/dotfiles/vimrc "$TARGET_HOME/.vimrc" > /dev/null 2>&1
cp $TMUX_DIR/dotfiles/dircolors "$TARGET_HOME/.dircolors" > /dev/null 2>&1
cp $TMUX_DIR/dotfiles/inputrc "$TARGET_HOME/.inputrc" > /dev/null 2>&1
cp $TMUX_DIR/dotfiles/bash_functions "$TARGET_HOME/.bash_functions" > /dev/null 2>&1

log "Installing vim-plug"
curl -fLo "$TARGET_HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > /dev/null 2>&1

log "Installing vim plugins"
sudo -u "$TARGET_USER" vim -E -s -u "$TARGET_HOME/.vimrc" +PlugInstall +qall > /dev/null 2>&1

log "Creating .tmux directory"
mkdir -p "$TARGET_HOME/.tmux/" > /dev/null 2>&1
log "Copying fzf-files to .tmux directory"
cp $TMUX_DIR/fzf-files/* "$TARGET_HOME/.tmux/" > /dev/null 2>&1
log "Changing ownership of configuration files"
chown $TARGET_USER:$TARGET_GROUP "$TARGET_HOME"/{.bashrc,.tmux.conf,.vimrc,.dircolors,.inputrc,.bash_functions} > /dev/null 2>&1
chown -R $TARGET_USER:$TARGET_GROUP "$TARGET_HOME/.tmux/" > /dev/null 2>&1
chown -R $TARGET_USER:$TARGET_GROUP "$TARGET_HOME/.vim/" > /dev/null 2>&1
chown -R $TARGET_USER:$TARGET_GROUP "$TARGET_HOME/.fzf/" > /dev/null 2>&1

if [[ "$@" == *"--download-tmux"* || ! -f "/usr/local/bin/tmux" ]]; then
    log "Downloading tmux binary"
    wget -q --no-check-certificate 'https://gpte-public-documents.s3.us-east-1.amazonaws.com/rh1_2025_lab17/rh1-lab17-tmux-binary' -O tmux > /dev/null 2>&1
    log "Copying tmux binary to /usr/local/bin"
    sudo cp tmux /usr/local/bin/ > /dev/null 2>&1
    sudo chmod +x /usr/local/bin/tmux > /dev/null 2>&1
fi

if [[ "$@" == *"--download-oc"* ]]; then
    log "Downloading OpenShift CLI client"
    wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.16.21/openshift-client-linux.tar.gz > /dev/null 2>&1
    log "Extracting OpenShift CLI client"
    tar xzf openshift-client-linux.tar.gz > /dev/null 2>&1
    log "Copying oc binary to /usr/local/bin"
    sudo cp oc /usr/local/bin/ > /dev/null 2>&1
    log "Setting executable permissions for tmux and oc"
    sudo chmod +x /usr/local/bin/oc > /dev/null 2>&1
fi

log "Creating oc-logs-fzf.sh script"
sudo cp oc-logs-fzf.sh /usr/local/bin/ > /dev/null 2>&1

#if [[ "$USER" == "lchiaret" ]]; then
    log "Creating OCP scripts to /usr/local/bin"
    sudo cp ocpscripts/* /usr/local/bin/ > /dev/null 2>&1
#fi

log "Setting executable permissions for oc-logs-fzf.sh"
sudo chmod +x /usr/local/bin/oc-logs-fzf.sh > /dev/null 2>&1

log "Installing tmuxp and bat"
sudo dnf install -y python3-pip bat -q > /dev/null 2>&1
sudo -u "$TARGET_USER" pip3 install --user tmuxp -q > /dev/null 2>&1

log "Copying tmux-sessions directory to home"
cp -R tmux-sessions "$TARGET_HOME/" > /dev/null 2>&1
chown -R $TARGET_USER:$TARGET_GROUP "$TARGET_HOME/tmux-sessions/" > /dev/null 2>&1

log "Configuration complete"
