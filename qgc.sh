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
if [ -f "$/etc/apt/sources.list.d/radxa.list" ]; then
sudo mv /etc/apt/sources.list.d/radxa.list /etc/apt/sources.list.d/radxa.list.bak
sudo mv /etc/apt/sources.list.d/radxa-rockchip.list /etc/apt/sources.list.d/radxa-rockchip.list.bak
fi
sudo apt update -y


echo "======================================================================"
echo "Inserting wifi driver"
echo "======================================================================"
sudo insmod ~/RC/88x2bu_ohd.ko


echo "======================================================================"
echo "Loading openhd binary "
echo "======================================================================"
sudo cp ~/RC/openhd /usr/local/bin/


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

PLATFORM_PACKAGES="libpoco-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libcamera-openhd libunwind-dev "

curl -1sLf 'https://dl.cloudsmith.io/public/openhd/release/setup.deb.sh'| sudo -E bash
sudo apt update
#apt upgrade -y -o Dpkg::Options::="--force-overwrite" --no-install-recommends --allow-downgrades
sudo apt upgrade --no-install-recommends -y
# Install platform-specific packages
echo "Installing platform-specific packages..."
 for package in ${PLATFORM_PACKAGES} ${BASE_PACKAGES}; do
     echo "Installing ${package}..."
     #apt install -y -o Dpkg::Options::="--force-overwrite" --no-install-recommends ${package}
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
