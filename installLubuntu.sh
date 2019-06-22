#!/bin/bash
set -e
apt update && apt -y dist-upgrade
sudo apt-get install lubuntu-desktop
sudo apt-get install xrdp
lxsession -e LXDE -s Lubuntu
# nano /etc/xrdp/startwm.sh
# last line lxsession -s Lubuntu -e LXDE
sudo service xrdp restart
# For Update xdrp 
# https://github.com/neutrinolabs/xrdp/wiki/Building-on-Debian-8
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "/home/$USER/.docker" -R

exit 0