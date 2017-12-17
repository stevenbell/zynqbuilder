/* testhw.cpp
 * Push fake data through a single-input kernel
 */
#include <stdio.h>
#include <stdlib.h> // malloc
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
  Buffer bufs[${len(streams)}] = {0};

% for s in streams:
  bufs[${loop.index}].width = ${s['width']};
  bufs[${loop.index}].height = ${s['height']};
  bufs[${loop.index}].depth = ${s['depth']};
  bufs[${loop.index}].stride = ${s['width']};

% endfor

  // Allocate CMA memory for the streams
  int ok;
% for s in streams:
  ok = ioctl(cma, GET_BUFFER, (long unsigned int)(bufs + ${loop.index}));
  if(ok < 0){
    printf("Failed to allocate buffer ${loop.index}!\n");
    return(0);
  }
%endfor

% if len(taps) is not 0:
  // Allocate regular memory for the taps
  unsigned char* taps = (unsigned char*) malloc(${tapoffsets[-1]});
  bzero(taps, ${tapoffsets[-1]});
% endif

  // Fill the input buffers with fake data
  int mapbytes;
  unsigned char* data;
% for s in streams:
% if s['type'] == 'input':
  // Fill buffer ${loop.index}: ${s['name']}
  mapbytes = bufs[${loop.index}].stride * bufs[${loop.index}].height * bufs[${loop.index}].depth;
  data = (unsigned char*) mmap(NULL, mapbytes,
                            PROT_WRITE, MAP_SHARED, cma, bufs[${loop.index}].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap \"${s['name']}\" (${loop.index}) failed!\n");
    return(0);
  }

  bzero(data, mapbytes);
  for(int i = 0; i < bufs[${loop.index}].height; i++){
    for(int j = 0; j < bufs[${loop.index}].width; j += 4){
      data[(i * bufs[${loop.index}].stride + j) * bufs[${loop.index}].depth + 0] = 0xa0;
% if s['depth'] == 3:
      data[(i * bufs[${loop.index}].stride + j) * bufs[${loop.index}].depth + 1] = 0;
      data[(i * bufs[${loop.index}].stride + j) * bufs[${loop.index}].depth + 2] = 0;
% endif
    }
  }
  munmap((void*)data, mapbytes);

% endif
% endfor


  // Set the tap values
// % Only if there actually are taps
/*
  long* taps = (long*)mmap(NULL, 0x1a4, PROT_WRITE, MAP_SHARED, hwacc, 0);
  taps[0x010>>2] = 0;
  taps[0x078>>2] = 30;
  taps[0x140>>2] = 100;
  munmap((void*)taps, 0x1a4);
*/

  // Run the processing operation
  int id = ioctl(hwacc, PROCESS_IMAGE, (long unsigned int)bufs);
  printf("Processing ID %d\n", id);
  ioctl(hwacc, PEND_PROCESSED, id);

  // Print out a little bit of the result buffer
% for s in streams:
% if s['type'] == 'output':
  mapbytes = bufs[${loop.index}].stride * bufs[${loop.index}].height * bufs[${loop.index}].depth;
 
  data = (unsigned char*) mmap(NULL, mapbytes,
                      PROT_READ, MAP_SHARED, cma, bufs[${loop.index}].mmap_offset);
  if(data == MAP_FAILED){
    printf("mmap output \"${s['name']}\" (${loop.index}) failed!\n");
    return(0);
  }

  for(int i = 0; i < 10; i++){
    for(int j = 0; j < 20; j++){
      printf("%x, ", data[i * bufs[${loop.index}].stride * bufs[${loop.index}].depth + j]);
    }
    printf("\n");
  }
  munmap((void*)data, mapbytes);
% endif
% endfor

  ok = ioctl(cma, FREE_IMAGE, (long unsigned int)bufs);
  ok = ioctl(cma, FREE_IMAGE, (long unsigned int)(bufs + 1));

  close(hwacc);
  close(cma);
  return(0);
}

