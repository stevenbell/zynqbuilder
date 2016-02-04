#include "dma_bufferset.h"

/* Initializes an empty buffer list */
void buffer_initlist(BufferList *list)
{
  list->head = NULL;
  list->tail = NULL;
  sema_init(&list->mutex, 1);
}

/* Attaches a buffer at the tail of the list */
void buffer_enqueue(BufferList* list, BufferSet* buf)
{
  while(down_interruptible(&(list->mutex)) != 0) {}

  // If there's nothing in the list, then the item we add will be both head
  // and tail, and we need to set that.
  if(list->head == NULL){
    list->head = buf;
  }
  // If there is something in the list, point it to the new node
  // If tail is NULL, the head is also NULL, and we won't take this branch.
  else{
    list->tail->next = buf;
  }

  buf->next = NULL; // This is the new end of the list
  list->tail = buf; // Update the tail pointer
  up(&(list->mutex));
}

/* Removes a buffer from the head of the list*/
BufferSet* buffer_dequeue(BufferList* list)
{
  BufferSet* result;
  while(down_interruptible(&(list->mutex)) != 0) {}
  result = list->head;

  // If there isn't anything in the list, this method is pointless
  if(result == NULL){
    return NULL;
  }

  // If there is something in the list, return it and update the head
  list->head = result->next;

  // If the list is now empty (i.e, the head was also the tail), then we need
  // to also update the tail to reflect that.
  if(list->head == NULL){
    list->tail = NULL;
  }
  up(&(list->mutex));
  return result;
}

/* Checks whether a buffer list is empty, returns true if so. */
bool buffer_listempty(BufferList* list)
{
  bool empty;
  while(down_interruptible(&(list->mutex)) != 0) {}
  empty = (list->head == NULL);
  up(&(list->mutex));
  return empty; 
}

