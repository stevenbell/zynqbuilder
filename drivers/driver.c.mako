/* Generated automatically by ${toolName} on ${date}
 * Combined VDMA/DMA driver to run the camera and an image pipeline
 *
 * Like other drivers, the interface is a character driver with a single file.
 * However, all operations are handled via ioctl() and mmap(), rather than with
 * read() and write().  This is so that we can pass the data around and access
 * it without having to do any copying.  The other zero-copy method is scatter-
 * gather to userspace, but then we have to worry about the SG table and cache
 * flush/invalidate.
 *
 *
 * Steven Bell <sebell@stanford.edu>
 * 28 February 2014
 */

#include <linux/module.h>
#include <linux/cdev.h> // Character device
#include <linux/slab.h> // kmalloc
#include <asm/io.h> // ioremap and friends
#include <asm/uaccess.h> // Copy to/from userspace pointers
#include <asm/cacheflush.h> // flush L1 cache
#include <asm/outercache.h> // flush L2 cache
#include <linux/sched.h> // current task struct
#include <linux/fs.h> // File node numbers
#include <linux/device.h>
#include <linux/interrupt.h>
#include <linux/dma-mapping.h>
#include <linux/mm.h>
#include <linux/pagemap.h>
#include <linux/of_platform.h>

#include "common.h"
#include "buffer.h"
#include "dma_bufferset.h"
#include "ioctl_cmds.h"

// The Linux kernel keeps track of whether it has been "tainted" with non-GPL
// kernel modules.  GPL may not be the right thing to put here.
MODULE_LICENSE("GPL");

#define CLASSNAME "hwacc" // Shows up in /sys/class
#define DEVNAME "hwacc0" // Shows up in /dev

// Memory mappings for the peripherals
% for s in streams:
#define ${s['name'].upper()}_DMA_CONTROLLER_BASE ${s['dma_addr']}
#define ${s['name'].upper()}_DMA_CONTROLLER_SIZE 0x30
% endfor

#define ACC_CONTROLLER_BASE ${baseaddr}
#define ACC_CONTROLLER_SIZE ${regwidth}
#define ACC_CONTROLLER_PAGES ${(regwidth / 1024) + 1}

// Hardware address pointers from ioremap
// We do byte-wise pointer arithmetic on these, so use uchar
% for s in streams:
unsigned char* ${s['name']}_dma_controller;
% endfor
unsigned char* acc_controller;

dev_t device_num;
struct cdev *chardev;
struct device *pipe_dev;
struct class *pipe_class;

#define N_DMA_BUFFERSETS 16 // Number of "buffer set" objects for passing through the queues
BufferSet buffer_pool[N_DMA_BUFFERSETS];

#define SG_DESC_SIZE 16 // Size of each SG descriptor, in 32-byte words
#define SG_DESC_BYTES (SG_DESC_SIZE * 4)  // Size of each descriptor in bytes

// Each scanline is a separate scatter-gather block so that we can handle striding.
// For example, the VDMA engine writes data in with a 2048-pixel stride, where
// the last 128 pixels are empty; this lets us grab the valid parts and stream
// them all together.

// For input, we have one SG block per image row, which gives 1080 * (16*4),
// a little over 64kb. The output might be stripped, so we should do the same.
// So page order has to be over 64kb/4kb = 16, -> page order 5.
#define SG_PAGEORDER 5

// A BufferSet is attached to one of the following lists, which determines its state.
// All of the lists maintain order (i.e, FIFO).
// FREE - Input buffer is ready to be filled with data
BufferList free_list;
// QUEUED - Has data (flushed to RAM) and is ready to be streamed
BufferList queued_list;
// PROCESSING - Input DMA has started, and output DMA has not yet finished.
// This implies that some part of the buffer's contents are in the stencil path.
// If more than one buffer is in this state, something is probably very wrong.
BufferList processing_list;
// COMPLETE - DMA has finished, and output data is ready to be handed back to the user
BufferList complete_list;

