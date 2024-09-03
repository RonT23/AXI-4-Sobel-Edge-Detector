#ifndef _SOBEL_PL_H_
#define _SOBEL_PL_H_

#include "pl.h"

#define SOBEL_IP_CORE_REG_BASE 		0x43c00000	 // the sobel edge detector AXI-Lite MMAP Registers base address
#define SOBEL_IP_CORE_REG_SIZE 		4 * 1024	 // the range to allocate for the IP core's control registers

#define ENABLE_REG_OFFSET			0x00		 // system enable     : Enable_Reg <= 0x00[0:0]
#define INPUT_COUNT_REG_OFFSET		0x04		 // input data count  : Count_In_Reg <= 0x04[31:0]
#define OUTPUT_COUNT_REG_OFFSET		0x08		 // output data count : Count_Out_Reg <= 0x08[31:0]
#define CLOCK_COUNT_REG_OFFSET		0x0c		 // clock count       : Clock_Reg <= 0x0c[31:0]

#define CHUNK_SIZE_PER_TRANSFER		4096		// increase this for faster processing. Caution however is needed! The transfer size that
												// the AXI DMA IP core can handle must be an integer power of 2.

//#define IS_VERBOSE // uncomment this for verbose messages

typedef struct {

	Channel *channel;		// DMA channel
	char *file;				// input filename
	uint32_t transfer_size;	// Transfer size in bytes	
	uint32_t total_size;	// Total data size in bytes
	uint32_t status;		// The worker status
	int halt_op;			// Halt signal (not used here)

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
