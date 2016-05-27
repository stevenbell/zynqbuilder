#include <linux/module.h>
#include <linux/cdev.h> // Character device
#include <linux/device.h>
#include <asm/uaccess.h> // Copy to/from userspace pointers
#include <linux/mm.h>
#include <linux/pagemap.h>

MODULE_LICENSE("GPL");

#include "common.h"
#include "buffer.h"
#include "ioctl_cmds.h"

#define CLASSNAME "cmabuffer" // Shows up in /sys/class
#define DEVNAME "cmabuffer0" // Shows up in /dev

dev_t device_num;
struct cdev *chardev;
struct device *cmabuf_dev;
struct class *cmabuf_class;

const int debug_level = 4; // 0 is errors only, increasing numbers print more stuff

// TODO: allow the file handle to be opened multiple times, and access
// the same pool of memory?
static int dev_open(struct inode *inode, struct file *file)
{
  TRACE("cmabuffer: dev_open\n");
  // Set up the image buffers; fail if it fails.
  if(init_buffers(cmabuf_dev) < 0){
    return(-ENOMEM);
  }

  return(0);
}

static int dev_close(struct inode *inode, struct file *file)
{
  TRACE("cmabuffer: dev_close\n");
  cleanup_buffers(cmabuf_dev); // Release all the buffer memory

  return(0);
}

void free_image(Buffer* buf)
{
  release_buffer(buf);
  DEBUG("Releasing image\n");
}


long dev_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
  Buffer tmp, *tmpptr;
  DEBUG("ioctl cmd %d | %lu (%lx) \n", cmd, arg, arg);
  switch(cmd){
    case GET_BUFFER:
      TRACE("ioctl: GET_BUFFER\n");
      // Get the desired buffer parameters from the object passed to us
      if(access_ok(VERIFY_READ, (void*)arg, sizeof(Buffer)) &&
         copy_from_user(&tmp, (void*)arg, sizeof(Buffer)) == 0){
        tmpptr = acquire_buffer(tmp.width, tmp.height, tmp.depth, tmp.stride);
        if(tmpptr == NULL){
          return(-ENOBUFS);
        }
      }
      else{
        return(-EIO);
      }

      // Now copy the retrieved buffer back to the user
      if(access_ok(VERIFY_WRITE, (void*)arg, sizeof(Buffer)) &&
         (copy_to_user((void*)arg, tmpptr, sizeof(Buffer)) == 0)) { } // All ok, nothing to do
      else{
        return(-EIO);
      }
    break;

    case FREE_IMAGE:
      TRACE("ioctl: FREE_IMAGE\n");
      // Copy the object into our tmp copy
      if(access_ok(VERIFY_READ, (void*)arg, sizeof(Buffer)) &&
         copy_from_user(&tmp, (void*)arg, sizeof(Buffer)) == 0){
          free_image(&tmp);
      }
      else{
        return(-EACCES);
      }
      break;

    default:
      return(-EINVAL); // Unknown command, return an error
      break;
  }
  return(0); // Success
}

int vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
{
  // Get the index of the page
  // This is base_addr + offset
  // TODO: do some error checking on the offset
  vmf->page = virt_to_page(get_base_addr() + (vmf->pgoff << PAGE_SHIFT));
  get_page(vmf->page);

  //DEBUG("Page fault: %lu %x %x", vmf->pgoff, get_base_addr(), vmf->page);
  return(0);
}

static struct vm_operations_struct vma_operations = {
  .fault = vma_fault,
};

int dev_mmap(struct file *filp, struct vm_area_struct *vma)
{
  TRACE("dev_mmap\n");
  // Just set up the operations; fault operation does all the hard work
  vma->vm_ops = &vma_operations;
  return 0;
}

struct file_operations fops = {
  // No read/write; everything is handled by ioctl and mmap
  .open = dev_open,
  .release = dev_close,
  .unlocked_ioctl = dev_ioctl,
  .mmap = dev_mmap,
};

static int cmabuf_driver_init(void)
{
  // Get a single character device number
  alloc_chrdev_region(&device_num, 0, 1, DEVNAME);
  DEBUG("Device registered with major %d, minor: %d\n", MAJOR(device_num), MINOR(device_num));

  // Set up the device and class structures so we show up in sysfs,
  // and so we have a device we can hand to the DMA request
  cmabuf_class = class_create(THIS_MODULE, CLASSNAME);

  // If we had multiple devices, we could break it apart with
  // MAJOR(device_num), and then add in our own minor number, with
  // MKDEV(MAJOR(device_num), minor_num)
  cmabuf_dev = device_create(cmabuf_class, NULL, device_num, 0, DEVNAME);

  // Register the driver with the kernel
  chardev = cdev_alloc();
  chardev->ops = &fops;
  cdev_add(chardev, device_num, 1);

  DEBUG("Driver initialized\n");

  return(0);
}

static void cmabuf_driver_exit(void)
{
  device_unregister(cmabuf_dev);
  class_destroy(cmabuf_class);
  cdev_del(chardev);
  unregister_chrdev_region(device_num, 1);

}

module_init(cmabuf_driver_init);
module_exit(cmabuf_driver_exit);

