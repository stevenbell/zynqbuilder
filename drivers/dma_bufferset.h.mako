/* Generated automatically by ${toolName} on ${date} */

#ifndef _DMA_BUFFERPAIR_H_
#define _DMA_BUFFERPAIR_H_

#include <linux/semaphore.h>
#include <linux/device.h>
#include "buffer.h"

typedef struct BufferSet {
  int id;
  // Each input/output stream is allocated separately and shuffled around
  // We have full copies since pointers we're handed may not persist
% for s in streams:
  Buffer ${s['name']};
  unsigned long* ${s['name']}_sg; // Memory for SG table
  unsigned long ${s['name']}_sg_phys; // Physical address of SG table
% endfor
  // TODO: what if the tap width is zero?
  //unsigned char tap_vals[$//{tapwidth}]; // Data that describes the tap state
  struct BufferSet* next; // Next buffer set in chain, if any
} BufferSet;


typedef struct BufferList{
  BufferSet* head;
  BufferSet* tail;
  struct semaphore mutex;
} BufferList;


void buffer_initlist(BufferList *list);
void buffer_enqueue(BufferList* list, BufferSet* buf);
BufferSet* buffer_dequeue(BufferList* list);
BufferSet* buffer_dequeueid(BufferList* list, int id);
bool buffer_listempty(BufferList* list);
bool buffer_hasid(BufferList* list, int id);

#endif

