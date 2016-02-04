# zynqbuilder
Tools for building a bootable Zynq system
The base project assumes a ZC702 board with the Xilinx camera from the Zynq video and imaging kit.  It doesn't matter if you actually have the camera connected.

# Vivado project

Open Vivado, and from the TCL console, run

    source mkproject.tcl -notrace

Then run

    mkproject PROJECTNAME PROJECTPATH IP_PATH

From here, you should be able to synthesize the design and create a bitstream.

# SD card image
The SD card should have two partitions; one FAT32 about 100MB, and one ext4 partition taking up the rest of the card.  The FAT partition contains the boot files, and the ext4 partition contains the filesystem.  The system starts with a tiny filesystem in a ramdisk, and switches over once it's partly booted.

There are four files necessary to boot from the SD card.  The Makefile includes commands to generate all of these.  If the xilinx tools are in your path, you should be able to run

    sh make_uboot.sh

Then you can run

    make
    make SDCARD_DIR=/YOUR/SDCARD copy

## Boot image (boot.bin)
The boot image contains three things:
- First-stage bootloader (FSBL), which configures the FPGA and chainloads u-boot
- FPGA bitsream (optional)
- u-boot, which reads the device tree and then chainloads the Linux kernel

The FSBL is dependant on the FPGA configuration (clock frequencies, I/O, etc), so it should be rebuilt when the design changes.

u-boot is just a binary.

## Linux kernel (uimage)
We use the stock Xilinx kernel from one of their releases (currently 2014.4).
The kernel drivers need to be compiled against the source code for the kernel, but this is easy to do since Xilinx releases are tagged in their git repository.

## Initial root file system (uramdisk.image.gz)
Using uramdisk.image.gz from [http://www.wiki.xilinx.com/Ubuntu+on+Zynq]
This is required because it has an initramfs that chainloads to the SD card.

## Device tree (devicetree.dtb)
The device tree is a system for informing the kernel what hardware exists on an embedded platform, and provides some other configuration details like boot parameters.
This is "compiled" (or rather, compressed) into a "device tree blob" (DTB) from the source DTS file.

## Real root file system (ext4 partition on SD card)
[Ubuntu core](https://wiki.ubuntu.com/Core) is pretty nice, because you have a normal-ish system with access to any software you might need.  However, the release itself is really minimal and takes a little work to set up.

- Download the CD image for Ubuntu core for armhf: http://cdimage.ubuntu.com/ubuntu-core/releases/15.04/release/
- Extract it to your SD card partition
- Use chroot to create a new user and install ssh, following the directions here: http://askubuntu.com/questions/216621/how-to-add-user-to-separate-filesystem-armel

    adduser ubuntu
    passwd ubuntu < set it to "ubuntu" >
    addgroup adm ubuntu
    addgroup sudo ubuntu
    
    apt-get update
    apt-get install ssh
    apt-get install sudo # This is important. :-)

- At this point, you should be able to boot, and make any other changes you want locally rather than via chroot.

    sudo chsh -s /bin/bash ubuntu # Change the default shell to bash
    sudo apt-get install your_favorite_things

