# Partition SD card
Use gparted to create 2 partitions on the SD card.  One is ~200MB, FAT32, the other is ext4 and fills the rest of the card.

# Downloaded ubuntu core for armhf
http://cdimage.ubuntu.com/ubuntu-core/releases/15.04/release/

Extract this to the ext4 partition.

# Boot files:
Put these files on the FAT32 boot partition:

- Linux kernel from Xilinx 2014.4 release
- devicetree from Xilinx 2014.4 release
- boot.bin from X
  Modified the devicetree to use /dev/mmcXXX0p1 instead of /dev/ram
  dtc -I dtb -O dts -o devicetree.dts devicetree.dtb
  <edit>
  dtc -I dts -O dtb -o devicetree_sdcard.dtb devicetree.dts
- uimage rootfs from http://www.wiki.xilinx.com/Ubuntu+on+Zynq  This is required because it has an initramfs that chainloads to the SD card.

# Used chroot to create a new user and install ssh
http://askubuntu.com/questions/216621/how-to-add-user-to-separate-filesystem-armel

adduser ubuntu
passwd ubuntu < set it to "ubuntu" >
addgroup adm ubuntu
addgroup sudo ubuntu

apt-get update
apt-get install ssh
apt-get install sudo # This is important. :-)

# Changed the default shell to bash for the 'ubuntu' user
sudo chsh -s /bin/bash ubuntu

# Installed lots of stuff
bsdmainutils kmod

