#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/param.h>
#include <sys/mman.h>
#include <sys/time.h>

#include "sobel_pl.h"

/*
 * Function to retrieve and validate user input.
 * @param argc   : Number of input arguments.
 * @param argv   : Array of input argument values.
 * @param params : Sobel edge detection data structure.
 * @return       : SOBEL_SUCCESS on success, SOBEL_FAILURE on failure.
 */
int get_input(int argc, char *argv[], sobel_edge_detection_t *params) {

    if (argc < 5) {
        printf("Usage   : %s <FIN> <FOUT> <NX> <NY> \n\n", argv[0]);
        printf("  FIN  : Path to the 8-bit input grayscale raw image \n");
        printf("  FOUT : Path to the 8-bit output grayscale raw image \n");
        printf("  NX   : Horizontal image dimension \n");
        printf("  NY   : Vertical image dimension \n");
        exit(1);
    }

    printf("[STATUS] Checking the inputs \n");

    // Input file name
    params->Fin = argv[1];          
    params->fdi = open(params->Fin, O_RDONLY);

    if (params->fdi == -1) {

        #ifdef IS_VERBOSE
            printf("[ERROR] FIN : %s \n", params->Fin);
            printf("Could not open %s \n", params->Fin);
            printf("[STATUS] Exiting with failure!");
        #endif

        return SOBEL_FAILURE;

    }

    #ifdef IS_VERBOSE
        printf("[OK] FIN : %s \n", params->Fin);
    #endif

    close(params->fdi);
    
    // Output file name
    params->Fout = argv[2];  
    params->fdo = open(params->Fout, O_WRONLY | O_CREAT, 0666);

    if (params->fdo == -1) {

        #ifdef IS_VERBOSE
            printf("[ERROR] FOUT :  %s \n", params->Fout);
            printf("Could not open %s \n", params->Fout);
            printf("[STATUS] Exiting with failure!");
        #endif

        return SOBEL_FAILURE;

    }

    #ifdef IS_VERBOSE
        printf("[OK] FOUT : %s \n", params->Fout);
    #endif

    close(params->fdo);

    // Horizontal image dimension
    params->Nx = atoi(argv[3]);

    if (params->Nx <= 0) {

        #ifdef IS_VERBOSE
            printf("[ERROR] NX : %d \n", params->Nx);
            printf("NX must be a number greater than zero \n");
            printf("[STATUS] Exiting with failure!");
        #endif

        return SOBEL_FAILURE;

    }

    #ifdef IS_VERBOSE
        printf("[OK] NX : %d \n", params->Nx);
    #endif

    // Vertical image dimension
    params->Ny = atoi(argv[4]);

    if (params->Ny <= 0) {

        #ifdef IS_VERBOSE
            printf("[ERROR] NY : %d \n", params->Ny);
            printf("NY must be a number greater than zero \n");
            printf("[STATUS] Exiting with failure!");
        #endif

        return SOBEL_FAILURE;

    }

    #ifdef IS_VERBOSE
        printf("[OK] NY : %d [OK]\n", params->Ny);
    #endif

    return SOBEL_SUCCESS;
} /* end of get_input() */

/*
 * Function to allocate memory buffers for input and output data, and 
 * to read the input image.
 * @param params : Sobel edge detection data structure.
 * @return       : SOBEL_SUCCESS on success, SOBEL_FAILURE on failure.
 */
