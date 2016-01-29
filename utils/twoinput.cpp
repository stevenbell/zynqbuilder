#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include "buffer.h"
#include "ioctl_cmds.h"

int main(int argc, char* argv[])
{
  // Open the hardware device
  int hwacc = open("/dev/hwacc0", O_RDWR);
  if(hwacc == -1){
    printf("Failed to open hardware device!\n");
    return(0);
  }

  // Allocate input and output buffers
  Buffer bufs[3];
  bufs[0].width = bufs[1].width = 256;
  bufs[0].height = bufs[1].height = 256;
  bufs[0].depth = bufs[1].depth = 4; // Data is [RGB0x00]
  bufs[0].stride = bufs[1].stride = 256;

  bufs[2].width = 256;
  bufs[2].height = 256;
  bufs[2].depth = 4;
  bufs[2].stride = 256;

  int ok = ioctl(hwacc, GET_BUFFER, (long unsigned int)bufs);
  if(ok < 0){
    printf("Failed to allocate buffer 0!\n");
    return(0);
  }

  ok = ioctl(hwacc, GET_BUFFER, (long unsigned int)(bufs + 1));
  if(ok < 0){
    printf("Failed to allocate buffer 1!\n");
    return(0);
  }

  ok = ioctl(hwacc, GET_BUFFER, (long unsigned int)(bufs + 2));
  if(ok < 0){
    printf("Failed to allocate buffer 2!\n");
    return(0);
  }


  // Fill the first buffer with vertical stripes
  long* data = (long*) mmap(NULL, bufs[0].stride * bufs[0].height * bufs[0].depth,
                            PROT_WRITE, MAP_SHARED, hwacc, bufs[0].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap 0 failed!\n");
    return(0);
  }

  for(int i = 0; i < bufs[0].height; i++){
    for(int j = 0; j < bufs[0].width - 1; j += 2){
      data[i * bufs[0].stride + j] = 0;
      data[i * bufs[0].stride + j + 1] = 0x02020200; // RGB0
    }
  }
  munmap((void*)data, bufs[0].stride * bufs[0].height * bufs[0].depth);

  // Fill the second buffer with horizonal stripes
  data = (long*) mmap(NULL, bufs[1].stride * bufs[1].height * bufs[1].depth,
                      PROT_WRITE, MAP_SHARED, hwacc, bufs[1].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap 1 failed!\n");
    return(0);
  }

  for(int i = 0; i < bufs[1].height - 1; i += 2){
    for(int j = 0; j < bufs[1].width; j++){
      data[i * bufs[1].stride + j] = 0;
      data[(i + 1) * bufs[1].stride + j] = 0x04040400;
    }
  }
  munmap((void*)data, bufs[1].stride * bufs[1].height * bufs[1].depth);

  // Run the processing operation
  ioctl(hwacc, PROCESS_IMAGE, (long unsigned int)bufs);

  ioctl(hwacc, PEND_PROCESSED, NULL);

  // Print out the result buffer
  data = (long*) mmap(NULL, bufs[2].stride * bufs[2].height * bufs[2].depth,
                      PROT_READ, MAP_SHARED, hwacc, bufs[2].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap 2 failed!\n");
    return(0);
  }

  for(int i = 0; i < 10; i++){
    for(int j = 0; j < 10; j++){
      printf("%lx, ", data[i * bufs[2].stride + j]);
    }
    printf("\n");
  }
  munmap((void*)data, bufs[2].stride * bufs[2].height * bufs[2].depth);

  return(0);
}

