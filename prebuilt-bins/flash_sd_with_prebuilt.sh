#!/bin/bash

# Copy boot components to BOOT partition
cp ./BOOT.BIN ./image.ub ./boot.scr ./system.dtb /media/$USER/BOOT

# Extract the root file system to ROOTFS partition
sudo tar -xvf ./rootfs.tar.gz -C /media/$USER/ROOTFS

# Create a data folder and populate with images

sudo mkdir -p /media/$USER/ROOTFS/sample-data
sudo cp ../data-samples/raw/* /media/$USER/ROOTFS/sample-data

# Compile and install the software driver
sudo cp ./sobel_pl_main /media/$USER/ROOTFS/usr/bin

sync

echo "SD Memory card is ready!"
