/* buffer.c
 * Implementation of buffer management for DMA/VMDA combined driver.
 * This implementation can be swapped out for a different one which makes
 * better use of memory, uses a different allocation scheme, etc.
 *
 * Steven Bell <sebell@stanford.edu>
 * 17 March 2014
 */

#include <linux/device.h>
#include <linux/dma-mapping.h>
#include <linux/string.h>

#include "common.h"
#include "buffer.h"

extern const int debug_level; // This is defined in the including driver

// For now, the implementation assumes a fixed number of large buffers.
// Asking for smaller images just returns a whole large buffer, and asking
// for a larger image fails.  A better solution would be to use a buddy
// allocator and give out pieces that are only as large as necessary.
#define N_BUFFERS 8
#define BUFFER_SIZE (2048*1080*4) // This number must be a multiple of 4k pages so mmap works

unsigned char free_flag[N_BUFFERS];
Buffer buffers[N_BUFFERS];
unsigned long base_phys_addr; // Physical base address of buffer
void* base_kern_addr = NULL; // Kernel virtual base address of buffer

int init_buffers(struct device* dev)
{
  int i;
  //dma_set_mask (dev, 0xffffffff); // Anything in a 32-bit space is fair game
  dma_set_coherent_mask (dev, 0xffffffff); // Anything in a 32-bit space is fair game

  // Allocate a huge chunk of memory
  // For now, let's try and do this with the new-ish Linux Contiguous Memory
  // Allocator (CMA).
  // Boot-time parameter should be set in the devicetree: cma=100MB
  printk("Allocating %d for CMA.\n", N_BUFFERS*BUFFER_SIZE);
  base_kern_addr = dma_alloc_coherent(dev, N_BUFFERS*BUFFER_SIZE,
                         (dma_addr_t*)&base_phys_addr, GFP_KERNEL);
  // TODO: make sure this is page-aligned so mmap works later
  if(base_kern_addr == NULL){
    printk("Failed to allocate memory! Check CMA size.\n");
    return(-1);
  }

  printk("memory allocated at %lx / %lx\n", (unsigned long)base_kern_addr, base_phys_addr);

  // Create some buffers to fill with data as the camera streams.
  for(i = 0; i < N_BUFFERS; i++){
    buffers[i].id = i;
    buffers[i].phys_addr = base_phys_addr + (i * BUFFER_SIZE);
    buffers[i].kern_addr = base_kern_addr + (i * BUFFER_SIZE);
    buffers[i].mmap_offset = i * BUFFER_SIZE;
    //buffers[i].cvals = kmalloc(sizeof(struct mMap), GFP_KERNEL);
    free_flag[i] = 1;
printk("Buffer %d  phys: %lx  kern: %lx\n", i, (unsigned long)buffers[i].phys_addr, (unsigned long)buffers[i].kern_addr);
  }

  return(0); // Success
}

/* "Destructor" which frees memory */
void cleanup_buffers(struct device* dev)
{
  dma_free_coherent(dev, N_BUFFERS*BUFFER_SIZE, base_kern_addr, base_phys_addr);
  printk("Freed CMA memory\n");
  base_kern_addr = NULL;

/*
  int i;
  for(i = 0; i < N_BUFFERS; i++){
    kfree(buffers[i].cvals);
  }
*/
}

void* get_base_addr(void)
{
  return(base_kern_addr);
}

/* depth is in bytes
 * stride is in pixels (i.e., multiply by depth to get stride in bytes)
 */
// TODO: mutex access to the free flag
Buffer* acquire_buffer(unsigned int width, unsigned int height, unsigned int depth, unsigned int stride)
{
  int i = 0;

  if(base_kern_addr == NULL){
    WARNING("Device not yet opened; can't acquire buffer\n");
    return NULL;
  }

  if(width > stride){
    ERROR("acquire_buffer failed: width (%d) must be <= to stride (%d)\n", width, stride);
    return NULL;
  }
  if((stride * height * depth) > BUFFER_SIZE){
    ERROR("acquire_buffer failed: requested bytes (%d) exceeds maximum (%d)\n", (stride*height*depth), BUFFER_SIZE);
    return NULL;
  }

  // Scan through the list and grab the first free one
  while(i < N_BUFFERS && free_flag[i] == 0){
    //printk("acquire_bufffer: %d is already taken, counting to %d\n", i, N_BUFFERS);
    i++;
  }
  if(i < N_BUFFERS){
    free_flag[i] = 0; // Mark as used

    // Set the dimensions and return it to the user
    buffers[i].width = width;
    buffers[i].height = height;
    buffers[i].depth = depth;
    buffers[i].stride = stride;

    /*
printk("clearing buffer %d at %lx\n", i, buffers[i].kern_addr);
  data = (unsigned long*) buffers[i].kern_addr;
  for(j = 0; j < width*height*depth / sizeof(unsigned long); j++){
    data[j] = 0xee;
  }
*/
    DEBUG("acquire_buffer: Returning buffer %d\n", i);
    return(buffers + i);
  }
  else{
    // We ran off the end without finding a free buffer
    ERROR("acquire_buffer failed: no free buffers\n");
    return(NULL);
  }
}

void zero_buffer(Buffer* buf)
{
  memset(buf, 0, sizeof(Buffer));
}

void release_buffer(Buffer* buf)
{
  // TODO: error/bounds checking
  free_flag[buf->id] = 1; // Mark as free
  // Trust the user to quit using the pointer
  DEBUG("release_buffer: free buffer %d\n", buf->id);
}

EXPORT_SYMBOL(acquire_buffer);
EXPORT_SYMBOL(release_buffer);

