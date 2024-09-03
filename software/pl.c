#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#include <sys/param.h>
#include <sys/mman.h>

#include "pl.h"

/*
 * This function configures and sets up the AXI DMA Channel.
 * @param channel : Pointer to the DMA channel structure (either RX or TX).
 * @return        : SOBEL_SUCCESS on success, SOBEL_FAILURE on failure.
 */
int AXI_DMA_Init (Channel *channel){
	char chan_name[64] = "/dev/";
	strcat(chan_name, channel->name);
	
	// Open the channel
	channel->fd = open(chan_name, O_RDWR);
	if (channel->fd == -1) {
		return SOBEL_FAILURE;
	}
	
	// Map memory
	channel->buf_ptr = (struct channel_buffer *)mmap(NULL, sizeof(struct channel_buffer) * 2, PROT_READ | PROT_WRITE, MAP_SHARED, channel->fd, 0);
	if (channel->buf_ptr == MAP_FAILED) {
		return SOBEL_FAILURE;
	} 

	return SOBEL_SUCCESS;
}/* end of AXI_DMA_Init() */


/*
 * This function writes data to a memory-mapped AXI Lite register. It writes 
 * 32-bit wide data to virtual memory at the address calculated as (reg + offset).
 * @param AxiReg : AXI Lite register data structure.
 * @param offset : Offset from the base address of the AXI Lite register.
 * @param data   : The unsigned 32-bit data to write.
 */
void AXILite_Register_Write (AXILite_Register_t * AxiReg, uint32_t offset, uint32_t data) {

    AxiReg->ptr[ offset >> 2 ] = ( uint32_t ) data;

}

/*
 * This function reads 32-bit wide data from a memory-mapped AXI Lite register 
 * at the address calculated as (reg + offset).
 * @param AxiReg : AXI Lite register data structure.
 * @param offset : Offset from the base address of the AXI Lite register.
 * @return       : The value stored in the register.
 */
uint32_t AXILite_Register_Read (AXILite_Register_t * AxiReg, uint32_t offset) {

    return ( uint32_t ) AxiReg->ptr[ offset >> 2 ];

} /* end of AXILite_Register_Read() */
