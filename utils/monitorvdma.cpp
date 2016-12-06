/* Continuously print information about the status of the VDMA engine.
 * Assumes there are only three buffers in the ring, and prints their
 * addresses.
 * Steven Bell <sebell@stanford.edu>
 */

#include <fcntl.h>
#include <time.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdio.h>

const int VDMA_ADDR = 0x4300000;

int main(int argc, char* argv[])
{
  timespec delay;
  delay.tv_sec = 0;
  delay.tv_nsec = 1000000; // 1ms

  int memHandle = open("/dev/mem", O_RDWR);

  unsigned char* vdmaData = (unsigned char*)mmap(NULL, 0x100, PROT_READ,        MAP_SHARED, memHandle, 0x43000000);

  while(1){
    printf("CURDESC: %08lx, BUF 0: %08lx, BUF 1: %08lx, BUF 2: %08lx\n",
      *(unsigned long*)(vdmaData + 0x24),
      *(unsigned long*)(vdmaData + 0xac),
      *(unsigned long*)(vdmaData + 0xb0),
      *(unsigned long*)(vdmaData + 0xb4));
    nanosleep(&delay, NULL);
  }

  return(0);
}