int setup(sobel_edge_detection_t *params) {

    printf("[STATUS] Inserting dma-proxy.ko driver module\n");

    // Rename the modules folder
    system("mv /lib/modules/* /lib/modules/xilinx/ > /dev/null 2>&1");

    // Remove the dma-proxy module if still active
    system("sudo rmmod -w /lib/modules/xilinx/extra/dma-proxy.ko > /dev/null 2>&1");

    // Insert the dma-proxy module
    system("sudo insmod /lib/modules/xilinx/extra/dma-proxy.ko > /dev/null 2>&1");

    printf("[STATUS] Initializing the DMA channels\n");

    // Setup the DMA channels
	params->tx_channel = (Channel *)malloc(sizeof(Channel));
	params->rx_channel = (Channel *)malloc(sizeof(Channel));

    params->tx_channel->name = (char *)DMA_TX_CHANNEL_NAME;
    params->rx_channel->name = (char *)DMA_RX_CHANNEL_NAME;

    // Activate the AXI DMA IP core
    if (AXI_DMA_Init(params->tx_channel) || AXI_DMA_Init(params->rx_channel)) {

        printf("[ERROR] Cannot initialize the DMA channels \n");
        printf("[STATUS] Exiting with failures \n");
        return SOBEL_FAILURE;

    }

    printf("[STATUS] Setting up the AXI4-Lite Sobel Edge Detector interface \n");

    // Map the AXI Sobel Edge Detector registers 
	int fd = open("/dev/mem", O_RDWR | O_SYNC); 
    
    params->reg = (AXILite_Register_t *)malloc(sizeof(AXILite_Register_t));
    
    params->reg->size = SOBEL_IP_CORE_REG_SIZE;
    params->reg->base = SOBEL_IP_CORE_REG_BASE;
    params->reg->ptr = mmap(NULL, params->reg->size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, params->reg->base);
    
    #ifdef IS_VERBOSE
        printf("[INFO] Register Address Space Size : %d B\n", params->reg->size);
        printf("[INFO] Register Physical Address   : 0x%x \n", params->reg->base);
        printf("[INFO] Register Mapped Address     : 0x%x \n", params->reg->ptr);
    #endif

    // Disable the core if already is enabled and then enable it
    printf("[STATUS] Enabling the Sobel Edge Detector IP core\n");

    AXILite_Register_Write(params->reg, ENABLE_REG_OFFSET, 0x00);
    AXILite_Register_Write(params->reg, ENABLE_REG_OFFSET, 0x01);

    // verify that the register is written
    if ( AXILite_Register_Read(params->reg, ENABLE_REG_OFFSET) != 1 ) {

        printf("[ERROR] Reg@[0x%x + 0x%x] cannot be written \n", params->reg->base, ENABLE_REG_OFFSET);
        printf("[STATUS] Exiting with failure \n");

        close(fd);

        return SOBEL_FAILURE;

    }

    close(fd);

    return SOBEL_SUCCESS;

} /* end of setup()*/

/*
 * Function to create the Sobel DMA controller threads
 * @param thread_args   : The thread arguments.
 * @param channel       : The DMA channel.
 * @param handler       : The thread handler function.
 * @param file          : The file to use (read or write).
 * @param transfer_size : The data size to transfer.
 * @param total_size    : The total data size. 
 */
void create_thread(dma_thread_args_t *thread_args, Channel *channel, void *handler, char *file, int transfer_size, int total_size) {

    thread_args->channel = channel;
    thread_args->file = file;
    thread_args->transfer_size = transfer_size;
    thread_args->total_size = total_size;

    pthread_create(&channel->tid, NULL, handler, (void *)thread_args);
} /* end of create_thread() */

/*
 * TX thread. Reads the input image file stored in the MMC to DRAM and then 
 * issues DMA transfer requests from PS to PL through the AXI DMA IP Core in chunks of N bytes at a time.
 * @param args : The list of worker arguments.
 */
