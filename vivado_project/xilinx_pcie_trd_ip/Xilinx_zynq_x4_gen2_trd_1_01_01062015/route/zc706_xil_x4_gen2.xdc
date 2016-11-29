###############################################################################
# Pinout and Related I/O Constraints
###############################################################################


set_property package_pin AK23 [get_ports perst_n]
set_property IOSTANDARD LVCMOS25 [get_ports perst_n]


# Add the following signals for the LEDs if desired


set_property package_pin Y21 [get_ports {led[0]}]
set_property package_pin G2  [get_ports {led[1]}]
set_property package_pin W21 [get_ports {led[2]}]

set_property IOSTANDARD LVCMOS25 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[2]}]




# SYS clock 100 MHz (input) signal. The pcie_clk_p and pcie_clk_n
# signals are the PCI Express reference clock. Series-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#

set_property package_pin N8 [get_ports pcie_clk_p]
set_property package_pin N7 [get_ports pcie_clk_n]



# Transceiver instance placement.  This constraint selects the
# transceivers to be used, which also dictates the pinout for the
# transmit and receive differential pairs.  Please refer to the
# Virtex-7 GT Transceiver User Guide (UG) for more information.
#

# PCIe Lanes
set_property LOC GTXE2_CHANNEL_X0Y15 [get_cells {xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property LOC GTXE2_CHANNEL_X0Y14 [get_cells {xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property LOC GTXE2_CHANNEL_X0Y13 [get_cells {xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property LOC GTXE2_CHANNEL_X0Y12 [get_cells {xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]


#
# PCI Express Block placement. This constraint selects the PCI Express
# Block to be used.
#

set_property LOC PCIE_X0Y0 [get_cells xil_pcie_wrapper/pcie_7x_0/inst/inst/pcie_top_i/pcie_7x_i/pcie_block_i]




###############################################################################
# Timing Constraints
###############################################################################



#
# Timing requirements and related constraints.
#

create_clock -name sys_clk -period 10 [get_pins refclk_ibuf/O]
create_clock -name txoutclk -period 10 [get_pins xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK]


create_generated_clock -name clk_125mhz_mux \
                        -source [get_pins xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] \
                        -divide_by 1 \
                        [get_pins xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]

create_generated_clock -name clk_250mhz_mux \
                        -source [get_pins xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] \
                        -divide_by 1 -add -master_clock [get_clocks -of [get_pins xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] \
                        [get_pins xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]

set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux -group clk_250mhz_mux




set_false_path -to [get_pins {xil_pcie_wrapper/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*}]


#set_false_path -through [get_cells {*/p_rst_reg}]


###############################################################################
# Physical Constraints
###############################################################################

###############################################################################
# End
###############################################################################
