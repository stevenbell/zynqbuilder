ARCH := arm
KER_DIR := /home/steven/work/linux-xlnx/
#KER_DIR := /cad/xilinx/linux-xlnx/

HWCONFIG := ../hwconfig.yml

# There are three modules created from this source code
#   cmabuffer - Provides access to large contiguous memory buffers from Linux CMA
#   hwacc - Driver for hardware accelerator, using one or more DMA engines
#   xilcam - Driver for VDMA engine connected to the Xilinx camera
obj-m := hwacc.o xilcam.o cmabuffer.o

# Dependencies for each of the modules
# Note that some code related to buffer handling and ioctl numbers is shared
hwacc-objs := driver.o dma_bufferset.o
xilcam-objs := vdma.o
cmabuffer-objs := cmabuf.o buffer.o

# Call the Linux source makefiles to do the dirty work
all: driver.c dma_bufferset.c dma_bufferset.h vdma.c buffer.c buffer.h
	$(MAKE) ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) CROSS_COMPILE=arm-xilinx-linux-gnueabi- modules

install:
	scp -i ~/.ssh/zynq_linaro hwacc.ko ubuntu@10.42.0.196:
	scp -i ~/.ssh/zynq_linaro xilcam.ko ubuntu@10.42.0.196:
	scp -i ~/.ssh/zynq_linaro cmabuffer.ko ubuntu@10.42.0.196:

clean:
	make ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) clean

cleanall:
	make ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) clean
	rm driver.c

driver.c: driver.c.mako $(HWCONFIG)
	python ../parameterize.py $(HWCONFIG) driver.c.mako:driver.c

dma_bufferset.h: dma_bufferset.h.mako $(HWCONFIG)
	python ../parameterize.py $(HWCONFIG) dma_bufferset.h.mako:dma_bufferset.h