// Wait queues to pend on the various DMA operations. Things waiting on these
// are woken up when the interrupt fires.
% for s in streams:
DECLARE_WAIT_QUEUE_HEAD(wq_${s['name']});
%endfor
DECLARE_WAIT_QUEUE_HEAD(processing_finished);
DECLARE_WAIT_QUEUE_HEAD(buffer_free_queue); // Writes waiting for a free buffer
% for s in streams:
% if s['type'] == 'output':
atomic_t ${s['name']}_finished_count;
% endif
% endfor

// Workqueues which are used to asynchronously configure the DMA engine after
// a buffer has been filled and to move a buffer after DMA finishes.
struct workqueue_struct* dma_launch_queue;
struct workqueue_struct* dma_finished_queue;

// Forward declarations of the work functions
void dma_launch_work(struct work_struct*);
void dma_finished_work(struct work_struct*);

// Corresponding structures that get put in the queues above.  We only need one
// instance, since we're simply launching work, not queuing up a bunch of tasks.
DECLARE_WORK(dma_launch_struct, dma_launch_work);
DECLARE_WORK(dma_finished_struct, dma_finished_work);

const int debug_level = 3; // 0 is errors only, increasing numbers print more stuff

// If the DMAs are configured in the multichannel mode,
// use this flag to enable 2D transfer mode
const bool use_2D_mode = true;

// If the device use the accelerator coherency port (ACP) of PS,
// use this flag to enforce cache coherency and to avoid cache flushing
const bool use_acp = true;

/**
 * Probes the DMA engine to confirm that it exists at the assigned memory
 * location and that scatter-gather DMA is built-in.  The only reason
 * this would fail is if the image in the FPGA doesn't match the software
 * build.
 * Return: 0 on success, -1 on failure
 */
int check_dma_engine(unsigned char* dma_controller)
{
  unsigned long status;

  status = ioread32((void*)dma_controller + 0x04);
  // The SG bit should be set - see page 29 of the DMA datasheet (PG021)
  if((status & 0x00000008) == 0){
    ERROR("ERROR: Scatter-gather DMA not built in!\n");
    return(-1);
  }
  if((status & 0x00000770) != 0){
    // Some error occurred; try to reset the engine (bit 3 of DMACR)
    iowrite32(0x00000004, (void*)dma_controller + 0x00);
    // Spin and wait until the reset finishes
    while(ioread32((void*)dma_controller + 0x00) & 0x00000004) {}
  }

  // setup SG_CTL register
  // SG_CACHE: 1111 defines memory type as 'write-back read and write-allocate'
  // SG_USER: tie off high to enable coherency when allowed by SG_CACHE
  //
  // Note that S2MM and MM2S share the same SG_CTL, so the write w.r.t the
  // output DMA is unnecessary, but the out-of-range write looks fine
  iowrite32(0x00000f0f, (void*)dma_controller + 0x2c);
  return(0);
}

static int dev_open(struct inode *inode, struct file *file)
{
  int i;

  // Set up the image buffer set
  buffer_initlist(&free_list);
  buffer_initlist(&queued_list);
  buffer_initlist(&processing_list);
  buffer_initlist(&complete_list);

  // Allocate memory for the scatter-gather tables in the buffer set and put
  // them on the free list.  The actual data will be attached when needed.
  for(i = 0; i < N_DMA_BUFFERSETS; i++){
    buffer_pool[i].id = i;
% for s in streams:
    buffer_pool[i].${s['name']}_sg = (unsigned long*) __get_free_pages(GFP_KERNEL, SG_PAGEORDER);
    if(buffer_pool[i].${s['name']}_sg == NULL){
      ERROR("Failed to allocate memory for SG table ${s['name']}_sg %d\n", i);
    }
% endfor

    DEBUG("enqueing buffer set %d\n", i);
    buffer_enqueue(&free_list, buffer_pool + i);
  }
% for s in streams:
% if s['type'] == 'output':
  atomic_set(&${s['name']}_finished_count, 0); // No buffers finished yet
% endif
% endfor
  return(0);
}

static int dev_close(struct inode *inode, struct file *file)
{
  int i;

  // TODO: Wait until the DMA engine is done, so we don't write to memory after freeing it

  for(i = 0; i < N_DMA_BUFFERSETS; i++){
% for s in streams:
    free_pages((unsigned long)buffer_pool[i].${s['name']}_sg, SG_PAGEORDER);
% endfor
  }

  return(0);
}

