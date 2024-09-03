#!/usr/bin/env python3
'''
	Description :this program is used to visualize images from csv image data
	@ file_path : the path to the input csv
	@ Nx : the horizontal image dimension
	@ Ny : the vertical image dimension
'''
import numpy as np
import matplotlib.pyplot as plt
import sys
	
if __name__ == "__main__":
	
	if (len(sys.argv) < 4):
		print(f"\n Usage : {sys.argv[0]} <file_path> <Nx> <Ny> \n")
		exit()
	
	data = np.loadtxt(sys.argv[1], delimiter=',')
	im = np.reshape(data, (int(sys.argv[2]), int(sys.argv[3])))
	plt.imshow(im, cmap='gray')
	plt.show()
