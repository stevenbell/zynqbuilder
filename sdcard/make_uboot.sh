
WORK_DIR=build
UBOOT_DIR=uboot

UBOOT_REV=head

mkdir -p $WORK_DIR
git clone git://github.com/Xilinx/u-boot-xlnx.git $WORK_DIR/$UBOOT_DIR
cd $WORK_DIR/$UBOOT_DIR
git checkout xilinx-v2014.4

# Get the 

export BUILD_DIR=$WORK_DIR/$UBOOT_DIR/build

export CROSS_COMPILE=arm-xilinx-eabi-
# This will change to zynq_zc702_config in uboot 2015
make zynq_zc70x_config
make -j 4


