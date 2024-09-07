#!/bin/usr/python3

import os
import platform

current_os = platform.system()
print(current_os)

'''
    Function to read a configuration file and return its contents as a dictionary.

    The configuration file is expected to have key-value pairs separated by commas.
    Each key-value pair should be on a separate line, with the key and value being
    separated by a comma. The value can optionally be enclosed in double quotes.

    @param file_path: The path to the configuration file.
    @return: A dictionary containing the key-value pairs from the configuration file.
'''
def read_config_file(file_path):
    config = {}
    try:
        with open(file_path, 'r') as file:

            for line in file:
            
                line = line.strip()
            
                if line:
                    _key, _val = line.split(',', 1)
                    config[_key.strip()] = _val.strip('"')

    except FileNotFoundError:
        print(f"[ERROR] The file {file_path} was not found.")

    except Exception as e:
        print(f"[ERROR] {e}")

    return config

'''
    Function to build a Vivado project from the given TCL script and generate the XSA file.
    
    This function automates the process of building a Vivado project by executing
    a TCL script using Vivado. It works on both Windows and Linux (Unix) platforms,
    provided that the Vivado application is installed and accessible.

    @param config: A dictionary containing the configuration options, which include:
        - PROJ_DIR: The project directory path.
        - VIVADO_DIR: The path to the Vivado executable.
        - TCL_FILE: The path to the TCL script used to build the project.
        - RUN_VIVADO_GUI: (Optional) Set to "YES" to run Vivado in GUI mode.
    
    @return: Returns 1 on success, or -1 if a required configuration is missing.
'''
def build_Vivado_project(config):

    proj_dir = config.get('PROJ_DIR')
    vivado_dir = config.get('VIVADO_DIR')
    tcl_file = config.get("TCL_FILE")

    if not proj_dir:
        print("[ERROR] Missing PROJ_DIR in the configuration.")
        return -1

    if not vivado_dir:
        print("[ERROR] Missing VIVADO_DIR in the configuration.")
        return -1

    if not tcl_file:
        print("[ERROR] Missing TCL_FILE in the configuration.")
        return -1

    # go to root project directory
    os.chdir(proj_dir)

    tcl_file = os.path.join(proj_dir, tcl_file)

    # reproduce the project through the TCL 
    if config.get('RUN_VIVADO_GUI') == "YES":
        os.system(f'{vivado_dir} -source {tcl_file} &')
    
    else:
        os.system(f'{vivado_dir} -mode tcl -source {tcl_file}')

    # clean-up if requested
    if current_os == "Windows":
        os.system(f"rmdir /S /Q .\\.Xil")
        os.system(f"del /S /Q .\\vivado*")
        os.system(f"rmdir /S /Q .\\sobel_soc")
        
    else:
        os.system(f"rm -rf ./.Xil")
        os.system(f"rm -rf ./vivado*")
        os.system(f"rm -rf ./sobel_soc")

    return 1

'''
    Function to build a PetaLinux project using the provided configuration on Linux (Unix) machines.
    
    This function automates the process of building a PetaLinux project by running a
    PetaLinux creation script. It must be run on a Linux (Unix) machine and requires
    the PetaLinux tools to be installed.

    @param config: A dictionary containing the following configuration options:
        - PROJ_DIR: The root project directory.
        - PETALINUX_DIR: The directory where PetaLinux tools are installed.
        - OS_FOLDER: The folder where the PetaLinux build script is located.
        - XSA_FILE: The hardware description (XSA) file to be used.
        - RM_OS_PRJ: (Optional) Set to "YES" to remove the OS project folder after build.

    @return: Returns 1 on success, or -1 if an error occurs or if run on Windows.
'''
def build_PetaLinux_project(config):

    # if not linux exit
    if current_os != "Linux":
        print("[ERROR] This function cannot be executed on Windows machines.")
        return -1

    proj_dir = config.get('PROJ_DIR')
    os_tools_dir = config.get("PETALINUX_DIR")
    os_build_folder = config.get("OS_FOLDER")
    xsa_file = config.get("XSA_FILE")

    if not proj_dir:
        print("[ERROR] Missing PROJ_DIR in the configuration.")
        return -1
    
    if not os_tools_dir:
        print("[ERROR] Missing PETALINUX_DIR in the configuration.")
        return -1

    if not os_build_folder:
        print("[ERROR] Missing OS_FOLDER in the configuration.")
        return -1

    if not xsa_file:
        print("[ERROR] Missing XSA_FILE in the configuration.")
        return -1

    build_script_file_path = os.path.join(proj_dir, os_build_folder)
    xsa_file = os.path.join(proj_dir, xsa_file)
    
    os.chdir(build_script_file_path)

    # run the petalinux creation script
    os.system(f"chmod +x ./create_petalinux_base_image.sh")
    os.system(f"./create_petalinux_base_image.sh {os_tools_dir} {xsa_file}")
    
    os.chdir(build_script_file_path)

    # clean-up if requested
    if config.get("RM_OS_PRJ") == "YES":
        os.system("sudo rm -r ./sobel_soc_zynq")

    return 1

'''
    Function to flash the SD card with the PetaLinux project files.
    
    This function automates the process of flashing an SD card with the PetaLinux
    binaries using a shell script. It is designed to run on Linux systems and will
    fail if executed on Windows. Additionally, if specified, it can load data
    onto the SD card after flashing.

    @param config: A dictionary containing the following configuration options:
        - PROJ_DIR: The root project directory.
        - OS_FOLDER: The folder where the PetaLinux build binaries are located.
        - LOAD_TEST_DATA: (Optional) Set to "YES" to load test images to the SD card after flashing.

    @return: Returns 1 on success, or -1 if an error occurs or if run on Windows.
'''
def flash_sd(config):
    
    # if not linux exit
    if current_os == "Windows":
        print("[ERROR] This function cannot be executed on Windows machines.")
        return -1

    proj_dir = config.get("PROJ_DIR")
    os_build_folder = config.get("OS_FOLDER")
    
    if not proj_dir:
        print("[ERROR] Missing PROJ_DIR in the configuration.")
        return -1
    
    if not os_build_folder:
        print("[ERROR] Missing OS_FOLDER in the configuration.")
        return -1

    petalinux_bins_path = os.path.join(proj_dir, os_build_folder)
    
    os.chdir(petalinux_bins_path)

    # run the flash_sd.sh script
    os.system(f"chmod +x ./flash_sd.sh")
    os.system(f"./flash.sh {petalinux_bins_path}/petalinux-bins {proj_dir}")
    
    # if defined load also some test images
    if config.get("LOAD_TEST_DATA") == "YES":
        
        data_folder = config.get("DATA_FOLDER")

        if not data_folder:
            print("[ERROR] Missing DATA_FOLDER in the configuration.")
            return -1

        data_folder = os.path.join(proj_dir, data_folder)

        os.system(f"sudo cp {data_folder}/* /media/$USER/ROOTFS/home/petalinux/")
    
    return 1
    
    
if __name__ == "__main__":

    config = read_config_file('env.config')

    if config.get("BUILD_VIVADO_PRJ") == "YES":
        if build_Vivado_project(config) < 0 :
            exit()

    if config.get("BUILD_OS_PRJ") == "YES" :
        if build_PetaLinux_project(config) < 0:
            exit()
    
    if config.get("FLASH_SD") == "YES":
        if flash_sd(config) < 0:
            exit()