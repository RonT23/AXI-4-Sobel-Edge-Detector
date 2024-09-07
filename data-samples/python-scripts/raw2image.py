#!/usr/bin/env python3
'''
Description:
    This program visualizes images from raw image data by interpreting the raw
    bytes as 8-bit grayscale pixel values.

Usage:
    - <file_path>: Path to the input raw image file
    - <rows>     : Vertical image dimension (number of rows)
    - <columns>  : Horizontal image dimension (number of columns)

Example:
    $ python visualize_raw_image.py image.raw 512 512
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
        with open(file_path, 'rb') as fp:
            data = np.fromfile(fp, dtype=np.uint8, count=rows * cols)

        if data.size != rows * cols:
            print(f"Error: Data size ({data.size} bytes) does not match specified dimensions ({Nx}x{Ny} pixels).")
            sys.exit(1)

        # Reshape the data into a 2D array representing the image
        im = np.reshape(data, (rows, cols)) 

        # Display the image using matplotlib
        plt.imshow(im, cmap='gray')
        plt.title(f'Image from {file_path}')
        plt.show()

    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
        sys.exit(1)

    except ValueError:
        print("Error: Invalid dimensions provided. Nx and Ny should be positive integers.")
        sys.exit(1)

    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
