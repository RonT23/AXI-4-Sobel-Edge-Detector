#!/bin/bash

if [ -z "$1" ] ; then
    echo "Usage : $0 <PetaLinux-tools-path> <Path-to-xsa> <Output-bin-path>"
    exit 1
fi

petalinux_project_name="sobel_soc_zynq"

# Source PetaLinux tools
source "$1/settings.sh"

# Create a PetaLinux project
petalinux-create --type project --name $petalinux_project_name --template zynq --force
cd ./$petalinux_project_name

# Configure the PetaLinux on the propvided hardware
petalinux-config --get-hw-description=$2

# Create and configure the DMA-Proxy module
petalinux-create --type modules --name dma-proxy --enable --force
cp ../dma-proxy.* ./project-spec/meta-user/recipes-modules/dma-proxy/files
cp ../system-user.dtsi ./project-spec/meta-user/recipes-bsp/device-tree/files

# Create the command file to append the dma-proxy.h to .bb
echo "13i" > cmd.txt
echo "file://dma-proxy.h \ " >> cmd.txt
echo "." >> cmd.txt
echo "w" >> cmd.txt
echo "q" >> cmd.txt

ed ./project-spec/meta-user/recipes-modules/dma-proxy/dma-proxy.bb < cmd.txt

rm cmd.txt

# Build the applications
petalinux-build

# Package the boot components
petalinux-package --boot --force --fsbl ./images/linux/zynq_fsbl.elf --fpga ./images/linux/system.bit --uboot ./images/linux/u-boot.elf

# Export boot components
mkdir -p $3
cp ./images/linux/BOOT.BIN ./images/linux/boot.scr ./images/linux/system.dtb ./images/linux/image.ub ./images/linux/rootfs.tar.gz $3
