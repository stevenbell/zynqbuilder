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
# Nov 26, 2016  Jing Pu
#               - ported to zynq mini module 7z100

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

# IP cores from Zynq PCIE TRD, see http://www.wiki.xilinx.com/ZYNQ_PCIe_TRD_2015.4
set pcie_repo "${myLocation}/xilinx_pcie_trd_ip"

set fmc_constraints "${myLocation}/mmp_7z100_fmc.xdc"
set pcie_constraints "${myLocation}/mmp_7z100_pcie.xdc"
#Python script to extract info about IP component
set get_ip_info "${myLocation}/get_component_info.py"
set top_wrapper_pcie "${myLocation}/mmp_7z100_pcie_fmc_top.v"

# e.g. mkproject my_proj my_work /nobackup/jingpu/Halide-HLS/apps/hls_examples/demosaic_harris_hls/hls_prj/solution1/impl/ip 1 1
proc mkproject { projectName projectPath ip_path build_camera build_pcie} {
    # Repositories where additional IP cores live
    global avnet_repo
    global pcie_repo
    global fmc_constraints
    global pcie_constraints
    global get_ip_info
    global top_wrapper_pcie
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
    puts "  $pcie_repo"
    puts "  $hls_repo"

    # Create the empty project
    create_project $projectName $projectPath -part xc7z100ffg900-2

    # Add board specific constraint file
    set_property board_part em.avnet.com:mini_module_plus_7z100_rev_c:part0:1.0 [current_project]
    if { $build_camera } {
        import_files -norecurse -fileset constrs_1 $fmc_constraints
    }
    if { $build_pcie } {
        import_files -norecurse -fileset constrs_1 $pcie_constraints
    }

    # Add Avnet IP Repository
    puts "***** Updating Vivado to include IP Folder"
    set_property ip_repo_paths "$avnet_repo $hls_repo $pcie_repo" [current_project]
    update_ip_catalog

    # Create an empty block design
    set bd_name $projectName\_bd
    create_bd_design $bd_name

    # Populate the block design
    create_root_design $ip_vlnv $build_camera $build_pcie $axis_input_name $axis_output_name

    # Add Project source files
    puts "***** Adding Source Files to Block Design..."
    if { $build_pcie } {
        if { $build_camera } {
            import_files -fileset sources_1 -norecurse $top_wrapper_pcie
        } else {
            puts "ERROR: no top wrapper available for design with PCIe but no FMC. Please implement it."
            return 1
        }
    } else {
        set bd_path "${projectPath}/${projectName}.srcs/sources_1/bd/${bd_name}"
        make_wrapper -files [get_files "${bd_path}/${bd_name}.bd"] -top
        add_files -norecurse "${bd_path}/hdl/${bd_name}_wrapper.v"
    }

    puts "***** Building Binary..."
    update_compile_order -fileset sources_1
    update_compile_order -fileset sim_1
    launch_runs impl_1 -to_step write_bitstream
}

# Procedure to create entire design
proc create_root_design { ip_vlnv build_camera build_pcie axis_input_name axis_output_name} {
    puts "***** Creating Block Design..."

    set rootCell  [get_bd_cells /]
    current_bd_instance $rootCell

    # Create instance: processing_system7_0, and set properties
    set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]

    # Set the parameters for the system
    # We can't install a proper preset, so we load the settings locally
    source build_preset_7z100.tcl
    set_property -dict $7z100preset $processing_system7_0

    # Set user parameters
    set_property -dict [ list \
                             CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
                             CONFIG.PCW_IRQ_F2P_INTR {1} \
                             CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
                             CONFIG.PCW_USE_S_AXI_ACP {1} \
                             CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {1} \
                             CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
                             CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {0} \
                             CONFIG.PCW_QSPI_GRP_IO1_ENABLE {1} \
                             CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} ] $processing_system7_0

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

    # Add PCIE related components
    if { $build_pcie } {
        # Create ports and interface ports
        create_bd_port -dir I -type rst EXT_SYS_RST
        create_bd_port -dir I EXT_PCIE_REFCLK
        create_bd_port -dir O -from 4 -to 0 EXT_LEDS
        create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 EXT_PCIE

        # Create instance: z7_pcie_dma_top
        create_hier_cell_z7_pcie_dma_top [current_bd_instance .] z7_pcie_dma_top

        # Create instance: TPG_VDMA, and set properties
        set TPG_VDMA [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vdma:6.2 TPG_VDMA ]
        set_property -dict [ list \
                                 CONFIG.c_enable_debug_info_11 {1} \
                                 CONFIG.c_enable_debug_info_15 {1} \
                                 CONFIG.c_include_mm2s {1} \
                                 CONFIG.c_include_mm2s_dre {0} \
                                 CONFIG.c_include_s2mm_dre {0} \
                                 CONFIG.c_include_s2mm_sf {0} \
                                 CONFIG.c_m_axis_mm2s_tdata_width {64} \
                                 CONFIG.c_mm2s_genlock_mode {3} \
                                 CONFIG.c_mm2s_linebuffer_depth {4096} \
                                 CONFIG.c_mm2s_max_burst_length {16} \
                                 CONFIG.c_num_fstores {1} \
                                 CONFIG.c_s2mm_genlock_mode {2} \
                                 CONFIG.c_s2mm_linebuffer_depth {4096} \
                                 CONFIG.c_s2mm_max_burst_length {16} \
                                 CONFIG.c_s2mm_sof_enable {1} \
                                 CONFIG.c_use_mm2s_fsync {1} \
                                ] $TPG_VDMA

        # Create other instances
        create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 led_const_one
        set_property -dict [list CONFIG.CONST_WIDTH {2} CONFIG.CONST_VAL {3}] [get_bd_cells led_const_one]
        create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 led_concat

        # PS add AXI_HP2 port
        set_property -dict [list CONFIG.PCW_USE_S_AXI_HP2 {1}] [get_bd_cells processing_system7_0]

        # Add two more interrupt signal ports
        set_property -dict [list CONFIG.NUM_PORTS {4}] [get_bd_cells interrupt_concat]

        # Create interface connections
        connect_bd_intf_net [get_bd_intf_ports EXT_PCIE] [get_bd_intf_pins z7_pcie_dma_top/pcie_7x_mgt]
        connect_bd_intf_net [get_bd_intf_pins TPG_VDMA/M_AXIS_MM2S] -boundary_type upper [get_bd_intf_pins z7_pcie_dma_top/S_AXIS]
        connect_bd_intf_net [get_bd_intf_pins TPG_VDMA/S_AXIS_S2MM] -boundary_type upper [get_bd_intf_pins z7_pcie_dma_top/axi_str_s2c0_vdma]

        # Create port connections
        connect_bd_net [get_bd_pins TPG_VDMA/mm2s_introut] [get_bd_pins interrupt_concat/In2]
        connect_bd_net [get_bd_pins TPG_VDMA/s2mm_introut] [get_bd_pins interrupt_concat/In3]
        connect_bd_net [get_bd_pins z7_pcie_dma_top/video_clk] [get_bd_pins processing_system7_0/FCLK_CLK1]
        connect_bd_net [get_bd_pins TPG_VDMA/m_axis_mm2s_aclk] [get_bd_pins processing_system7_0/FCLK_CLK1]
        connect_bd_net [get_bd_pins TPG_VDMA/s_axis_s2mm_aclk] [get_bd_pins processing_system7_0/FCLK_CLK1]
        connect_bd_net [get_bd_ports EXT_SYS_RST] [get_bd_pins z7_pcie_dma_top/perst_n]
        connect_bd_net [get_bd_ports EXT_PCIE_REFCLK] [get_bd_pins z7_pcie_dma_top/sys_clk]
        connect_bd_net [get_bd_pins TPG_VDMA/s2mm_fsync_out] [get_bd_pins TPG_VDMA/mm2s_fsync]
        connect_bd_net [get_bd_ports EXT_LEDS] [get_bd_pins led_concat/dout]
        connect_bd_net [get_bd_pins z7_pcie_dma_top/led] [get_bd_pins led_concat/In1]
        connect_bd_net [get_bd_pins led_const_one/dout] [get_bd_pins led_concat/In0]

        # Connect AXI_GP0
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/z7_pcie_dma_top/pcie_7x_0/user_clk_out (250 MHz)" }  [get_bd_intf_pins z7_pcie_dma_top/ps]
        # fix the reset signal
        delete_bd_objs [get_bd_nets rst_pcie_7x_0_250M_peripheral_aresetn] [get_bd_nets z7_pcie_dma_top_user_reset_out] [get_bd_cells rst_pcie_7x_0_250M]
        delete_bd_objs [get_bd_nets z7_pcie_dma_top/pcie_7x_0_user_reset_out]
        delete_bd_objs [get_bd_pins z7_pcie_dma_top/user_reset_out]
        connect_bd_net [get_bd_pins z7_pcie_dma_top/user_reset_n] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] -boundary_type upper
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "/processing_system7_0/FCLK_CLK0 (100 MHz)" }  [get_bd_intf_pins TPG_VDMA/S_AXI_LITE]


        # Connect VDMA AXI MM interfaces to PS AXI_HP2
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/TPG_VDMA/M_AXI_MM2S" Clk "/processing_system7_0/FCLK_CLK1 (142 MHz)" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP2]
        apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_HP2" Clk "/processing_system7_0/FCLK_CLK1 (142 MHz)" }  [get_bd_intf_pins TPG_VDMA/M_AXI_S2MM]

    }

    # Set address segments
    if { $build_pcie } {
        set_property range 64K [get_bd_addr_segs {z7_pcie_dma_top/NWL_AXI_DMA_0/t/SEG_axi_shim_0_reg0}]
        set_property offset 0x40020000 [get_bd_addr_segs {z7_pcie_dma_top/NWL_AXI_DMA_0/t/SEG_axi_shim_0_reg0}]
        set_property offset 0x40020000 [get_bd_addr_segs {processing_system7_0/Data/SEG_user_registers_slave_0_Reg}]
        set_property offset 0x40090000 [get_bd_addr_segs {processing_system7_0/Data/SEG_TPG_VDMA_Reg}]
    }
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

