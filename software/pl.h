#ifndef _PL_H_
#define _PL_H_

#include <pthread.h>
#include <stdint.h>

#include "dma-proxy.h"

#define SOBEL_SUCCESS  0
#define SOBEL_FAILURE -1

#define DMA_TX_CHANNEL_NAME "dma_proxy_tx_0"
#define DMA_RX_CHANNEL_NAME "dma_proxy_rx_0"

typedef struct{

	struct channel_buffer *buf_ptr;
	char *name;
	int fd;
	pthread_t tid;
	pthread_t ret;
	
}Channel;

typedef struct{

	uint32_t base;
	uint32_t *ptr;
	uint32_t size;	

}AXILite_Register_t;

void AXILite_Register_Write( AXILite_Register_t * AxiRegs, uint32_t offset, uint32_t data );

uint32_t AXILite_Register_Read( AXILite_Register_t * AxiRegs, uint32_t offset );

int AXI_DMA_Init( Channel *channel );

#endif
