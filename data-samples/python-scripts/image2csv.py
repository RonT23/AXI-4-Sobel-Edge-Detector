#!/usr/bin/env python3
'''
Description:
    This program converts an image file (common formats: .png, .jpg, .tiff)
    to a CSV file to be used in Vivado simulations.

Usage:
    - <file_path_in>: The path to the input image file (.png, .jpg, .tiff).
    - <file_path_out>: The path to the output CSV file.

Example:
    $ python image_to_csv.py input_image.png output_data.csv
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
        # Load the image and convert it to grayscale (L)
        img = Image.open(file_path_in)
        img_gray = img.convert('L')

        # Flatten the image into a 1D array
        sq = np.array(img_gray).flatten()

        # Save the flattened data into a CSV file
        np.savetxt(file_path_out, sq, delimiter=',', fmt='%d')

        print(f"Image successfully converted to CSV and saved to {file_path_out}")

    except FileNotFoundError:
        print(f"Error: The file '{file_path_in}' was not found.")
        sys.exit(1)

    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)