# Hierarchical cell: tuser_monoshot_gen
proc create_hier_cell_tuser_monoshot_gen { parentCell nameHier } {

    if { $parentCell eq "" || $nameHier eq "" } {
        puts "ERROR: create_hier_cell_tuser_monoshot_gen() - Empty argument(s)!"
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

    # Create pins
    create_bd_pin -dir I -from 63 -to 0 s2c0_tuser
    create_bd_pin -dir O tuser_pulse
    create_bd_pin -dir I user_clk

    # Create instance: s2c0_tuser_ff, and set properties
    set s2c0_tuser_ff [ create_bd_cell -type ip -vlnv xilinx.com:user:util_flipflop:1.0 s2c0_tuser_ff ]
    set_property -dict [ list \
                             CONFIG.C_INIT {1} \
                             CONFIG.C_SET_RST_HIGH {0} \
                             CONFIG.C_SIZE {1} \
                             CONFIG.C_USE_ASYNCH {0} \
                             CONFIG.C_USE_CE {0} \
                             CONFIG.C_USE_RST {0} \
                             CONFIG.C_USE_SET {0} \
                            ] $s2c0_tuser_ff

    # Create instance: s2c0_tuser_ff_inv, and set properties
    set s2c0_tuser_ff_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 s2c0_tuser_ff_inv ]
    set_property -dict [ list \
                             CONFIG.C_OPERATION {not} \
                             CONFIG.C_SIZE {1} \
                            ] $s2c0_tuser_ff_inv

    # Create instance: util_reduced_logic_0, and set properties
    set util_reduced_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 util_reduced_logic_0 ]
    set_property -dict [ list \
                             CONFIG.C_SIZE {2} \
                            ] $util_reduced_logic_0

    # Create instance: xlconcat_0, and set properties
    set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

    # Create instance: xlconstant_2, and set properties
    set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                            ] $xlconstant_2

    # Create instance: xlslice_0, and set properties
    set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
    set_property -dict [ list \
                             CONFIG.DIN_FROM {16} \
                             CONFIG.DIN_TO {16} \
                             CONFIG.DIN_WIDTH {64} \
                            ] $xlslice_0

    # Create port connections
    connect_bd_net -net axi_str_s2c0_tuser_16 [get_bd_pins s2c0_tuser_ff/D] [get_bd_pins xlconcat_0/In0] [get_bd_pins xlslice_0/Dout]
    connect_bd_net -net axi_str_s2c0_tuser_r [get_bd_pins s2c0_tuser_ff/Q] [get_bd_pins s2c0_tuser_ff_inv/Op1]
    connect_bd_net -net nwl_backend_dma_x4g2_0_s2c0_tuser [get_bd_pins s2c0_tuser] [get_bd_pins xlslice_0/Din]
    connect_bd_net -net user_clk [get_bd_pins user_clk] [get_bd_pins s2c0_tuser_ff/Clk]
    connect_bd_net -net user_lnk_up_inv1_res [get_bd_pins s2c0_tuser_ff_inv/Res] [get_bd_pins xlconcat_0/In1]
    connect_bd_net -net util_reduced_logic_0_res [get_bd_pins tuser_pulse] [get_bd_pins util_reduced_logic_0/Res]
    connect_bd_net -net xlconcat_0_dout [get_bd_pins util_reduced_logic_0/Op1] [get_bd_pins xlconcat_0/dout]
    connect_bd_net -net xlconstant_2_const [get_bd_pins s2c0_tuser_ff/CE] [get_bd_pins s2c0_tuser_ff/Rst] [get_bd_pins s2c0_tuser_ff/Set] [get_bd_pins xlconstant_2/dout]

    # Restore current instance
    current_bd_instance $oldCurInst
}


