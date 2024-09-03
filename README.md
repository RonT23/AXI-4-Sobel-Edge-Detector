# AXI4 Sobel Edge Detector

## Folder Content

1. Hardware
    - sim [ok]
    - sources [ok]
    - Sobel_Package.vhd [ok]
    - Sobel_SoC.tcl [Need to be generated on new Vivado and tried]

2. Petalinux-OS
    - create_petalinux_base_image.sh [ok]
    - dma-proxy driver source [ok]
    - flash_sd.sh [ok]

4. Software
    - sources and Makefile [ok]
    
5. Data-Samples
    - Python scripts [Need to fix dimensions Nx <-> Ny]
    - raw-files [need to add new images]
    - csv-files [need to add new images]
    - original-files [need to add new images]

6. Build-SoC
    - build.py [build a python script that will generate the hardware, build the petalinux-os, compile the software and in general build all the required binaries for the SoC and deploy them on SD]
    - env.config [add enviroment variables]

## Overview

## Key Features

## Design Limitations

## Usage

## Integration with ZYNQ-7 PS
