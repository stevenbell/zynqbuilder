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

  // Open the camera device
  int xilcam = open("/dev/xilcam0", O_RDWR);
  if(xilcam == -1){
    printf("Failed to open camera hardware!\n");
    return(0);
  }

  printf("Waiting a second for images to roll in\n");
  usleep(250000);

  Buffer buf;
  int ok = ioctl(xilcam, GRAB_IMAGE, (long unsigned int)&buf);
  if(ok < 0){
    printf("Failed to grab image: %s\n", strerror(errno));
    return(0);
  }
  
  printf("Received buffer %d  %lx\n", buf.id, (unsigned long)buf.kern_addr);

  // Save the image
  long* data = (long*) mmap(NULL, buf.stride * buf.height * buf.depth,
                      PROT_READ, MAP_SHARED, cma, buf.mmap_offset);
  FILE* out = fopen("dump", "w");
  fwrite(data, sizeof(char), buf.stride * buf.height * buf.depth, out);
  fclose(out);
  printf("Wrote file (%d x %d x %d)\n", buf.stride, buf.height, buf.depth);

  munmap((void*)data, buf.stride * buf.height * buf.depth);

  close(xilcam);
  close(cma);
  return(0);
}

