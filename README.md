# AXI4 Sobel Edge Detector

## Folder Content

1. Hardware
    - sim                               [ok]
    - sources                           [ok]
    - Sobel_Package.vhd                 [ok]
    - Sobel_SoC.tcl                     [ok]

2. Petalinux-OS
    - create_petalinux_base_image.sh    [ok]
    - dma-proxy driver source           [ok]
    - flash_sd.sh                       [ok]

4. Software
    - sources                           [test and revalidate]
    - Makefile                          [ok]
    
5. Data-Samples
    - Python scripts                    [pk]
    - raw-files                         [ok]
    - csv-files                         [ok]
    - original-files                    [ok]

6. Build-SoC
    - build.py                          [ compile the software and in general build all the required binaries for the SoC and deploy them on SD]
    - env.config                        [add enviroment variables]

Test everything on Ajax

Write the document for the IP core

Write the user-guide for the repository

## Overview

Description of this project. Description of the contents.

## Key Features

## Design Limitations

## Usage

## Integration with ZYNQ-7 PS