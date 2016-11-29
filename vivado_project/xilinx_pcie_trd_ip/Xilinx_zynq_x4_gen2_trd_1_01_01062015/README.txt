Northwest Logic Delivery for Xilinx_zynq_x4_gen2_trd (Version 1.01) Date: 01/06/2015 09:07
==========================================================================================

Delivery Notes
--------------

Included:

  Northwest Logic AXI DMA Back-End Core
  Northwest Logic Expresso Reference Design
  Northwest Logic PCIe Bus Functional Model
  Northwest Logic PCIe Core Model
  Northwest Logic Expresso Testbench

Xilinx Hard PCIe Core
---------------------
This release uses the Xilinx Hard PCIe Core with an IPI based design flow
targeted for Vivado 2014.2 or later versions.

The Xilinx PCIe hard IP and Northwest Logic DMA IP have been integrated
together to create a single IPI block. This integrated IP repository can be
found in the ./nwl_ip directory. To add this IP to a Vivado project do the
following steps:

  1) Create/Open a Vivado project.
  2) [Optional] The integrated ./nwl_ip directory will be attached to the Vivado
     project as an IP repository in the following step. If desired, copy the
     ./nwl_ip directory to a new location that will be better suited for use
     with your project.
  3) In the Vivado GUI, add the [copied] integrated IP repository to the project
     via the main menu Tools:Project Settings:IP:Add Respository... button.
  4) Now you can start an IPI based Block Design in one of two ways:
     a) Use the Flow Navigator:IP Integrator:Create Block Design button
     b) Use the main menu Flow:Create Block Design selection

At this point you should be able to Add IP using 'nwl' to search for the
block and add to your design. Continue to add other IP as needed for your
design, and wire up the logic. A complete IPI based reference design example
can be built in the Route directory, see 'Route' section below for more
information.

PCIe Reconfiguration:

If you need to reconfigure the PCIe core to change the PCI vendor and other
similar settings, you will need to do this via the Vivado nwl_ip project in
the ./nwl_ip directory. Open up the nwl_ip project in the Vivado GUI and
navigate to the Xilinx PCIe Core IP, called "pcie", in the Sources window.
Right click on PCIe IP and select "Re-customize IP...". Once this is
complete you can go back to your project to build with the new changes.


Reference Design
----------------
A full reference design has been provided which implements the following
resources:
  BAR0   - Registers
  BAR1/2 - Map to the same internal SRAM resource

The reference design provides a highly useful starting point for customer
designs as it implements register and target resources which are common
to most designs.

A full simulation and route of the reference design has been provided to
get customers up and going quickly.


Setting up Xilinx Models for Simulation
--------------------------------------------------------
Xilinx uses SecureIP libraries for the simulation models of the PHY used in
the fpga.

Prior to running the provided reference design simulation, it is necessary
to use the Xilinx Simulation Library Compilation Wizard to compile the
Xilinx SecureIP libraries and to configure your simulator.


Simulation
---------------------
A ModelSim simulation script has been included which you can use to
simulate the reference design. You can modify the ref_design_ts.v file
to change the stimulus of the simulation. To run the simulation:
open ModelSim, change to the tb directory and type:

> do sim.do



Route
-----

A Vivado build script is included to build the reference design for the Xilinx
ZC706 development board with an XC7Z045 FPGA using a 100 MHz reference clock.

To build the FPGA, run the following batch file from the ./route directory
on the command-line:

> build.bat

This command will first create a Vivado project, pull in the integrated IPI block
and reference design IPI block, connect them together and run the place-and-route
on the design. To view the IPI block design:
    - Open the Vivado project ./route/ipi_prj.xpr
    - Expand the top level module in the Sources window
    - Double-click on the IPI block design.


Docs
----
User Guides are available in the doc directory



Support
-------
I look forward to supporting you in your use of the provided cores.
Please contact me at:

    Mark Wagner
    Senior Design Engineer
    Northwest Logic
    1100 NW Compton Drive, Suite 100
    Beaverton, OR 97006
    Email: mwagner@nwlogic.com
    Phone: 503.533.5800 x307



File Descriptions
-----------------

  Xilinx Zynq Hard PCIe Core:

  Northwest Logic DMA Back-End:
     - nwl_ip\rtl\dma_back_end_axi.vp (top-level)

  Northwest Logic Expresso Reference Design:
     - rtl_ref_design\ref_tiny_fifo.v
     - rtl_ref_design\ref_dc_fifo.v
     - rtl_ref_design\ref_inferred_shallow_ram.v
     - rtl_ref_design\ref_dc_fifo_adv_block_ram.v
     - rtl_ref_design\ref_sc_fifo_shallow_ram.v
     - rtl_ref_design\ref_dc_fifo_shallow_ram.v
     - rtl_ref_design\ref_dc_fifo_block_ram.v
     - rtl_ref_design\ref_inferred_block_ram.v
     - rtl_ref_design\register_example_axi.v
     - rtl_ref_design\t_example.v
     - rtl_ref_design\packet_check_axi.v
     - rtl_ref_design\packet_gen_axi.v
     - rtl_ref_design\dma_ref_design_axi.v
     - rtl_ref_design\ref_gray_sync_bus.v
     - rtl_ref_design\ref_bin_to_gray.v
     - rtl_ref_design\sdram_dma_ref_design_axi.v
     - rtl_ref_design\ref_gray_to_bin.v
     - rtl_ref_design\sram_mp_axi.v
     - rtl_ref_design\util_sync_bus.v
     - rtl_ref_design\util_sync_flops.v
     - rtl_ref_design\util_toggle_pos_sync.v

  :
     - models\pcie_bfm_x4.v (top-level)

  Northwest Logic PCIe Core Model:
     - models\bfm_pcie_core_vc1.vp (top-level)

  Northwest Logic Expresso Testbench:
     - tb\report_assertions.v
     - tb\ref_design_ts.v
     - tb\tb_top.v (top-level)
     - tb\direct_dma_bfm.v
     - tb\glbl.v

