# mkproject.tcl
# Create a complete Vivado project which integrates a core from HLS
#
# Change log:
# Dec 11, 2015  Steven Bell <sebell@stanford.edu>
#               - based on generated script from Vivado
# Feb 02, 2016  Artem Vasilyev <tema8@stanord.edu>
#               - fixed paths to components, added parsing of IP information
# May 27, 2016  Jing Pu
#               - ported the script to vivado 2015.4
# Jun 01, 2016  Jing Pu
#               - added arguments to turn off camera components

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
    puts ""
    puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

    return 1
}

################################################################
# START
################################################################
variable myLocation [file dirname [file normalize [info script]]]

# from avnet open source repo at https://github.com/Avnet/hdl, release 'fmc_imageon_gs_MZ7020_FMCCC_20160225_161355'
set avnet_repo "${myLocation}/hdl-fmc_imageon_gs_MZ7020_FMCCC_20160225_161355_IP"

set constrPath "${myLocation}/zc702_fmc_imageon_vita_passthrough.xdc"
#Python script to extract info about IP component
set get_ip_info "${myLocation}/get_component_info.py"

# e.g. mkproject my_proj my_work /nobackup/jingpu/Halide-HLS/apps/hls_examples/demosaic_harris_hls/hls_prj/solution1/impl/ip 1
proc mkproject { projectName projectPath ip_path build_camera} {
    # Repositories where additional IP cores live
    global avnet_repo
    global constrPath
    global get_ip_info
    #Get ablosute path to HLS
    set hls_repo [file normalize $ip_path]
    set ip_vlnv [exec python $get_ip_info $hls_repo "VLNV"]
    # TODO: This only handles single-input kernels
    set axis_input_name [string trim [exec python $get_ip_info $hls_repo "axis_input"] \[\]\' ]
    set axis_output_name [exec python $get_ip_info $hls_repo "axis_output"]

    puts "Creating project $projectName in $projectPath"
    puts "IP core VLNV: $ip_vlnv"
    puts "Using ip core directories:"
    puts "  $avnet_repo"
    puts "  $hls_repo"

    # Create the empty project
    create_project $projectName $projectPath -part xc7z020clg484-1

    # Add board specific constraint file
    set_property board_part xilinx.com:zc702:part0:1.2 [current_project]
    if { $build_camera } {
        add_files -norecurse -fileset constrs_1 $constrPath
    }

    # Add Avnet IP Repository
    puts "***** Updating Vivado to include IP Folder"
    set_property ip_repo_paths "$avnet_repo $hls_repo" [current_project]
    update_ip_catalog

    # Create an empty block design
    set bd_name $projectName\_bd
    create_bd_design $bd_name

    # Populate the block design
    create_root_design $ip_vlnv $build_camera

    # Add Project source files
    puts "***** Adding Source Files to Block Design..."
    set bd_path "${projectPath}/${projectName}.srcs/sources_1/bd/${bd_name}"
    make_wrapper -files [get_files "${bd_path}/${bd_name}.bd"] -top
    add_files -norecurse "${bd_path}/hdl/${bd_name}_wrapper.v"

    puts "***** Building Binary..."
    update_compile_order -fileset sources_1
    update_compile_order -fileset sim_1
    launch_runs impl_1 -to_step write_bitstream
}

# Procedure to create entire design
proc create_root_design { ip_vlnv build_camera axis_input_name axis_output_name} {
    puts "***** Creating Block Design..."

    set rootCell  [get_bd_cells /]
    current_bd_instance $rootCell

    # Create instance: processing_system7_0, and set properties
    set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
    set_property -dict [ list \
                             CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
                             CONFIG.PCW_IRQ_F2P_INTR {1} \
                             CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
                             #CONFIG.PCW_USE_S_AXI_HP1 {1} \
                             CONFIG.PCW_USE_S_AXI_ACP {1} CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {1} \
                             CONFIG.preset {ZC702*}  ] $processing_system7_0
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" } $processing_system7_0

    # Create instance: axi_dma_1, and set properties
    set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
    set_property -dict [ list  CONFIG.c_include_sg {1} \
                             CONFIG.c_enable_multi_channel {1} \
                             CONFIG.c_sg_include_stscntrl_strm {0} \
                             CONFIG.c_m_axis_mm2s_tdata_width {16} ] $axi_dma_1

    # Create instance: interrupt_concat, and set properties
    set interrupt_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 interrupt_concat ]

    # Create instance: accelerator, and set properties
    set accelerator [ create_bd_cell -type ip -vlnv $ip_vlnv accelerator ]

    set out_width_converter [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0]
    set_property -dict [list CONFIG.TUSER_BITS_PER_BYTE.VALUE_SRC USER CONFIG.HAS_TKEEP.VALUE_SRC USER CONFIG.HAS_TSTRB.VALUE_SRC USER CONFIG.HAS_TLAST.VALUE_SRC USER CONFIG.TDEST_WIDTH.VALUE_SRC USER CONFIG.TID_WIDTH.VALUE_SRC USER] $out_width_converter
    set_property -dict [list CONFIG.M_TDATA_NUM_BYTES {4} CONFIG.HAS_TLAST {1} CONFIG.HAS_MI_TKEEP {1}] $out_width_converter

    # Connect accelerator input/output streams
    connect_bd_intf_net [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS] [get_bd_intf_pins accelerator/$axis_output_name]
    connect_bd_intf_net [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS] [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM]
    connect_bd_intf_net [get_bd_intf_pins accelerator/$axis_input_name] [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S]
    connect_bd_net [get_bd_pins axis_dwidth_converter_0/aclk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk]
    connect_bd_net [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins axi_dma_1/axi_resetn]

    # DMA interrupt signals
    connect_bd_net [get_bd_pins axi_dma_1/mm2s_introut] [get_bd_pins interrupt_concat/In0]
    connect_bd_net [get_bd_pins axi_dma_1/s2mm_introut] [get_bd_pins interrupt_concat/In1]
    connect_bd_net [get_bd_pins interrupt_concat/dout] [get_bd_pins processing_system7_0/IRQ_F2P]

    # Connect config buses using AXI GP0
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins accelerator/s_axi_config]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_1/S_AXI_LITE]

    # Connect AXI_ACP
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_dma_1/M_AXI_SG" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins processing_system7_0/S_AXI_ACP]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_ACP" Clk "Auto" }  [get_bd_intf_pins axi_dma_1/M_AXI_MM2S]
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_ACP" Clk "Auto" }  [get_bd_intf_pins axi_dma_1/M_AXI_S2MM]

    # Add camera related components
    if { $build_camera } {
        # Update processing_system properties, more AXI HP ports and fabric clocks
        set_property -dict [ list \
                                 CONFIG.PCW_EN_CLK1_PORT {1} \
                                 CONFIG.PCW_EN_CLK2_PORT {1} \
                                 CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {142} \
                                 CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} \
                                 CONFIG.PCW_USE_S_AXI_HP0 {1}] $processing_system7_0

        # Create ports and interface ports
        create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 fmc_imageon_iic
        create_bd_intf_port -mode Slave -vlnv avnet.com:interface:onsemi_vita_cam_rtl:1.0 vita_cam
        create_bd_intf_port -mode Master -vlnv avnet.com:interface:onsemi_vita_spi_rtl:1.0 vita_spi
        create_bd_port -dir O -from 0 -to 0 fmc_imageon_iic_rst_n
        create_bd_port -dir I vita_clk

        # Create instance: fmc_imageon_vita_color
        create_hier_cell_fmc_imageon_vita_color [current_bd_instance .] fmc_imageon_vita_color

        # Create instance: axi_vdma_0, and set properties
        set axi_vdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 axi_vdma_0 ]
        set_property -dict [ list CONFIG.c_include_mm2s {0}  ] $axi_vdma_0
        # enable debug register FRMPTR_STS
        set_property -dict [list CONFIG.C_ENABLE_DEBUG_INFO_12 {1}] $axi_vdma_0

        # Create interface connections
        connect_bd_intf_net [get_bd_intf_ports vita_cam] [get_bd_intf_pins fmc_imageon_vita_color/vita_cam]
        connect_bd_intf_net [get_bd_intf_ports fmc_imageon_iic] [get_bd_intf_pins fmc_imageon_vita_color/iic]
        connect_bd_intf_net [get_bd_intf_ports vita_spi] [get_bd_intf_pins fmc_imageon_vita_color/vita_spi]
        connect_bd_intf_net [get_bd_intf_pins axi_vdma_0/S_AXIS_S2MM] [get_bd_intf_pins fmc_imageon_vita_color/video_out]

        # Create port connections
        connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins axi_vdma_0/s_axis_s2mm_aclk] [get_bd_pins fmc_imageon_vita_color/axi4s_clk]
        connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK2] [get_bd_pins fmc_imageon_vita_color/clk200]
        connect_bd_net [get_bd_ports fmc_imageon_iic_rst_n] [get_bd_pins fmc_imageon_vita_color/iic_rst_n]
        connect_bd_net [get_bd_ports vita_clk] [get_bd_pins fmc_imageon_vita_color/vita_clk]

        # Connect AXI_GP0
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins fmc_imageon_vita_color/vita_cam_ctrl]
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins fmc_imageon_vita_color/vita_spi_ctrl]
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins fmc_imageon_vita_color/iic_ctrl]
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_vdma_0/S_AXI_LITE]

        # Connect AXI_HP0
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_vdma_0/M_AXI_S2MM" Clk "/processing_system7_0/FCLK_CLK1 (142 MHz)" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
    }

    # Set address segments
    if { $build_camera } {
        set_property offset 0x43000000 [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_vdma_0_Reg}]
        set_property offset 0x41600000 [get_bd_addr_segs {processing_system7_0/Data/SEG_fmc_imageon_iic_0_Reg}]
        set_property offset 0x43D00000 [get_bd_addr_segs {processing_system7_0/Data/SEG_accelerator_Reg}]
        set_property offset 0x43C30000 [get_bd_addr_segs {processing_system7_0/Data/SEG_onsemi_vita_spi_0_Reg}]
        set_property offset 0x43C00000 [get_bd_addr_segs {processing_system7_0/Data/SEG_onsemi_vita_cam_0_Reg}]
    }
    set_property offset 0x40400000 [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_dma_1_Reg}]
    set_property offset 0x43C10000 [get_bd_addr_segs {processing_system7_0/Data/SEG_accelerator_Reg}]
    include_bd_addr_seg [get_bd_addr_segs -excluded axi_dma_1/Data_SG/SEG_processing_system7_0_ACP_IOP]
    include_bd_addr_seg [get_bd_addr_segs -excluded axi_dma_1/Data_SG/SEG_processing_system7_0_ACP_M_AXI_GP0]

    regenerate_bd_layout

    validate_bd_design
    save_bd_design
    close_bd_design [current_bd_design]
}
# End of create_root_design()


