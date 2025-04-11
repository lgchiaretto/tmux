#!/bin/bash

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] - $1"
}

USER=$(id -un)
GROUP=$(id -gn)

log "Changing directory to /home/$USER"
cd /home/$USER

log "Cloning fzf repository"
git clone https://github.com/junegunn/fzf.git
cd fzf
log "Installing fzf"
./install

log "Configuring .bashrc, vimrc and .tmux.conf files"
cp dotfiles/bashrc /home/$USER/.bashrc
cp dotfiles/tmux.conf /home/$USER/.tmux.conf
cp dotfiles/vimrc /home/$USER/.vimrc
log "Copying tmux.conf to /etc/tmux.conf"
sudo cp dotfiles/tmux.conf /etc/tmux.conf

log "Creating .tmux directory"
mkdir -p /home/$USER/.tmux/
log "Copying fzf-files to .tmux directory"
cp fzf-files/* /home/$USER/.tmux/
log "Changing ownership of configuration files"
chown $USER:$GROUP /home/$USER/{.bashrc,.tmux.conf,.vimrc}
chown -R $USER:$GROUP /home/$USER/.tmux/

log "Downloading tmux binary"
wget -q --no-check-certificate 'https://gpte-public-documents.s3.us-east-1.amazonaws.com/rh1_2025_lab17/rh1-lab17-tmux-binary' -O tmux
log "Downloading OpenShift CLI client"
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.16.21/openshift-client-linux.tar.gz
log "Extracting OpenShift CLI client"
tar xzf openshift-client-linux.tar.gz

log "Copying tmux and oc binaries to /usr/local/bin"
sudo cp {tmux,oc} /usr/local/bin/
log "Setting executable permissions for tmux and oc"
sudo chmod +x /usr/local/bin/tmux
sudo chmod +x /usr/local/bin/oc

log "Installing tmuxp"
sudo dnf install -y python3-pip -q
pip3 install tmuxp -q

log "Copying tmux-sessions directory to home"
cp -R tmux-sessions ~/

log "Configuration complete"
