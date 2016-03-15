/* grabprocess.cpp
 * Grab two images, and process them together.
 */

#include <stdio.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h> // strerror
#include <errno.h> // errno
#include "buffer.h"
#include "ioctl_cmds.h"

int main(int argc, char* argv[])
{
  // Open the buffer allocation device
  // It has to be opened to open the camera, since the camera
  // uses it to allocate the memory.
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

  // Open the camera device
  int xilcam = open("/dev/xilcam0", O_RDWR);
  if(xilcam == -1){
    printf("Failed to open camera hardware!\n");
    return(0);
  }

  printf("Waiting a second for images to roll in\n");
  usleep(250000);

  Buffer bufs[3];
  int ok = ioctl(xilcam, GRAB_IMAGE, (long unsigned int)(bufs + 0));
  if(ok < 0){
    printf("Failed to grab first image: %s\n", strerror(errno));
    return(0);
  }
  
  printf("Waiting to capture the second image\n");
  usleep(500000);

  ok = ioctl(xilcam, GRAB_IMAGE, (long unsigned int)(bufs + 1));
  if(ok < 0){
    printf("Failed to grab second image: %s\n", strerror(errno));
    return(0);
  }

  // Allocate the result buffer
  bufs[2].width = 256;
  bufs[2].height = 256;
  bufs[2].depth = 4;
  bufs[2].stride = 256;
  ok = ioctl(cma, GET_BUFFER, (long unsigned int)(bufs + 2));
  if(ok < 0){
    printf("Failed to allocate buffer 2!\n");
    return(0);
  }

  // Cut the captured images down to size
  bufs[0].width = bufs[1].width = 256;
  bufs[0].height = bufs[1].height = 256;
  bufs[0].depth = bufs[1].depth = 4; // Pretend that the data is 4 bytes
  // Leave stride alone

  // Run the processing operation
  int id = ioctl(hwacc, PROCESS_IMAGE, (long unsigned int)bufs);
  ioctl(hwacc, PEND_PROCESSED, id);

  // Save the image
  FILE* out = fopen("dump", "w");
  long* data = (long*) mmap(NULL, bufs[2].stride * bufs[2].height * bufs[2].depth,
                      PROT_READ, MAP_SHARED, cma, bufs[2].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap 2 failed!\n");
    return(0);
  }
  fwrite(data, sizeof(char), bufs[2].stride * bufs[2].height * bufs[2].depth, out);
  fclose(out);
  printf("Wrote file (%d x %d x %d)\n", bufs[2].stride, bufs[2].height, bufs[2].depth);

  munmap((void*)data, bufs[2].stride * bufs[2].height * bufs[2].depth);

  close(xilcam);
  close(hwacc);
  close(cma);
  return(0);
}

