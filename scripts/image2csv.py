#!/usr/bin/env python3
'''
	Description : this program is used to convert an image file of
	common image formats (.png, .jpg, .tiff) to csv used for
	simulations on Vivado
	@ file_path_in : the path to the input image of common type (.png, .jpg, .tiff)
	@ file_path_out : the path to the output csv file
'''

import numpy as np
from PIL import Image
import sys
	
if __name__ == "__main__":
	
    if (len(sys.argv) < 3):
        print(f"\n Usage : {sys.argv[0]} <file_path_in> <file_path_out>\n")
        exit()

    img = Image.open(sys.argv[1])

    img_gray = img.convert('L')
    Nx, Ny = img_gray.size

    sq = np.array(img_gray).flatten()

    np.savetxt(sys.argv[2], sq, delimiter=',', fmt='%d')