# mkproject.tcl
# Create a complete Vivado project which integrates a core from HLS
#
# Steven Bell <sebell@stanford.edu>, based on generated script from Vivado
# 11 December 2015
# Artem Vasilyev <tema8@stanord.edu>, fixed paths to components, added
# parsing of IP information
#  2 February 2016

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

puts "Script loaded.  Create a design using"
puts "  mkproject PROJECT_NAME PROJECT_PATH IP_PATH"
variable myLocation [file dirname [file normalize [info script]]]
set avnet_repo "${myLocation}/avnet_fmc_imageon_cores"
set constrPath "${myLocation}/zc702_fmc_imageon_vita_passthrough.xdc"
#Python script to extract info about IP component
set get_ip_info "${myLocation}/get_component_info.py"

proc mkproject { projectName projectPath ip_path} {
  # Repositories where additional IP cores live
  global avnet_repo
  global constrPath
  global get_ip_info
  #Get ablosute path to HLS
  set hls_repo [file normalize $ip_path]
  set ip_vlnv [exec python $get_ip_info $hls_repo "VLNV"]

  puts "Creating project $projectName in $projectPath"
  puts "IP core VLNV: $ip_vlnv"
  puts "Using ip core directories:"
  puts "  $avnet_repo"
  puts "  $hls_repo"

  # Create the empty project
  create_project $projectName $projectPath -part xc7z020clg484-1
  set_property BOARD_PART xilinx.com:zc702:part0:1.1 [current_project]

  # Set IP repo paths
  set_property ip_repo_paths "$avnet_repo $hls_repo" [current_project]
  update_ip_catalog

  # Create an empty block design
  set design_name $projectName\_bd
  set bd_name [create_bd_design $design_name]
  set bd_path "${projectPath}/${projectName}.srcs/sources_1/bd/${bd_name}"
  #puts "block design path: $bd_path"

  # Populate the block design 
  create_root_design "" $ip_vlnv $hls_repo

  # All done with the block diagram, close it now
  close_bd_design [get_bd_designs $design_name]

  # Add the constraints file and mark it as an XDC
  set obj [get_filesets constrs_1]
  add_files -norecurse -fileset $obj $constrPath
  set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$constrPath"]]
  set_property "file_type" "XDC" $file_obj

  # Create the HDL wrapper for the design
  make_wrapper -files [get_files "${bd_path}/${design_name}.bd"] -top

  # Add newly created HDL wrapper as a source
  add_files -norecurse "${bd_path}/hdl/${design_name}_wrapper.v"
  update_compile_order -fileset sources_1
  update_compile_order -fileset sim_1
}