/* Builds a scatter-gather descriptor chain for a buffer.
 * SG is particularly useful for automatically handling strided images, such as
 * blocks of a larger image.
 * Each image row is a new sg slice, and starts on a new memory location,
 * which may not be adjacent to the last one.
 */
void build_sg_chain(const Buffer buf, unsigned long* sg_ptr_base, unsigned long* sg_phys)
{
  int sg; // Descriptor count
  unsigned long* sg_ptr = sg_ptr_base; // Pointer which will be incremented along the chain
  TRACE("build_sg_chain: sg_ptr 0x%lx, sg_phys 0x%lx\n", (unsigned long)sg_ptr, (unsigned long)sg_phys);

  for(sg = 0; sg < buf.height; sg++){
    sg_ptr[0] = virt_to_phys(sg_ptr + SG_DESC_SIZE); // Pointer to next descriptor
    sg_ptr[1] = 0; // Upper 32 bits of descriptor pointer (unused)
    sg_ptr[2] = buf.phys_addr + (sg * buf.stride * buf.depth); // Address where the data lives
    sg_ptr[3] = 0; // Upper 32 bits of data address (unused)
    // Next 2 words are reserved
    sg_ptr[6] = (buf.width * buf.depth); // Width of data is width*depth of image
    if(sg == 0){
      sg_ptr[6] |= 0x08000000; // Start of frame flag
    }
    if(sg == buf.height-1){
      sg_ptr[6] |= 0x04000000; // End of frame flag
    }
    sg_ptr[7] = 0; // Clear the status; the DMA engine will set this

    sg_ptr += SG_DESC_SIZE; // Move to next descriptor
  }
  TRACE("build_sg_chain: built SG table\n");

  // This is always mapped DMA_TO_DEVICE, since the DMA engine is reading the SG table
  // regardless of the data direction.
  *sg_phys = virt_to_phys(sg_ptr_base);
  //*sg_phys = dma_map_single(pipe_dev, sg_ptr_base, SG_DESC_BYTES * buf.height, DMA_TO_DEVICE);
}

// Use 2-D transfer feature in Xilinx AXI DMA.
// To enable this feature, DMA IP needs to be configured with Multichannel mode enabled.
// With this feature, a transfer of a sub-block of 2-D data requires only one descriptor.
void build_sg_chain_2D(const Buffer buf, unsigned long* sg_ptr_base, unsigned long* sg_phys)
{
  unsigned long* sg_ptr = sg_ptr_base; // Pointer which will be incremented along the chain
  TRACE("build_sg_chain_2D: sg_ptr 0x%lx, sg_phys 0x%lx\n", (unsigned long)sg_ptr, (unsigned long)sg_phys);

  // the sg chain only has one descriptor
  sg_ptr[0] = virt_to_phys(sg_ptr + SG_DESC_SIZE); // Pointer to next descriptor
  sg_ptr[1] = 0; // Upper 32 bits of descriptor pointer (unused)
  sg_ptr[2] = buf.phys_addr; // Address where the data lives
  sg_ptr[3] = 0; // Upper 32 bits of data address (unused)

  // 0x10: AxUSER|AxCACHE|Rsvd|TUSER|Rsvd|TID|Rsvd|TDEST
  if (use_acp) {
    // AxCACHE: 0011 defines memory type as 'normal non-cacheable bufferable'
    // AxCACHE: 1111 defines memory type as 'write-back read and write-allocate'
    // AxUSER: tie off high to enable coherency when allowed by AxCACHE
    sg_ptr[4] = 0xff000000; // values for AxCACHE (1111) and AxUSER (1111)
  } else {
    // for some reason, AxCACHE (1111) with dma_map/unmap doesn't
    // work correctly on Linux 4.0 kernel, so we use 0011 for AxCACHE field
    sg_ptr[4] = 0x03000000; // values for AxCACHE (0011) and AxUSER (0000)
  }

  // 0x14: VSIZE|Rsvd|Stride
  sg_ptr[5] = buf.stride * buf.depth;  // Stride of the 2D block
  sg_ptr[5] |= (buf.height << 19);     // VSize, i.e. the height of the block

  // 0x18: SOP|EOP|Rsvd|HSIZE
  sg_ptr[6] = (buf.width * buf.depth); // Width of data is width*depth of image
  sg_ptr[6] |= 0x08000000; // Start of frame flag
  sg_ptr[6] |= 0x04000000; // End of frame flag

  sg_ptr[7] = 0; // Clear the status; the DMA engine will set this


  // This is always mapped DMA_TO_DEVICE, since the DMA engine is reading the SG table
  // regardless of the data direction.
  *sg_phys = virt_to_phys(sg_ptr_base);
  //TRACE("build_sg_chain_2D: call dma_map_single()\n");
  //*sg_phys = dma_map_single(pipe_dev, sg_ptr_base, SG_DESC_BYTES * 1, DMA_TO_DEVICE);
}

