###############################################################################
# User Configuration
# Link Width   - x4
# Link Speed   - gen2
# Family       - zynq
# Part         - xc7z100
# Package      - ffg900
# Speed grade  - -2
# PCIe Block   - X0Y0
###############################################################################
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################


###############################################################################
# Pinout and Related I/O Constraints
###############################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#

# Sys EXT_SYS_RST Pins
set_property PULLUP true [get_ports EXT_SYS_RST]
set_property IOSTANDARD LVCMOS25 [get_ports EXT_SYS_RST]
set_property PACKAGE_PIN AC14 [get_ports EXT_SYS_RST]

#GTX
set_property LOC GTXE2_CHANNEL_X0Y15 [get_cells {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN P5 [get_ports {EXT_PCIE_rxn[0]}]
set_property PACKAGE_PIN P6 [get_ports {EXT_PCIE_rxp[0]}]
set_property PACKAGE_PIN N3 [get_ports {EXT_PCIE_txn[0]}]
set_property PACKAGE_PIN N4 [get_ports {EXT_PCIE_txp[0]}]

set_property LOC GTXE2_CHANNEL_X0Y14 [get_cells {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[1].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN T5 [get_ports {EXT_PCIE_rxn[1]}]
set_property PACKAGE_PIN T6 [get_ports {EXT_PCIE_rxp[1]}]
set_property PACKAGE_PIN P1 [get_ports {EXT_PCIE_txn[1]}]
set_property PACKAGE_PIN P2 [get_ports {EXT_PCIE_txp[1]}]

set_property LOC GTXE2_CHANNEL_X0Y13 [get_cells {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[2].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN U3 [get_ports {EXT_PCIE_rxn[2]}]
set_property PACKAGE_PIN U4 [get_ports {EXT_PCIE_rxp[2]}]
set_property PACKAGE_PIN R3 [get_ports {EXT_PCIE_txn[2]}]
set_property PACKAGE_PIN R4 [get_ports {EXT_PCIE_txp[2]}]

set_property LOC GTXE2_CHANNEL_X0Y12 [get_cells {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_lane[3].gt_wrapper_i/gtx_channel.gtxe2_channel_i}]
set_property PACKAGE_PIN V5 [get_ports {EXT_PCIE_rxn[3]}]
set_property PACKAGE_PIN V6 [get_ports {EXT_PCIE_rxp[3]}]
set_property PACKAGE_PIN T1 [get_ports {EXT_PCIE_txn[3]}]
set_property PACKAGE_PIN T2 [get_ports {EXT_PCIE_txp[3]}]

# LED Pins
set_property PACKAGE_PIN AH14 [get_ports {EXT_LEDS[0]}]
set_property PACKAGE_PIN AH13 [get_ports {EXT_LEDS[1]}]
set_property PACKAGE_PIN AD16 [get_ports {EXT_LEDS[2]}]
set_property PACKAGE_PIN AD15 [get_ports {EXT_LEDS[3]}]
set_property PACKAGE_PIN AD14 [get_ports {EXT_LEDS[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {EXT_LEDS[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {EXT_LEDS[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {EXT_LEDS[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {EXT_LEDS[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {EXT_LEDS[4]}]

###############################################################################
# Physical Constraints
###############################################################################
#
# SYS clock 100 MHz (input) signal. The EXT_PCIE_REFCLK_p and EXT_PCIE_REFCLK_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#

set_property LOC IBUFDS_GTE2_X0Y6 [get_cells pcie_refclk_buf]
set_property PACKAGE_PIN N8 [get_ports EXT_PCIE_REFCLK_P]
set_property PACKAGE_PIN N7 [get_ports EXT_PCIE_REFCLK_N]

###############################################################################
# Timing Constraints
###############################################################################
#
create_clock -period 10.000 -name EXT_PCIE_REFCLK [get_pins pcie_refclk_buf/O]
#create_clock -period 10.000 -name EXT_PCIE_REFCLK [get_ports EXT_PCIE_REFCLK_P]
#

# Timing ignoring the below pins to avoid CDC analysis, but care has been taken in RTL to sync properly to other clock domain.
#
#
###############################################################################
# Tandem Configuration Constraints
###############################################################################

set_false_path -from [get_ports EXT_SYS_RST]


###############################################################################
# End
###############################################################################

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/INT_USERCLK2_OUT]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[0]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[1]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[2]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[3]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[4]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[5]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[6]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[7]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[8]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[9]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[10]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[11]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[12]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[13]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[14]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[15]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[16]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[17]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[18]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[19]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[20]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[21]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[22]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[23]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[24]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[25]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[26]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[27]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[28]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[29]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[30]} {mmp_proj_bd_i/z7_pcie_dma_top/xlconcat_1_dout[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 22 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[0]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[1]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[2]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[3]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[4]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[5]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[6]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[7]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[8]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[9]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[10]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[11]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[12]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[13]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[14]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[15]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[16]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[17]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[18]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[19]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[20]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TUSER[21]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[0]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[1]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[2]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[3]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[4]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[5]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[6]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TKEEP[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 64 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[0]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[1]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[2]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[3]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[4]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[5]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[6]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[7]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[8]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[9]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[10]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[11]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[12]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[13]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[14]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[15]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[16]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[17]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[18]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[19]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[20]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[21]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[22]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[23]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[24]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[25]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[26]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[27]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[28]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[29]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[30]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[31]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[32]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[33]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[34]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[35]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[36]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[37]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[38]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[39]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[40]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[41]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[42]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[43]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[44]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[45]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[46]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[47]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[48]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[49]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[50]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[51]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[52]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[53]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[54]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[55]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[56]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[57]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[58]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[59]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[60]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[61]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[62]} {mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TDATA[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TUSER[0]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TUSER[1]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TUSER[2]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TUSER[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 8 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[0]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[1]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[2]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[3]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[4]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[5]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[6]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TKEEP[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 64 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[0]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[1]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[2]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[3]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[4]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[5]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[6]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[7]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[8]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[9]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[10]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[11]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[12]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[13]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[14]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[15]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[16]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[17]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[18]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[19]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[20]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[21]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[22]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[23]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[24]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[25]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[26]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[27]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[28]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[29]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[30]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[31]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[32]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[33]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[34]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[35]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[36]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[37]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[38]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[39]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[40]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[41]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[42]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[43]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[44]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[45]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[46]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[47]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[48]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[49]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[50]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[51]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[52]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[53]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[54]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[55]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[56]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[57]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[58]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[59]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[60]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[61]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[62]} {mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TDATA[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WSTRB[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WSTRB[1]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WSTRB[2]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WSTRB[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[1]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[2]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[3]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[4]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[5]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[6]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[7]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[8]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[9]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[10]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[11]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[12]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[13]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[14]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[15]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[16]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[17]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[18]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[19]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[20]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[21]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[22]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[23]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[24]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[25]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[26]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[27]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[28]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[29]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[30]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 2 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RRESP[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RRESP[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[1]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[2]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[3]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[4]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[5]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[6]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[7]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[8]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[9]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[10]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[11]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[12]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[13]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[14]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[15]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[16]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[17]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[18]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[19]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[20]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[21]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[22]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[23]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[24]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[25]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[26]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[27]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[28]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[29]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[30]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RDATA[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 2 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_BRESP[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_BRESP[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 32 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[1]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[2]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[3]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[4]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[5]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[6]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[7]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[8]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[9]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[10]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[11]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[12]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[13]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[14]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[15]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[16]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[17]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[18]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[19]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[20]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[21]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[22]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[23]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[24]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[25]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[26]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[27]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[28]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[29]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[30]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWADDR[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[0]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[1]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[2]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[3]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[4]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[5]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[6]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[7]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[8]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[9]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[10]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[11]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[12]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[13]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[14]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[15]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[16]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[17]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[18]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[19]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[20]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[21]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[22]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[23]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[24]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[25]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[26]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[27]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[28]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[29]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[30]} {mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARADDR[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_ARVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_AWVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_BREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_BVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_RVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_shim_0_m_axi_WVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/axi_str_s2c0_tuser_cycle]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/nwl_backend_dma_x4g2_0_s_axis_tx_TVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TLAST]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TREADY]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/pcie_7x_0_m_axis_rx_TVALID]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/raw_data_packet_0_data_mismatch]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/user_registers_slave_0_enable_checker1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/user_registers_slave_0_enable_generator1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list mmp_proj_bd_i/z7_pcie_dma_top/user_registers_slave_0_enable_loopback1]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_INT_USERCLK2_OUT]