void *ps2pl(void *args) {
    int buf_id = 0;
    int fi;

	dma_thread_args_t *thread_args = (dma_thread_args_t *)args;  

    // Open the input file
    if ( (fi = open(thread_args->file, O_RDONLY)) == -1) {

        printf("[ERROR] Unable to open input file \n");
        printf("[STATUS] Exiting with failure! \n");
        thread_args->status = SOBEL_FAILURE;

        return NULL;
    }

    uint32_t n_read = 0;  								// Total number of bytes read from the input file
    uint32_t transfer = thread_args->transfer_size;  	// Size of each DMA transfer
    uint32_t total = thread_args->total_size;  			// Total size of data to be transferred

    Channel *channel = thread_args->channel;
	
    while ( n_read < total ) {

	    // Adjust the transfer size if remaining data is less than the transfer size.
        if (transfer > (total - n_read)) {
            transfer = total - n_read;
        }

        // Read data from the input file into the buffer.
        uint32_t n = read(fi, channel->buf_ptr[buf_id].buffer, transfer);
        if (n <= 0) {
            printf("[WARN] Return value from input file: %d \n", n);
            printf("[STATUS] Terminating the thread\n");
            break;
        }

        channel->buf_ptr[buf_id].length = n;  // Set the length of the data in the buffer
        n_read += n;  						  // Update the total number of bytes read

        // Start the DMA transfer from PS to PL (blocking)
        if (ioctl(channel->fd, XFER, &buf_id) < 0) {
            printf("[ERROR] PS to PL DMA transfer failed \n");
            printf("[STATUS] Exiting with failure! \n");
            thread_args->status = SOBEL_FAILURE;
            close(fi);
            return NULL;
        }

        // Wait until DMA transfer completes succesfully
        if (channel->buf_ptr[buf_id].status != PROXY_NO_ERROR) {
            printf("[ERROR] PS to PL DMA transfer encountered a proxy error \n");
            printf("[STATUS] Exiting with failure! \n");
            thread_args->status = SOBEL_FAILURE; 
            close(fi);  
            return NULL;
        }

    }

    printf("[STATUS] PS to PL Thread terminated! \n");

    close(fi);
    thread_args->status = SOBEL_SUCCESS;
    return NULL;

} /* end of ps2pl() */

/*
 * RX thread. Issues DMA transfer requests to the S2MM interface of the DMA IP Core,
 * reads processed edge data from the Sobel edge detector IP Core, and writes the data 
 * in chunks of N bytes to MMC. 
 * @param args : The list of worker arguments.
 */
void *pl2ps(void *args) {
    int buf_id = 0;  
    int fo; 

    dma_thread_args_t *thread_args = (dma_thread_args_t *)args; 

    if ( (fo = open(thread_args->file, O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1) {
        printf("[ERROR] Unable to open output file \n");
        printf("[STATUS] Exiting with failure! \n");
        thread_args->status = SOBEL_FAILURE;
        return NULL;
    }

    uint32_t n_write = 0;  								// Total number of bytes written to the output file
    uint32_t transfer = thread_args->transfer_size;  	// Size of each DMA transfer
    uint32_t total = thread_args->total_size;  			// Total size of data to be transferred

    Channel *channel = thread_args->channel;

    while (n_write < total) {

	    // Adjust the transfer size if remaining data is less than the transfer size.
        if (transfer > (total - n_write)) {
            transfer = total - n_write;
        }

        channel->buf_ptr[buf_id].length = transfer;  // Set the length of the data to be transferred.

        // Start the DMA transfer from PL to PS.
        if (ioctl(channel->fd, XFER, &buf_id) < 0) {
            printf("[ERROR] PL to PS DMA transfer failed \n");
            printf("[STATUS] Exiting with failure! \n");
            thread_args->status = SOBEL_FAILURE;
            close(fo);
            return NULL;
        }

        // Write the received data to the output file.
        uint32_t n = write(fo, channel->buf_ptr[buf_id].buffer, transfer);
        if (n <= 0) {
            printf("[WARN] Return vale from output file: %d", n);
            printf("[STATUS] Terminating the thread. \n");
            break;
        }

        if (channel->buf_ptr[buf_id].status != PROXY_NO_ERROR) {
            printf("[ERROR] PL to PS DMA transfer encountered a proxy error \n");
            printf("[STATUS] Exiting with failure! \n");
            thread_args->status = SOBEL_FAILURE;
            close(fo); 
            return NULL;
        }

        n_write += n;  // Update the total number of bytes written 

    }

    printf("[STATUS] PL to PS Thread terminated!\n");

    close(fo);
    thread_args->status = SOBEL_SUCCESS; 

    return NULL;
	
} /* end of pl2ps() */

/*
 * Function to get the current time of day.
 * @return : The current time as a timeval structure.
 */
struct timeval get_time(void) {
    struct timeval t;

    gettimeofday(&t, NULL);

    return t;
} /* end of get_time() */

/*
 * Function to measure the elapsed time.
 * @param t_i : Start time.
 * @param t_f : End time.
 * @return    : The elapsed time in seconds.
 */
double elapsed_time(struct timeval t_i, struct timeval t_f) {
    return (t_f.tv_sec - t_i.tv_sec) + ((t_f.tv_usec - t_i.tv_usec) / 1000000.0);
} /* end of elapsed_time() */
