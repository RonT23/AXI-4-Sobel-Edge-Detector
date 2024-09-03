#!/usr/bin/env python3
'''
    Description : this program is used to convert an image file of
    common image formats (.png, .jpg, .tiff) to raw 8-bit
    values that represent gray scale pixels
    @ file_path_in : the path to the input image of common type (.png, .jpg, .tiff)
    @ file_path_out : the path to export the raw file
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

    with open(sys.argv[2], 'wb') as fp:
        fp.write(sq)