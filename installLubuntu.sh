#!/bin/bash
set -e
sudo apt update && sudo apt -y dist-upgrade
sudo apt-get install lubuntu-desktop
sudo apt update && sudo apt -y dist-upgrade

# https://github.com/neutrinolabs/xrdp/wiki/Building-on-Debian-8
# nano /etc/xrdp/startwm.sh
# last line lxsession -s Lubuntu -e LXDE
sudo systemctl enable xrdp
sudo service xrdp restart

# Themeing
# https://www.deviantart.com/satya164/art/elementary-Dark-GTK3-Theme-244257862

# Docker 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

sudo groupadd docker
sudo usermod -aG docker $USER
# If still Permission denied
sudo chmod 666 /var/run/docker.sock

mkdir .docker
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "/home/$USER/.docker" -R

exit 0