/* Sets up a buffer for processing through the stencil path.  This drops the
 * image buffers into a BufferSet object, builds the scatter-gather tables,
 * and flushes the cache. Then it drops the BufferSet into the
 * queue to be pushed to the stencil path DMA engine as soon as it's free.
 */
int process_image(${", ".join(["Buffer* " + s['name'] + "_b" for s in streams])})
{
  BufferSet* src;

% for s in streams:
% if s['type'] == 'input':
  if(${s['name']}_b->width != ${s['width']} ||
     ${s['name']}_b->height != ${s['height']} ||
     ${s['name']}_b->depth != ${s['depth']}){
    ERROR("Buffer size for ${s['name']} doesn't match hardware!");
  }
% endif
% endfor

  TRACE("process_image: begin\n");
  // Acquire a bufferset to pass through the processing chain
  wait_event_interruptible(buffer_free_queue, !buffer_listempty(&free_list));
  src = buffer_dequeue(&free_list);

  TRACE("process_image: got BufferSet\n");
% for s in streams:
  src->${s['name']} = *${s['name']}_b;
% endfor

  // Set up the scatter-gather descriptor chains
% for s in streams:
  if (use_2D_mode)
    build_sg_chain_2D(src->${s['name']}, src->${s['name']}_sg, &src->${s['name']}_sg_phys);
  else
    build_sg_chain(src->${s['name']}, src->${s['name']}_sg, &src->${s['name']}_sg_phys);
% endfor

  // Map the buffers for DMA
  // This causes cache flushes for the source buffer(s)
  // The invalidate for the result happens on the unmap
  if (!use_acp) {
% for s in streams:
% if s['type'] == 'input':
    dma_map_single(pipe_dev, src->${s['name']}.kern_addr,
                   src->${s['name']}.height * src->${s['name']}.stride * src->${s['name']}.depth, DMA_TO_DEVICE);
% else:
    dma_map_single(pipe_dev, src->${s['name']}.kern_addr,
                   src->${s['name']}.height * src->${s['name']}.stride * src->${s['name']}.depth, DMA_FROM_DEVICE);
% endif
% endfor

    //flush_cache_all(); // flush l1 cache
    //outer_flush_all(); // flush l2 cache, kernel dump "bus error"
    TRACE("process_image: dma_map_single() finished.\n");
  }

  // Now throw this whole thing into the queue.
  // When the DMA engine is free, it will get pulled off and run.
  buffer_enqueue(&queued_list, src);

  // Launch a work queue task to write this to the DMA
  queue_work(dma_launch_queue, &dma_launch_struct);

  TRACE("process_image: return\n");
  return(src->id);
}


