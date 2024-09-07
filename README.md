# AXI4 Sobel Edge Detector

## Project Overview

In this project we implement a ZYNQ-7 SoC for edge detection using the Sobel algorithm. The project combines the custom development of a Sobel Edge Detector FPGA core in VHDL using AMD Vivado, embedded Linux using AMD's PetaLinux utilities and embedded software in C for controlling the system from user-space. 

## Introduction

## Repository Content

- The build folder contains the automation python file `build.py` which is used to automate the build of the SoC along with the configuration file needed to define the parameters for the build. 
- The data-sampels contains some sample images both in CSV, RAW and TIFF formats as well as some python scripts used to convert images and visualize. 
- The hardware folder contains the VHDL description for both the Sobel Edge Detector IP Core FPGA design and the simulation along with the TCL script used to re-generate the Vivado project. 
- The petalinux-os folder contains scripts and source code used to generate PetaLinux binaries. 
- The software folder contains all the source code for the software application used to control the Sobel SoC. 
- The docs folder contains documents for both the FPGA implementation and the SoC design and evaluation. 

## The SED IP Core 

The Sobel Edge Detector IP Core (SED) is a custom AXI-4 compatible peripheral designed in VHDL for FPGA application with the task of accelerating the edge detection processing on images.  

### Features

### Limitations

### Performance

### Usage

More information about the design and operation of the IP core can be found in `/docs/AXI-4-SED.pdf`.

## The Z7SED SoC

The ZYNQ 7000 Sobel Edge Detector (Z7SED) is a ZYNQ 7000 based SoC which uses the SED peripheral controlled by a user-space Linux application. 

### Block Diagram

### Operating System

### Software

More information about the design and operation of the Z7SED can be found in `/docs/Z7SED-SoC.pdf`.

## Building the Z7SED SoC 

Use the `build.py` script in `/build/` folder. The script will take care and configure and build everything and deploy the binaries and related files into the SD card of the ZYNQ-based development board with FPGA fabric. Before running the script in a text edidor of your choise open the `env.config` file to provide some configurations that are needed from the automated build script. The parameters are described in the following table.

<div align="center">

| Parameter | Description |
|-----------|-------------|
| PROJ_DIR  | The full path to the project folder |
| VIVADO_DIR | The full path to the Vivado executable |
| PETALINUX_DIR | The full path to the PetaLinux tools |
| SW_FOLDER | The relative path within the project folder to the software folder |
| TCL_FILE |The relative path within the project to the TCL Vivado project file |
| XSA_FILE | The relative path within the project to the generated XSA file |
| OS_FOLDER | The relative path to the PetaLinux OS filder | 
| DATA_FOLDER | The relative path within the project folder to the data folder |
| BUILD_VIVADO_PRJ | "YES" or "NO". Defines to the build.py wether to create or not the Vivado project |
| RUN_VIVADO_GUI | "YES" or "NO". Defines to the build.py weather to run the Vivado in GUI mode or in TCL|
| RM_VIVADO_PRJ | "YES" or "NO". Defines weather to remove the Vivado project files after the XSA is generated |
| BUILD_OS_PRJ | "YES" or "NO". Defines whether to create the PetaLinux project or not |
| RM_OS_PRJ | "YES" or "NO". Defines whether to remove the PetaLinux files after the binaries are created. |
| FLASH_SD | "YES" or "NO". Defines whether to flash the SD card or not. |
| LOAD_DATA | "YES" or "NO". Defines whether to load the data from the provided data folder into the SD card of the board | 

</div>