# Hierarchical cell: fmc_imageon_vita_color
proc create_hier_cell_fmc_imageon_vita_color { parentCell nameHier } {

  if { $parentCell eq "" || $nameHier eq "" } {
     puts "ERROR: create_hier_cell_fmc_imageon_vita_color() - Empty argument(s)!"
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 cfa_ctrl
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 video_out
  create_bd_intf_pin -mode Slave -vlnv avnet.com:interface:avnet_vita_rtl:1.0 vita_cam
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 vita_cam_ctrl
  create_bd_intf_pin -mode Master -vlnv avnet.com:interface:onsemi_vita_spi_rtl:1.0 vita_spi
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 vita_spi_ctrl

  # Create pins
  create_bd_pin -dir I -from 0 -to 0 -type rst axi4lite_aresetn
  create_bd_pin -dir I -type clk axi4lite_clk
  create_bd_pin -dir I -type clk axi4s_clk
  create_bd_pin -dir I clk200
  create_bd_pin -dir I vita_clk

  # Create instance: gnd, and set properties
  set gnd [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd ]
  set_property -dict [ list CONFIG.CONST_VAL {0}  ] $gnd

  # Create instance: onsemi_vita_cam_0, and set properties
  set onsemi_vita_cam_0 [ create_bd_cell -type ip -vlnv avnet:onsemi_vita:onsemi_vita_cam:3.1 onsemi_vita_cam_0 ]
  set_property -dict [ list CONFIG.C_DEBUG_PORT {false}  ] $onsemi_vita_cam_0

  # Create instance: onsemi_vita_spi_0, and set properties
  set onsemi_vita_spi_0 [ create_bd_cell -type ip -vlnv avnet:onsemi_vita:onsemi_vita_spi:3.1 onsemi_vita_spi_0 ]

  # Create instance: v_vid_in_axi4s_0, and set properties
  set v_vid_in_axi4s_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_in_axi4s:3.0 v_vid_in_axi4s_0 ]
  set_property -dict [ list CONFIG.C_M_AXIS_VIDEO_FORMAT {12}  ] $v_vid_in_axi4s_0

  # Create instance: vcc, and set properties
  set vcc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vcc ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins vita_cam] [get_bd_intf_pins onsemi_vita_cam_0/IO_CAM_IN]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins video_out] [get_bd_intf_pins v_vid_in_axi4s_0/video_out]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins vita_spi] [get_bd_intf_pins onsemi_vita_spi_0/IO_SPI_OUT]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins vita_cam_ctrl] [get_bd_intf_pins onsemi_vita_cam_0/S00_AXI]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins vita_spi_ctrl] [get_bd_intf_pins onsemi_vita_spi_0/S00_AXI]
  connect_bd_intf_net -intf_net onsemi_vita_cam_0_VID_IO_OUT [get_bd_intf_pins onsemi_vita_cam_0/VID_IO_OUT] [get_bd_intf_pins v_vid_in_axi4s_0/vid_io_in]

  # Create port connections
  connect_bd_net -net clk_fpga_0 [get_bd_pins axi4lite_clk] [get_bd_pins onsemi_vita_cam_0/s00_axi_aclk] [get_bd_pins onsemi_vita_spi_0/s00_axi_aclk]
  connect_bd_net -net clk_fpga_1 [get_bd_pins clk200] [get_bd_pins onsemi_vita_cam_0/clk200]
  connect_bd_net -net clk_fpga_2 [get_bd_pins axi4s_clk] [get_bd_pins v_vid_in_axi4s_0/aclk]
  connect_bd_net -net gnd_const [get_bd_pins gnd/dout] [get_bd_pins onsemi_vita_cam_0/reset] [get_bd_pins onsemi_vita_cam_0/trigger1] [get_bd_pins v_vid_in_axi4s_0/rst]
  connect_bd_net -net proc_sys_reset_peripheral_aresetn [get_bd_pins axi4lite_aresetn] [get_bd_pins onsemi_vita_cam_0/s00_axi_aresetn] [get_bd_pins onsemi_vita_spi_0/s00_axi_aresetn]
  connect_bd_net -net vcc_const [get_bd_pins onsemi_vita_cam_0/oe] [get_bd_pins onsemi_vita_spi_0/oe] [get_bd_pins v_vid_in_axi4s_0/aclken] [get_bd_pins v_vid_in_axi4s_0/aresetn] [get_bd_pins v_vid_in_axi4s_0/axis_enable] [get_bd_pins v_vid_in_axi4s_0/vid_io_in_ce] [get_bd_pins vcc/dout]
  connect_bd_net -net video_clk_div4 [get_bd_pins vita_clk] [get_bd_pins onsemi_vita_cam_0/clk] [get_bd_pins v_vid_in_axi4s_0/vid_io_in_clk]
  
  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell ip_vlnv ip_path} {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set fmc_imageon_iic [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fmc_imageon_iic ]
  set vita_cam [ create_bd_intf_port -mode Slave -vlnv avnet.com:interface:avnet_vita_rtl:1.0 vita_cam ]
  set vita_spi [ create_bd_intf_port -mode Master -vlnv avnet.com:interface:onsemi_vita_spi_rtl:1.0 vita_spi ]

  # Create ports
  set fmc_imageon_iic_rst_n [ create_bd_port -dir O -from 0 -to 0 fmc_imageon_iic_rst_n ]
  set vita_clk [ create_bd_port -dir I vita_clk ]

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
  set_property -dict [ list CONFIG.c_m_axis_mm2s_tdata_width {8} CONFIG.c_sg_include_stscntrl_strm {0}  ] $axi_dma_1

  # Create instance: axi_mem_intercon, and set properties
  set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}  ] $axi_mem_intercon

  # Create instance: axi_mem_intercon_1, and set properties
  set axi_mem_intercon_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 ]
  set_property -dict [ list CONFIG.NUM_MI {1} CONFIG.NUM_SI {3}  ] $axi_mem_intercon_1

  # Create instance: axi_vdma_0, and set properties
  set axi_vdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 axi_vdma_0 ]
  set_property -dict [ list CONFIG.c_include_mm2s {0}  ] $axi_vdma_0

  # Create instance: dout_padding, and set properties
  set dout_padding [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 dout_padding ]
  set_property -dict [ list CONFIG.CONST_VAL {0} CONFIG.CONST_WIDTH {8}  ] $dout_padding

  # Create instance: dout_padding_concat, and set properties
  set dout_padding_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 dout_padding_concat ]

  # Create instance: fmc_imageon_iic_0, and set properties
  set fmc_imageon_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 fmc_imageon_iic_0 ]
  set_property -dict [ list CONFIG.IIC_BOARD_INTERFACE {Custom} CONFIG.USE_BOARD_FLOW {true}  ] $fmc_imageon_iic_0

  # Create instance: fmc_imageon_vita_color
  create_hier_cell_fmc_imageon_vita_color [current_bd_instance .] fmc_imageon_vita_color

  # Create instance: ila_0, and set properties
  set ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ila:5.0 ila_0 ]
  set_property -dict [ list CONFIG.C_DATA_DEPTH {16384} CONFIG.C_NUM_OF_PROBES {9} CONFIG.C_SLOT_0_AXI_PROTOCOL {AXI4S}  ] $ila_0

  # Create instance: interrupt_concat, and set properties
  set interrupt_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 interrupt_concat ]

  # Create instance: accelerator, and set properties
  set accelerator [ create_bd_cell -type ip -vlnv $ip_vlnv accelerator ]

  #Discover signal names in accelerator
  global get_ip_info
  set ip_clock [exec python $get_ip_info $ip_path "clock"]
  set ip_reset [exec python $get_ip_info $ip_path "reset"]
  set ip_aximm [exec python $get_ip_info $ip_path "aximm"]
  set ip_axis_const  [exec python $get_ip_info $ip_path "axis_const"]
  set ip_axis_output [exec python $get_ip_info $ip_path "axis_output"]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.preset {ZC702*}  ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {7}  ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_50M, and set properties
  set rst_processing_system7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_50M ]

  # Create interface connections
  connect_bd_intf_net -intf_net IO_CAM_IN_1 [get_bd_intf_ports vita_cam] [get_bd_intf_pins fmc_imageon_vita_color/vita_cam]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_mem_intercon/S00_AXI] [get_bd_intf_pins axi_vdma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_dma_1/M_AXI_SG] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins axi_dma_1/M_AXI_MM2S] [get_bd_intf_pins axi_mem_intercon_1/S01_AXI]
  connect_bd_intf_net -intf_net S02_AXI_1 [get_bd_intf_pins axi_dma_1/M_AXI_S2MM] [get_bd_intf_pins axi_mem_intercon_1/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXIS_MM2S [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins accelerator/$ip_axis_const]
  connect_bd_intf_net -intf_net axi_mem_intercon_1_M00_AXI [get_bd_intf_pins axi_mem_intercon_1/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP1]
  connect_bd_intf_net -intf_net axi_mem_intercon_M00_AXI [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net fmc_imageon_iic_0_IIC [get_bd_intf_ports fmc_imageon_iic] [get_bd_intf_pins fmc_imageon_iic_0/IIC]
  connect_bd_intf_net -intf_net fmc_imageon_vita_color_IO_SPI_OUT [get_bd_intf_ports vita_spi] [get_bd_intf_pins fmc_imageon_vita_color/vita_spi]
  connect_bd_intf_net -intf_net fmc_imageon_vita_color_video_out [get_bd_intf_pins axi_vdma_0/S_AXIS_S2MM] [get_bd_intf_pins fmc_imageon_vita_color/video_out]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins fmc_imageon_iic_0/S_AXI] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_vdma_0/S_AXI_LITE] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_dma_1/S_AXI_LITE] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins fmc_imageon_vita_color/cfa_ctrl] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M04_AXI [get_bd_intf_pins fmc_imageon_vita_color/vita_cam_ctrl] [get_bd_intf_pins processing_system7_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M05_AXI [get_bd_intf_pins fmc_imageon_vita_color/vita_spi_ctrl] [get_bd_intf_pins processing_system7_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M06_AXI [get_bd_intf_pins accelerator/$ip_aximm] [get_bd_intf_pins processing_system7_0_axi_periph/M06_AXI]

  # Create port connections
  connect_bd_net -net axi4s_clk_1 [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins axi_vdma_0/m_axi_s2mm_aclk] [get_bd_pins axi_vdma_0/s_axis_s2mm_aclk] [get_bd_pins fmc_imageon_vita_color/axi4s_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK]
  connect_bd_net -net axi_dma_1_mm2s_introut [get_bd_pins axi_dma_1/mm2s_introut] [get_bd_pins interrupt_concat/In0]
  connect_bd_net -net axi_dma_1_s2mm_introut [get_bd_pins axi_dma_1/s2mm_introut] [get_bd_pins interrupt_concat/In1]
  connect_bd_net -net axi_dma_1_s_axis_s2mm_tready [get_bd_pins axi_dma_1/s_axis_s2mm_tready] [get_bd_pins accelerator/${ip_axis_output}_TREADY]
  connect_bd_net -net dout_padding_concat_dout [get_bd_pins axi_dma_1/s_axis_s2mm_tdata] [get_bd_pins dout_padding_concat/dout]
  connect_bd_net -net fmc_imageon_iic_0_gpo [get_bd_ports fmc_imageon_iic_rst_n] [get_bd_pins fmc_imageon_iic_0/gpo]
  connect_bd_net -net accelerator_p_hw_output_2_stencil_stream_TDATA [get_bd_pins dout_padding_concat/In0] [get_bd_pins accelerator/${ip_axis_output}_TDATA]
  connect_bd_net -net accelerator_p_hw_output_2_stencil_stream_TLAST [get_bd_pins axi_dma_1/s_axis_s2mm_tlast] [get_bd_pins accelerator/${ip_axis_output}_TLAST]
  connect_bd_net -net accelerator_p_hw_output_2_stencil_stream_TVALID [get_bd_pins axi_dma_1/s_axis_s2mm_tvalid] [get_bd_pins accelerator/${ip_axis_output}_TVALID]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_dma_1/m_axi_mm2s_aclk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] [get_bd_pins axi_dma_1/m_axi_sg_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins axi_mem_intercon_1/ACLK] [get_bd_pins axi_mem_intercon_1/M00_ACLK] [get_bd_pins axi_mem_intercon_1/S00_ACLK] [get_bd_pins axi_mem_intercon_1/S01_ACLK] [get_bd_pins axi_mem_intercon_1/S02_ACLK] [get_bd_pins axi_vdma_0/s_axi_lite_aclk] [get_bd_pins fmc_imageon_iic_0/s_axi_aclk] [get_bd_pins fmc_imageon_vita_color/axi4lite_clk] [get_bd_pins ila_0/clk] [get_bd_pins accelerator/${ip_clock}] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP1_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_50M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_pins fmc_imageon_vita_color/clk200] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_50M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_50M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_50M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_50M_peripheral_aresetn [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins axi_mem_intercon_1/ARESETN] [get_bd_pins axi_mem_intercon_1/M00_ARESETN] [get_bd_pins axi_mem_intercon_1/S00_ARESETN] [get_bd_pins axi_mem_intercon_1/S01_ARESETN] [get_bd_pins axi_mem_intercon_1/S02_ARESETN] [get_bd_pins fmc_imageon_iic_0/s_axi_aresetn] [get_bd_pins fmc_imageon_vita_color/axi4lite_aresetn] [get_bd_pins accelerator/${ip_reset}] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_50M/peripheral_aresetn]
  connect_bd_net -net vita_clk_1 [get_bd_ports vita_clk] [get_bd_pins fmc_imageon_vita_color/vita_clk]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins interrupt_concat/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins dout_padding/dout] [get_bd_pins dout_padding_concat/In1]

  # Create address segments
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_SG] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
  create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_vdma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
  create_bd_addr_seg -range 0x10000 -offset 0x40400000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg] SEG_axi_vdma_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x41600000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs fmc_imageon_iic_0/S_AXI/Reg] SEG_fmc_imageon_iic_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs fmc_imageon_vita_color/onsemi_vita_cam_0/S00_AXI/Reg] SEG_onsemi_vita_cam_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C30000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs fmc_imageon_vita_color/onsemi_vita_spi_0/S00_AXI/Reg] SEG_onsemi_vita_spi_0_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x43C10000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs accelerator/${ip_aximm}/Reg] SEG_accelerator_Reg
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