void dma_launch_work(struct work_struct* ws)
{
  BufferSet* buf;
  TRACE("dma_launch_work: begin\n");
  while(!buffer_listempty(&queued_list)){
    buf = buffer_dequeue(&queued_list);

    // Sleep until all the DMA engines are idle or halted (bits 0 and 1)
    // Write should always be idle first, but do all of them to be safe
% for s in streams:
    wait_event_interruptible(wq_${s['name']}, (ioread32(${s['name']}_dma_controller + 0x04) & 0x00000003) != 0);
% endfor

    // TODO: set taps, LUTs, etc

    // Kick off the DMA write operations
    TRACE("dma_launch_work: writing DMA registers\n");

% for s in streams:
    DEBUG("dma_launch_work: sg_phys 0x%lx\n", (unsigned long)buf->${s['name']}_sg_phys);
    iowrite32(0x00010002, ${s['name']}_dma_controller + 0x00); // Stop, so we can set the head ptr
    iowrite32(buf->${s['name']}_sg_phys, ${s['name']}_dma_controller + 0x08); // Pointer to the first descriptor
    iowrite32(0x00011003, ${s['name']}_dma_controller + 0x00); // Run and enable interrupts
    if (use_2D_mode)
      iowrite32(buf->${s['name']}_sg_phys, ${s['name']}_dma_controller + 0x10); // 2D mode: Last descriptor, starts transfer
    else
      iowrite32(buf->${s['name']}_sg_phys + (buf->${s['name']}.height - 1) * SG_DESC_BYTES, ${s['name']}_dma_controller + 0x10); // Last descriptor, starts transfer

% endfor
    // Start the stencil engine running
    // control register [7: auto_restart, --- 3: ap_ready, 2: ap_idle, 1: ap_done, 0: ap_start]
    iowrite32(0x00000001, acc_controller + ${registers['control']});
    TRACE("dma_launch_work: Transfers started\n");

    // Move the buffer to the processing list
    buffer_enqueue(&processing_list, buf);
  } // END while(buffers in QUEUED list)
}

void dma_finished_work(struct work_struct* ws)
{
  BufferSet* buf;
  TRACE("dma_finished_work: begin\n");

  // Check that all of the output DMAs have completed their work
  // TODO: bugs may lurk here if there are multiple outputs and the primary
  // finishes first.
  while(${" && ".join(["atomic_read(&" + s['name'] + "_finished_count) > 0" for s in streams if s['type'] == 'output'])}) {

    // Decrement the completion count
    // This is the only part of the driver that will decrement these counts,
    // so we can be sure that if they're all >0, we have a frame.
% for s in streams:
% if s['type'] == 'output':
    atomic_dec(&${s['type']}_finished_count);
% endif
% endfor

    buf = buffer_dequeue(&processing_list);
    DEBUG("dma_finished_work: buf: %lx\n", (unsigned long)buf);

    // Unmap each of the SG buffers
% for s in streams:
    //dma_unmap_single(pipe_dev, buf->${s['name']}_sg_phys, SG_DESC_BYTES * buf->${s['name']}.height, DMA_TO_DEVICE);
% endfor

    // Unmap all the input and output buffers (with appropriate direction)
    // For the source buffers, this should do nothing.  For the result buffers,
    // it should cause a cache invalidate.
    if (!use_acp) {
% for s in streams:
% if s['type'] == 'input':
      //dma_unmap_single(pipe_dev, buf->${s['name']}.phys_addr,
      //buf->${s['name']}.height * buf->${s['name']}.stride * buf->${s['name']}.depth, DMA_TO_DEVICE);
% else:
      //dma_unmap_single(pipe_dev, buf->${s['name']}.phys_addr,
      //buf->${s['name']}.height * buf->${s['name']}.stride * buf->${s['name']}.depth, DMA_FROM_DEVICE);
% endif
% endfor
    TRACE("dma_finished_work: dma_unmap_single() finished.\n");
    }

    buffer_enqueue(&complete_list, buf);
  }

  // Both the DMA launcher (which starts new DMA transactions) and the read()
  // operation (which waits for new data) want to know this is finished.
  TRACE("dma_finished_work: DMA read finished\n");
  wake_up_interruptible_all(&processing_finished);
}

// Interrupt handlers for the input DMA engine(s)
% for s in streams:
% if s['type'] == 'input':
irqreturn_t dma_${s['name']}_finished_handler(int irq, void* dev_id)
{
  iowrite32(0x00007000, ${s['name']}_dma_controller + 0x04); // Acknowledge/clear interrupt
  wake_up_interruptible(&wq_${s['name']});
  DEBUG("irq: DMA ${s['name']} finished.\n");
  return(IRQ_HANDLED);
}
% endif
% endfor

