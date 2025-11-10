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

if [[ $USER == "root" ]]; then
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

log "Setting up configuration file"
if [ ! -f "$TARGET_HOME/.tmux/config.sh" ]; then
    cp "$TMUX_DIR/config.sh.example" "$TARGET_HOME/.tmux/config.sh" > /dev/null 2>&1
        
    if [ -t 0 ]; then
        echo ""
        echo "================================================"
        echo "  Configuration Setup"
        echo "================================================"
        echo ""
        echo "The default cluster path is: /vms/clusters"
        read -p "Do you want to customize it? (y/N): " customize
            
        if [[ "$customize" =~ ^[Yy]$ ]]; then
            read -p "Enter clusters base path: " clusters_path
            if [ -n "$clusters_path" ]; then
                sed -i "s|export CLUSTERS_BASE_PATH=.*|export CLUSTERS_BASE_PATH=\"${clusters_path}\"|" "$TARGET_HOME/.tmux/config.sh"
                log "Set CLUSTERS_BASE_PATH to: $clusters_path"
            fi

            read -p "Enter KVM variables directory path (press Enter for default): " kvm_vars_dir
            if [ -n "$kvm_vars_dir" ]; then
                sed -i "s|export KVM_VARIABLES_DIR=.*|export KVM_VARIABLES_DIR=\"${kvm_vars_dir}\"|" "$TARGET_HOME/.tmux/config.sh"
                log "Set KVM_VARIABLES_DIR to: $kvm_vars_dir"
            fi

            read -p "Enter the border label for FZF menus (press Enter for 'chiarettolabs.com.br'): " fzf_label
            if [ -n "$fzf_label" ]; then
                sed -i "s|export FZF_BORDER_LABEL=.*|export FZF_BORDER_LABEL=\"${fzf_label}\"|" "$TARGET_HOME/.tmux/config.sh"
                log "Set FZF_BORDER_LABEL to: $fzf_label"
            fi
        fi
    fi
    chown $TARGET_USER:$TARGET_GROUP "$TARGET_HOME/.tmux/config.sh" > /dev/null 2>&1
else
    log "Configuration file already exists, skipping"
fi

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

if [[ "$@" == *"--download-oc"* || ! -f "/usr/local/bin/oc" ]]; then
    log "Downloading OpenShift CLI client"
    wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.19.13/openshift-client-linux.tar.gz > /dev/null 2>&1
    log "Extracting OpenShift CLI client"
    tar xzf openshift-client-linux.tar.gz > /dev/null 2>&1
    log "Copying oc binary to /usr/local/bin"
    sudo cp oc /usr/local/bin/ > /dev/null 2>&1
    log "Setting executable permissions for tmux and oc"
    sudo chmod +x /usr/local/bin/oc > /dev/null 2>&1
fi

log "Creating oc-logs-fzf.sh script"
sudo cp oc-logs-fzf.sh /usr/local/bin/ > /dev/null 2>&1

log "Creating OCP scripts to /usr/local/bin"
sudo cp ocpscripts/* /usr/local/bin/ > /dev/null 2>&1

log "Setting executable permissions for oc-logs-fzf.sh"
sudo chmod +x /usr/local/bin/oc-logs-fzf.sh > /dev/null 2>&1

log "Installing tmuxp, bat and yq"
sudo dnf install -y python3-pip bat yq -q > /dev/null 2>&1
sudo -u "$TARGET_USER" pip3 install --user tmuxp -q > /dev/null 2>&1

log "Copying tmux-sessions directory to home"
cp -R tmux-sessions "$TARGET_HOME/" > /dev/null 2>&1
chown -R $TARGET_USER:$TARGET_GROUP "$TARGET_HOME/tmux-sessions/" > /dev/null 2>&1

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
