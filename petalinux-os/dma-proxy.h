#include <linux/ioctl.h>

#define BUFFER_SIZE (128 * 1024)
#define BUFFER_COUNT 1
#define TX_BUFFER_COUNT 1
#define RX_BUFFER_COUNT 1
#define BUFFER_INCREMENT 1

#define FINISH_XFER _IOW('a', 'a', int32_t*)
#define START_XFER  _IOW('a', 'b', int32_t*)
#define XFER        _IOW('a', 'c', int32_t*)

struct channel_buffer{
	unsigned int buffer[BUFFER_SIZE / sizeof(unsigned int)];
	enum proxy_status {
		PROXY_NO_ERROR = 0,
		PROXY_BUSY     = 1,
		PROXY_TIMEOUT  = 2,
		PROXY_ERROR    = 3	
	} status;
	unsigned int length;
} __attribute__ ((aligned (1024)));
