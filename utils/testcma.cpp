/* Test the cmabuffer driver
 * Steven Bell <sebell@stanford.edu>
 * 26 February 2016
 */

#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/mman.h>
#include "buffer.h"
#include "ioctl_cmds.h"

int main(int argc, char* argv[])
{
  // Open the buffer allocation device
  int cma = open("/dev/cmabuffer0", O_RDWR);
  if(cma == -1){
    printf("Failed to open cma provider!\n");
    return(0);
  }

  Buffer buf;
  buf.width = 256;
  buf.height = 256;
  buf.depth = 4; // Data is [RGB0x00]
  buf.stride = 256;

  int ok = ioctl(cma, GET_BUFFER, (long unsigned int)&buf);
  if(ok < 0){
    printf("Failed to allocate buffer 0!\n");
    return(0);
  }

  // Fill the buffer with vertical stripes
  long* data = (long*) mmap(NULL, buf.stride * buf.height * buf.depth,
                            PROT_WRITE, MAP_SHARED, cma, buf.mmap_offset);
  if(data == MAP_FAILED){
    printf("initial mmap failed!\n");
    return(0);
  }

  for(int i = 0; i < buf.height; i++){
    for(int j = 0; j < buf.width - 1; j += 2){
      data[i * buf.stride + j] = 0;
      data[i * buf.stride + j + 1] = 0x02020200; // RGB0
    }
  }
  munmap((void*)data, buf.stride * buf.height * buf.depth);

  data = (long*) mmap(NULL, buf.stride * buf.height * buf.depth,
                            PROT_READ, MAP_SHARED, cma, buf.mmap_offset);
  if(data == MAP_FAILED){
    printf("readback mmap failed!\n");
    return(0);
  }

  for(int i = 0; i < 10; i++){
    for(int j = 0; j < 10; j++){
      printf("%lx, ", data[i * buf.stride + j]);
    }
    printf("\n");
  }
  munmap((void*)data, buf.stride * buf.height * buf.depth);



  ok = ioctl(cma, FREE_IMAGE, (long unsigned int)&buf);

  close(cma);

  printf("Success.\n");
}