// The first output DMA engine is responsible for launching the "finished"
// work task.  It's ok if the transaction isn't complete yet, because the
// task will wait for all of the engines to complete a frame and increment
// the semaphore.
% for s in [s for s in streams if s['type'] == 'output']:
irqreturn_t dma_${s['name']}_finished_handler(int irq, void* dev_id)
{
  iowrite32(0x00007000, ${s['name']}_dma_controller + 0x04); // Acknowledge/clear interrupt
  wake_up_interruptible(&wq_${s['name']}); // The next processing action can now start
  TRACE("irq: DMA ${s['name']} finished.\n");

  // Keep an explicit count of the number of buffers, to cover the rare
  // (hopefully impossible) case where a second buffer finished before the work
  // queue task actually executes.  This would cause dma_finished_work to only
  // execute once, when it was queued twice.
  atomic_inc(&${s['name']}_finished_count);

% if loop.index is 0:
  // Delegate the work of moving the buffer from "PROCESSING" to "FINISHED".
  // We can't do it here, since we're in an atomic context and trying to lock
  // access to the list could cause us to block.
  DEBUG("irq: Launching workqueue to complete processing\n");
  // Launch a work queue task to write this to the DMA
  queue_work(dma_finished_queue, &dma_finished_struct);
% endif

  return(IRQ_HANDLED);
}
% endfor


/* Blocks until a result is complete, and removes the buffer set from the queue.
 * This should be called once for each process_image call.
 */
void pend_processed(int id)
{
  BufferSet* resultSet;

  TRACE("pend_processed: begin for bufferset %d\n", id);

  // Block until a completed buffer becomes available
  wait_event_interruptible(processing_finished, buffer_hasid(&complete_list, id));

  // Remove the buffer
  resultSet = buffer_dequeueid(&complete_list, id);
  if(resultSet == NULL){
    ERROR("buffer_dequeue for id %d failed!\n", id);
    return;
  }

  // Put the buffer set back on the free list
  buffer_enqueue(&free_list, resultSet);
  wake_up_interruptible(&buffer_free_queue);

  TRACE("pend_processed: return for bufferset %d\n", id);
}

long dev_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
  Buffer ${", ".join(["tmp_" + s['name'] for s in streams])};

  DEBUG("ioctl cmd %d | %lu (%lx) \n", cmd, arg, arg);
  switch(cmd){
    case PROCESS_IMAGE:
      TRACE("ioctl: PROCESS_IMAGE\n");
      if(access_ok(VERIFY_READ, (void*)arg, ${len(streams)}*sizeof(Buffer)) &&
         ${" &&\n         ".join(["copy_from_user(&tmp_" + s['name'] + ", (void*)(arg + sizeof(Buffer)*" + str(i) + "), sizeof(Buffer)) == 0" for (i, s) in enumerate(streams)])}){
        return process_image(${", ".join(["&tmp_" + s['name'] for s in streams])});
      }
      else{
        return(-EIO); // can't read or copy; more informative error here?
      }
      break;
    case PEND_PROCESSED:
      TRACE("ioctl: PEND_PROCESSED\n");
      pend_processed(arg);
      break;
    default:
      return(-EINVAL); // Unknown command, return an error
      break;
  }
  return(0); // Success
}

int dev_mmap(struct file *filp, struct vm_area_struct *vma)
{
  unsigned long physical_pfn, vsize;
  physical_pfn = (ACC_CONTROLLER_BASE >> PAGE_SHIFT) + vma->vm_pgoff; // Physical page
  vsize = vma->vm_end - vma->vm_start; // Requested virtual size (in bytes)

  // Check that the user isn't asking to map too much (or too high)
  if(vsize > ((ACC_CONTROLLER_PAGES - vma->vm_pgoff) << PAGE_SHIFT)){
    return -EINVAL;
  }

  io_remap_pfn_range(vma, vma->vm_start, physical_pfn, vsize, vma->vm_page_prot);

  TRACE("dev_mmap virt: %lx, phys: %lx, size: %lx\n", vma->vm_start, physical_pfn << PAGE_SHIFT, vsize);
  return(0);
}

