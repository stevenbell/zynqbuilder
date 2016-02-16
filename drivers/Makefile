ARCH := arm
KER_DIR := /cad/xilinx/linux-xlnx/

obj-m := hwacc.o # Top level modules
hwacc-objs := driver.o dma_bufferset.o buffer.o # Dependencies

# Call the Linux source makefiles to do the dirty work
all: driver.c dma_bufferset.c dma_bufferset.h
	$(MAKE) ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) CROSS_COMPILE=arm-xilinx-linux-gnueabi- modules

install:
	scp -i ~/.ssh/zynq_linaro hwacc.ko ubuntu@10.42.0.196:

clean:
	make ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) clean

cleanall:
	make ARCH=$(ARCH) -C $(KER_DIR) M=$(PWD) clean
	rm driver.c

driver.c: driver.c.mako hwconfig.yml
	python drivergen.py

dma_bufferset.h: dma_bufferset.h.mako
	python drivergen.py


