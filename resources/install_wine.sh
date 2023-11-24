#!/bin/bash

# Allow i386 Architecture
dpkg --add-architecture i386 && \
apt-get update && \
apt-get install wget gnupg2 software-properties-common -y

apt install -y apt-transport-https

# We will now setup the winehq key and repository
wget -nc https://dl.winehq.org/wine-builds/winehq.key

apt-key add winehq.key && \
add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ jammy main'

# Setup key and repository for dependency of wine
wget -nv https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_22.04/Release.key -O Release.key &&
apt-key add - < Release.key &&
apt-add-repository 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_22.04/ ./'

# Update repository 
apt-get update

## Now we will install wine
apt-get install -y --install-recommends winehq-stable winbind
apt-get install -y xvfb libvulkan1 libgl1-mesa-glx

# Clean key files
rm winehq.key Release.key

wine --version

# Install winetricks
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/sbin/winetricks
chmod a+x /usr/sbin/winetricks

