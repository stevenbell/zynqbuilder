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

  if(result != NULL){
   // We've picked off the front item, so update the head pointer
   list->head = result->next;
  }
  else{
    // If there isn't anything in the list, this method is pointless
    printk("Attempted to dequeue from empty list!\n");
  }

  // If the list is now empty (i.e, the head was also the tail), then we need
  // to also update the tail to reflect that.
  if(list->head == NULL){
    list->tail = NULL;
  }
  up(&(list->mutex));
  return result;
}

/* Removes the buffer with the corresponding id
 * Will return NULL if not found */
BufferSet* buffer_dequeueid(BufferList* list, int id)
{
  BufferSet* s;
  BufferSet* prev = NULL;
  while(down_interruptible(&(list->mutex)) != 0) {}

  // Find the matching BufferSet
  for(s = list->head; s != NULL; s = s->next){
    if(s->id == id){
      // Move the upstream pointer that was pointing to s
      if(prev != NULL){
        // There was a previous item; make it point to the next
        prev->next = s->next;
      }
      else{
        // This was the head, so change the head pointer
        list->head = s->next;
      }
      // Move the tail pointer if this was the last item
      // If there was only one item, this will make the tail NULL
      if(list->tail == s){
        list->tail = prev;
      }
      break; // We've found it, so quit now
    }
    else{
      // This isn't it; move to the next item
      prev = s;
    }
  } // END iterating through the linked list

  up(&(list->mutex));
  return s;
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

bool buffer_hasid(BufferList* list, int id)
{
  bool found = false;
  BufferSet* s;

  while(down_interruptible(&(list->mutex)) != 0) {}
  for(s = list->head; s != NULL; s = s->next){
    if(s->id == id){
      found = true;
      break; // Found it; we can quit now
    }
  }
  up(&(list->mutex));
  return found;
}

