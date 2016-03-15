/* buffer.h
 * Defines an interface for working with large image buffers.  The actual
 * implementation can be modified independent of the driver code.
 *
 * Steven Bell <sebell@stanford.edu>
 * 17 March 2014
 */

#ifndef _BUFFER_H_
#define _BUFFER_H_

// TODO: extract this buffer struct so the user code doesn't see the kernel methods
// TODO: should stride be in bytes, rather than pixels?  Probably doesn't matter much...
struct device;

typedef struct 
{
  unsigned int id; // ID flag for internal use
  unsigned int width; // Width of the image
  unsigned int stride; // Stride between rows, in pixels. This must be >= width
  unsigned int height; // Height of the image
  unsigned int depth; // Byte-depth of the image
  unsigned int phys_addr; // Bus address for DMA
  void* kern_addr; // Kernel virtual address
  struct mMap* cvals;
  unsigned int mmap_offset;
} Buffer;

/* Performs any global initialization of the buffer code, such as allocating
 * pools of memory and filling out buffer structs. */
int init_buffers(struct device* dev);
void cleanup_buffers(struct device* dev);
bool offset_in_range(unsigned long offset);
void* get_base_addr(void); // TODO remove this in favor of a better mmap solution?

/* Gets a buffer of the requested size.
 * Returns NULL if no buffers of the requested size are available.
 */
Buffer* acquire_buffer(unsigned int width, unsigned int height, unsigned int depth, unsigned int stride);

/* Returns a new buffer object which points to the same memory, but which has
 * a smaller shape.  The base pointers and width/height are adjusted to match.
 */
Buffer* slice_buffer(Buffer* orig, unsigned int x, unsigned int y, unsigned int width, unsigned int height);

void zero_buffer(Buffer* buf);

/* Releases the buffer back into the "free" pool to be acquired again. */
void release_buffer(Buffer* buf);

#endif

