#!/bin/bash

USER=$(id -un)
GROUP=$(id -gn)

echo "Configuring .bashrc, vimrc and .tmux.conf files"
cp {.bashrc,.tmux.conf,.vimrc} /home/$USER
sudo cp .tmux.conf /etc/tmux.conf
mkdir -p /home/$USER/.tmux/
cp ocp-project.tmux ocp-cluster.tmux fzf-url.sh /home/$USER/.tmux/
chown $USER:$GROUP /home/$USER/{.bashrc,.tmux.conf,.vimrc}
chown -R $USER:$GROUP /home/$USER/.tmux/
echo Downloading tmux
wget -q --no-check-certificate 'https://gpte-public-documents.s3.us-east-1.amazonaws.com/rh1_2025_lab17/rh1-lab17-tmux-binary' -O tmux
echo Downloading oc client
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.16.21/openshift-client-linux.tar.gz
tar xzf openshift-client-linux.tar.gz
echo Copying files to /usr/local/bin 
sudo cp {tmux,oc} /usr/local/bin/
sudo chmod +x /usr/local/bin/tmux
sudo chmod +x /usr/local/bin/oc
echo "Installing tmuxp"
sudo dnf install -y python3-pip -q
pip3 install tmuxp -q
echo "Copying tmux-sessions dir to '$USER' home"
cp -R tmux-sessions ~/
echo "Done"
