/** this file is the code fragment for timer driver code. It doesn't compile.
 */


#define TIMER_CONTROLLER_BASE 0x42800000
#define TIMER_CONTROLLER_SIZE 0x20

unsigned char* timer_controller;

typedef struct {
  unsigned long counter0;
  unsigned long counter1;
} timer_count_t;

static inline void read_timer(timer_count_t *count) {
  unsigned long cur_counter1;

  /* (page 21 of PG079) The following are the steps for reading the 64-bit counter/timer:
     1. Read the upper 32-bit timer/counter register (TCR1).
     2. Read the lower 32-bit timer/counter register (TCR0).
     3. Read the upper 32-bit timer/counter register (TCR1) again. If the value is different from
     the 32-bit upper value read previously, go back to previous step (reading TCR0).
     Otherwise 64-bit timer counter value is correct.
  */
  cur_counter1 = ioread32((void*)timer_controller + 0x18);
  do {
    count->counter1 = cur_counter1;
    count->counter0 = ioread32((void*)timer_controller + 0x08);
    cur_counter1 = ioread32((void*)timer_controller + 0x18);
  } while (cur_counter1 != count->counter1);
}

static inline void debug_timer(void) {
  timer_count_t count;
  if(debug_level > 0) {
    read_timer(&count);
    DEBUG("debug_timer: %lu, %lu\n", count.counter1, count.counter0);
  }
}

long dev_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
  timer_count_t timer_count;
  DEBUG("ioctl cmd %d | %lu (%lx) \n", cmd, arg, arg);

  switch(cmd){
    case READ_TIMER:
      TRACE("ioctl: READ_TIMER\n");
      read_timer(&timer_count);
      // Now copy the retrieved buffer back to the user
      if(access_ok(VERIFY_WRITE, (void*)arg, sizeof(timer_count_t)) &&
         (copy_to_user((void*)arg, &timer_count, sizeof(timer_count_t)) == 0)) { } // All ok, nothing to do
      else{
        return(-EIO);
      }
      break;
    default:
      return(-EINVAL); // Unknown command, return an error
      break;
  }
  return(0); // Success
}

static int hwacc_probe(struct platform_device *pdev)
{
  timer_controller = ioremap(TIMER_CONTROLLER_BASE, TIMER_CONTROLLER_SIZE);
  iowrite32(0x00000891, timer_controller);  // set cascade mode (64bit mode), capture mode, and auto load, and enable timer

  if(timer_controller == NULL){
    ERROR("ioremap failed for one or more devices!\n");
    return(-ENODEV);
  }

  DEBUG("TIMER started\n");
  debug_timer();
  return(0);
}

static int hwacc_remove(struct platform_device *pdev)
{
  iounmap(timer_controller);
  return(0);
}