# Hierarchical cell: fmc_imageon_vita_color
proc create_hier_cell_fmc_imageon_vita_color { parentCell nameHier } {
    puts "***** Creating fmc_imageon block..."

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

    # Create cell and set as current instance
    set hier_obj [create_bd_cell -type hier $nameHier]
    current_bd_instance $hier_obj

    # Create pins and interface pins
    create_bd_intf_pin -mode Slave  -vlnv avnet.com:interface:onsemi_vita_cam_rtl:1.0 vita_cam
    create_bd_intf_pin -mode Master -vlnv avnet.com:interface:onsemi_vita_spi_rtl:1.0 vita_spi
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 video_out
    create_bd_intf_pin -mode Slave  -vlnv xilinx.com:interface:aximm_rtl:1.0 vita_cam_ctrl
    create_bd_intf_pin -mode Slave  -vlnv xilinx.com:interface:aximm_rtl:1.0 vita_spi_ctrl
    create_bd_intf_pin -mode Slave  -vlnv xilinx.com:interface:aximm_rtl:1.0 iic_ctrl
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic
    create_bd_pin -dir I -from 0 -to 0 -type rst axi4lite_aresetn
    create_bd_pin -dir O -from 0 -to 0 iic_rst_n
    create_bd_pin -dir I -type clk axi4lite_clk
    create_bd_pin -dir I -type clk axi4s_clk
    create_bd_pin -dir I clk200
    create_bd_pin -dir I vita_clk

    # Create instance: vcc and gnd
    set vcc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vcc ]
    set gnd [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 gnd ]
    set_property -dict [ list CONFIG.CONST_VAL {0}  ] $gnd

    # Create instance: onsemi_vita_cam_0, and set properties
    set onsemi_vita_cam_0 [ create_bd_cell -type ip -vlnv avnet:onsemi_vita:onsemi_vita_cam:3.2 onsemi_vita_cam_0 ]
    set_property -dict [ list CONFIG.C_DEBUG_PORT {false}  ] $onsemi_vita_cam_0

    # Create instance: onsemi_vita_spi_0, and set properties
    set onsemi_vita_spi_0 [ create_bd_cell -type ip -vlnv avnet:onsemi_vita:onsemi_vita_spi:3.2 onsemi_vita_spi_0 ]

    # Create instance: v_vid_in_axi4s_0, and set properties
    set v_vid_in_axi4s_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_vid_in_axi4s:4.0 v_vid_in_axi4s_0 ]
    set_property -dict [ list CONFIG.C_M_AXIS_VIDEO_FORMAT {12} CONFIG.C_HAS_ASYNC_CLK {1} ] $v_vid_in_axi4s_0

    # Create instance: fmc_imageon_iic_0, and set properties
    set fmc_imageon_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 fmc_imageon_iic_0 ]
    set_property -dict [ list CONFIG.IIC_BOARD_INTERFACE {Custom} CONFIG.USE_BOARD_FLOW {true}  ] $fmc_imageon_iic_0

    # Create interface connections
    connect_bd_intf_net [get_bd_intf_pins vita_cam] [get_bd_intf_pins onsemi_vita_cam_0/IO_CAM_IN]
    connect_bd_intf_net [get_bd_intf_pins vita_spi] [get_bd_intf_pins onsemi_vita_spi_0/IO_SPI_OUT]
    connect_bd_intf_net [get_bd_intf_pins video_out] [get_bd_intf_pins v_vid_in_axi4s_0/video_out]
    connect_bd_intf_net [get_bd_intf_pins vita_cam_ctrl] [get_bd_intf_pins onsemi_vita_cam_0/S00_AXI]
    connect_bd_intf_net [get_bd_intf_pins vita_spi_ctrl] [get_bd_intf_pins onsemi_vita_spi_0/S00_AXI]
    connect_bd_intf_net [get_bd_intf_pins iic_ctrl] [get_bd_intf_pins fmc_imageon_iic_0/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins onsemi_vita_cam_0/VID_IO_OUT] [get_bd_intf_pins v_vid_in_axi4s_0/vid_io_in]
    connect_bd_intf_net [get_bd_intf_pins iic] [get_bd_intf_pins fmc_imageon_iic_0/IIC]

    # Create port connections
    connect_bd_net [get_bd_pins axi4lite_clk] [get_bd_pins onsemi_vita_cam_0/s00_axi_aclk] [get_bd_pins onsemi_vita_spi_0/s00_axi_aclk] [get_bd_pins fmc_imageon_iic_0/s_axi_aclk]
    connect_bd_net [get_bd_pins clk200] [get_bd_pins onsemi_vita_cam_0/clk200]
    connect_bd_net [get_bd_pins axi4s_clk] [get_bd_pins v_vid_in_axi4s_0/aclk]
    connect_bd_net [get_bd_pins gnd/dout] [get_bd_pins onsemi_vita_cam_0/reset] [get_bd_pins onsemi_vita_cam_0/trigger1] [get_bd_pins v_vid_in_axi4s_0/vid_io_in_reset]
    connect_bd_net [get_bd_pins axi4lite_aresetn] [get_bd_pins onsemi_vita_cam_0/s00_axi_aresetn] [get_bd_pins onsemi_vita_spi_0/s00_axi_aresetn] [get_bd_pins fmc_imageon_iic_0/s_axi_aresetn]
    connect_bd_net [get_bd_pins onsemi_vita_cam_0/oe] [get_bd_pins onsemi_vita_spi_0/oe] [get_bd_pins v_vid_in_axi4s_0/aclken] [get_bd_pins v_vid_in_axi4s_0/aresetn] [get_bd_pins v_vid_in_axi4s_0/axis_enable] [get_bd_pins v_vid_in_axi4s_0/vid_io_in_ce] [get_bd_pins vcc/dout]
    connect_bd_net [get_bd_pins vita_clk] [get_bd_pins onsemi_vita_cam_0/clk] [get_bd_pins v_vid_in_axi4s_0/vid_io_in_clk]
    connect_bd_net [get_bd_pins iic_rst_n] [get_bd_pins fmc_imageon_iic_0/gpo]

    # Restore current instance
    current_bd_instance $oldCurInst
}

puts "Script loaded.  Create a design using"
puts "  mkproject PROJECT_NAME PROJECT_PATH IP_PATH BUILD_CAMERA"
puts "e.g. mkproject my_proj my_work /nobackup/jingpu/Halide-HLS/apps/hls_examples/demosaic_harris_hls/hls_prj/solution1/impl/ip 1"
