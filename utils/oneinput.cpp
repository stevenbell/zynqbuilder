/* oneinput.cpp
 * Push fake data through a single-input kernel
 */
#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <strings.h> // bzero
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

  // Open the hardware device
  int hwacc = open("/dev/hwacc0", O_RDWR);
  if(hwacc == -1){
    printf("Failed to open hardware device!\n");
    return(0);
  }

  // Allocate input and output buffers
  Buffer bufs[2];
  bufs[0].width = 264;
  bufs[0].height = 264;
  bufs[0].depth = 3; // Assume data is [RGB]
  bufs[0].stride = 264;

  bufs[1].width = 256;
  bufs[1].height = 256;
  bufs[1].depth = 3;
  bufs[1].stride = 256;

  int ok = ioctl(cma, GET_BUFFER, (long unsigned int)bufs);
  if(ok < 0){
    printf("Failed to allocate buffer 0!\n");
    return(0);
  }

  ok = ioctl(cma, GET_BUFFER, (long unsigned int)(bufs + 1));
  if(ok < 0){
    printf("Failed to allocate buffer 1!\n");
    return(0);
  }

  // Fill the buffer with vertical stripes
  unsigned char* data = (unsigned char*) mmap(NULL,
                            bufs[0].stride * bufs[0].height * bufs[0].depth,
                            PROT_WRITE, MAP_SHARED, cma, bufs[0].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap 0 failed!\n");
    return(0);
  }

  bzero(data, bufs[0].stride * bufs[0].height * bufs[0].depth);
  for(int i = 0; i < bufs[0].height; i++){
    for(int j = 0; j < bufs[0].width; j += 4){
      data[(i * bufs[0].stride + j) * bufs[0].depth + 0] = 0xa0;
      data[(i * bufs[0].stride + j) * bufs[0].depth + 1] = 0;
      data[(i * bufs[0].stride + j) * bufs[0].depth + 2] = 0;
    }
  }
  munmap((void*)data, bufs[0].stride * bufs[0].height * bufs[0].depth);

  // Set the tap values
  long* taps = (long*)mmap(NULL, 0x1a4, PROT_WRITE, MAP_SHARED, hwacc, 0);
  taps[0x010>>2] = 0;
  taps[0x078>>2] = 30;
  taps[0x140>>2] = 100;
  munmap((void*)taps, 0x1a4);

  // Run the processing operation
  int id = ioctl(hwacc, PROCESS_IMAGE, (long unsigned int)bufs);
  printf("Processing ID %d\n", id);
  ioctl(hwacc, PEND_PROCESSED, id);

  // Print out the result buffer
  data = (unsigned char*) mmap(NULL, bufs[1].stride * bufs[1].height * bufs[1].depth,
                      PROT_READ, MAP_SHARED, cma, bufs[1].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap output failed!\n");
    return(0);
  }

  for(int i = 0; i < 10; i++){
    for(int j = 0; j < 20; j++){
      printf("%x, ", data[i * bufs[1].stride * bufs[1].depth + j]);
    }
    printf("\n");
  }
  munmap((void*)data, bufs[1].stride * bufs[1].height * bufs[1].depth);

  ok = ioctl(cma, FREE_IMAGE, (long unsigned int)bufs);
  ok = ioctl(cma, FREE_IMAGE, (long unsigned int)(bufs + 1));

  close(hwacc);
  close(cma);
  return(0);
}

