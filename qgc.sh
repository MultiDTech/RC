#!/bin/bash

set -e
PLATFORM="$1"

echo "Is this script being run in a Radxa Zero 3W ?"
read confirm 

if [[ "$confirm" == "n" ]]; then
  echo "DO NOT RUN THIS SCIPT IN NON-RK3566 PLATFORMS"
else

echo "======================================================================"
echo "Updating apt"
echo "======================================================================"
if [ -f "/etc/apt/sources.list.d/radxa.list" ]; then
sudo mv /etc/apt/sources.list.d/radxa.list /etc/apt/sources.list.d/radxa.list.bak
sudo mv /etc/apt/sources.list.d/radxa-rockchip.list /etc/apt/sources.list.d/radxa-rockchip.list.bak
fi
sudo apt update -y


echo "======================================================================"
echo "Inserting wifi driver"
echo "======================================================================"
if ! lsmod | grep -q "88x2bu_ohd"; then
sudo insmod /home/radxa/RC/88x2bu_ohd.ko
fi


echo "======================================================================"
echo "Loading openhd binary "
echo "======================================================================"
sudo cp /home/radxa/RC/openhd /usr/local/bin/
sudo chmod +x /usr/local/bin/openhd


echo "======================================================================"
echo "Installing flatpak"
echo "======================================================================"
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak install --noninteractive flathub org.mavlink.qgroundcontrol
echo "======================================================================"
echo "Installed flatpak, added flathub to repo, installed QGC"
echo "======================================================================"


echo "======================================================================"
echo "Installing mandatory dependencies for openhd "
echo "======================================================================"

BASE_PACKAGES="libpoco-dev clang-format libusb-1.0-0-dev libpcap-dev libsodium-dev libnl-3-dev libnl-genl-3-dev libnl-route-3-dev libsdl2-dev git ruby-dev"
PLATFORM_PACKAGES="libpoco-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libunwind-dev"

# Install platform-specific packages
echo "Installing platform-specific packages..."
 for package in ${PLATFORM_PACKAGES} ${BASE_PACKAGES}; do
     echo "Installing ${package}..."
     apt install -y --no-install-recommends ${package}
     if [ $? -ne 0 ]; then
         echo "Failed to install ${package}!"
         exit 1
     fi
 done

gem install dotenv -v 2.8.1
gem install fpm

echo "======================================================================"
echo "hopefully it worked ?"
echo "======================================================================"

fi