struct file_operations fops = {
  // No read/write; everything is handled by ioctl and mmap
  .open = dev_open,
  .release = dev_close,
  .unlocked_ioctl = dev_ioctl,
  .mmap = dev_mmap,
};

static int hwacc_probe(struct platform_device *pdev)
{
  int irqok;
  struct resource* r_irq = NULL;

  // TODO: this is pretty fragile, as it relies on the ordering in the device
  // tree.  It might be better to break them out in the device tree.
% for n in range(len(streams)):
  r_irq = platform_get_resource(pdev, IORESOURCE_IRQ, ${n});
  if(r_irq == NULL){
    ERROR("IRQ lookup failed.  Check the device tree.\n");
  }
  TRACE("IRQ number is %d\n", r_irq->start);
  irqok = request_irq(r_irq->start, dma_${streams[n]['name']}_finished_handler, 0, "hwacc ${streams[n]['name']}", NULL);
  if(irqok != 0){ return irqok; }
% endfor

  // Create workqueue threads
  dma_launch_queue = create_singlethread_workqueue("dma_launch");
  dma_finished_queue = create_singlethread_workqueue("dma_done"); // names just show up in `ps`

  // Get a single character device number
  alloc_chrdev_region(&device_num, 0, 1, DEVNAME);
  DEBUG("Device registered with major %d, minor: %d\n", MAJOR(device_num), MINOR(device_num));

  // Set up the device and class structures so we show up in sysfs,
  // and so we have a device we can hand to the DMA request
  pipe_class = class_create(THIS_MODULE, CLASSNAME);

  // If we had multiple devices, we could break it apart with
  // MAJOR(device_num), and then add in our own minor number, with
  // MKDEV(MAJOR(device_num), minor_num)
  pipe_dev = device_create(pipe_class, NULL, device_num, 0, DEVNAME);

  // Get pointers to the memory-mapped hardware
% for s in streams:
  ${s['name']}_dma_controller = ioremap(${s['name'].upper()}_DMA_CONTROLLER_BASE, ${s['name'].upper()}_DMA_CONTROLLER_SIZE);
% endfor

  acc_controller = ioremap(ACC_CONTROLLER_BASE, ACC_CONTROLLER_SIZE);
  if(${" || ".join([s['name'] + "_dma_controller == NULL" for s in streams])}
    || acc_controller == NULL){
    ERROR("ioremap failed for one or more devices!\n");
    return(-ENODEV);
  }

% for s in streams:
  if(check_dma_engine(${s['name']}_dma_controller)){
    ERROR("DMA engine ${s['name']} is misconfigured or hung!\n");
    return(-ENODEV);
  }
% endfor

  // Register the driver with the kernel
  chardev = cdev_alloc();
  chardev->ops = &fops;
  cdev_add(chardev, device_num, 1);

  DEBUG("Driver initialized\n");

  return(0);
}

static int hwacc_remove(struct platform_device *pdev)
{
  struct resource* r_irq = NULL;

  // Release the IRQ lines
% for n in range(len(streams)):
  r_irq = platform_get_resource(pdev, IORESOURCE_IRQ, ${n});
  if(r_irq == NULL){
    ERROR("IRQ lookup failed on release.  Check the device tree.\n");
  }
  free_irq(r_irq->start, NULL);
% endfor

  device_unregister(pipe_dev);
  class_destroy(pipe_class);
  cdev_del(chardev);
  unregister_chrdev_region(device_num, 1);

  // Release all the iomapped hardware
% for s in streams:
  iounmap(${s['name']}_dma_controller);
% endfor
  iounmap(acc_controller);
  return(0);
}

static struct of_device_id hwacc_of_match[] = {
  { .compatible = "hwacc", },
  {}
};

static struct platform_driver hwacc_driver = {
	.driver = {
		.name = "hwacc",
		.of_match_table = hwacc_of_match,
	},
	.probe = hwacc_probe,
	.remove = hwacc_remove,
};

module_platform_driver(hwacc_driver)

