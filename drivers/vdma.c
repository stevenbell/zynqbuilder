/* vdma.c
 * Linux kernel driver for the Xilinx VDMA engine that works in
 * conjunction with the cmabuffer driver.
 *
 * Steven Bell <sebell@stanford.edu>
 * 15 December 2015, based on earlier work
 */

// TODO: some of these are probably unnecessary
#include <linux/module.h>
#include <linux/cdev.h> // Character device
#include <linux/slab.h> // kmalloc
#include <asm/io.h> // ioremap and friends
#include <asm/uaccess.h> // Copy to/from userspace pointers
#include <linux/sched.h> // current task struct
#include <linux/fs.h> // File node numbers
#include <linux/device.h>

#include "common.h"
#include "buffer.h"
#include "ioctl_cmds.h"

MODULE_LICENSE("GPL");

#define CLASSNAME "xilcam" // Shows up in /sys/class
#define DEVNAME "xilcam0" // Shows up in /dev

#define VDMA_CONTROLLER_BASE 0x43000000
#define VDMA_CONTROLLER_SIZE 0x100

unsigned char* vdma_controller;

dev_t device_num;
struct cdev *chardev;
struct device *vdma_dev;
struct class *vdma_class;

#define N_VDMA_BUFFERS 3 // Number of "live" buffers in the VDMA buffer ring
Buffer* vdma_buf[N_VDMA_BUFFERS]; // Handles for buffers in the ring

int debug_level = 3; // 0 is errors only, increasing numbers print more stuff

static int dev_open(struct inode *inode, struct file *file)
{
  int i;
  unsigned long status;
  iowrite32(0x00010044, vdma_controller + 0x30); // reset, so we can configure

  // Acquire buffers and hand them to the VDMA engine
  for(i = 0; i < N_VDMA_BUFFERS; i++){
    vdma_buf[i] = acquire_buffer(1920, 1080, 1, 2048);
    if(vdma_buf[i] == NULL){
      return(-ENOMEM);
    }
    iowrite32(vdma_buf[i]->phys_addr, vdma_controller + 0xac + i*4);
  }

  iowrite32(N_VDMA_BUFFERS, vdma_controller + 0x48); // Set number of buffers

  status = ioread32(vdma_controller + 0x34);
  DEBUG("dev_open: ioread32 at offset 0x34 returned %08lx\n", status);
  iowrite32(0xffffffff, vdma_controller + 0x34); // clear errors
  DEBUG("dev_open: iowrite32 at offset 0x34 with %08x\n", 0xffffffff);
  status = ioread32(vdma_controller + 0x34);
  DEBUG("dev_open: ioread32 at offset 0x34 returned %08lx\n", status);


  iowrite32(1920, vdma_controller + 0xa4); // Horizontal size (1 byte/pixel)
  iowrite32(2048, vdma_controller + 0xa8); // Stride (1 byte/pixel)
  iowrite32(1080, vdma_controller + 0xa0); // Vertical size, start transfer


  // Run in circular mode, and keep interrupts off
  iowrite32(0x00010043, vdma_controller + 0x30);
  status = ioread32(vdma_controller + 0x30);
  DEBUG("dev_open: ioread32 at offset 0x30 returned %08lx\n", status);
  status = ioread32(vdma_controller + 0x34);
  DEBUG("dev_open: ioread32 at offset 0x34 returned %08lx\n", status);

  TRACE("dev_open: Started VDMA\n");;
  return(0);
}

static int dev_close(struct inode *inode, struct file *file)
{
  iowrite32(0x00010040, vdma_controller + 0x30); // Stop, so we can configure
  // Free our collection of big buffers
  // for(i = 0; i < N_VDMA_BUFFERS; i++){
  //   release_buffer(vdma_buf[i]);
  // }

  TRACE("dev_close: Stopped VDMA\n");
  return(0);
}


