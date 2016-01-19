# Before running this, run the command-line
# export CROSS_COMPILE=arm-xilinx-linux-gnueabi-

ARCH := arm
KER_DIR := /home/steven/work/linux-xlnx/

obj-m := vdma.o # Top level modules
vdma-objs := driver.o dma_bufferset.o buffer.o # Dependencies

# Call the Linux source makefiles to do the dirty work
all: driver.c
	$(MAKE) ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) modules

install:
	scp -i ~/.ssh/zynq_linaro vdma.ko ubuntu@10.42.0.196:

clean: 
	make ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) clean

driver.c: driver.c.mako hwconfig.yml
	python drivergen.py


