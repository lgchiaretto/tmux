#!/bin/bash

USER=$(id -un)
GROUP=$(id -gn)

echo "Configuring .bashrc, vimrc and .tmux.conf files"
cp {.bashrc,.tmux.conf,.vimrc} /home/$USER
mkdir -p /home/$USER/.tmux/
cp ocp-project.tmux ocp-cluster.tmux /home/$USER/.tmux/
chown $USER:$GROUP /home/$USER/{.bashrc,.tmux.conf,.vimrc}
chown -R $USER:$GROUP /home/$USER/.tmux/
echo Downloading tmux
wget -q --no-check-certificate 'https://docs.google.com/uc?export=download&id=15gI-MP8HyaJ65WIH-F3-TSl_pOQuPjEB' -O tmux
echo Downloading oc client
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.17.3/openshift-client-linux.tar.gz
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
