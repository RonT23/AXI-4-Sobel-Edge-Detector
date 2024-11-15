#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage : $0 <PetaLinux-binaries-path> <Project-path>"
    exit 1
fi

# Copy boot components to BOOT partition
cd $1
cp ./BOOT.BIN ./image.ub ./boot.scr ./system.dtb /media/$USER/BOOT

# Extract the root file system to ROOTFS partition
sudo tar -xvf ./rootfs.tar.gz -C /media/$USER/ROOTFS

# Compile and install the software driver
make -C /$2/software
sudo cp /$2/software/sobel_pl_main /media/$USER/ROOTFS/usr/bin
make -C /$2/software clean

sync

echo "SD Memory card is ready!"
