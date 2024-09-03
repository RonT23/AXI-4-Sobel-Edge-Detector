#!/usr/bin/env python3
'''
    Description : this program is used to visualize images from raw image data
    @ file_path : the path to the input raw image
    @ Nx : the horizontal image dimension
    @ Ny : the vertical image dimension

'''

import numpy as np
import matplotlib.pyplot as plt
import sys
	
if __name__ == "__main__":
	
    if (len(sys.argv) < 3):
        print(f"\n Usage : {sys.argv[0]} <file_path> <Nx> <Ny>\n")
        exit()

    with open(sys.argv[1], 'rb') as fp:
        data = np.fromfile(fp, dtype=np.uint8, count= int(sys.argv[2])*int(sys.argv[3]))

    im = np.reshape(data, (int(sys.argv[2]), int(sys.argv[3])))

    plt.imshow(im, cmap='gray')
    plt.show()