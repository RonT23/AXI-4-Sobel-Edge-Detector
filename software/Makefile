#CC = gcc
CC = arm-linux-gnueabihf-gcc
CFLAGS = -g -Wall -static -O3
LDFLAGS =

SRC = sobel_pl_main.c sobel_pl.c pl.c
EXE = sobel_pl_main

all: $(EXE)

$(EXE): $(SRC)
		$(CC) $(CFLAGS) $(SRC) -o $@ $(LDFLAGS)

clean:
		rm -rf $(EXE)

.PHONY: all clean
