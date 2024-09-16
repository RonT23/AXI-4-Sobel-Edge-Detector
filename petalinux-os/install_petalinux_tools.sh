#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage : $0 <Path-to-PetaLinux-Installer>"
    exit 1
fi

# install tools and libraries required for the PetaLinux tools
sudo apt-get install -y gcc 
sudo apt-get install -y git 
sudo apt-get install -y make 
sudo apt-get install -y net-tools 
sudo apt-get install -y libncurses5-dev 
sudo apt-get install -y tftpd 
sudo apt-get install -y zlib1g-dev 
sudo apt-get install -y libssl-dev 
sudo apt-get install -y flex 
sudo apt-get install -y bison 
sudo apt-get install -y libselinux1 
sudo apt-get install -y gnupg 
sudo apt-get install -y wget 
sudo apt-get install -y diffstat 
sudo apt-get install -y chrpath 
sudo apt-get install -y socat 
sudo apt-get install -y xterm 
sudo apt-get install -y autoconf 
sudo apt-get install -y libtool 
sudo apt-get install -y tar 
sudo apt-get install -y unzip 
sudo apt-get install -y texinfo 
sudo apt-get install -y zlib1g-dev 
sudo apt-get install -y gcc-multilib 
sudo apt-get install -y build-essential 
sudo apt-get install -y libsdl1.2-dev 
sudo apt-get install -y libglib2.0-dev 
sudo apt-get install -y zlib1g:i386 
sudo apt-get install -y screen 
sudo apt-get install -y pax 
sudo apt-get install -y gzip 
sudo apt-get install -y gawk 
sudo apt-get install -y libtinfo5

# execute the petalinux installer
chmod +x $1/petalinux*.run
$1/petalinux*.run