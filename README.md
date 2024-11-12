# AXI4 Sobel Edge Detector

## CAUTION!

**THIS REPOSITORY IS NOT YET COMPLETE. THERE IS WORK TO BE DONE ON DOCUMENTATION AND THE USER GUIDE. FOR NOW, THE SOURCE CODE IS AVAILABLE.**

## Project Overview

This project implements a ZYNQ-7 SoC for edge detection using the Sobel algorithm. It combines the custom development of a Sobel Edge Detector FPGA core in VHDL using AMD Vivado, embedded Linux using AMD's PetaLinux utilities, and embedded software in C for user-space system control.

## Introduction

- Comming Soon

## Repository Content

- The build folder contains the automation Python script `build.py`, which automates the SoC build process. It also includes the configuration file that defines the build parameters.
- The `data-samples` folder contains sample images in CSV, RAW, and TIFF formats, as well as Python scripts for image conversion and visualization.
- The `hardware` folder contains the VHDL description of the Sobel Edge Detector IP Core FPGA design, simulation files, and a TCL script to regenerate the Vivado project.
- The `petalinux-os` folder contains scripts and source code for generating PetaLinux binaries.
- The `software` folder contains all the source code for the software application used to control the Sobel SoC. 
- The `docs` folder contains documentation on the FPGA implementation, SoC design, and evaluation.

## The SED IP Core 

The Sobel Edge Detector IP Core (SED) is a custom AXI-4 compatible peripheral, designed in VHDL for FPGA applications to accelerate edge detection processing on images.

### Features

- Comming Soon

### Limitations

- Comming Soon

### Performance

- Comming Soon

### Usage

- Comming Soon

## The Z7SED SoC

- Comming Soon

### Block Diagram

- Comming Soon

### Operating System

- Comming Soon

### Software

- Comming Soon

## Building the Z7SED SoC 

Use the `build.py` script in the `/build/` folder to configure, build, and deploy the binaries and related files to the SD card of the ZYNQ-based development board with FPGA fabric. Before running the script, open the `env.config` file in a text editor of your choice to provide the required configurations, as described in the table below.

<div align="center">

| Parameter | Description |
|-----------|-------------|
| PROJ_DIR  | Full path to the project folder |
| VIVADO_DIR | Full path to the Vivado executable |
| PETALINUX_DIR | Full path to the PetaLinux tools |
| SW_FOLDER | Relative path within the project folder to the software folder |
| TCL_FILE | Relative path within the project folder to the TCL Vivado project file |
| XSA_FILE | Relative path within the project folder to the generated XSA file |
| OS_FOLDER | Relative path to the PetaLinux OS folder | 
| DATA_FOLDER | Relative path within the project folder to the data folder |
| BUILD_VIVADO_PRJ | "YES" or "NO". Defines whether `build.py` should create the Vivado project |
| RUN_VIVADO_GUI | "YES" or "NO". Defines whether `build.py` should run the Vivado in GUI or TCL mode|
| RM_VIVADO_PRJ | "YES" or "NO". Defines whether to remove the Vivado project files after the XSA generation |
| BUILD_OS_PRJ | "YES" or "NO". Defines whether to create the PetaLinux project |
| RM_OS_PRJ | "YES" or "NO". Defines whether to remove the PetaLinux files after the binaries creation. |
| FLASH_SD | "YES" or "NO". Defines whether to flash the SD card. |
| LOAD_DATA | "YES" or "NO". Defines whether to load the data from the data folder onto the boards SD card| 

</div>
