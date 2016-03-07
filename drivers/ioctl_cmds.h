#ifndef _IOCTL_CMDS_H_
#define _IOCTL_CMDS_H_

// TODO: switch these out for "proper" mostly-system-unique ioctl numbers
#define GET_BUFFER 1000 // Get an unused buffer
#define GRAB_IMAGE 1001 // Acquire image from camera
#define FREE_IMAGE 1002 // Release buffer
#define PROCESS_IMAGE 1003 // Push to stencil path
#define PEND_PROCESSED 1004 // Retreive from stencil path
#define READ_TIMER 1010 // Retreive hw timer count

// TODO: set width, height?

#endif
