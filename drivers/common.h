#ifndef _COMMON_H_
#define _COMMON_H_

#define ERROR(...)   printk(__VA_ARGS__)
#define WARNING(...) if(debug_level > 0) printk(__VA_ARGS__)
#define TRACE(...)   if(debug_level > 1) printk(__VA_ARGS__)
#define DEBUG(...)   if(debug_level > 2) printk(__VA_ARGS__)

#endif