int grab_image(Buffer* buf)
{
  Buffer* tmp;
  unsigned long slot; // Slot VDMA S2MM is working on
  unsigned long status;

  // Allocate a new buffer to swap in
  tmp = acquire_buffer(1920, 1080, 1, 2048);

  // If this fails, return failure
  if(tmp == NULL){
    return(-ENOBUFS);
  }

  // Grab the most recently completed image
  // The current frame store location is in 0x24 (FRMPTR_STS), bits 20-16
  // Note 0x24 (FRMPTR_STS) is only available if C_ENABLE_DEBUG_INFO_12=1
  slot = ioread32(vdma_controller + 0x24);
  DEBUG("grab_image: ioread32 at offset 0x24 returned %08lx\n", slot);
  slot = (slot & 0x001F0000) >> 16;
  /*
  // The current frame store location is in 0x28 (PARK_PTR_REG), bits 28-24
  // Note 0x28 (PARK_PTR_REG) is only useful for our purpose
  // if there is no VDMA error (see register 0x34)
  status = ioread32(vdma_controller + 0x34);
  DEBUG("grab_image: ioread32 at offset 0x34 returned %08lx\n", status);
  slot = ioread32(vdma_controller + 0x28);
  DEBUG("grab_image: ioread32 at offset 0x28 returned %08lx\n", slot);
  slot = slot >> 24;
  */

  // Get the previous one, which is the most recently finished
  DEBUG("grab_image: VMDA current working frame in slot %lu\n", slot);
  slot = (slot + N_VDMA_BUFFERS - 1) % N_VDMA_BUFFERS;
  DEBUG("grab_image: most recently finished frame in slot %lu\n", slot);

  // Copy the buffer object for the caller
  *buf = *vdma_buf[slot];

  // Replace it with the new buffer
  vdma_buf[slot] = tmp;

  // Write the change to the VDMA engine
  iowrite32(vdma_buf[slot]->phys_addr, vdma_controller + 0xac + slot*4);

  // Write the vertical size again so the settings take effect
  iowrite32(1080, vdma_controller + 0xa0);

  TRACE("grab_image: replaced %d with %d\n", buf->id, vdma_buf[slot]->id);
  return(0);
}


long dev_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
  Buffer tmp;

  switch(cmd){
    case GRAB_IMAGE:
      TRACE("ioctl: GRAB_IMAGE\n");
      if(grab_image(&tmp) == 0 && 
        access_ok(VERIFY_WRITE, (void*)arg, sizeof(Buffer)))
      {
        TRACE("Copying raw buffer object to user\n");
        // copy_to_user returns number of uncopied bytes, which should be 0
        if(copy_to_user((void*)arg, &tmp, sizeof(Buffer)) != 0){
          return(-EIO);
        }
      }
      else{
        return(-ENOBUFS);
      }
      break;

    default:
      return(-EINVAL); // Unknown command, return an error
      break;
  }
  return(0); // Success
}

struct file_operations fops = {
  // No read/write; everything is handled by ioctl
  .open = dev_open,
  .release = dev_close,
  .unlocked_ioctl = dev_ioctl,
};


static int vdma_driver_init(void)
{
  // Get a single character device number
  alloc_chrdev_region(&device_num, 0, 1, DEVNAME);
  DEBUG("VDMA device registered with major %d, minor: %d\n", MAJOR(device_num), MINOR(device_num));

  // Set up the device and class structures so we show up in sysfs,
  // and so we have a device we can hand to the DMA request
  vdma_class = class_create(THIS_MODULE, CLASSNAME);

  // If we had multiple devices, we could break it apart with
  // MAJOR(device_num), and then add in our own minor number, with
  // MKDEV(MAJOR(device_num), minor_num)
  vdma_dev = device_create(vdma_class, NULL, device_num, 0, DEVNAME);

  vdma_controller = ioremap(VDMA_CONTROLLER_BASE, VDMA_CONTROLLER_SIZE);
  if(vdma_controller == NULL){
    return(-ENODEV);
  }

  // Register the driver with the kernel
  chardev = cdev_alloc();
  chardev->ops = &fops;
  cdev_add(chardev, device_num, 1);

  DEBUG("VDMA driver initialized\n");
  return(0);
}

static void vdma_driver_exit(void)
{
  device_unregister(vdma_dev);
  class_destroy(vdma_class);
  cdev_del(chardev);
  unregister_chrdev_region(device_num, 1);

  iounmap(vdma_controller);
}

module_init(vdma_driver_init);
module_exit(vdma_driver_exit);

