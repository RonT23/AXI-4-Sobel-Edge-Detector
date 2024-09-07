#!/usr/bin/env python3
'''
Description: This program visualizes images from CSV image data.

Usage: 
    - <file_path>: Path to the input CSV file containing image data
    - <rows>     : Vertical image dimension (number of rows)
    - <columns>  : Horizontal image dimension (number of columns)

Example:
    $ python visualize_image.py image_data.csv 512 512
'''

import numpy as np
import matplotlib.pyplot as plt
import sys

if __name__ == "__main__":

    if len(sys.argv) != 4:
        print(f"\nUsage: {sys.argv[0]} <file_path> <rows> <columns>\n")
        sys.exit(1) 

    file_path = sys.argv[1]
    rows = int(sys.argv[2])
    cols = int(sys.argv[3])  

    try:
        data = np.loadtxt(file_path, delimiter=',')
        
        if data.size != rows * cols:
            print(f"Error: Data size ({data.size}) does not match specified dimensions ({Ny}, {Nx}).")
            sys.exit(1)

        # Reshape the flat data into a 2D image
        im = np.reshape(data, (rows, cols))
        
        # Display the image using matplotlib
        plt.imshow(im, cmap='gray')
        plt.title(f'Image from {file_path}')
        plt.show()

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
