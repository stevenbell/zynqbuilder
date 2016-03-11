# These parameters are defaults and should usually be overriden, e.g.,
#   make SDCARD_DIR=/YOUR/PATH/HERE copy
SDCARD_DIR=/media/steven/2E9F-3602
PROJECT_DIR=/nobackup/jingpu/Halide-HLS/apps/hls_examples/stereo_hls/zynqbuilder/vivado_project/work

# These are defaults which match the zynqbuilder vivado project.
# You shouldn't have to change these.
SYSDEF:=$(shell find $(PROJECT_DIR) -name *.sysdef)

# These are just variables for keeping track of paths; leave these alone.
BUILD_DIR=build
STAGING_DIR=$(BUILD_DIR)/staging
BOOTIMAGE_DIR=$(BUILD_DIR)/bootimage
EXPORT_DIR=$(BUILD_DIR)/export
UBOOT_DIR=$(BUILD_DIR)/uboot
BIN_DIR=binary

VPATH=$(BUILD_DIR)/fsbl/Debug
# TODO: do an MD5 hash and write a log as to where everything came from

.PHONY : all copy binary clean cleansd

all: binary devicetree.dtb bootimage

copy: all
	cp $(STAGING_DIR)/* $(SDCARD_DIR)

clean:
	rm -r $(STAGING_DIR)/*
	rm -r $(EXPORT_DIR)/*

cleansd:
	rm -r $(SDCARD_DIR)/*

# Just copies the static binaries into the staging directory
binary: $(BIN_DIR)/uImage $(BIN_DIR)/uramdisk.image.gz
	mkdir -p $(STAGING_DIR)
	# Kernel
	cp $(BIN_DIR)/uImage $(STAGING_DIR)
	# Root file system
	cp $(BIN_DIR)/uramdisk.image.gz $(STAGING_DIR)

# Builds the device tree blob from source and puts it in the staging directory
devicetree.dtb:
	mkdir -p $(STAGING_DIR)
	cd devicetree; python dtgen.py
	dtc -I dts -O dtb -o $(STAGING_DIR)/devicetree.dtb devicetree/devicetree.dts

# Builds the first-stage bootloader from source, using the Xilinx project
fsbl.elf: ps7_init.c
	mkdir -p $(BUILD_DIR)/fsbl/src
	cp -r fsbl_project_src/* $(BUILD_DIR)
	cp $(EXPORT_DIR)/ps7_init.c $(BUILD_DIR)/fsbl/src
	cp $(EXPORT_DIR)/ps7_init.h $(BUILD_DIR)/fsbl/src
	$(MAKE) -C $(BUILD_DIR)/fsbl/Debug all

ps7_init.c system.bit: $(SYSDEF)
	rm -rf $(EXPORT_DIR)/* # Just in case
	unzip -o $(SYSDEF) -d $(EXPORT_DIR)

# TODO: depends on u-boot
bootimage: fsbl.elf system.bit
	mkdir -p $(BOOTIMAGE_DIR)
	# Boot image configuration file
	cp bootimage.bif $(BOOTIMAGE_DIR)
	# FSBL
	cp $(BUILD_DIR)/fsbl/Debug/fsbl.elf $(BOOTIMAGE_DIR)
	# bitstream
	cp $(shell find $(EXPORT_DIR) -name *.bit) $(BOOTIMAGE_DIR)/system.bit
	# u-boot
	cp $(UBOOT_DIR)/u-boot $(BOOTIMAGE_DIR)/u-boot.elf
	
	cd $(BOOTIMAGE_DIR) && bootgen -w on -image bootimage.bif -o i boot.bin
	cp $(BOOTIMAGE_DIR)/boot.bin $(STAGING_DIR)



