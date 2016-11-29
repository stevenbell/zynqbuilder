
#####################
# Build IPI Project #
#####################

create_project -name ipi_prj -force -part xc7z045-2-ffg900

read_verilog ../rtl_ref_design/dma_ref_design_axi.v


read_verilog ../rtl_ref_design/util_sync_bus.v
read_verilog ../rtl_ref_design/util_sync_flops.v
read_verilog ../rtl_ref_design/util_toggle_pos_sync.v
read_verilog ../rtl_ref_design/ref_inferred_block_ram.v
read_verilog ../rtl_ref_design/ref_inferred_shallow_ram.v
read_verilog ../rtl_ref_design/ref_sc_fifo_shallow_ram.v
read_verilog ../rtl_ref_design/ref_tiny_fifo.v
read_verilog ../rtl_ref_design/sram_mp_axi.v
add_files -fileset constrs_1 -norecurse [glob ./*.xdc]

# The following commands add the IP repositories to the design so the IP can be available in IPI
set_property ip_repo_paths "../nwl_ip nwl_refdes_ip" [current_fileset]
update_ip_catalog

# The following commands create a new IPI design, add the DMA IP and Xilinx PCIe and make some connections
create_bd_design "xil_pcie_wrapper_ipi"
update_compile_order -fileset sources_1



create_bd_cell -type ip -vlnv nwlogic.com:ip:NWL_AXI_DMA:1.01 NWL_AXI_DMA_0
create_bd_cell -type ip -vlnv nwlogic.com:ip:NWL_AXI_Ref_Des:1.01 NWL_AXI_Ref_Des_0
create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_7x:3.0 pcie_7x_0


set_property -dict [list CONFIG.Bar0_Size {64}                  ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar0_Enabled {true}             ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar1_Enabled {true}             ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar1_Size {8}                   ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar2_Enabled {true}             ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar2_Size {8}                   ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Class_Code_Base {11}            ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Buf_Opt_BMA {true}              ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.MSIx_Enabled {true}             ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.MSIx_Table_Size {20}            ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.MSIx_Table_Offset {c00}         ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.MSIx_PBA_Offset {e00}           ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.en_ext_clk {false}              ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Xlnx_Ref_Board {ZC706}          ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.PCIe_Debug_Ports {false}        ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar1_Type {Memory}              ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Bar2_Type {Memory}              ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Maximum_Link_Width {X4}         ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Link_Speed {5.0_GT/s}           ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.mode_selection {Advanced}       ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.User_Clk_Freq {250}             ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Trgt_Link_Speed {4'h2}          ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Vendor_ID {19AA}                ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Device_ID {E004}                ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Subsystem_Vendor_ID {19AA}      ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Subsystem_ID {E004}             ]      [get_bd_cells pcie_7x_0]
set_property -dict [list CONFIG.Revision_ID {04}                ]      [get_bd_cells pcie_7x_0]


#enable the appropriate signal groups on the DMA IP
set_property -dict [list CONFIG.USE_S_AXI {false} CONFIG.USE_M_INTR {false}] [get_bd_cells NWL_AXI_DMA_0]
set_property -dict [list CONFIG.USE_MGMT {false} CONFIG.USE_TEST {false} ] [get_bd_cells NWL_AXI_Ref_Des_0]


# make connections between the DMA and Reference Design

#create external ports
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 ram_s2c
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 ram_c2s
set_property CONFIG.DATA_WIDTH [get_property CONFIG.DATA_WIDTH [get_bd_intf_pins NWL_AXI_Ref_Des_0/ram_s2c]] [get_bd_intf_ports ram_s2c]
set_property CONFIG.DATA_WIDTH [get_property CONFIG.DATA_WIDTH [get_bd_intf_pins NWL_AXI_Ref_Des_0/ram_c2s]] [get_bd_intf_ports ram_c2s]
set_property -dict [list CONFIG.FREQ_HZ {250000000}] [get_bd_intf_ports ram_s2c]
set_property -dict [list CONFIG.FREQ_HZ {250000000}] [get_bd_intf_ports ram_c2s]



create_bd_port -dir I -type rst perst_n
create_bd_port -dir I -type clk pcie_clk
create_bd_port -dir I -from 3 -to 0 rx_p
create_bd_port -dir I -from 3 -to 0 rx_n
create_bd_port -dir O -from 3 -to 0 tx_p
create_bd_port -dir O -from 3 -to 0 tx_n
create_bd_port -dir O -type clk user_clk
create_bd_port -dir O -type rst user_rst_n
create_bd_port -dir O mgmt_mst_en
create_bd_port -dir O -from 1 -to 0 s2c_areset_n
create_bd_port -dir O -from 1 -to 0 c2s_areset_n


#assign AXI address space between master and slaves
assign_bd_address [get_bd_addr_segs {NWL_AXI_Ref_Des_0/S_AXI/reg0 }]
assign_bd_address [get_bd_addr_segs {NWL_AXI_Ref_Des_0/S2C/Reg }]
assign_bd_address [get_bd_addr_segs {NWL_AXI_Ref_Des_0/RAM_C2S/Reg }]


#connecting internal signals
connect_bd_net [get_bd_pins pcie_7x_0/user_clk_out] [get_bd_pins NWL_AXI_DMA_0/user_clk]
connect_bd_net [get_bd_pins pcie_7x_0/user_reset_out] [get_bd_pins NWL_AXI_DMA_0/user_reset]
connect_bd_net [get_bd_pins pcie_7x_0/user_lnk_up] [get_bd_pins NWL_AXI_DMA_0/user_link_up]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/mgmt_interrupt] [get_bd_pins NWL_AXI_DMA_0/user_interrupt]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/pcie_rst_n] [get_bd_pins NWL_AXI_DMA_0/user_rst_n]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/s2c_fifo_addr_n] [get_bd_pins NWL_AXI_DMA_0/s2c_fifo_addr_n]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/c2s_fifo_addr_n] [get_bd_pins NWL_AXI_DMA_0/c2s_fifo_addr_n]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/c2s_ruserstatus] [get_bd_pins NWL_AXI_DMA_0/c2s_ruserstatus]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/c2s_ruserstrb] [get_bd_pins NWL_AXI_DMA_0/c2s_ruserstrb]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/s2c_areset_n] [get_bd_pins NWL_AXI_DMA_0/s2c_areset_n]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/c2s_areset_n] [get_bd_pins NWL_AXI_DMA_0/c2s_areset_n]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/s2c_wusercontrol] [get_bd_pins NWL_AXI_DMA_0/s2c_wusercontrol]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/s2c_wusereop] [get_bd_pins NWL_AXI_DMA_0/s2c_wusereop]
connect_bd_net [get_bd_pins NWL_AXI_Ref_Des_0/s2c_awusereop] [get_bd_pins NWL_AXI_DMA_0/s2c_awusereop]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_Ref_Des_0/pcie_clk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_DMA_0/t_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_DMA_0/c2s_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_DMA_0/s2c_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_Ref_Des_0/s2c_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_Ref_Des_0/c2s_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_Ref_Des_0/t_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_pins NWL_AXI_DMA_0/m_aclk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets NWL_AXI_DMA_0_user_rst_n] [get_bd_pins NWL_AXI_Ref_Des_0/t_areset_n] [get_bd_pins NWL_AXI_DMA_0/user_rst_n]
connect_bd_net -net [get_bd_nets NWL_AXI_DMA_0_user_rst_n] [get_bd_pins NWL_AXI_DMA_0/t_areset_n] [get_bd_pins NWL_AXI_DMA_0/user_rst_n]
connect_bd_net -net [get_bd_nets NWL_AXI_DMA_0_user_rst_n] [get_bd_pins NWL_AXI_DMA_0/m_areset_n] [get_bd_pins NWL_AXI_DMA_0/user_rst_n]


#connect bus interfaces
connect_bd_intf_net [get_bd_intf_pins pcie_7x_0/m_axis_rx] [get_bd_intf_pins NWL_AXI_DMA_0/s_axis_rx]
connect_bd_intf_net [get_bd_intf_pins pcie_7x_0/s_axis_tx] [get_bd_intf_pins NWL_AXI_DMA_0/m_axis_tx]
connect_bd_intf_net [get_bd_intf_pins NWL_AXI_Ref_Des_0/S2C] [get_bd_intf_pins NWL_AXI_DMA_0/S2C]
connect_bd_intf_net [get_bd_intf_pins NWL_AXI_Ref_Des_0/C2S] [get_bd_intf_pins NWL_AXI_DMA_0/C2S]
connect_bd_intf_net [get_bd_intf_ports ram_s2c] [get_bd_intf_pins NWL_AXI_Ref_Des_0/ram_s2c]
connect_bd_intf_net [get_bd_intf_ports ram_c2s] [get_bd_intf_pins NWL_AXI_Ref_Des_0/ram_c2s]
connect_bd_intf_net [get_bd_intf_pins pcie_7x_0/pcie2_cfg_err] [get_bd_intf_pins NWL_AXI_DMA_0/pcie2_cfg_err]
connect_bd_intf_net [get_bd_intf_pins pcie_7x_0/pcie2_cfg_interrupt] [get_bd_intf_pins NWL_AXI_DMA_0/pcie2_cfg_interrupt]
connect_bd_intf_net [get_bd_intf_pins pcie_7x_0/pcie2_cfg_status] [get_bd_intf_pins NWL_AXI_DMA_0/pcie2_cfg_status]
connect_bd_intf_net [get_bd_intf_pins pcie_7x_0/pcie_cfg_fc] [get_bd_intf_pins NWL_AXI_DMA_0/pcie_cfg_fc]
connect_bd_intf_net [get_bd_intf_pins NWL_AXI_DMA_0/M_AXI] [get_bd_intf_pins NWL_AXI_Ref_Des_0/S_AXI]


#connecting external ports
connect_bd_net [get_bd_ports pcie_clk] [get_bd_pins pcie_7x_0/sys_clk]
connect_bd_net [get_bd_ports perst_n] [get_bd_pins pcie_7x_0/sys_rst_n]
connect_bd_net [get_bd_ports rx_n] [get_bd_pins pcie_7x_0/pci_exp_rxn]
connect_bd_net [get_bd_ports rx_p] [get_bd_pins pcie_7x_0/pci_exp_rxp]
connect_bd_net [get_bd_ports tx_n] [get_bd_pins pcie_7x_0/pci_exp_txn]
connect_bd_net [get_bd_ports tx_p] [get_bd_pins pcie_7x_0/pci_exp_txp]
connect_bd_net [get_bd_ports mgmt_mst_en] [get_bd_pins NWL_AXI_DMA_0/mgmt_mst_en]
connect_bd_net -net [get_bd_nets NWL_AXI_DMA_0_c2s_areset_n] [get_bd_ports c2s_areset_n] [get_bd_pins NWL_AXI_DMA_0/c2s_areset_n]
connect_bd_net -net [get_bd_nets NWL_AXI_DMA_0_s2c_areset_n] [get_bd_ports s2c_areset_n] [get_bd_pins NWL_AXI_DMA_0/s2c_areset_n]
connect_bd_net -net [get_bd_nets pcie_7x_0_user_clk_out] [get_bd_ports user_clk] [get_bd_pins pcie_7x_0/user_clk_out]
connect_bd_net -net [get_bd_nets NWL_AXI_DMA_0_user_rst_n] [get_bd_ports user_rst_n] [get_bd_pins NWL_AXI_DMA_0/user_rst_n]



save_bd_design


### Build design

set start_time [clock seconds]

generate_target {Synthesis Simulation} [get_files ./ipi_prj.srcs/sources_1/bd/xil_pcie_wrapper_ipi/xil_pcie_wrapper_ipi.bd]


synth_design -top dma_ref_design -part xc7z045-2-ffg900

write_checkpoint -force ./post_synth
report_timing -sort_by group -max_paths 100 -path_type full -file ./timing_synth.rpt

opt_design -directive ExploreSequentialArea

place_design -directive Explore
write_checkpoint -force ./post_place
report_timing -sort_by group -max_paths 100 -path_type full -file ./timing_place.rpt

phys_opt_design -directive AggressiveExplore
report_timing -sort_by group -max_paths 100 -path_type full -file ./timing_physopt.rpt

route_design -directive Explore
write_checkpoint -force ./post_route



report_timing_summary -file ./timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type full -file ./timing.rpt
report_utilization -hierarchical -file ./utilization.rpt
report_io -file ./pin.rpt


set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
write_bitstream -force ./dma_ref_design.bit


set end_time [clock seconds]
set total_time [ expr { $end_time - $start_time} ]
set absolute_time [clock format $total_time -format {%H:%M:%S} -gmt true ]
puts "\ntotal build time: $absolute_time\n"

