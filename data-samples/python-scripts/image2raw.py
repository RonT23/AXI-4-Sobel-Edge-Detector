#!/usr/bin/env python3
'''
Description:
    This program converts an image file (common formats: .png, .jpg, .tiff)
    to raw 8-bit values representing grayscale pixels.

Usage:
    - <file_path_in>: The path to the input image file (.png, .jpg, .tiff)
    - <file_path_out>: The path to export the raw file

Example:
    $ python image_to_raw.py input_image.png output_data.raw
'''

import numpy as np
from PIL import Image
import sys

if __name__ == "__main__":

    if len(sys.argv) != 3:
        print(f"\nUsage: {sys.argv[0]} <file_path_in> <file_path_out>\n")
        sys.exit(1)

    file_path_in = sys.argv[1]
    file_path_out = sys.argv[2]

    try:
        # Open the image file and convert it to grayscale (L)
        img = Image.open(file_path_in)
        img_gray = img.convert('L')

        # Flatten the image into a 1D array
        sq = np.array(img_gray).flatten()

        # Write the raw pixel data to the output file as bytes
        with open(file_path_out, 'wb') as fp:
            fp.write(sq.tobytes())  
            
        print(f"Image successfully converted to raw format and saved to {file_path_out}")

    except FileNotFoundError:
        print(f"Error: The file '{file_path_in}' was not found.")
        sys.exit(1)

    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
