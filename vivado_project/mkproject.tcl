# mkproject.tcl
# Create a complete Vivado project which integrates a core from HLS
#
# Steven Bell <sebell@stanford.edu>, based on generated script from Vivado
# 11 December 2015

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

puts "Script loaded.  Create a design using"
puts "  mkproject PROJECTNAME PATH"


# mkproject myProj work
proc mkproject { projectName projectPath } {
    set accelerator_out_stream_name p_hw_output_2_stencil_stream

    # Repositories where additional IP cores live
    set hls_repo "/nobackup/jingpu/Halide-HLS/apps/hls_examples/stereo_hls/hls_proj/solution2"

    puts "Creating project $projectName in $projectPath"
    puts "Using ip core directories:"
    puts "  $hls_repo"

    # Create the empty project
    create_project $projectName $projectPath -part xc7z020clg484-1
    set_property BOARD_PART xilinx.com:zc702:part0:1.1 [current_project]

    # Set IP repo paths
    set_property ip_repo_paths "$hls_repo" [current_project]
    update_ip_catalog

    # Create an empty block design
    set design_name $projectName\_bd
    set bd_path [create_bd_design $design_name]
    puts "block design path: $bd_path"

    # Populate the block design
    create_root_design ""

    # All done with the block diagram, close it now
    close_bd_design [get_bd_designs $design_name]

    # Create the HDL wrapper for the design
    # TODO: get this filename from the create_bd_design command
    set bd_path ${projectName}_bd
    make_wrapper -files [get_files ${projectPath}/${projectName}.srcs/sources_1/bd/$bd_path/${bd_path}.bd] -top

    add_files -norecurse ${projectPath}/${projectName}.srcs/sources_1/bd/$bd_path/hdl/${bd_path}_wrapper.v
    update_compile_order -fileset sources_1
    update_compile_order -fileset sim_1


    launch_runs synth_1 -jobs 4
    wait_on_run synth_1

    open_run synth_1 -name synth_1
    create_debug_core u_ila_0 ila
    set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
    set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
    set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
    set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
    set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
    set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
    set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
    set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
    set_property port_width 1 [get_debug_ports u_ila_0/clk]
    connect_debug_port u_ila_0/clk [get_nets [list myProj_bd_i/processing_system7_0/inst/FCLK_CLK0 ]]

    set_property port_width 8 [get_debug_ports u_ila_0/probe0]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
    connect_debug_port u_ila_0/probe0 [get_nets myProj_bd_i/axi_dma_2_M_AXIS_MM2S_TDATA*]
    create_debug_port u_ila_0 probe
    set_property port_width 8 [get_debug_ports u_ila_0/probe1]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
    connect_debug_port u_ila_0/probe1 [get_nets myProj_bd_i/axi_dma_1_M_AXIS_MM2S_TDATA*]
    create_debug_port u_ila_0 probe
    set_property port_width 8 [get_debug_ports u_ila_0/probe2]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
    connect_debug_port u_ila_0/probe2 [get_nets myProj_bd_i/accelerator_${accelerator_out_stream_name}_TDATA*]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe3]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
    connect_debug_port u_ila_0/probe3 [get_nets [list myProj_bd_i/accelerator_${accelerator_out_stream_name}_TLAST ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe4]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
    connect_debug_port u_ila_0/probe4 [get_nets [list myProj_bd_i/accelerator_${accelerator_out_stream_name}_TREADY ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe5]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
    connect_debug_port u_ila_0/probe5 [get_nets [list myProj_bd_i/accelerator_${accelerator_out_stream_name}_TVALID ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe6]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
    connect_debug_port u_ila_0/probe6 [get_nets [list myProj_bd_i/axi_dma_1_M_AXIS_MM2S_TLAST ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe7]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
    connect_debug_port u_ila_0/probe7 [get_nets [list myProj_bd_i/axi_dma_1_M_AXIS_MM2S_TREADY ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe8]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
    connect_debug_port u_ila_0/probe8 [get_nets [list myProj_bd_i/axi_dma_1_M_AXIS_MM2S_TVALID ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe9]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
    connect_debug_port u_ila_0/probe9 [get_nets [list myProj_bd_i/axi_dma_2_M_AXIS_MM2S_TLAST ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe10]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
    connect_debug_port u_ila_0/probe10 [get_nets [list myProj_bd_i/axi_dma_2_M_AXIS_MM2S_TREADY ]]
    create_debug_port u_ila_0 probe
    set_property port_width 1 [get_debug_ports u_ila_0/probe11]
    set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
    connect_debug_port u_ila_0/probe11 [get_nets [list myProj_bd_i/axi_dma_2_M_AXIS_MM2S_TVALID ]]
    save_constraints -force

    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    close_design
    open_run impl_1
}

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

    # TODO expose the following variables to the scipt interface
    set ip_vlnv xilinx.com:hls:p_hls_target_hw_output_2_stencil_stream
    set accelerator_axilite_name s_axi_axilite_hls_target_hw_output_2_stencil_stream
    set accelerator_out_stream_name p_hw_output_2_stencil_stream
    set accelerator_in0_stream_name p_interpolated_3_stencil_update_stream
    set accelerator_in1_stream_name p_interpolated_4_stencil_update_stream

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

    # Create instance: processing_system7_0, and set properties
    set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
    set_property -dict [ list \
                             #CONFIG.PCW_EN_CLK1_PORT {1} \
                             #CONFIG.PCW_EN_CLK2_PORT {1} \
                             CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} \
                             #CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} \
                             #CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} \
                             CONFIG.PCW_IRQ_F2P_INTR {1} \
                             CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
                             CONFIG.PCW_USE_S_AXI_HP0 {1} \
                             #CONFIG.PCW_USE_S_AXI_HP1 {1} \
                             CONFIG.preset {ZC702*}  ] $processing_system7_0
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" } $processing_system7_0

    # Create instance: accelerator, and set properties
    set accelerator [ create_bd_cell -type ip -vlnv $ip_vlnv accelerator ]

    # Create instance: axi_dma_1, and set properties
    set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_1 ]
    set_property -dict [ list \
                             CONFIG.c_m_axis_mm2s_tdata_width {8} \
                             CONFIG.c_sg_include_stscntrl_strm {0}  ] $axi_dma_1


    set axi_dma_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_2 ]
    set_property -dict [list CONFIG.c_sg_include_stscntrl_strm {0} \
                            CONFIG.c_m_axis_mm2s_tdata_width {8} \
                            CONFIG.c_include_s2mm {0}] $axi_dma_2

    # Create instance: interrupt_concat, and set properties
    set interrupt_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 interrupt_concat ]
    set_property -dict [list CONFIG.NUM_PORTS {3}] $interrupt_concat

    # Connect AXI interfaces
    startgroup
    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_dma_1/M_AXI_SG" Clk "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins accelerator/${accelerator_axilite_name}]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_1/S_AXI_LITE]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_2/S_AXI_LITE]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_HP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_1/M_AXI_MM2S]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_HP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_1/M_AXI_S2MM]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_HP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_2/M_AXI_SG]

    apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Slave "/processing_system7_0/S_AXI_HP0" Clk "Auto" }  [get_bd_intf_pins axi_dma_2/M_AXI_MM2S]
    endgroup

    # Connect AXIS interfaces
    connect_bd_intf_net [get_bd_intf_pins axi_dma_1/M_AXIS_MM2S] [get_bd_intf_pins accelerator/${accelerator_in0_stream_name}]
    connect_bd_intf_net [get_bd_intf_pins axi_dma_2/M_AXIS_MM2S] [get_bd_intf_pins accelerator/${accelerator_in1_stream_name}]
    connect_bd_intf_net [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM] [get_bd_intf_pins accelerator/${accelerator_out_stream_name}]

    # Mark_DEBUG AXIS interfaces
    set_property HDL_ATTRIBUTE.MARK_DEBUG true [get_bd_intf_nets axi_dma_1_M_AXIS_MM2S]
    set_property HDL_ATTRIBUTE.MARK_DEBUG true [get_bd_intf_nets axi_dma_2_M_AXIS_MM2S]
    set_property HDL_ATTRIBUTE.MARK_DEBUG true [get_bd_intf_nets accelerator_${accelerator_out_stream_name}]

    # Connect interrupt signals
    connect_bd_net [get_bd_pins axi_dma_1/mm2s_introut] [get_bd_pins interrupt_concat/In0]
    connect_bd_net [get_bd_pins axi_dma_1/s2mm_introut] [get_bd_pins interrupt_concat/In1]
    connect_bd_net [get_bd_pins axi_dma_2/mm2s_introut] [get_bd_pins interrupt_concat/In2]
    connect_bd_net [get_bd_pins interrupt_concat/dout] [get_bd_pins processing_system7_0/IRQ_F2P]


    # Create address segments
    #create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_SG] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
    #create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_MM2S] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
    #create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM] SEG_processing_system7_0_HP1_DDR_LOWOCM
    #create_bd_addr_seg -range 0x40000000 -offset 0x0 [get_bd_addr_spaces axi_vdma_0/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] SEG_processing_system7_0_HP0_DDR_LOWOCM
    #create_bd_addr_seg -range 0x10000 -offset 0x40400000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] SEG_axi_dma_1_Reg
    #create_bd_addr_seg -range 0x10000 -offset 0x43000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_vdma_0/S_AXI_LITE/Reg] SEG_axi_vdma_0_Reg


    regenerate_bd_layout

    # Restore current instance
    current_bd_instance $oldCurInst

    validate_bd_design
    save_bd_design
}
# End of create_root_design()


