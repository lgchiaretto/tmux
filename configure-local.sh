#!/bin/bash

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

USER=$(id -un)
GROUP=$(id -gn)
TMUX_DIR=$(pwd)

log "Changing directory to /home/$USER"
cd /home/$USER > /dev/null 2>&1

log "Cloning fzf repository"
git clone https://github.com/junegunn/fzf.git > /dev/null 2>&1
cd fzf > /dev/null 2>&1
log "Installing fzf"
./install --key-bindings --completion --update-rc > /dev/null 2>&1
cd $TMUX_DIR > /dev/null 2>&1
log "Copying .bashrc, .vimrc, .dircolors, .inputrc and .tmux.conf files"
cp dotfiles/bashrc /home/$USER/.bashrc > /dev/null 2>&1
cp dotfiles/tmux.conf /home/$USER/.tmux.conf > /dev/null 2>&1
cp dotfiles/vimrc /home/$USER/.vimrc > /dev/null 2>&1
cp dotfiles/dircolors /home/$USER/.dircolors > /dev/null 2>&1
cp dotfiles/inputrc /home/$USER/.inputrc > /dev/null 2>&1

log "Creating .tmux directory"
mkdir -p /home/$USER/.tmux/ > /dev/null 2>&1
log "Copying fzf-files to .tmux directory"
cp fzf-files/* /home/$USER/.tmux/ > /dev/null 2>&1
log "Changing ownership of configuration files"
chown $USER:$GROUP /home/$USER/{.bashrc,.tmux.conf,.vimrc,.dircolors,.inputrc} > /dev/null 2>&1
chown -R $USER:$GROUP /home/$USER/.tmux/ > /dev/null 2>&1

if [[ "$@" == *"--download-tmux"* ]]; then
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
cp oc-logs-fzf.sh /usr/local/bin/ > /dev/null 2>&1

log "Setting executable permissions for oc-logs-fzf.sh"
sudo chmod +x /usr/local/bin/oc-logs-fzf.sh > /dev/null 2>&1

log "Installing tmuxp"
sudo dnf install -y python3-pip -q > /dev/null 2>&1
pip3 install tmuxp -q > /dev/null 2>&1

log "Copying tmux-sessions directory to home"
cp -R tmux-sessions ~/ > /dev/null 2>&1

log "Configuration complete"
