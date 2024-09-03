#ifndef _SOBEL_PL_H_
#define _SOBEL_PL_H_

#include "pl.h"

#define SOBEL_IP_CORE_REG_BASE 		0x43c00000	 // the sobel edge detector AXI-Lite MMAP Registers base address
#define SOBEL_IP_CORE_REG_SIZE 		4 * 1024

#define ENABLE_REG_OFFSET			0x00
#define INPUT_COUNT_REG_OFFSET		0x04
#define OUTPUT_COUNT_REG_OFFSET		0x08
#define CLOCK_COUNT_REG_OFFSET		0x0c

#define CHUNK_SIZE_PER_TRANSFER		4096

//#define IS_VERBOSE // uncomment this for verbose messages

typedef struct {

	Channel *channel;		// DMA channel
	char *file;				// input filename
	uint32_t transfer_size;	// Transfer size in bytes	
	uint32_t total_size;	// Total data size in bytes
	uint32_t status;		// The worker status
	int halt_op;			// Halt signal

}dma_thread_args_t;

typedef struct {

    char * Fin;         // Input image file path
    char * Fout;        // Output image file path

    int Nx;             // Number of columns
    int Ny;             // Number of rows
    int fdi;            // Input image file descriptor
    int fdo;            // Output image file descriptor

	Channel *rx_channel;	// DMA receiver channel
	Channel *tx_channel;	// DMA transmitter channel

	AXILite_Register_t *reg; // Sobel IP core registers

} sobel_edge_detection_t;

int get_input(int argc, char * argv[], sobel_edge_detection_t * params);

int setup(sobel_edge_detection_t * params);

void create_thread(dma_thread_args_t *thread_args, Channel *channel, void *handler, char *file, int transfer_size, int total_size);

struct timeval get_time(void);

double elapsed_time(struct timeval t_i, struct timeval t_f);

void *ps2pl (void *args);

void *pl2ps (void *args);

#endif
