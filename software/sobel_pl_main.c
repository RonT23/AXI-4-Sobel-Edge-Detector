#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/param.h>
#include <sys/mman.h>

#include "sobel_pl.h"
#include "pl.h"

int main (int argc, char *argv[]) {
	
	printf("\n\n");
    printf("Sobel Edge Detector SoC-FPGA v1.0 \n");
	printf("---------------------------------------- \n");
	printf("Ronaldo Tsela \n");
	printf("August 2024 \n");
    printf("---------------------------------------- \n");
	printf("\n\n");

	sobel_edge_detection_t params;
	dma_thread_args_t *tx_args;
	dma_thread_args_t *rx_args;

    if ( get_input(argc, argv, &params) != SOBEL_SUCCESS ) {  exit( SOBEL_FAILURE ); }

	if ( setup( &params ) != SOBEL_SUCCESS ) 			   {  exit( SOBEL_FAILURE ); } 
	
	int N = params.Nx * params.Ny;
	
	tx_args =  (dma_thread_args_t *)malloc( sizeof(dma_thread_args_t) );
	rx_args =  (dma_thread_args_t *)malloc( sizeof(dma_thread_args_t) );
	
	if (!(tx_args) || !(rx_args)) {

		printf("[ERROR] Failed to allocate memory for DMA thread arguments \n");
		printf("[STATUS] Exiting with failure! \n");
		
		free(tx_args);
		free(rx_args);
		
		exit(SOBEL_FAILURE);
	}

	printf("[STATUS] Starting the edge detection processing \n");

    struct timeval t_start = get_time();
	
	// Configure and create the threads
	create_thread( rx_args, params.rx_channel, pl2ps, params.Fout, CHUNK_SIZE_PER_TRANSFER, N);
    create_thread( tx_args, params.tx_channel, ps2pl, params.Fin, CHUNK_SIZE_PER_TRANSFER, N);
	 
	// Join threads on termination or error
	pthread_join(params.rx_channel->tid, NULL);
	pthread_join(params.tx_channel->tid, NULL);
	
	// error from the threads
	if (( rx_args->status == SOBEL_FAILURE || tx_args->status == SOBEL_FAILURE )) {  

		printf("[ERROR] Threads terminated with errors. \n");

	} else { 
		
		struct timeval t_end = get_time();
		double proc_time = elapsed_time(t_start, t_end);

		printf("[INFO] The processed image is stored at : %s \n", params.Fout);

		printf("\n\n");
		printf("---------------------------------------- \n");
		printf("Processing Time (Measured in Software) : %.2f ms \n", proc_time * 1000.0 );
		printf("Total throughput (Measured in Software): %.2f bps \n", (double) params.Nx * params.Ny * 8 / proc_time);
		printf("Number of bytes read (Core stats)      : %d   bytes \n", AXILite_Register_Read(params.reg, INPUT_COUNT_REG_OFFSET));
		printf("Number of bytes written (Core stats)   : %d   bytes \n", AXILite_Register_Read(params.reg, OUTPUT_COUNT_REG_OFFSET));
		printf("Number of clock cycles (Core stats)    : %d   cc \n", AXILite_Register_Read(params.reg, CLOCK_COUNT_REG_OFFSET));
		printf("---------------------------------------- \n");
		printf("\n\n");

	}

	AXILite_Register_Write(params.reg, 0x00, 0x00);

	close(params.tx_channel->fd); 
	close(params.rx_channel->fd);

	free(rx_args); 
	free(tx_args);

    return SOBEL_SUCCESS;

}/* end of main() */
