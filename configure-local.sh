#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1"
}

USER=$(id -un)
GROUP=$(id -gn)

log "Changing directory to /home/$USER"
cd /home/$USER > /dev/null 2>&1

log "Cloning fzf repository"
git clone https://github.com/junegunn/fzf.git > /dev/null 2>&1
cd fzf > /dev/null 2>&1
log "Installing fzf"
./install > /dev/null 2>&1

log "Configuring .bashrc, vimrc and .tmux.conf files"
cp dotfiles/bashrc /home/$USER/.bashrc > /dev/null 2>&1
cp dotfiles/tmux.conf /home/$USER/.tmux.conf > /dev/null 2>&1
cp dotfiles/vimrc /home/$USER/.vimrc > /dev/null 2>&1

log "Creating .tmux directory"
mkdir -p /home/$USER/.tmux/ > /dev/null 2>&1
log "Copying fzf-files to .tmux directory"
cp fzf-files/* /home/$USER/.tmux/ > /dev/null 2>&1
log "Changing ownership of configuration files"
chown $USER:$GROUP /home/$USER/{.bashrc,.tmux.conf,.vimrc} > /dev/null 2>&1
chown -R $USER:$GROUP /home/$USER/.tmux/ > /dev/null 2>&1

log "Downloading tmux binary"
wget -q --no-check-certificate 'https://gpte-public-documents.s3.us-east-1.amazonaws.com/rh1_2025_lab17/rh1-lab17-tmux-binary' -O tmux > /dev/null 2>&1
log "Downloading OpenShift CLI client"
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.16.21/openshift-client-linux.tar.gz > /dev/null 2>&1
log "Extracting OpenShift CLI client"
tar xzf openshift-client-linux.tar.gz > /dev/null 2>&1

log "Copying tmux and oc binaries to /usr/local/bin"
sudo cp {tmux,oc} /usr/local/bin/ > /dev/null 2>&1
log "Setting executable permissions for tmux and oc"
sudo chmod +x /usr/local/bin/tmux > /dev/null 2>&1
sudo chmod +x /usr/local/bin/oc > /dev/null 2>&1

log "Installing tmuxp"
sudo dnf install -y python3-pip -q > /dev/null 2>&1
pip3 install tmuxp -q > /dev/null 2>&1

log "Copying tmux-sessions directory to home"
cp -R tmux-sessions ~/ > /dev/null 2>&1

log "Configuration complete"