# Hierarchical cell: z7_pcie_dma_top
proc create_hier_cell_z7_pcie_dma_top { parentCell nameHier } {
    puts "***** Creating z7_pcie_dma_top block..."

    if { $parentCell eq "" || $nameHier eq "" } {
        puts "ERROR: create_hier_cell_z7_pcie_dma_top() - Empty argument(s)!"
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
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axi_str_s2c0_vdma
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 ps
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt

    # Create pins
    create_bd_pin -dir O -type clk clk_250
    create_bd_pin -dir O -from 0 -to 0 dma_reset_out
    create_bd_pin -dir O -from 2 -to 0 led
    create_bd_pin -dir I -type rst perst_n
    create_bd_pin -dir I -type clk sys_clk
    create_bd_pin -dir O -from 0 -to 0 user_reset_n
    create_bd_pin -dir I video_clk

    # Create instance: DEVICE_SN_101000A35, and set properties
    set DEVICE_SN_101000A35 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 DEVICE_SN_101000A35 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {4311747125} \
                             CONFIG.CONST_WIDTH {64} \
                            ] $DEVICE_SN_101000A35

    # Create instance: NWL_AXI_DMA_0, and set properties
    set NWL_AXI_DMA_0 [ create_bd_cell -type ip -vlnv nwlogic.com:ip:NWL_AXI_DMA:1.01 NWL_AXI_DMA_0 ]

    # Create instance: axi_shim_0, and set properties
    set axi_shim_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axi_shim:1.0 axi_shim_0 ]

    # Create instance: c2s1_areset_n_inv, and set properties
    set c2s1_areset_n_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 c2s1_areset_n_inv ]
    set_property -dict [ list \
                             CONFIG.C_OPERATION {not} \
                             CONFIG.C_SIZE {1} \
                            ] $c2s1_areset_n_inv

    # Create instance: clk_period_4h, and set properties
    set clk_period_4h [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 clk_period_4h ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {4} \
                             CONFIG.CONST_WIDTH {8} \
                            ] $clk_period_4h

    # Create instance: dwidth_converter_c2s_i, and set properties
    set dwidth_converter_c2s_i [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.0 dwidth_converter_c2s_i ]
    set_property -dict [ list \
                             CONFIG.Clock_Type_AXI {Independent_Clock} \
                             CONFIG.Enable_TLAST {true} \
                             CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
                             CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
                             CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
                             CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
                             CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
                             CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
                             CONFIG.HAS_TKEEP {true} \
                             CONFIG.HAS_TSTRB {false} \
                             CONFIG.INTERFACE_TYPE {AXI_STREAM} \
                             CONFIG.Input_Depth_axis {4096} \
                             CONFIG.TDATA_NUM_BYTES {8} \
                             CONFIG.TUSER_WIDTH {1} \
                            ] $dwidth_converter_c2s_i

    # Create instance: dwidth_converter_s2c_i, and set properties
    set dwidth_converter_s2c_i [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.0 dwidth_converter_s2c_i ]
    set_property -dict [ list \
                             CONFIG.Clock_Type_AXI {Independent_Clock} \
                             CONFIG.Enable_TLAST {true} \
                             CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} \
                             CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} \
                             CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Block_RAM} \
                             CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} \
                             CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Block_RAM} \
                             CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} \
                             CONFIG.HAS_TKEEP {true} \
                             CONFIG.HAS_TSTRB {false} \
                             CONFIG.INTERFACE_TYPE {AXI_STREAM} \
                             CONFIG.Input_Depth_axis {4096} \
                             CONFIG.TDATA_NUM_BYTES {8} \
                             CONFIG.TUSER_WIDTH {1} \
                            ] $dwidth_converter_s2c_i

    # Create instance: gen_check_reset, and set properties
    set gen_check_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_reduced_logic:2.0 gen_check_reset ]
    set_property -dict [ list \
                             CONFIG.C_OPERATION {or} \
                             CONFIG.C_SIZE {3} \
                            ] $gen_check_reset

    # Create instance: led_ctrl_0, and set properties
    set led_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:led_ctrl:1.0 led_ctrl_0 ]

    # Create instance: logic_low, and set properties
    set logic_low [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_low ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                            ] $logic_low

    # Create instance: logic_zero, and set properties
    set logic_zero [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic_zero ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                            ] $logic_zero

    # Create instance: pcie_7x_0, and set properties
    set pcie_7x_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_7x:3.2 pcie_7x_0 ]
    set_property -dict [ list \
                             CONFIG.Bar0_64bit {false} \
                             CONFIG.Bar0_Scale {Kilobytes} \
                             CONFIG.Bar0_Size {64} \
                             CONFIG.Bar1_Enabled {true} \
                             CONFIG.Bar1_Scale {Kilobytes} \
                             CONFIG.Bar1_Size {8} \
                             CONFIG.Bar1_Type {Memory} \
                             CONFIG.Bar2_Enabled {true} \
                             CONFIG.Bar2_Scale {Kilobytes} \
                             CONFIG.Bar2_Size {8} \
                             CONFIG.Bar2_Type {Memory} \
                             CONFIG.Base_Class_Menu {Simple_communication_controllers} \
                             CONFIG.Class_Code_Base {07} \
                             CONFIG.Device_ID {7042} \
                             CONFIG.Interface_Width {64_bit} \
                             CONFIG.Link_Speed {5.0_GT/s} \
                             CONFIG.MSIx_PBA_BIR {BAR_0} \
                             CONFIG.MSIx_Table_BIR {BAR_0} \
                             CONFIG.Max_Payload_Size {512_bytes} \
                             CONFIG.Maximum_Link_Width {X4} \
                             CONFIG.PCIe_Debug_Ports {false} \
                             CONFIG.Pcie_fast_config {Tandem_PROM (Refer PG054)} \
                             CONFIG.RBAR_Num {0} \
                             CONFIG.Ref_Clk_Freq {100_MHz} \
                             CONFIG.Sub_Class_Interface_Menu {Other_communications_device} \
                             CONFIG.Trans_Buf_Pipeline {None} \
                             CONFIG.Trgt_Link_Speed {4'h2} \
                             CONFIG.Use_Class_Code_Lookup_Assistant {true} \
                             CONFIG.User_Clk_Freq {250} \
                             #CONFIG.Xlnx_Ref_Board {ZC706} \
                             CONFIG.cfg_mgmt_if {false} \
                             CONFIG.en_ext_clk {false} \
                             CONFIG.mode_selection {Advanced} \
                             CONFIG.pl_interface {false} \
                             CONFIG.rcv_msg_if {false} \
                            ] $pcie_7x_0

    # Create instance: pcie_perf_mon_0, and set properties
    set pcie_perf_mon_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:pcie_perf_mon:1.0 pcie_perf_mon_0 ]

    # Create instance: raw_data_packet_0, and set properties
    set raw_data_packet_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:raw_data_packet:1.0 raw_data_packet_0 ]

    # Create instance: s2c1_areset_n_inv, and set properties
    set s2c1_areset_n_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 s2c1_areset_n_inv ]
    set_property -dict [ list \
                             CONFIG.C_OPERATION {not} \
                             CONFIG.C_SIZE {1} \
                            ] $s2c1_areset_n_inv

    # Create instance: tuser_monoshot_gen
    create_hier_cell_tuser_monoshot_gen $hier_obj tuser_monoshot_gen

    # Create instance: user_lnk_up_int_i, and set properties
    set user_lnk_up_int_i [ create_bd_cell -type ip -vlnv xilinx.com:user:util_flipflop:1.0 user_lnk_up_int_i ]
    set_property -dict [ list \
                             CONFIG.C_INIT {1} \
                             CONFIG.C_SET_RST_HIGH {0} \
                             CONFIG.C_SIZE {1} \
                             CONFIG.C_USE_ASYNCH {0} \
                             CONFIG.C_USE_CE {0} \
                             CONFIG.C_USE_RST {0} \
                             CONFIG.C_USE_SET {0} \
                            ] $user_lnk_up_int_i

    # Create instance: user_lnk_up_inv, and set properties
    set user_lnk_up_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 user_lnk_up_inv ]
    set_property -dict [ list \
                             CONFIG.C_OPERATION {not} \
                             CONFIG.C_SIZE {1} \
                            ] $user_lnk_up_inv

    # Create instance: user_registers_slave_0, and set properties
    set user_registers_slave_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:user_registers_slave:1.0 user_registers_slave_0 ]

    # Create instance: user_reset_i, and set properties
    set user_reset_i [ create_bd_cell -type ip -vlnv xilinx.com:user:util_flipflop:1.0 user_reset_i ]
    set_property -dict [ list \
                             CONFIG.C_INIT {1} \
                             CONFIG.C_SET_RST_HIGH {0} \
                             CONFIG.C_SIZE {1} \
                             CONFIG.C_USE_ASYNCH {0} \
                             CONFIG.C_USE_CE {0} \
                             CONFIG.C_USE_RST {0} \
                             CONFIG.C_USE_SET {0} \
                            ] $user_reset_i

    # Create instance: user_reset_n, and set properties
    set user_reset_n [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 user_reset_n ]
    set_property -dict [ list \
                             CONFIG.C_OPERATION {not} \
                             CONFIG.C_SIZE {1} \
                            ] $user_reset_n

    # Create instance: vcc, and set properties
    set vcc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vcc ]

    # Create instance: xlconcat_0, and set properties
    set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
    set_property -dict [ list \
                             CONFIG.NUM_PORTS {3} \
                            ] $xlconcat_0

    # Create instance: xlconcat_1, and set properties
    set xlconcat_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_1 ]
    set_property -dict [ list \
                             CONFIG.IN0_WIDTH {16} \
                             CONFIG.IN1_WIDTH {16} \
                            ] $xlconcat_1

    # Create instance: xlconstant_0, and set properties
    set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {5} \
                            ] $xlconstant_0

    # Create instance: xlconstant_1, and set properties
    set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {16} \
                            ] $xlconstant_1

    # Create instance: xlconstant_3, and set properties
    set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_3 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {3} \
                            ] $xlconstant_3

    # Create instance: xlconstant_4, and set properties
    set xlconstant_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_4 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {128} \
                            ] $xlconstant_4

    # Create instance: xlconstant_5, and set properties
    set xlconstant_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_5 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {48} \
                            ] $xlconstant_5

    # Create instance: xlconstant_6, and set properties
    set xlconstant_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_6 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {8} \
                            ] $xlconstant_6

    # Create instance: xlconstant_7, and set properties
    set xlconstant_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_7 ]
    set_property -dict [ list \
                             CONFIG.CONST_VAL {0} \
                             CONFIG.CONST_WIDTH {2} \
                            ] $xlconstant_7

    # Create interface connections
    connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins dwidth_converter_c2s_i/S_AXIS]
    connect_bd_intf_net -intf_net NWL_AXI_DMA_0_pcie2_cfg_err [get_bd_intf_pins NWL_AXI_DMA_0/pcie2_cfg_err] [get_bd_intf_pins pcie_7x_0/pcie2_cfg_err]
    connect_bd_intf_net -intf_net NWL_AXI_DMA_0_pcie2_cfg_interrupt [get_bd_intf_pins NWL_AXI_DMA_0/pcie2_cfg_interrupt] [get_bd_intf_pins pcie_7x_0/pcie2_cfg_interrupt]
    connect_bd_intf_net -intf_net NWL_AXI_DMA_0_s2c0 [get_bd_intf_pins NWL_AXI_DMA_0/s2c0] [get_bd_intf_pins dwidth_converter_s2c_i/S_AXIS]
    connect_bd_intf_net -intf_net NWL_AXI_DMA_0_s2c1 [get_bd_intf_pins NWL_AXI_DMA_0/s2c1] [get_bd_intf_pins raw_data_packet_0/axi_str_tx]
    connect_bd_intf_net -intf_net NWL_AXI_DMA_0_t [get_bd_intf_pins NWL_AXI_DMA_0/t] [get_bd_intf_pins axi_shim_0/t]
    connect_bd_intf_net -intf_net axi_shim_0_m_axi [get_bd_intf_pins axi_shim_0/m_axi] [get_bd_intf_pins user_registers_slave_0/s_axi]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_intf_nets axi_shim_0_m_axi]
    connect_bd_intf_net -intf_net dwidth_converter_c2s_i_M_AXIS [get_bd_intf_pins NWL_AXI_DMA_0/c2s0] [get_bd_intf_pins dwidth_converter_c2s_i/M_AXIS]
    connect_bd_intf_net -intf_net dwidth_converter_c2s_new1_m_axis [get_bd_intf_pins axi_str_s2c0_vdma] [get_bd_intf_pins dwidth_converter_s2c_i/M_AXIS]
    connect_bd_intf_net -intf_net nwl_backend_dma_x4g2_0_s_axis_tx [get_bd_intf_pins NWL_AXI_DMA_0/m_axis_tx] [get_bd_intf_pins pcie_7x_0/s_axis_tx]
    connect_bd_intf_net -intf_net [get_bd_intf_nets nwl_backend_dma_x4g2_0_s_axis_tx] [get_bd_intf_pins NWL_AXI_DMA_0/m_axis_tx] [get_bd_intf_pins pcie_perf_mon_0/s_axis_tx]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_intf_nets nwl_backend_dma_x4g2_0_s_axis_tx]
    connect_bd_intf_net -intf_net pcie_7x_0_m_axis_rx [get_bd_intf_pins NWL_AXI_DMA_0/s_axis_rx] [get_bd_intf_pins pcie_7x_0/m_axis_rx]
    connect_bd_intf_net -intf_net [get_bd_intf_nets pcie_7x_0_m_axis_rx] [get_bd_intf_pins pcie_7x_0/m_axis_rx] [get_bd_intf_pins pcie_perf_mon_0/m_axis_rx]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_intf_nets pcie_7x_0_m_axis_rx]
    connect_bd_intf_net -intf_net pcie_7x_0_pcie2_cfg_status [get_bd_intf_pins NWL_AXI_DMA_0/pcie2_cfg_status] [get_bd_intf_pins pcie_7x_0/pcie2_cfg_status]
    connect_bd_intf_net -intf_net pcie_7x_0_pcie_cfg_fc [get_bd_intf_pins pcie_7x_0/pcie_cfg_fc] [get_bd_intf_pins pcie_perf_mon_0/fc]
    connect_bd_intf_net -intf_net [get_bd_intf_nets pcie_7x_0_pcie_cfg_fc] [get_bd_intf_pins NWL_AXI_DMA_0/pcie_cfg_fc] [get_bd_intf_pins pcie_perf_mon_0/fc]
    connect_bd_intf_net -intf_net pcie_perf_mon_0_init_fc [get_bd_intf_pins pcie_perf_mon_0/init_fc] [get_bd_intf_pins user_registers_slave_0/init_fc]
    connect_bd_intf_net -intf_net raw_data_packet_0_axi_str_rx [get_bd_intf_pins NWL_AXI_DMA_0/c2s1] [get_bd_intf_pins raw_data_packet_0/axi_str_rx]
    connect_bd_intf_net -intf_net s_axi_ps_1 [get_bd_intf_pins ps] [get_bd_intf_pins user_registers_slave_0/s_axi_ps]
    connect_bd_intf_net -intf_net pcie_7x_mgt_1 [get_bd_intf_pins pcie_7x_mgt] [get_bd_intf_pins pcie_7x_0/pcie_7x_mgt]

    # Create port connections
    connect_bd_net -net DEVICE_SN_101000A35_dout [get_bd_pins DEVICE_SN_101000A35/dout] [get_bd_pins pcie_7x_0/cfg_dsn]
    connect_bd_net -net NWL_AXI_DMA_0_c2s1_areset_n [get_bd_pins NWL_AXI_DMA_0/c2s1_areset_n] [get_bd_pins c2s1_areset_n_inv/Op1]
    connect_bd_net -net NWL_AXI_DMA_0_s2c0_tuser [get_bd_pins NWL_AXI_DMA_0/s2c0_tuser] [get_bd_pins tuser_monoshot_gen/s2c0_tuser]
    connect_bd_net -net NWL_AXI_DMA_0_s2c1_areset_n [get_bd_pins NWL_AXI_DMA_0/s2c1_areset_n] [get_bd_pins s2c1_areset_n_inv/Op1]
    connect_bd_net -net axi_str_s2c0_tuser_cycle [get_bd_pins dwidth_converter_s2c_i/s_axis_tuser] [get_bd_pins tuser_monoshot_gen/tuser_pulse]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_nets axi_str_s2c0_tuser_cycle]
    connect_bd_net -net clk_1 [get_bd_pins sys_clk] [get_bd_pins pcie_7x_0/sys_clk]
    connect_bd_net -net clk_period_4h_const [get_bd_pins clk_period_4h/dout] [get_bd_pins pcie_perf_mon_0/clk_period_in_ns]
    connect_bd_net -net led_ctrl_0_led [get_bd_pins led] [get_bd_pins led_ctrl_0/led]
    connect_bd_net -net logic_low_dout [get_bd_pins logic_low/dout] [get_bd_pins pcie_7x_0/cfg_err_acs] [get_bd_pins pcie_7x_0/cfg_err_atomic_egress_blocked] [get_bd_pins pcie_7x_0/cfg_err_cor] [get_bd_pins pcie_7x_0/cfg_err_cpl_abort] [get_bd_pins pcie_7x_0/cfg_err_cpl_timeout] [get_bd_pins pcie_7x_0/cfg_err_cpl_unexpect] [get_bd_pins pcie_7x_0/cfg_err_ecrc] [get_bd_pins pcie_7x_0/cfg_err_internal_cor] [get_bd_pins pcie_7x_0/cfg_err_internal_uncor] [get_bd_pins pcie_7x_0/cfg_err_locked] [get_bd_pins pcie_7x_0/cfg_err_malformed] [get_bd_pins pcie_7x_0/cfg_err_mc_blocked] [get_bd_pins pcie_7x_0/cfg_err_norecovery] [get_bd_pins pcie_7x_0/cfg_err_poisoned] [get_bd_pins pcie_7x_0/cfg_err_posted] [get_bd_pins pcie_7x_0/cfg_err_ur] [get_bd_pins pcie_7x_0/cfg_interrupt] [get_bd_pins pcie_7x_0/cfg_interrupt_assert] [get_bd_pins pcie_7x_0/cfg_interrupt_stat] [get_bd_pins pcie_7x_0/cfg_pm_force_state_en] [get_bd_pins pcie_7x_0/cfg_pm_halt_aspm_l0s] [get_bd_pins pcie_7x_0/cfg_pm_halt_aspm_l1] [get_bd_pins pcie_7x_0/cfg_pm_send_pme_to] [get_bd_pins pcie_7x_0/cfg_pm_wake] [get_bd_pins pcie_7x_0/cfg_trn_pending] [get_bd_pins pcie_7x_0/cfg_turnoff_ok] [get_bd_pins pcie_7x_0/startup_clk] [get_bd_pins pcie_7x_0/startup_gsr] [get_bd_pins pcie_7x_0/startup_gts] [get_bd_pins pcie_7x_0/startup_pack] [get_bd_pins pcie_7x_0/startup_usrcclko] [get_bd_pins pcie_7x_0/startup_usrdoneo]
    connect_bd_net -net pcie_7x_0_cfg_lstatus [get_bd_pins NWL_AXI_DMA_0/cfg_lstatus] [get_bd_pins led_ctrl_0/cfg_lstatus] [get_bd_pins pcie_7x_0/cfg_lstatus]
    connect_bd_net -net pcie_7x_0_user_lnk_up [get_bd_pins pcie_7x_0/user_lnk_up] [get_bd_pins user_lnk_up_int_i/D]
    connect_bd_net -net pcie_perf_mon_0_rx_byte_count [get_bd_pins pcie_perf_mon_0/rx_byte_count] [get_bd_pins user_registers_slave_0/rx_pcie_byte_cnt]
    connect_bd_net -net pcie_perf_mon_0_rx_payload_count [get_bd_pins pcie_perf_mon_0/rx_payload_count] [get_bd_pins user_registers_slave_0/rx_pcie_payload_cnt]
    connect_bd_net -net pcie_perf_mon_0_tx_byte_count [get_bd_pins pcie_perf_mon_0/tx_byte_count] [get_bd_pins user_registers_slave_0/tx_pcie_byte_cnt]
    connect_bd_net -net pcie_perf_mon_0_tx_payload_count [get_bd_pins pcie_perf_mon_0/tx_payload_count] [get_bd_pins user_registers_slave_0/tx_pcie_payload_cnt]
    connect_bd_net -net perst_n_1 [get_bd_pins perst_n] [get_bd_pins pcie_7x_0/sys_rst_n]
    connect_bd_net -net raw_data_packet_0_data_mismatch [get_bd_pins raw_data_packet_0/data_mismatch] [get_bd_pins user_registers_slave_0/data_mismatch1]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_nets raw_data_packet_0_data_mismatch]
    connect_bd_net -net s_aclk_1 [get_bd_pins video_clk] [get_bd_pins dwidth_converter_c2s_i/s_aclk] [get_bd_pins dwidth_converter_s2c_i/m_aclk]
    connect_bd_net -net user_clk [get_bd_pins clk_250] [get_bd_pins NWL_AXI_DMA_0/c2s0_aclk] [get_bd_pins NWL_AXI_DMA_0/c2s1_aclk] [get_bd_pins NWL_AXI_DMA_0/s2c0_aclk] [get_bd_pins NWL_AXI_DMA_0/s2c1_aclk] [get_bd_pins NWL_AXI_DMA_0/t_aclk] [get_bd_pins NWL_AXI_DMA_0/user_clk] [get_bd_pins axi_shim_0/user_clk] [get_bd_pins dwidth_converter_c2s_i/m_aclk] [get_bd_pins dwidth_converter_s2c_i/s_aclk] [get_bd_pins led_ctrl_0/user_clk] [get_bd_pins pcie_7x_0/user_clk_out] [get_bd_pins pcie_perf_mon_0/clk] [get_bd_pins raw_data_packet_0/clk] [get_bd_pins tuser_monoshot_gen/user_clk] [get_bd_pins user_lnk_up_int_i/Clk] [get_bd_pins user_registers_slave_0/s_axi_clk] [get_bd_pins user_registers_slave_0/s_axi_clk_ps] [get_bd_pins user_reset_i/Clk]
    connect_bd_net -net user_lnk_up [get_bd_pins NWL_AXI_DMA_0/user_link_up] [get_bd_pins led_ctrl_0/user_lnk_up] [get_bd_pins user_lnk_up_int_i/Q] [get_bd_pins user_lnk_up_inv/Op1]
    connect_bd_net -net user_lnk_up_inv_res [get_bd_pins pcie_perf_mon_0/reset] [get_bd_pins user_lnk_up_inv/Res] [get_bd_pins user_reset_i/D]
    connect_bd_net -net user_registers_slave_0_enable_checker1 [get_bd_pins raw_data_packet_0/enable_checker] [get_bd_pins user_registers_slave_0/enable_checker1]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_nets user_registers_slave_0_enable_checker1]
    connect_bd_net -net user_registers_slave_0_enable_generator1 [get_bd_pins raw_data_packet_0/enable_generator] [get_bd_pins user_registers_slave_0/enable_generator1]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_nets user_registers_slave_0_enable_generator1]
    connect_bd_net -net user_registers_slave_0_enable_loopback1 [get_bd_pins raw_data_packet_0/enable_loopback] [get_bd_pins user_registers_slave_0/enable_loopback1]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_nets user_registers_slave_0_enable_loopback1]
    connect_bd_net -net user_registers_slave_0_pkt_len1 [get_bd_pins raw_data_packet_0/pkt_len] [get_bd_pins user_registers_slave_0/pkt_len1] [get_bd_pins xlconcat_1/In1]
    connect_bd_net -net user_reset [get_bd_pins NWL_AXI_DMA_0/user_reset] [get_bd_pins led_ctrl_0/user_reset] [get_bd_pins user_reset_i/Q] [get_bd_pins user_reset_n/Op1] [get_bd_pins xlconcat_0/In2]
    connect_bd_net -net user_reset_n [get_bd_pins user_reset_n] [get_bd_pins NWL_AXI_DMA_0/t_areset_n] [get_bd_pins dwidth_converter_c2s_i/s_aresetn] [get_bd_pins dwidth_converter_s2c_i/s_aresetn] [get_bd_pins user_registers_slave_0/s_axi_areset_n] [get_bd_pins user_registers_slave_0/s_axi_areset_n_ps] [get_bd_pins user_reset_n/Res]
    connect_bd_net -net util_reduced_logic_0_res [get_bd_pins gen_check_reset/Res] [get_bd_pins raw_data_packet_0/reset]
    connect_bd_net -net util_vector_logic_0_res [get_bd_pins s2c1_areset_n_inv/Res] [get_bd_pins xlconcat_0/In0]
    connect_bd_net -net util_vector_logic_1_res [get_bd_pins c2s1_areset_n_inv/Res] [get_bd_pins xlconcat_0/In1]
    connect_bd_net -net xlconcat_0_dout [get_bd_pins gen_check_reset/Op1] [get_bd_pins xlconcat_0/dout]
    connect_bd_net -net xlconcat_1_dout [get_bd_pins raw_data_packet_0/axi_str_tx_tuser] [get_bd_pins xlconcat_1/dout]
    set_property -dict [ list \
                             HDL_ATTRIBUTE.MARK_DEBUG {true} \
                             HDL_ATTRIBUTE.DEBUG_IN_BD {true} \
                            ] [get_bd_nets xlconcat_1_dout]
    connect_bd_net -net xlconstant_0_const1 [get_bd_pins pcie_7x_0/cfg_aer_interrupt_msgnum] [get_bd_pins pcie_7x_0/cfg_ds_device_number] [get_bd_pins pcie_7x_0/cfg_pciecap_interrupt_msgnum] [get_bd_pins xlconstant_0/dout]
    connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconcat_1/In0] [get_bd_pins xlconstant_1/dout]
    connect_bd_net -net xlconstant_2_const2 [get_bd_pins pcie_7x_0/rx_np_ok] [get_bd_pins pcie_7x_0/rx_np_req] [get_bd_pins pcie_7x_0/startup_keyclearb] [get_bd_pins pcie_7x_0/startup_usrcclkts] [get_bd_pins pcie_7x_0/startup_usrdonets] [get_bd_pins pcie_7x_0/tx_cfg_gnt] [get_bd_pins vcc/dout]
    connect_bd_net -net xlconstant_3_const [get_bd_pins pcie_7x_0/cfg_ds_function_number] [get_bd_pins xlconstant_3/dout]
    connect_bd_net -net xlconstant_4_const [get_bd_pins pcie_7x_0/cfg_err_aer_headerlog] [get_bd_pins xlconstant_4/dout]
    connect_bd_net -net xlconstant_5_dout [get_bd_pins pcie_7x_0/cfg_err_tlp_cpl_header] [get_bd_pins xlconstant_5/dout]
    connect_bd_net -net xlconstant_6_dout [get_bd_pins pcie_7x_0/cfg_ds_bus_number] [get_bd_pins pcie_7x_0/cfg_interrupt_di] [get_bd_pins xlconstant_6/dout]
    connect_bd_net -net xlconstant_7_dout [get_bd_pins pcie_7x_0/cfg_pm_force_state] [get_bd_pins xlconstant_7/dout]
    connect_bd_net -net zero [get_bd_pins dma_reset_out] [get_bd_pins NWL_AXI_DMA_0/user_interrupt] [get_bd_pins dwidth_converter_c2s_i/s_axis_tuser] [get_bd_pins logic_zero/dout] [get_bd_pins user_lnk_up_int_i/CE] [get_bd_pins user_lnk_up_int_i/Rst] [get_bd_pins user_lnk_up_int_i/Set] [get_bd_pins user_reset_i/CE] [get_bd_pins user_reset_i/Rst] [get_bd_pins user_reset_i/Set]

    # Perform GUI Layout
    regenerate_bd_layout -hierarchy [get_bd_cells /z7_pcie_dma_top] -layout_string {
        guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port video_clk -pg 1 -y 1830 -defaultsOSRD
preplace port clk_250 -pg 1 -y 1530 -defaultsOSRD
preplace port ps -pg 1 -y 1410 -defaultsOSRD
preplace port perst_n -pg 1 -y 1290 -defaultsOSRD
preplace port sys_clk -pg 1 -y 1270 -defaultsOSRD
preplace port S_AXIS -pg 1 -y 1540 -defaultsOSRD
preplace port axi_str_s2c0_vdma -pg 1 -y 1440 -defaultsOSRD
preplace portBus txn -pg 1 -y 560 -defaultsOSRD
preplace portBus txp -pg 1 -y 580 -defaultsOSRD
preplace portBus led -pg 1 -y 1970 -defaultsOSRD
preplace portBus dma_reset_out -pg 1 -y 1270 -defaultsOSRD
preplace portBus user_reset_n -pg 1 -y 1550 -defaultsOSRD
preplace portBus rxn -pg 1 -y 20 -defaultsOSRD
preplace portBus rxp -pg 1 -y 40 -defaultsOSRD
preplace inst user_registers_slave_0 -pg 1 -lvl 9 -y 1560 -defaultsOSRD
preplace inst logic_zero -pg 1 -lvl 11 -y 1320 -defaultsOSRD
preplace inst pcie_7x_0 -pg 1 -lvl 6 -y 690 -defaultsOSRD
preplace inst vcc -pg 1 -lvl 5 -y 430 -defaultsOSRD
preplace inst user_lnk_up_int_i -pg 1 -lvl 1 -y 1640 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 5 -y 510 -defaultsOSRD
preplace inst pcie_perf_mon_0 -pg 1 -lvl 8 -y 1510 -defaultsOSRD
preplace inst NWL_AXI_DMA_0 -pg 1 -lvl 7 -y 1650 -defaultsOSRD
preplace inst xlconstant_1 -pg 1 -lvl 4 -y 1890 -defaultsOSRD
preplace inst s2c1_areset_n_inv -pg 1 -lvl 3 -y 1960 -defaultsOSRD
preplace inst raw_data_packet_0 -pg 1 -lvl 6 -y 2140 -defaultsOSRD
preplace inst dwidth_converter_c2s_i -pg 1 -lvl 6 -y 1580 -defaultsOSRD
preplace inst xlconstant_3 -pg 1 -lvl 5 -y 970 -defaultsOSRD
preplace inst xlconcat_0 -pg 1 -lvl 4 -y 2020 -defaultsOSRD
preplace inst user_reset_i -pg 1 -lvl 3 -y 1710 -defaultsOSRD
preplace inst led_ctrl_0 -pg 1 -lvl 11 -y 1970 -defaultsOSRD
preplace inst axi_shim_0 -pg 1 -lvl 8 -y 1680 -defaultsOSRD
preplace inst xlconstant_4 -pg 1 -lvl 5 -y 590 -defaultsOSRD
preplace inst xlconcat_1 -pg 1 -lvl 5 -y 1900 -defaultsOSRD
preplace inst logic_low -pg 1 -lvl 5 -y 350 -defaultsOSRD
preplace inst gen_check_reset -pg 1 -lvl 5 -y 2020 -defaultsOSRD
preplace inst clk_period_4h -pg 1 -lvl 7 -y 1880 -defaultsOSRD
preplace inst xlconstant_5 -pg 1 -lvl 5 -y 670 -defaultsOSRD
preplace inst xlconstant_6 -pg 1 -lvl 5 -y 890 -defaultsOSRD
preplace inst c2s1_areset_n_inv -pg 1 -lvl 3 -y 2040 -defaultsOSRD
preplace inst xlconstant_7 -pg 1 -lvl 5 -y 1050 -defaultsOSRD
preplace inst user_lnk_up_inv -pg 1 -lvl 2 -y 1780 -defaultsOSRD
preplace inst user_reset_n -pg 1 -lvl 10 -y 1910 -defaultsOSRD
preplace inst dwidth_converter_s2c_i -pg 1 -lvl 11 -y 1440 -defaultsOSRD
preplace inst tuser_monoshot_gen -pg 1 -lvl 10 -y 1790 -defaultsOSRD
preplace inst DEVICE_SN_101000A35 -pg 1 -lvl 7 -y 1240 -defaultsOSRD
preplace netloc dwidth_converter_c2s_new1_m_axis 1 11 1 NJ
preplace netloc Conn1 1 0 6 NJ 1520 NJ 1520 NJ 1520 NJ 1520 NJ 1520 NJ
preplace netloc NWL_AXI_DMA_0_t 1 7 1 1940
preplace netloc NWL_AXI_DMA_0_s2c1 1 5 3 950 1350 NJ 1350 1930
preplace netloc xlconstant_5_dout 1 5 1 NJ
preplace netloc xlconstant_1_dout 1 4 1 NJ
preplace netloc axi_str_s2c0_tuser_cycle 1 10 1 3410
preplace netloc pcie_7x_0_pcie2_cfg_status 1 6 1 1520
preplace netloc xlconstant_3_const 1 5 1 890
preplace netloc rxp_1 1 0 7 NJ 30 NJ 30 NJ 30 NJ 30 NJ 30 NJ 30 1440
preplace netloc xlconstant_0_const1 1 5 1 930
preplace netloc raw_data_packet_0_data_mismatch 1 6 3 NJ 1440 NJ 1620 2580
preplace netloc led_ctrl_0_led 1 11 1 NJ
preplace netloc NWL_AXI_DMA_0_pcie2_cfg_err 1 5 3 960 20 NJ 20 1950
preplace netloc s_axi_ps_1 1 0 9 NJ 1370 NJ 1370 NJ 1370 NJ 1370 NJ 1370 NJ 1370 NJ 1370 NJ 1370 NJ
preplace netloc raw_data_packet_0_axi_str_rx 1 6 1 1550
preplace netloc DEVICE_SN_101000A35_dout 1 5 3 940 0 NJ 0 2030
preplace netloc rxn_1 1 0 7 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 NJ 10 1450
preplace netloc user_reset 1 3 8 490 1790 NJ 1790 NJ 1790 1560 1950 NJ 1950 NJ 1950 3130 1960 NJ
preplace netloc pcie_perf_mon_0_init_fc 1 8 1 2590
preplace netloc pcie_7x_0_pcie_cfg_fc 1 6 2 1470 1430 NJ
preplace netloc xlconcat_1_dout 1 5 1 920
preplace netloc util_reduced_logic_0_res 1 5 1 910
preplace netloc user_registers_slave_0_pkt_len1 1 4 6 690 1970 890 1990 NJ 1990 NJ 1990 NJ 1990 3090
preplace netloc NWL_AXI_DMA_0_s2c0_tuser 1 7 3 NJ 1380 NJ 1380 3130
preplace netloc NWL_AXI_DMA_0_c2s1_areset_n 1 2 6 290 2090 NJ 2090 NJ 2090 NJ 2000 NJ 2000 1950
preplace netloc xlconstant_7_dout 1 5 1 NJ
preplace netloc user_registers_slave_0_enable_generator1 1 5 5 970 1980 NJ 1980 NJ 1980 NJ 1980 3100
preplace netloc s_aclk_1 1 0 11 NJ 1530 NJ 1530 NJ 1530 NJ 1530 NJ 1530 940 1490 NJ 1390 NJ 1390 NJ 1390 NJ 1390 3400
preplace netloc pcie_7x_1_pci_exp_txn 1 6 6 NJ 560 NJ 560 NJ 560 NJ 560 NJ 560 NJ
preplace netloc zero 1 0 12 -60 1550 NJ 1550 280 1580 NJ 1580 NJ 1580 900 1680 1500 1190 N 1190 NJ 1190 NJ 1190 NJ 1190 3750
preplace netloc xlconstant_2_const2 1 5 1 900
preplace netloc user_clk 1 0 12 -70 1540 NJ 1540 300 1570 NJ 1570 NJ 1570 930 1690 1450 1380 1990 1610 2620 1400 3120 1460 3430 1530 NJ
preplace netloc logic_low_dout 1 5 1 910
preplace netloc NWL_AXI_DMA_0_s2c1_areset_n 1 2 6 290 1910 NJ 1940 NJ 1960 NJ 1960 NJ 1960 1930
preplace netloc xlconcat_0_dout 1 4 1 NJ
preplace netloc clk_period_4h_const 1 7 1 NJ
preplace netloc clk_1 1 0 6 NJ 1270 NJ 1270 NJ 1270 NJ 1270 NJ 1270 N
preplace netloc xlconstant_6_dout 1 5 1 920
preplace netloc pcie_7x_1_pci_exp_txp 1 6 6 NJ 580 NJ 580 NJ 580 NJ 580 NJ 580 NJ
preplace netloc perst_n_1 1 0 6 NJ 1290 NJ 1290 NJ 1290 NJ 1290 NJ 1290 N
preplace netloc pcie_7x_0_m_axis_rx 1 6 2 1530 1450 NJ
preplace netloc pcie_7x_0_user_lnk_up 1 0 7 -80 1360 NJ 1360 NJ 1360 NJ 1360 NJ 1360 NJ 1360 1440
preplace netloc xlconstant_4_const 1 5 1 890
preplace netloc util_vector_logic_0_res 1 3 1 NJ
preplace netloc user_registers_slave_0_enable_loopback1 1 5 5 940 1940 NJ 1940 NJ 1940 NJ 1940 3080
preplace netloc user_lnk_up_inv_res 1 2 6 290 1420 NJ 1420 NJ 1420 NJ 1420 NJ 1420 2030
preplace netloc pcie_perf_mon_0_tx_payload_count 1 8 1 2610
preplace netloc pcie_7x_0_cfg_lstatus 1 6 5 1490 1360 NJ 1360 NJ 1360 NJ 1360 NJ
preplace netloc NWL_AXI_DMA_0_pcie2_cfg_interrupt 1 5 3 970 40 NJ 40 1940
preplace netloc dwidth_converter_c2s_i_M_AXIS 1 6 1 N
preplace netloc user_reset_n 1 5 7 970 1780 1510 1930 NJ 1850 2640 1850 NJ 1850 3420 1550 NJ
preplace netloc pcie_perf_mon_0_tx_byte_count 1 8 1 2580
preplace netloc pcie_perf_mon_0_rx_payload_count 1 8 1 2590
preplace netloc pcie_perf_mon_0_rx_byte_count 1 8 1 2600
preplace netloc nwl_backend_dma_x4g2_0_s_axis_tx 1 5 3 950 1340 NJ 1330 1960
preplace netloc util_vector_logic_1_res 1 3 1 NJ
preplace netloc user_registers_slave_0_enable_checker1 1 5 5 960 1970 NJ 1970 NJ 1960 NJ 1960 3110
preplace netloc user_lnk_up 1 1 10 100 1620 NJ 1620 NJ 1620 NJ 1620 NJ 1670 1510 1400 NJ 1400 NJ 1370 NJ 1370 NJ
preplace netloc axi_shim_0_m_axi 1 8 1 2630
preplace netloc NWL_AXI_DMA_0_s2c0 1 7 4 1970 1350 NJ 1350 NJ 1350 NJ
levelinfo -pg 1 -120 20 190 390 590 790 1230 1770 2410 2910 3260 3590 3770 -top -10 -bot 2290
",
    }

    # Restore current instance
    current_bd_instance $oldCurInst
}





puts "Script loaded.  Create a design using"
puts "  mkproject PROJECT_NAME PROJECT_PATH IP_PATH BUILD_CAMERA BUILD_PCIE"
puts "e.g. mkproject my_proj my_work /nobackup/jingpu/Halide-HLS/apps/hls_examples/demosaic_harris_hls/hls_prj/solution1/impl/ip 1 1"

#mkproject mmp_fmc_proj mmp_fmc_dir /nobackup/jingpu/Halide-HLS/apps/hls_examples/demosaic_harris_hls/hls_prj/solution1/impl/ip 1 0
#mkproject mmp_fmc_pcie_proj mmp_fmc_pcie_dir /nobackup/jingpu/Halide-HLS/apps/hls_examples/demosaic_harris_hls/hls_prj/solution1/impl/ip 1 1
