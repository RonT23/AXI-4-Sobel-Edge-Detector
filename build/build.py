#!/bin/usr/python3

import os
import platform

current_os = platform.system()
print(current_os)

'''
    Function to read the configuration file.
    @param file_path : the path to the configuration file
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
    Build the Vivado project from the given TCL script. Generate and export the XSA file.
    This function can work on both Windows and Linux (Unix) devices. Requires Vivado app.
    @param config : the list of configurations
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
        print("[ERROR] Missing TCL_DIR in the configuration.")
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
    This function can only be executed on Linux (Unix) machines.
'''
def build_PetaLinux_project(config):

    # if not linux exit
    if current_os == "Windows":
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
        
    build_script_file_path = os.path.join(proj_dir, os_build_folder)
    xsa_file = os.path.join(proj_dir, xsa_file)
    
    os.chdir(build_script_file_path)

    print(proj_dir)
    print(os_tools_dir)
    print(build_PetaLinux_project)

    # run the petalinux creation script
    os.system(f"chmod +x ./create_petalinux_base_image.sh")
    os.system(f"./create_petalinux_base_image.sh {os_tools_dir} {xsa_file}")
    
    os.chdir(build_script_file_path)

    # clean-up if requested
    if config.get("RM_OS_PRJ") == "YES":
        os.system("sudo rm -r ./sobel_soc_zynq")

    return 1

def flash_sd(config):
    
    # if not linux exit
    if current_os == "Windows":
        print("[ERROR] This function cannot be executed on Windows machines.")
        return -1

    
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