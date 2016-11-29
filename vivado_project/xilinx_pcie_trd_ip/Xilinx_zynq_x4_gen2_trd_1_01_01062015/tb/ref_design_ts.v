// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                Copyright 2011 by Northwest Logic, Inc.
//
//  All rights reserved.  No part of this source code may be reproduced or
//  transmitted in any form or by any means, electronic or mechanical,
//  including photocopying, recording, or any information storage and
//  retrieval system, without permission in writing from Northwest Logic, Inc.
//
//  Further, no use of this source code is permitted in any form or means
//  without a valid, written license agreement with Northwest Logic, Inc.
//
//                         Northwest Logic, Inc.
//                  1100 NW Compton Drive, Suite 100
//                      Beaverton, OR 97006, USA
//
//                       Ph.  +1 503 533 5800
//                       Fax. +1 503 533 5900
//                          www.nwlogic.com
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -------------
// -- Defines --
// -------------

// -----------------------------------------------------
// Defines for Accessing Modules in the Design Hierarchy

// Top level entity paths
`define TOP_PATH                        tb_top
`define DUT_PATH                        `TOP_PATH.dut
`define DUT_PHY_PATH                    `DUT_PATH.pipe_if
`define RP0_PATH                        `TOP_PATH.pcie_bfm
`define BFM_PHY_PATH                    `RP0_PATH.pcie_model.pipe_if

`ifdef BFM_ASSERTIONS
`define ROOT_ASSERT_PATH                 `TOP_PATH.root_assert
`endif

// DMA BE Master Interface and Direct DMA Interface BFM Paths

`define DUT_COMPLETE_CORE               `DUT_PATH.xil_pcie_wrapper
`define DUT_COMPLETE_CORE_P_TX          `DUT_COMPLETE_CORE
`define DUT_DMA                         `DUT_COMPLETE_CORE.dma_back_end_axi


`define DUT_CLK                         `DUT_COMPLETE_CORE.user_clk

`define BFM_MODEL                       `RP0_PATH.pcie_model
`define BFM_PCIE_CORE                   `RP0_PATH.pcie_model.pcie_core_vc1
`define BFM_PCIE_USER_IF                `RP0_PATH.pcie_model.pcie_core_vc1.pcie_user_if_for_vc0
`define BFM_TL_BYPASS                   `RP0_PATH.pcie_model.pcie_core_vc1.pcie_engine_vc1.tl_bypass
`define BFM_RX_SYM_DETECT               `BFM_TL_BYPASS.pl_lanes_n.pl_rx_swizzle.sym_detect
`define BFM_DL_TLP_TX_CRC_3             `BFM_TL_BYPASS.dl_tx_main.dl_tlp_tx_crc_3
`define BFM_CLK                         `BFM_PCIE_CORE.clk
`define BFM_MGMT_PCIE_STATUS            `BFM_PCIE_CORE.mgmt_pcie_status

`define RP_TL_BYPASS                    `BFM_TL_BYPASS
`define EP_TL_BYPASS                    `DUT_EXPRESSO_TL_BYPASS
`define RP_MGMT_PCIE_STATUS             `BFM_MGMT_PCIE_STATUS
`define EP_CORE                         `DUT_EXPRESSO_CORE
`define RP_CORE                         `BFM_PCIE_CORE
`define RP_CLK                          `BFM_CLK
`define EP_CLK                          `DUT_CLK
`define RP_PHY_PATH                     `BFM_PHY_PATH
`define EP_PHY_PATH                     `DUT_PHY_PATH

`define AXI_SLAVE                       `DUT_PATH.sdram_dma_ref_design_pkt.t_example.the_axi_slave

// -------------------------------------------------------
// Defines for Accessing Root Port BFM Tasks and Functions

// Log
`define DISPLAY_HDR                     `RP0_PATH.display_hdr
`define DISPLAY_SHORT_HDR               `RP0_PATH.display_short_hdr

// Error Logging and Reporting
`define INC_ERRORS                      `RP0_PATH.inc_errors
`define REPORT_STATUS                   `RP0_PATH.report_status

// Memory Initialization
`define INIT_BFM_MEM                    `RP0_PATH.init_bfm_mem
`define INIT_STATUS_MEM                 `RP0_PATH.init_status_mem

// General Purpose TLP Transmission
`define XFER                            `RP0_PATH.xfer
`define XFERB                           `RP0_PATH.xferb

// Configuration Request TLP Transmission
 `define CFG_RD_BDF                    `RP0_PATH.cfg_rd_bdf
 `define CFG_RD_BDF_NULL               `RP0_PATH.cfg_rd_bdf_null

 `define CFG_WR_BDF                     `RP0_PATH.cfg_wr_bdf
 `define CFG_WR_BDF_NULL                `RP0_PATH.cfg_wr_bdf_null

// Memory Request TLP Transmission
`define MEM_WRITE_DWORD_ADDR32          `RP0_PATH.mem_write_dword_addr32
`define MEM_READ_DWORD_ADDR32           `RP0_PATH.mem_read_dword_addr32
`define MEM_WRITE_DWORD                 `RP0_PATH.mem_write_dword
`define MEM_WRITE_DWORD_POISON          `RP0_PATH.mem_write_dword_poison
`define MEM_WRITE_DWORD_ECRC            `RP0_PATH.mem_write_dword_ecrc
`define MEM_READ_DWORD                  `RP0_PATH.mem_read_dword
`define MEM_READ_DWORD_RO               `RP0_PATH.mem_read_dword_ro
`define MEM_READ_DWORD_ATTR             `RP0_PATH.mem_read_dword_attr
`define MEM_READ_DWORD_POISON           `RP0_PATH.mem_read_dword_poison
`define MEM_READ_DWORD_TIMEOUT          `RP0_PATH.mem_read_dword_timeout
`define MEM_READ_DWORD_FAST             `RP0_PATH.mem_read_dword_fast
`define MEM_READ_DWORD_FAST_ATTR        `RP0_PATH.mem_read_dword_fast_attr
`define MEM_READ_DWORD_RO_FAST          `RP0_PATH.mem_read_dword_ro_fast
`define MEM_READ_DWORD_FAST_WAIT        `RP0_PATH.mem_read_dword_fast_wait
`define MEM_WRITE_BURST                 `RP0_PATH.mem_write_burst
`define MEM_WRITE_BURST_PATTERN         `RP0_PATH.mem_write_burst_pattern
`define MEM_WRITE_BURST_PATTERN_ECRC    `RP0_PATH.mem_write_burst_pattern_ecrc
`define MEM_READ_BURST                  `RP0_PATH.mem_read_burst
`define MEM_READ_BURST_FAST             `RP0_PATH.mem_read_burst_fast
`define MEM_READ_BURST_PATTERN          `RP0_PATH.mem_read_burst_pattern
`define MEM_READ_BURST_PATTERN_OPT_FAST `RP0_PATH.mem_read_burst_pattern_option_fast
`define MEM_READ_BURST_TIMEOUT          `RP0_PATH.mem_read_burst_timeout

// I/O Request TLP Transmission
`define IO_WRITE_DWORD                  `RP0_PATH.io_write_dword
`define IO_READ_DWORD                   `RP0_PATH.io_read_dword

// Message TLP Transmission
`define TRANSMIT_MSG                    `RP0_PATH.transmit_msg

// MCDMA DMA Tasks
`define MCDMA_INIT_QUEUE                `RP0_PATH.mcdma_init_queue
`define MCDMA_INIT_CHECK_QUEUE          `RP0_PATH.mcdma_init_check_queue
`define MCDMA_DMA_ENABLE                `RP0_PATH.mcdma_dma_enable
`define MCDMA_RESET_DMA                 `RP0_PATH.mcdma_reset_dma
`define MCDMA_PCIE_INT_EN               `RP0_PATH.mcdma_pcie_int_en
`define MCDMA_AXI_INT_EN                `RP0_PATH.mcdma_axi_int_en
`define MCDMA_PCIE_INT_CLR              `RP0_PATH.mcdma_pcie_int_clr
`define MCDMA_AXI_INT_CLR               `RP0_PATH.mcdma_axi_int_clr
`define MCDMA_PCIE_ERR_CHECK            `RP0_PATH.mcdma_pcie_err_check
`define MCDMA_AXI_ERR_CHECK             `RP0_PATH.mcdma_axi_err_check
`define MCDMA_PEND_XFER                 `RP0_PATH.mcdma_pend_xfer
`define MCDMA_QUEUE_CHECK_DST_POP       `RP0_PATH.mcdma_queue_check_dst_pop
`define MCDMA_PROCESS_DMA_COMPLETIONS   `RP0_PATH.mcdma_process_dma_completions
`define MCDMA_WAIT_PCIE_INT             `RP0_PATH.mcdma_wait_pcie_int
`define MCDMA_WAIT_AXI_INT              `RP0_PATH.mcdma_wait_axi_int

`define SGL_MAST_PEND_SRC_XFER          `DUT_PATH.mc_ref_design.sgl_master.pend_src_xfer
`define SGL_MAST_PEND_DST_XFER          `DUT_PATH.mc_ref_design.sgl_master.pend_dst_xfer

// Block DMA Tasks;  for use with DUTs containing the NW Logic DMA Back-End Core with Block DMA Engines
`define DO_MULTI_DMA_G3                 `RP0_PATH.do_multi_dma_g3

// Packet DMA Tasks; for use with DUTs containing the NW Logic DMA Back-End Core with Packet DMA Engines
`define DO_PKT_DMA_CHAIN                `RP0_PATH.do_pkt_dma_chain
`define DO_PKT_DMA_LOOPBACK             `RP0_PATH.do_pkt_dma_loopback


// --------------------------------------------------------------------
// Defines for Enabling/Disabling Root Port BFM Completion Transmission

`define SET_CPL_HOLDOFF                 `RP0_PATH.set_cpl_holdoff
`define CLR_CPL_HOLDOFF                 `RP0_PATH.clr_cpl_holdoff

// Miscellaneous
`define SET_COMPLETION_ERROR_MODE       set_completion_error_mode

// Controls for slowing BFM packet recepetion; global slow enable
`define BFM_SLOW_RX_LOOP                `RP0_PATH.slow_rx_loop
// Controls for slowing BFM packet recepetion; individual packet type slow enable
`define BFM_SLOW_RX_MEM_RD              `RP0_PATH.slow_rx_mem_rd
`define BFM_SLOW_RX_MEM_WR              `RP0_PATH.slow_rx_mem_wr
`define BFM_SLOW_RX_IO_RD               `RP0_PATH.slow_rx_io_rd
`define BFM_SLOW_RX_IO_WR               `RP0_PATH.slow_rx_io_wr
`define BFM_SLOW_RX_CFG_RD              `RP0_PATH.slow_rx_cfg_rd
`define BFM_SLOW_RX_CFG_WR              `RP0_PATH.slow_rx_cfg_wr
`define BFM_SLOW_RX_MSG                 `RP0_PATH.slow_rx_msg
`define BFM_SLOW_RX_MSGD                `RP0_PATH.slow_rx_msgd
`define BFM_SLOW_RX_CPL                 `RP0_PATH.slow_rx_cpl
`define BFM_SLOW_RX_CPLD                `RP0_PATH.slow_rx_cpld

// BFM Tag Status; Non-posted request with tag[i] is (1) open/not completed or (0) closed/completed
`define BFM_INIT_TAG_STATUS             `RP0_PATH.bfm_init_tag_status
`define BFM_INIT_TAG_IS_CFG_EN          `RP0_PATH.bfm_init_tag_is_cfg_en
// Which tags were used by the DUT since initializing the field to 0 (at the start of simulation)
`define DUT_REQ_TAGS_USED               `RP0_PATH.dut_req_tags_used

// BFM base address for BFM MEM for 32-bit accesses
`define BFM_INT_BASE_IO_ADDR32          `RP0_PATH.bfm_base_io_addr32
`define BFM_INT_BASE_ADDR32             `RP0_PATH.bfm_base_addr32
`define BFM_INT_BASE_ADDR64             `RP0_PATH.bfm_base_addr64

`define BFM_INT_LIMIT_ADDR64            `RP0_PATH.bfm_limit_addr64
// BFM MSI-X Interrupt Controller; base address, number of vectors, and array containing interrupt vector hits
`define BFM_INT_MSIX_ADDR               `RP0_PATH.int_msix_addr
`define BFM_INT_MSIX_NUM_VECTORS        `RP0_PATH.int_msix_num_vectors
`define BFM_INT_MSIX_VECTOR_HIT         `RP0_PATH.int_msix_vector_hit

// BFM MSI Interrupt Controller; base address, base data value, number of vectors, and array containing interrupt vector hits
`define BFM_INT_MSI_ADDR                `RP0_PATH.int_msi_addr
`define BFM_INT_MSI_DATA                `RP0_PATH.int_msi_data
`define BFM_INT_MSI_NUM_VECTORS         `RP0_PATH.int_msi_num_vectors
`define BFM_INT_MSI_VECTOR_HIT          `RP0_PATH.int_msi_vector_hit

// BFM Legacy Interrupt Controller; array containing vector hits [INTD, INTC, INTB, INTA]
`define BFM_INT_LEGI_VECTOR_HIT         `RP0_PATH.int_legi_vector_hit

// Defines for BFM memory array sizes
`define BFM_STATUS_MEM                  `RP0_PATH.status_mem
`define BFM_MEM                         `RP0_PATH.bfm_mem
`define BFM_MEM_BSIZE                   `RP0_PATH.bfm_mem_bsize

// Defines for Root Port BFM received messages
`define BFM_MSG_EN                      `RP0_PATH.pcie_model.msg_en
`define BFM_MSG_DATA                    `RP0_PATH.pcie_model.msg_data

// Defines for IDs
`define BFM_ID                          `RP0_PATH.bfm_bdf
`define DUT_ID                          `RP0_PATH.dut_bdf

// Bus Number to begin configurating the PCIe Hierarchy
//   Devices on Bus Num == BFM_CFG0_BUS_NUM will receive Type 0 Cfg Requests
//   Devices on Bus Num != BFM_CFG0_BUS_NUM will receive Type 1 Cfg Requests
`define BFM_HOST_BUS_NUM                `RP0_PATH.host_bus_num
`define BFM_CFG0_BUS_NUM                `RP0_PATH.cfg0_bus_num
`define BFM_RP_IS_DS_SW                 `RP0_PATH.rp_is_ds_sw

// ------------------------------------
// Defines for Hard-Coded Root Port BFM

// N/A when using Root Port BFM that implements Configuration Registers
`define BFM_CFG_IO_BASE                 `RP0_PATH.cfg_io_base
`define BFM_CFG_IO_LIMIT                `RP0_PATH.cfg_io_limit
`define BFM_CFG_MEM_BASE                `RP0_PATH.cfg_mem_base
`define BFM_CFG_MEM_LIMIT               `RP0_PATH.cfg_mem_limit
`define BFM_CFG_PF_MEM_BASE             `RP0_PATH.cfg_pf_mem_base
`define BFM_CFG_PF_MEM_LIMIT            `RP0_PATH.cfg_pf_mem_limit
`define BFM_CFG_BAR0                    `RP0_PATH.cfg_bar0
`define BFM_CFG_BAR1                    `RP0_PATH.cfg_bar1
`define BFM_CFG_EXP_ROM                 `RP0_PATH.cfg_exp_rom

// --------------------------------
// Defines for DUT Behavior Control

`define DUT_RST_N                       `TOP_PATH.rst_n
`define PM_EXAMPLE_PATH                 `DUT_PATH.sdram_dma_ref_design_pkt.pm_example
`define DUT_WAKE_N                      `PM_EXAMPLE_PATH.wake_n
`define DUT_MAIN_POWER_GOOD             `PM_EXAMPLE_PATH.main_power_good
`define DUT_PM_D3COLD_N_PME_ASSERT      `PM_EXAMPLE_PATH.pm_d3cold_n_pme_assert
// supporting new AXI tasks

//
// encoding for AXI terminations
//
`define  AXI_OKAY                 2'b00
`define  AXI_EXOKAY               2'b01
`define  AXI_SLVERR               2'b10
`define  AXI_DECERR               2'b11



//
// used to select or deselect checking during register reading
//
`define  CHECK_DATA                1
`define  NO_CHECK_DATA             0


//
// used to set message filtering options
//
`define  NO_MSGS_FILTERED               1
`define  MSGS_W_CODE_7_ONLY             2
`define  MSGS_W_CODE_5_ONLY             3
`define  MSGS_W_CODE_3_ONLY             4
`define  MSGS_W_CODE_2_ONLY             5
`define  MSGS_W_CODE_1_ONLY             6
`define  MSGS_W_CODES_75321_ONLY        7
`define  MSGS_WO_CODE_7                 8
`define  MSGS_WO_CODE_5                 9
`define  MSGS_WO_CODE_3                10
`define  MSGS_WO_CODE_2                11
`define  MSGS_WO_CODE_1                12
`define  MSGS_WO_CODES_75321           13
`define  MSGS_W_CODE_7_W_ID            14
`define  MSGS_W_CODE_7_WO_ID           15
`define  ALL_MSGS_FILTERED             16

// -----------------------
// -- Module Definition --
// -----------------------

module ref_design_ts (

    rst_n,
    clk,
    pl_link_up,
    dl_link_up,
    test_done
);



// ----------------
// -- Parameters --
// ----------------


// NOTE: Only values defined using parameter are expected to be changed by the user;
//       Do not alter values defined using localparam

localparam  LOC_PCIE                                = 1'b0;
localparam  LOC_AXI                                 = 1'b1;
localparam  AXI_BUS_ODD_DATA_ADDER                  = 256'h03030303_03030303_03030303_03030303_03030303_03030303_03030303_03030303;

// Pattern constants; 32-bit patterns used to auto generate data payloads
localparam  PAT_CONSTANT                            = 0;    // next = curr
localparam  PAT_ONES                                = 1;    // next = all ones
localparam  PAT_ZEROS                               = 2;    // next = all zeros
localparam  PAT_INC_NIB                             = 3;    // for each nibble: next = curr + (pattern nibble width)
localparam  PAT_INC_BYTE                            = 4;    // for each byte:   next = curr + (pattern byte width)
localparam  PAT_INC_WORD                            = 5;    // for each word:   next = curr + (pattern word width)
localparam  PAT_INC_DWORD                           = 6;    // for each dword:  next = curr + (pattern dword width)
localparam  PAT_L_SHIFT                             = 7;    // for each dword:  next = curr << 1
localparam  PAT_R_SHIFT                             = 8;    // for each dword:  next = curr >> 1
localparam  PAT_L_ROT                               = 9;    // for each dword:  next = {curr[high_bit-1:0], curr[high_bit]}
localparam  PAT_R_ROT                               = 10;   // for each dword:  next = {curr[0], curr[high_bit:1]}
localparam  PAT_DEC_NIB                             = 11;   // for each nibble: next = curr - (pattern nibble width)
localparam  PAT_DEC_BYTE                            = 12;   // for each byte:   next = curr - (pattern byte width)
localparam  PAT_FIB_NIB                             = 13;   // Fibonacci sequence using data nibbles (psuedo random)

// Hardware packet generator/checker PATTERN constants
localparam  PKT_PAT_CONSTANT                = 2'h0; // next = curr
localparam  PKT_PAT_INC_BYTE                = 2'h1; // for each byte:  next = curr + (AXI_DATA_WIDTH/8)
localparam  PKT_PAT_LFSR                    = 2'h2; // for each dword: next = LFSR(curr)
localparam  PKT_PAT_INC_DWORD               = 2'h3; // for each dword: next = curr + (AXI_DATA_WIDTH/32)

// ------------------------------------
// Random Number Generation Seed Value
parameter   RANDOM_SEED                             = 32'b1; // Ensuring that the seed value is not zero!

// While phy_rx_elec_idle is low (data is active), randomly glitch phy_rx_elec_idle high to emulate possible
// hardware behavior; global behavior modifier that affects all tests
parameter     ENABLE_PHY_RX_IDLE_NOISE              = 0;

// ------------------------------------
// PCI/PCIe Enumeration (Configuration)

localparam  HOST_BUS_NUMBER                         = 8'h00;    // Bus number used for the top of the PCIe Hierarchy; don't modify

// These parameters are used for state storage arrays; reduce sizes to just size needed to consume fewer memory resources and to reduce simulation time; space is reserved even for busses
//   < HOST_BUS_NUMBER so that when the arrays are indexed by test code it is not necesary to subtract HOST_BUS_NUMBER to get the bus offset into the array; at least 2 busses are
//   required for all configurations because the Root Port has a minimum of one Upstream Bus and one Downstream Bus
//   For DUTs that are Endpoints, MAX_BUS_NUM must be >= HOST_BUS_NUMBER+2 (Upstream and Downstream bus of Root Port are always present) and MAX_DEVICE_NUM must be >= 1
parameter   MAX_BUS_NUM                             = 4;        // Maximum number of busses to support (BusNum==0 to BusNum==MAX_BUS_NUM-1); valid range 2 to 256
parameter   MAX_DEVICE_NUM                          = 32;        // Maximum number of devices to support per bus (DeviceNum==0 to DeviceNum==MAX_DEVICE_NUM-1); valid range 1 to 32
// Always support a maximum of 8 functions and up to 6 BARs implemented by Endpoints
localparam  MAX_FUNC_NUM                            = 8;        // Maximum Function number to support; FYI: configure_bus only scans for additional functions if Function 0 identifies itself as multi-function
localparam  MAX_BARS                                = 6;        // Type 0 devices have a maximum of 6 BARs; Type 1 devices have a maximum of 2 BARs; use larger number

// Address Map
//   If changing the default adress values below, it is important that DUT and BFM address regions of the same type
//     (32-bit Mem, 64-bit Mem, and 32-bit I/O) are not intermixed; the BFM Root Port implements Type 1 Configuration
//     Register TLP decode to route TLPs and requires the address regions be assigned in a compatible format

// Address Map : BFM Hard-Coded Root Port Configurations : BAR0, BAR1, Expansion ROM locations
//   For non-hard coded configurations Root Port BAR and Expansion ROM regions are allocated addresses just
//   like they are for DUT resources and these parameters are not used
parameter   BFM_BASE_ADDR_RP_BAR0                   = 32'hcc320000; // Root Port BAR0 == 32-bit Memory BAR
parameter   BFM_BASE_ADDR_RP_BAR1                   = 32'hcc080000; // Root Port BAR1 == 32-bit I/O BAR
parameter   BFM_BASE_ADDR_RP_EXP_ROM                = 32'hce000001; // Root Port Expansion ROM == 32-bit Memory BAR; enabled

// Address Map : Root Complex resources
//     {BFM_BASE_ADDR_BAR1_MSIX_HI, BFM_BASE_ADDR_BAR1_MSIX_LO} for receiving 64-bit Memory Write/Read Requests that are DUT-mastered MSI-X Interrupts
//     {BFM_BASE_ADDR_BAR1_MSI_HI,  BFM_BASE_ADDR_BAR1_MSI_LO } for receiving 64-bit Memory Write/Read Requests that are DUT-mastered MSI   Interrupts
//     {BFM_BASE_ADDR_BAR1_HI,      BFM_BASE_ADDR_BAR1_LO     } for receiving 64-bit Memory Write/Read Requests that are DUT-mastered transactions into "system" memory
parameter   BFM_BASE_ADDR_BAR1_MSIX_HI              = 32'hff640000; // Arbitrary, so using recognizable addresses
parameter   BFM_BASE_ADDR_BAR1_MSIX_LO              = 32'h00000000; //   ..
parameter   BFM_BASE_ADDR_BAR1_MSI_HI               = 32'hee640000; //   ..
parameter   BFM_BASE_ADDR_BAR1_MSI_LO               = 32'h00000000; //   ..
parameter   BFM_BASE_ADDR_BAR1_HI                   = 32'h80000000; //   ..
parameter   BFM_BASE_ADDR_BAR1_LO                   = 32'h00000000; //   ..
parameter   BFM_LIMIT_ADDR_BAR1_HI                  = 32'hc0000000; //   All accesses up to this address will be accepted by the BFM
//      BFM_BASE_ADDR_BAR0_MSIX                                 for receiving 32-bit Memory Write/Read Requests that are DUT-mastered MSI-X Interrupts
//      BFM_BASE_ADDR_BAR0_MSI                                  for receiving 32-bit Memory Write/Read Requests that are DUT-mastered MSI   Interrupts
//      BFM_BASE_ADDR_BAR0                                      for receiving 32-bit Memory Write/Read Requests that are DUT-mastered transactions into "system" memory
parameter   BFM_BASE_ADDR_BAR0_MSIX                 = 32'hbb320000; // Arbitrary, so using recognizable addresses
parameter   BFM_BASE_ADDR_BAR0_MSI                  = 32'haa320000; //   ..
parameter   BFM_BASE_ADDR_BAR0                      = 32'h82000000; //   ..
//      BFM_BASE_ADDR_BAR2                                      for receiving 32-bit I/O    Write/Read Requests that are DUT-mastered transactions into "system" I/O space
parameter   BFM_BASE_ADDR_BAR2                      = 32'h08000000; // Arbitrary, so using recognizable addresses

// Address Map : Root Port & DUT resources
//   Upper address limits for allocating resources to discovered functions including Root Port
//   BAR0,1 and Expansion ROM when the Root Port is implementing read/write configuration registers
//     {ALLOC_MEM_BAR_64_HI, ALLOC_MEM_BAR_64_LO}               64-bit Memory DUT & RP Resources allocated below this address
//      ALLOC_MEM_BAR_32                                        32-bit Memory DUT & RP Resources allocated below this address
//      ALLOC_IO_BAR_32                                         32-bit I/O    DUT & RP Resources allocated below this address
parameter   ALLOC_MEM_BAR_64_HI                     = BFM_BASE_ADDR_BAR1_HI; // Allocate DUT resources just below Root Complex resources
parameter   ALLOC_MEM_BAR_64_LO                     = BFM_BASE_ADDR_BAR1_LO; //   ..
parameter   ALLOC_MEM_BAR_32                        = BFM_BASE_ADDR_BAR0;    //   ..
parameter   ALLOC_IO_BAR_32                         = BFM_BASE_ADDR_BAR2;    //   ..

// PCI Express Max Payload Size to assign to PCI Express devices; Max Payload Size will be set to the lesser
//   of MAX_PAYLOAD_SIZE and the largest common supported Max Payload Size for all discovered functions
parameter   BFM_MAX_PAYLOAD_SIZE                    = 3'b010;   // MaxPayloadSize=512

// Minimum PCI Express SR-IOV Capability System Page Size to Use
// The Configuration Algoritm will use a Supported Page Size at least as large as this value (if any)
// A 0 value = 2^(0+12) Byte Page Size (4 KB)
parameter   MIN_PAGE_SIZE                           = 8; // 2^(x+12) Minimum Page Size. 0 = 4KB, 8 = 1 MB

// PCI Express Max Read Request Size to assign to PCI Express devices
parameter   BFM_MAX_RD_REQ_SIZE                     = 3'b010;   // MaxRdReqSize=512

// The following parameters affect Interrupt configuration and operation during enumeration
//   These global enables affect all discovered functions; individual functions can be enabled/disabled for MSI-X, MSI, or Legacy interrupts using the reg arrays provided for this purpose
parameter   ENABLE_MSIX_INT_ALLOCATION              = 1;        // Global enable (1) / disable (0) for MSI-X  interrupt allocation; when 0 MSI-X interrupts will not be allocated to any functions
parameter   ENABLE_MSI_INT_ALLOCATION               = 1;        // Global enable (1) / disable (0) for MSI    interrupt allocation; when 0 MSI-X interrupts will not be allocated to any functions
parameter   ENABLE_LEGACY_INT_ALLOCATION            = 1;        // Global enable (1) / disable (0) for Legacy interrupt allocation; when 0 MSI-X interrupts will not be allocated to any functions

parameter   ENABLE_ARI_CAPABLE_HIERARCHY            = 1;        // (1) Set ARI Capable Hierarchy in PF0 if it is an SRIOV function with ARI Capability Support being advertised; (0) Don't set ARI Capable Hierarchy
parameter   VF_ENABLE_LIMIT                         = 255;      // Limits Enumeration of VFs to this number per PF.

// Number of interrupt vectors implemented by the BFM; if the number of interrupt vectors requested by all discovered functions
//   exceeds the number of implemented vectors, then functions will be allocated fewer vectors than they requested
parameter   MAX_MSIX_VECTORS                        = 2048;     // Maximum number of 64-bit MSI-X Vectors that can be allocated to discovered functions; range 1 to 4096
parameter   MAX_MSI_VECTORS                         = 32;       // Maximum number of 64-bit MSI   Vectors that can be allocated to discovered functions; range 1 to 32

// Maximum number of interrupt vectors to allocate to a single function; if a function requests more than vectors than allowed, then the function will be allocated <= the maximum allowed amount
parameter   MAX_MSIX_VECTORS_PER_FUNCTION           = 2048;     // Maximum number of 64-bit MSI-X Vectors to allocate to a single function; range 1 to 4096
parameter   MAX_MSI_VECTORS_PER_FUNCTION            = 32;       // Maximum number of 64-bit MSI   Vectors to allocate to a single function; range 1 to 32

// Root Complex MSI-X/MSI vector address control
parameter   MSIX_ADDR_64_32_N                       = 1;        // 1 == Allocate MSI-X vectors at 64-bit address space; 0 == 32-bit
parameter   MSI_ADDR_64_32_N                        = 1;        // 1 == Allocate MSI   vectors at 64-bit address space; 0 == 32-bit

parameter   MSI_DATA_VALUE                          = 8'haa;    // Upper byte of data value to write to MSI Capability when enabling MSI

// Control whether MSI-X Table is Checked and with which method
parameter   MSIX_BURST_TABLE                        = 1;        // 1 == Set to write/read the MSI-X Table 4 DWORDs(one vector) at a time to reduce time to fill and check the MSI-X Table;
                                                                //   user design must support 128-bit writes/reads to the MSI-X table's BAR if MSIX_BURST_TABLE == 1
parameter   MSIX_CHECK_TABLE                        = 1;        // 1 == Read MSI-X tables back after writing to verify that table was written successfully; 0 == Skip check
parameter   MSI_CHECK_CFG                           = 1;        // 1 == Read MSI Cfg after writing to verify writes occurred as expected; 0 == Skip check
parameter   LEGI_CHECK_CFG                          = 1;        // 1 == Read Legacy Interrupt Cfg after writing to verify writes occurred as expected; 0 == Skip check

localparam  INT_MODE_DISABLED                       = 2'h3;
localparam  INT_MODE_MSIX                           = 2'h2;
localparam  INT_MODE_MSI                            = 2'h1;
localparam  INT_MODE_LEGACY                         = 2'h0;

// ECRC Control
parameter   DUT_ECRC_GEN_ON                         = 1;        // 1==Enable ECRC Generation in DUT (if present); 0==Disable
parameter   BFM_ECRC_GEN_ON                         = 1;        // 1==Enable ECRC Generation in BFM (if present); 0==Disable
parameter   DUT_ECRC_CHECK_ON                       = 1;        // 1==Enable ECRC Checking   in DUT (if present); 0==Disable
parameter   BFM_ECRC_CHECK_ON                       = 1;        // 1==Enable ECRC Checking   in BFM (if present); 0==Disable

// Maximum number of states to be added for MASTER tests
parameter   MAX_INSERT_IDLE_STATES                  = 9;

// Largest internal bus we can access via [rd|wr]_fld task:
localparam  NUM_FUNCS                               = 1;
parameter   MAX_SIG_WIDTH                           = (NUM_FUNCS > 1) ? 1024*NUM_FUNCS : 2048;

parameter     L0_TO_L1_TIMEOUT                        = 60000;  // Timeout value for state transition; PHY must be able to transition normally
parameter     L0_TO_L2_TIMEOUT                        = 60000;  //   between states in less time than these values; used for test timeouts
parameter     L1_TO_L0_TIMEOUT                        = 60000;  //   to verify that correct states are reached within a timeout period
parameter     L2_TO_L0_TIMEOUT                        = 120000;  //

parameter     BAR_TO_TEST                           = 1;        // Selects the BAR number which is tested for the above test cases; must be Read/Write capable RAM



parameter  FAST_FIFO_READ_ENABLE           = 0;


// ----------------
// Other Parameters

parameter   DEBUG_PASS_FAIL                         = 0;    // set to 1 for verbose pass/fail status
parameter   FINISH_STOP_N                           = 0;    // On errors and simulation completion, $stop if FINISH_STOP_N==0 else $finish
parameter   STOP_ON_ERR                             = 0;    // Set to 1 to $stop simulation on errors (for tests with optional $stop code);
                                                            //   Note: During NWL command line regressions, $stop is automatically elevated to $finish
                                                            //         by the regression flow for those simulators for which this is necessary

localparam  CORE_DATA_WIDTH                         = 64;
localparam  CORE_BE_WIDTH                           = 8;

localparam  NUM_LANES                               = 4;

localparam  BFM_NUM_LANES                           = NUM_LANES;

localparam MAX_NUM_LANES = (NUM_LANES > BFM_NUM_LANES) ? NUM_LANES : BFM_NUM_LANES;
localparam MIN_NUM_LANES = (NUM_LANES > BFM_NUM_LANES) ? BFM_NUM_LANES : NUM_LANES;


localparam  DMA_REG_BYTE_SIZE                       = 256;  // Size of each DMA Engines register space in bytes

// Locations to scan for Card to System DMA Engines
localparam  MAX_C2S_DMA_ENGINES                     = 2;    // Number of Card to System DMA Engines present

// Locations to scan for System to Card DMA Engines
localparam  MAX_S2C_DMA_ENGINES                     = 2;   // Number of System to Card DMA Engines present

// To save time, these localparams have the DMA detection logic scan only the implemented DMA Engine locations
//   Locations to scan for System to Card DMA Engines:
parameter   G3_RANGE1_LO                            = 0;                         // Always start with lowest S2C Engine #
parameter   G3_RANGE1_HI                            = MAX_S2C_DMA_ENGINES-1;     // Scan up to highest implemented engine #
//   Locations to scan for Card to System DMA Engines:
parameter   G3_RANGE2_LO                            = 32;                        // Always start with lowest C2S Engine #
parameter   G3_RANGE2_HI                            = 31+MAX_C2S_DMA_ENGINES;    // Scan up to highest implemented engine #

parameter   DMA_INTERRUPT_CONTROL                   = 32'h0000_00_00;            // Interrupt Mode[1:0] == 00 (IRQ on Descriptor completion with IRQ_on_Complete set)
                                                                                 // Interrupt Mode[1:0] == 10 (IRQ on Descriptor completion with EOP status)

// ----------------------
// -- Port Definitions --
// ----------------------

input               rst_n;
input               clk;
input               pl_link_up;
input               dl_link_up;
output              test_done;

// ----------------
// -- Port Types --
// ----------------

wire                rst_n;
wire                clk;
wire                pl_link_up;
wire                dl_link_up;
reg                 test_done;

// -------------------
// -- Local Signals --
// -------------------

// Log Handle
integer             l;

wire                debug;
wire                check_status;

// PCI Enumeration complete: 1 == Complete; 0 == Not complete
reg                 pci_enumeration_complete;

// Global arrays to store the configured location for each discovered Device
reg                 dev_present             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];                // 1 == Device Present; 0 == Not present
reg     [15:0]      dev_id_for_vf           [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

// Global arrays to store the configured location for each discovered BAR
reg                 bar_present             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // 1 == BAR Present; 0 == Not present
reg                 vf_bar_present          [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // 1 == BAR Present; 0 == Not present
reg                 bar_io_mem_n            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // 1 == I/O, 0 == Memory
reg     [63:0]      bar_addr                [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // Base address offset for BAR
reg     [63:0]      bar_addr_end            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // End byte address for BAR.
reg     [63:0]      vf_bar_addr             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // Base address offset for VF_BAR
reg     [2:0]       bar_index               [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // Cfg register address offset where BAR starts in Cfg Regs (0 = 0x10, 1 = 0x14, ...)
reg     [63:0]      vf_bar_size             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // Stride between VF windows in VF_BAR
reg     [31:0]      vf_page_size            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];                // System Page Assign for Virtual Functions
reg     [7:0]       vf_bar_vfnum            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // NumVfs actually implemented.
reg                 bar_no_mem64            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0][MAX_BARS-1:0];  // Set to request this BAR be located in 32-bit address space even if it is a 64-bit BAR
reg     [63:0]      dev_serial_num          [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];                // Device Serial Number

// Global arrays to store the configured location for each discovered Expansion ROM
reg                 exp_present             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];                // 1 == Expansion ROM Present; 0 == Not present
reg     [31:0]      exp_addr                [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];                // Base address offset for Expansion ROM

reg                 legi_present            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [1:0]       legi_dcba               [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

// Global array of Capability offsets for discovered device capabilities that are configured by this module
reg     [11:0]      cap_pm_addr             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

reg                 cap_msi_disable         [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_msi_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [7:0]       cap_msi_rvec            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg                 cap_msi_64              [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

reg     [11:0]      cap_pcie_addr           [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [4:0]       cap_pcie_intvec         [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [3:0]       cap_pcie_devtype        [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [2:0]       cap_pcie_max_pl_size_sup[MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg                 cap_pcie_ex_tag_sup     [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [1:0]       cap_pcie_aspm_sup       [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

reg                 cap_msix_disable        [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_msix_addr           [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_msix_rvec           [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

reg     [11:0]      cap_aer_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

reg     [11:0]      cap_ven_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_vsec_addr           [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_sec_pcie_addr       [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_pasid_addr          [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_ari_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_ats_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_sriov_addr          [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_tph_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_dsn_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_vpd_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_pb_addr             [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_resize_bar_addr     [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_dpa_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_l1pmss_addr         [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      cap_ltr_addr            [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

//enum                {CAP_CLEARED, CAP_FOUND, CAP_TESTED}  cap_list_status [4095:0];
reg      [1:0]      cap_list_status [4095:0];        // Two bits to define if each capability is {tested, present}
parameter [1:0]     CAP_CLEARED = 3'h0,
                    CAP_FOUND   = 3'h1,
                    CAP_TESTED  = 3'h2;

// Starting base addresses for PCIe Hierarchy configuration
reg     [63:0]      last_mem_bar_64;
reg     [63:0]      last_mem_bar_32;
reg     [63:0]      last_io_bar_32;
reg                 gap_mem_bar;                  //Normally set to 0, set to 1 to force an unused memory gap during BAR assignments
reg                 report_barsize_viol_as_error; //if 1, report 32-bit barsize request for too much memory as an error, otherwise report a "WARNING" message and don't configure the BAR.
integer             min_pg_size;                  //Normally set to MIN_PAGE_SIZE, but

// Interrupt method assigned to the function
reg     [1:0]       int_mode_msix_msi_leg   [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
// Number of vectors allocated to this function
reg     [11:0]      int_num_vectors_req     [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      int_num_vectors_alloc   [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];
reg     [11:0]      int_base_vector_num     [MAX_BUS_NUM-1:0][MAX_DEVICE_NUM-1:0][MAX_FUNC_NUM-1:0];

// Default device arrays, so don't need to use full decode
reg     [15:0]      dut_bdf;
reg     [15:0]      br_pcie_cap_bdf;      //Updated with latest found downstream port to support setting ARI forwarding enable
reg     [11:0]      br_pcie_cap_ptr;      //" "

reg     [1:0]       int_mode;
reg     [11:0]      int_num_vec_req;
reg     [11:0]      int_num_vec_alloc;
reg     [11:0]      int_num_base_vector;

reg                 dev_is_present;
reg     [63:0]      bar[MAX_BARS-1:0];      // Base address asigned to DUT BAR[i]
reg     [MAX_BARS-1:0] bar_exists;          // Whether BAR exists

reg     [31:0]      exp_bar;

reg     [11:0]      cap_addr_pm;
reg     [11:0]      cap_addr_msi;
reg     [11:0]      cap_addr_pcie;
reg     [11:0]      cap_addr_msix;
reg     [11:0]      cap_addr_aer;
reg     [11:0]      cap_addr_ven;
reg     [11:0]      cap_addr_tph;
reg     [11:0]      cap_addr_dsn;

// Value to setup BFM target BAR
reg     [31:0]  rp_bar0;
reg     [31:0]  rp_bar1;
reg     [31:0]  rp_exp_rom;

reg     [63:0]  bfm_bar0;               // 32-bit BFM Memory Starting Address
reg     [63:0]  bfm_64addr;
reg     [63:0]  bfm_bar1;               // 64-bit BFM Memory Starting Address
reg     [31:0]  bfm_bar2;               // 32-bit BFM I/O Starting Address

reg     [63:0]  bfm_msi_addr;           // Address expected for MSI Interrupts; Starting address expected for MSI-X Interrupts

integer         g3_num_c2s;
integer         g3_num_s2c;
integer         g3_num_com;
integer         g3_int_vec;

reg     [7:0]   g3_smallest_card_addr;
reg     [63:0]  g3_max_bcount;
reg     [63:0]  g3_com_bar;

reg     [31:0]  g3_c2s_cap          [MAX_C2S_DMA_ENGINES-1:0];
reg             g3_c2s_pkt_block_n  [MAX_C2S_DMA_ENGINES-1:0];
reg     [63:0]  g3_c2s_reg_base     [MAX_C2S_DMA_ENGINES-1:0];
reg     [63:0]  g3_c2s_pat_base     [MAX_C2S_DMA_ENGINES-1:0];
reg     [11:0]  g3_c2s_int_vector   [MAX_C2S_DMA_ENGINES-1:0];

reg     [31:0]  g3_s2c_cap          [MAX_S2C_DMA_ENGINES-1:0];
reg             g3_s2c_pkt_block_n  [MAX_S2C_DMA_ENGINES-1:0];
reg     [63:0]  g3_s2c_reg_base     [MAX_S2C_DMA_ENGINES-1:0];
reg     [63:0]  g3_s2c_pat_base     [MAX_S2C_DMA_ENGINES-1:0];
reg     [11:0]  g3_s2c_int_vector   [MAX_S2C_DMA_ENGINES-1:0];



reg             watch_error_msgs_flag = 0;


//
// global variable used by exp_delay
//
integer  expo_random_seed    = RANDOM_SEED;
integer  random_seed         = RANDOM_SEED;

//
// defines and variables dealing with messages
//

`define MSG_NO_DATA                1'b0
`define MSG_DATA                   1'b1

`define MSG_ROUTE_IMP_TO_RC        3'b000
`define MSG_ROUTE_BY_ADDRESS       3'b001
`define MSG_ROUTE_BY_ID            3'b010
`define MSG_ROUTE_IMP_FROM_RC      3'b011
`define MSG_ROUTE_LOCAL            3'b100
`define MSG_ROUTE_GATHER_TO_RC     3'b101

`define MSG_LATENCY_TOL_REPORTING  8'b0001_0000

`define MSG_CODE_ASSERT_INTA       8'b0010_0000
`define MSG_CODE_ASSERT_INTB       8'b0010_0001
`define MSG_CODE_ASSERT_INTC       8'b0010_0010
`define MSG_CODE_ASSERT_INTD       8'b0010_0011

`define MSG_CODE_DEASSERT_INTA     8'b0010_0100
`define MSG_CODE_DEASSERT_INTB     8'b0010_0101
`define MSG_CODE_DEASSERT_INTC     8'b0010_0110
`define MSG_CODE_DEASSERT_INTD     8'b0010_0111

`define MSG_CODE_VENDOR_DEF_0      8'b0111_1110
`define MSG_CODE_VENDOR_DEF_1      8'b0111_1111

`define  STD_MSG_SIZE              (1 + 2 + 3 + 8 + 8 + 8)
`define  NO_OF_STD_MSGS            256

`define  NO_OF_MSG_INFO            50
`define  MSG_INFO_NULL             8'H01
`define  MSG_INFO_TEST1            8'H02
`define  MSG_INFO_ID_00            8'H03
`define  MSG_INFO_ID_01            8'H04
`define  MSG_INFO_TEST_11          8'H05
`define  MSG_INFO_TEST_22          8'H06
`define  MSG_INFO_TEST_33          8'H07
`define  MSG_INFO_TEST_44          8'H08
`define  MSG_INFO_TEST_55          8'H09
`define  MSG_INFO_TEST_66          8'H0A
`define  MSG_INFO_TEST_77          8'H0B
`define  MSG_INFO_TEST_88          8'H0C
`define  MSG_INFO_TEST_99          8'H0D
`define  MSG_INFO_TEST_AA          8'H0E

`define  NO_OF_MSG_DATA            30
`define  MSG_DATA_NULL             8'H01
`define  MSG_DATA_TEST1            8'H02
`define  MSG_DATA_TEST2            8'H03
`define  MSG_DATA_TEST3            8'H04
`define  MSG_DATA_1DW_A            8'H05
`define  MSG_DATA_1DW_B            8'H06
`define  MSG_DATA_2DW_A            8'H07
`define  MSG_DATA_2DW_B            8'H08
`define  MSG_DATA_3DW_A            8'H09
`define  MSG_DATA_3DW_B            8'H0A

//
// indices of standard messages which can be used to
// activate or de-activate  legacy interrupts
//
`define  ACT_INTA_MSG              1
`define  ACT_INTB_MSG              2
`define  ACT_INTC_MSG              3
`define  ACT_INTD_MSG              4

`define  DEACT_INTA_MSG            5
`define  DEACT_INTB_MSG            6
`define  DEACT_INTC_MSG            7
`define  DEACT_INTD_MSG            8


reg    [`STD_MSG_SIZE - 1 : 0]  msg_heap      [1 : `NO_OF_STD_MSGS];
reg                     [63:0]  msg_info_heap [1 : `NO_OF_MSG_INFO];
reg                    [127:0]  msg_data_heap [1 : `NO_OF_MSG_DATA];
reg                     [15:0]  rsvd_vendor_id;



function automatic [7:0] dig2ascii;
input integer intval;
begin
    dig2ascii = "0"+intval%10;
end
endfunction

function automatic [7:0] byte_enables_from_fld;
input integer msb;
input integer lsb;
reg [7:0] be;
integer i;
begin
    be=0;
    for (i=(lsb >> 3); i<=(msb>>3); i=i+1)
        be[i]=1;
    byte_enables_from_fld = be;
end
endfunction

function automatic [MAX_SIG_WIDTH-1:0] get_slice;
input [MAX_SIG_WIDTH-1:0] bits;
input integer msb;
input integer lsb;
reg [MAX_SIG_WIDTH-1:0] result;
integer i;
begin
    result=0;
    for (i=lsb; i<=msb; i=i+1)
        result[i-lsb] = bits[i];
    get_slice = result;
end
endfunction

function automatic [MAX_SIG_WIDTH-1:0] set_slice;
input [MAX_SIG_WIDTH-1:0] orig_val;
input [MAX_SIG_WIDTH-1:0] value;
input integer msb;
input integer lsb;
integer i;
reg   [MAX_SIG_WIDTH-1:0] new_val;
begin
    for (i=0; i < MAX_SIG_WIDTH; i = i + 1)
        if ((i < lsb) || (i > msb))
            new_val[i] = orig_val[i];
        else
            new_val[i] = value[i-lsb];
    set_slice = new_val;
end
endfunction


function automatic [63:0] device_base;
input  [8*64:0] bus;
input [8*64:0] devname;
reg [63:0] addr;
begin
    case (bus)
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
    device_base = addr;
end
endfunction

function automatic [63:0] register_address;
input  [8*64:0] bus;
input [8*64:0] regname;
reg [63:0] addr;
begin
    addr = 64'bx;
    case (bus)
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
    if (addr[0] === 1'bx)
    begin
        $display ("ERROR: %m For bus \"%0s\", unknown reg/signal \"%0s\" reference at time %0t", bus, regname, $time);
        addr = {64{1'b1}};
    end
    register_address = addr;
end
endfunction

function automatic integer register_depth;
input  [8*64:0] bus;
input [8*64:0] regname;
integer depth;
begin
    case (bus)
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
    register_depth = depth;
end
endfunction

reg trace_rd_adr;
initial trace_rd_adr=1;


task automatic rd_seq;
input  [8*64:0] bus;
input  [31:0]   bus_opts;
input  [63:0]   address;
input integer first_bit;
input integer total_bits;
output [MAX_SIG_WIDTH-1:0]   fdata;

reg    [MAX_SIG_WIDTH-1:0]   fdata;
reg    [31:0]   rdata;
integer i;
integer cur_bit;
integer xfer, first_xfer, final_xfer, first_lsb, final_msb;
integer xfer_size;
begin
    xfer_size = 32;

    first_xfer = first_bit / xfer_size;
    first_lsb  = first_bit % xfer_size;

    final_xfer = (first_bit + total_bits - 1) / xfer_size;
    final_msb  = (first_bit + total_bits - 1) % xfer_size;

    fdata = 0;

    for (xfer = first_xfer; xfer <= final_xfer; xfer = xfer + 1)
    begin
        rd_adr(bus, bus_opts, address + {xfer, 2'b00}, 0, `NO_CHECK_DATA, rdata);

        for (i=0; i<xfer_size; i=i+1)
        begin
            cur_bit = i + (xfer * xfer_size) - first_bit;
            if ((cur_bit >= 0) && (cur_bit < total_bits))
            begin
                fdata[cur_bit] = rdata[i];
            end
        end
    end
end
endtask



task automatic wr_seq;
input  [8*64:0] bus;
input  [31:0]   bus_opts;
input  [63:0]   address;
input integer first_bit;
input integer total_bits;
input [MAX_SIG_WIDTH-1:0]   fdata;

reg   [MAX_SIG_WIDTH-1:0]   fdata;
reg   [31:0]   rdata, wdata;
integer i;
integer cur_bit, lsb, msb;
integer xfer, first_xfer, final_xfer, first_lsb, final_msb;
integer xfer_size;
begin
    xfer_size = 32;

    first_xfer = first_bit / xfer_size;
    first_lsb  = first_bit % xfer_size;

    final_xfer = (first_bit + total_bits - 1) / xfer_size;
    final_msb  = (first_bit + total_bits - 1) % xfer_size;

    for (xfer = first_xfer; xfer <= final_xfer; xfer = xfer + 1)
    begin
        // Read-Modify-Write first and last addresses if necessary
        if (((xfer == first_xfer) && (first_lsb != 0)) ||
            ((xfer == final_xfer) && (final_msb != (xfer_size-1))))
        begin
            rd_adr(bus, bus_opts, address + {xfer, 2'b00}, 0, `NO_CHECK_DATA, rdata);
        end

        lsb = (xfer == first_xfer) ? first_lsb : 0;
        msb = (xfer == final_xfer) ? final_msb : xfer_size - 1 ;

        for (i=0; i<xfer_size; i=i+1)
        begin
            cur_bit = (xfer * xfer_size) + i;
            wdata[i] =  ((i>=lsb) && (i<=msb)) ? fdata[cur_bit - first_bit] : rdata[i];
        end

        wr_adr(bus, bus_opts, address + {xfer, 2'b00}, wdata, 4'b1111);
    end
end
endtask


task automatic rd_adr;
input  [8*64:0] bus;
input  [31:0]   bus_opts;
input  [63:0]   addr;
input  [31:0]   expdata;
input           check;
output [31:0]   rdata;
reg    [31:0]   rdata;
reg    [1:0]    resp;
begin
    case (bus)
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
    if (check) begin
        if (rdata !== expdata) $display ("%m : ERROR: expdata %h, data read %h", expdata, rdata);
    end
    if ($test$plusargs("regspec_msgs_on") && trace_rd_adr)
        $display ("%m %0s                 %x %x %s", bus, addr, rdata, check ? "checked" : "");
end
endtask


task automatic rd_reg;
input [8*64:0] bus;
input [31:0]   bus_opts;
input [8*64:0] regname;
input  [31:0]  expdata;
input          check;
output [MAX_SIG_WIDTH-1:0] rdata;
reg    [MAX_SIG_WIDTH-1:0] rdata;

reg [31:0] tmpdata;
reg [63:0] addr;
integer i,j,depth;
begin
    trace_rd_adr=0;
    rdata=0;
    depth = register_depth(bus, regname);
    for (i=0; i<depth; i=i+1)
    begin
        rd_adr(bus, bus_opts, register_address(bus, regname) + (4*i), expdata, check, tmpdata);
        for (j=0; j<32; j=j+1) rdata[i*32 + j]=tmpdata[j];
    end
    trace_rd_adr=1;
    if ($test$plusargs("regspec_msgs_on"))
        $display ("%m %0s %s %x", bus, regname[32*8-1:0], rdata);
end
endtask

task automatic rd_fld;
input [8*64:0] bus;
input [31:0]   bus_opts;
input [8*64:0] regname_in;
input [8*64:0] fldname_in;
input [31:0]   expdata;
input          check;
output [MAX_SIG_WIDTH-1:0]  fdata;
reg [64:0] address;

reg [8*64:0] regname;
reg [8*64:0] fldname;
reg [31:0] rdata;
reg [MAX_SIG_WIDTH-1:0] fdata;
reg [MAX_SIG_WIDTH-1:0] sig_val;
integer lsb, width;
begin
    // Modify regname/fldname if needed
    convert_reg_field(bus,bus_opts, regname_in, fldname_in, regname, fldname);

    case (bus)
        "BFM": begin
            if (regname === "mgmt_cfg_8g_status") repeat (5) @(negedge `DUT_CLK);
            case (regname)
                "mgmt_cfg_constants"    : sig_val = `RP0_PATH.mgmt_cfg_constants;
                "mgmt_cfg_status"       : sig_val = `BFM_PCIE_CORE.mgmt_cfg_status;
                "mgmt_cfg_estatus"      : sig_val = `BFM_PCIE_CORE.mgmt_cfg_estatus;
                "mgmt_cfg_control"      : sig_val = `BFM_PCIE_CORE.mgmt_cfg_control;
                default: $display ("ERROR: %m \"%0s\" unknown signal \"%0s\" at time %0t", bus, regname, $time);
            endcase
            lsb   = bfm_lookup.signal_field_lsb(regname, fldname);
            width = bfm_lookup.signal_field_width(regname, fldname);
            fdata = get_slice(sig_val, lsb+width-1, lsb);
        end
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
    if (check) begin
        if (fdata !== expdata) $display ("%m : ERROR: expdata %h, data read %h at time %0t", expdata, fdata, $time);
    end
    if ($test$plusargs("regspec_msgs_on"))
        $display ("%m %0s %s %0s %0x %s", bus, regname[32*8-1:0], fldname, fdata, check ? "checked" : "");
end
endtask

reg trace_wr_adr;
initial trace_wr_adr = 1;

task automatic wr_adr;
input [8*64:0] bus;
input [31:0]   bus_opts;
input [63:0]   addr;
input [31:0]   wdata;
input [3:0]    wenb;
reg   [1:0]    resp;
begin
    if ($test$plusargs("regspec_msgs_on") && trace_wr_adr)
        $display ("%m %0s                 %x %x be:%b", bus, addr, wdata, wenb);
    case (bus)
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
end
endtask

task automatic wr_reg;
input [8*64:0] bus;
input [31:0]   bus_opts;
input [8*64:0] regname;
input [MAX_SIG_WIDTH-1:0]   wdata;
input [3:0]    wenb;
reg [31:0] tmpdata;
integer i,j,depth;
begin
    if ($test$plusargs("regspec_msgs_on"))
        $display ("%m %0s %s %x be:%b", bus, regname[32*8-1:0], wdata, wenb);
    trace_wr_adr=0;
    depth = register_depth(bus, regname);
    for (i=0; i<depth; i=i+1)
    begin
        for (j=0; j<32; j=j+1) tmpdata[j] = wdata[i*32 + j];
        wr_adr(bus, bus_opts, register_address(bus, regname) + (4*i), tmpdata, wenb);
    end
    trace_wr_adr=1;
end
endtask

task automatic convert_reg_field;
input [8*64:0] bus;
input [31:0]   bus_opts;
input [8*64:0] regname_in;
input [8*64:0] fldname_in;
output reg [8*64:0] regname;
output reg [8*64:0] fldname;
    begin
        regname = regname_in;
        fldname = fldname_in;

        if ((bus == "APB" || bus == "BFM") && (regname == "mgmt_cfg_mf_constants") && (fldname[8*4-1:8] !== "_fn"))
        begin
            if (bus_opts == 0)
            begin
                regname = "mgmt_cfg_constants";
            end
            else
            begin
                fldname = {fldname_in,"_fn",dig2ascii(bus_opts)};
            end
        end

        if ((regname !== regname_in || fldname !== fldname_in))
            $display("Note: Converted %0s (options: %h) register : field selection from %0s : %0s to %0s : %0s",
                     bus, bus_opts, regname_in, fldname_in, regname, fldname);
    end
endtask

task automatic wr_fld;
input [8*64:0] bus;
input [31:0]   bus_opts;
input [8*64:0] regname_in;
input [8*64:0] fldname_in;
input [MAX_SIG_WIDTH-1:0] fdata;
reg [64:0] address;
reg [MAX_SIG_WIDTH-1:0] rdata;
reg [8*64:0] regname;
reg [8*64:0] fldname;
integer lsb, msb, width;
begin
    // Modify regname/fldname if needed
    convert_reg_field(bus,bus_opts, regname_in, fldname_in, regname, fldname);

    if ($test$plusargs("regspec_msgs_on"))
        $display ("%m %0s %0s %0s %0x", bus, regname, fldname, fdata);
    case (bus)
        "BFM": begin
            lsb   = bfm_lookup.signal_field_lsb(regname, fldname);
            width = bfm_lookup.signal_field_width(regname, fldname);
            case (regname)
                "mgmt_cfg_constants"    : set_bfm_constants(lsb,width,fdata);
                "mgmt_cfg_control"      : set_bfm_control(lsb,width,fdata);
                default: begin
                    $display ("ERROR: %m \"%0s\" unknown reg/signal \"%0s\" at time %0t", bus, regname, $time);
                    `INC_ERRORS;
                end
            endcase
        end
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase

end
endtask

// axi_to_pcie_io_wr: performs the necessary AXI master reads and writes to initiate
// and complete (get return status) a PCIe IO write operation.
// This routines allows PCIe response status error checking to be pipelined (chk_preverr=1),
task axi_to_pcie_io_wr;

    input   [31:0]  addr;
    input   [31:0]  data;
    input   [3:0]   be;
    input           chk_preverr;
    input           wait_status;
    output  [1:0]   status;

    reg     [31:0]  read_data;
    integer         cnt;
    reg             done;

begin
    status = 2'h0; // Default to OK status for wait_status==0 case
    read_data = 32'hffff_ffff;
    //Wait for IO translation registers to become available
    cnt = 0;
    while(read_data[8]) begin
        rd_reg("AXI", 0, "TX_PCIE_IO_EXECUTE", 32'h0, `NO_CHECK_DATA, read_data);
        if(chk_preverr && (read_data[25:24] != 2'b0)) begin
            $display ("%m : ERROR, the previous IO operation received a %s response, time %0t", (read_data[24] ? "DECERR" : "SLVERR"), $time);
            `INC_ERRORS;
        end
        if(cnt[3:0] == 4'hf) $display("%m : Waiting on I/O translation register busy signal at time %0t", $time);
        cnt = cnt + 1;
    end
    wr_reg("AXI", 0, "TX_PCIE_IO_ADDRESS", addr, 4'b1111);
    wr_reg("AXI", 0, "TX_PCIE_IO_CONTROL", {20'h0,be[3:0],7'h0,1'b1}, 4'b1111);
    wr_reg("AXI", 0, "TX_PCIE_IO_DATA", data, 4'b1111);
    wr_reg("AXI", 0, "TX_PCIE_IO_EXECUTE", 32'h1, 4'b1111);

    // Wait for and return IO Completion Status when wait_status == 1
    if (wait_status)
    begin
        cnt  = 0;
        done = 0;
        while (~done)
        begin
            rd_reg("AXI", 0, "TX_PCIE_IO_EXECUTE", 32'h0, `NO_CHECK_DATA, read_data);
            if (read_data[16]) // io_done
            begin
                status = read_data[25:24]; // io_done_status
                done   = 1'b1;
            end
            else
            begin
                if(cnt[7:0] == 8'hff) $display("%m : Waiting for I/O write transaction to complete (polling for register io_done == 1) at time %0t", $time);
                cnt = cnt + 1;
                // Wait for a small time between polling events so bus is free for other transactions
                repeat (50) @(posedge `DUT_CLK);
            end
        end
    end
end
endtask

//axi_to_pcie_io_rd: waits for AXI I/O translation registers to be free, then issues an I/O read request,
//then waits for the I/O read to complete and checks the returning data against the expected data.
task axi_to_pcie_io_rd;

    input   [31:0]  addr;
    input   [31:0]  exp_data;
    input   [3:0]   be;
    input           expect_err;
    output  [31:0]  read_data;
    output  [1:0]   status;

    reg     [31:0]  read_data;
    reg     [31:0]  valid_mask;

    integer         cnt;

begin
    status = 2'h0;
    read_data = 32'hffff_ffff;
    //Wait for IO translation registers to become available
    cnt = 0;
    while(read_data[8]) begin
       rd_reg("AXI", 0, "TX_PCIE_IO_EXECUTE", 32'h0, `NO_CHECK_DATA, read_data);
       if(cnt[3:0] == 4'hf) $display("%m : Waiting on I/O translation register busy signal at time %0t", $time);
       cnt = cnt + 1;
    end
    wr_reg("AXI", 0, "TX_PCIE_IO_ADDRESS", addr, 4'b1111);
    wr_reg("AXI", 0, "TX_PCIE_IO_CONTROL", {20'h0,be[3:0],7'h0,1'b0}, 4'b1111);
    wr_reg("AXI", 0, "TX_PCIE_IO_EXECUTE", 32'h1, 4'b1111);
    //Wait for read data returning from the PCIe bus.
    read_data = 32'h0;
    cnt = 0;
    //Wait for the PCIe read to complete.
    while(read_data[16] == 1'b0) begin
       rd_reg("AXI", 0, "TX_PCIE_IO_EXECUTE", 32'h0, `NO_CHECK_DATA, read_data);
       if(cnt[3:0] == 4'hf) $display("%m : Waiting for I/O read completion at time %0t", $time);
       cnt = cnt + 1;
    end
    status = read_data[25:24];
    if(expect_err ^ (read_data[25:24] != 2'b0)) begin
       if(~expect_err)
          $display ("%m : ERROR, a read IO operation received a %s response, time %0t", (read_data[24] ? "DECERR" : "SLVERR"), $time);
       else
          $display ("%m : ERROR, a read IO operation that was supposed to get an error response, received an OK response instead, time %0t", $time);
      `INC_ERRORS;
    end
    rd_reg("AXI", 0, "TX_PCIE_IO_DONE_DATA", 32'h0, `NO_CHECK_DATA, read_data);
    valid_mask = {{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
    if((((read_data ^ exp_data) & valid_mask) != 32'h0) && ~expect_err) begin
        $display ("%m : Error, expected IO read data %h, received %h, at time %0t", (exp_data & valid_mask), (read_data & valid_mask),  $time);
        `INC_ERRORS;
    end
end
endtask

task compare;
input [8*128:0] name;
input [128:0] expected;
input [128:0] actual;
begin
    if (expected !== actual)
    begin
        $display ("ERROR: comparison %0s failed at time %0t", name, $time);
        $display ("   expected:%0x actual:%0x", expected, actual);
    end
end
endtask

task automatic mem_bar;
input [8*128:0] mem;
output  [63:0]  mem_addr;
reg     [9:0]   dma_channel;
reg     [7:0]   func;
reg     [15:0]  bdf;
reg     [63:0]  bar;
begin
    case (mem)
        "AXI": begin
            dma_channel    = 10'd0;
            bdf            = dut_bdf + {8'h0, func};
        end
        "PCIe": begin
            bar = bfm_64addr;   //Uses negative decode on the BFM
        end
        default: $display ("ERROR: %m unknown mem %0s at time %0t", mem, $time);
    endcase
    mem_addr = bar;
end
endtask

function [63:0] mem_bytes;
input [8*128:0] mem;
reg [63:0] bytes;
begin
    bytes=0;
    case (mem)
        "PCIe": begin
            bytes = 64'h0100_0000;  //NON-SV testbench models only 16MB of memory
        end
        default: $display ("ERROR: %m unknown mem %0s at time %0t", mem, $time);
    endcase
    mem_bytes = bytes;
end
endfunction


function [63:0] mem_addr_from_bus_addr;
input [8*128:0] bus;
input    [63:0] addr;
reg [63:0] new_addr;
reg [63:0] mask;
reg [63:0] mem_size;
begin
    new_addr={63{1'bx}};
    mem_size = mem_bytes(bus);
    mask = mem_size-1;
    case (bus)
        "AXI"  : new_addr = mask & addr;
        "PCIe" : new_addr = `RP0_PATH.bfm_addr_from_mem_addr(addr);
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
//    $display ("%m bus %0s addr %x mem_size %x mask %x new_addr %x", bus, addr, mem_size, mask, new_addr);
    mem_addr_from_bus_addr = new_addr;
end
endfunction

task set_mem_dword;
input [8*128:0] bus;
input    [63:0] addr;
input    [31:0] dword;
begin
//    $display ("%m %0s mem addr %x data %x at %0t", mem, addr, dword, $time);
    case (bus)
        "PCIe" :
         begin
            `BFM_MEM[ mem_addr_from_bus_addr( bus, addr ) ] = dword;
        end
        default: $display ("ERROR: %m unknown bus %0s at time %0t", bus, $time);
    endcase
end
endtask

task get_mem_dword;
input [8*128:0] bus;
input    [63:0] addr;
input    [31:0] expdata;
input           check;
output   [31:0] dword;
begin
    case (bus)
        "PCIe" : dword = `BFM_MEM[ mem_addr_from_bus_addr( bus, addr ) ];
        default: $display ("ERROR: %m unknown mem %0s at time %0t", bus, $time);
    endcase
//    $display ("%m %0s mem addr %x data %x at %0t", mem, addr, dword, $time);
    if (check) begin
        if (dword !== expdata) $display ("%m : ERROR: %0s bus addr %x expdata %x, got %x", bus, addr, expdata, dword);
    end
end
endtask

task setup_regspec_lookups;
reg [2:0] bar_sel;
begin
end
endtask



task nwl_retrain_link;
input [15:0] bdf;

reg [31:0]  read_data;
reg [11:0]  vend_cap_addr;
reg [11:0]  pcie_cap_addr;
reg [31:0]  hw_auto_reg;

    begin
        vend_cap_addr = get_cap_ven_addr(bdf);
        pcie_cap_addr = get_cap_pcie_addr(bdf);
        //             width_mask,  4'h0, speed, 6'h0, auto_recovery, auto_width, auto_speed
        hw_auto_reg = {     16'h0,  4'h0,  4'h0, 6'h0,          1'b1,       1'b0,       1'b0};
        `CFG_WR_BDF(bdf, vend_cap_addr + 12'h010, 4'hf, hw_auto_reg);
        `CFG_RD_BDF(bdf, pcie_cap_addr + 12'h010, 4'hf, read_data);
    end
endtask

task change_speed_width;
input [3:0] speed;
input integer width;

reg [31:0]  read_data;
reg [3:0]   curr_speed;
reg [5:0]   curr_width;
reg [11:0]  vend_cap_addr;
reg [11:0]  pcie_cap_addr;
reg [15:0]  width_mask;
reg [15:0]  downstream_id;
reg [31:0]  hw_auto_reg;
reg         change_speed;
reg         change_width;
reg [3:0]   speed_val;

    begin
        if (speed[0] === 1'bx)
        begin
            change_speed = 0;
            speed_val = 0;
        end
        else
        begin
            change_speed = 1;
            speed_val = speed;
        end

        if (width[0] === 1'bx)
            change_width = 0;
        else
            change_width = 1;

        downstream_id = (`DUT_ID == 16'h0) ? `BFM_ID : `DUT_ID;

        vend_cap_addr = get_cap_ven_addr(downstream_id);
        pcie_cap_addr = get_cap_pcie_addr(downstream_id);
        case (width)
            1 :      width_mask = 16'h0001;
            2 :      width_mask = 16'h0003;
            4 :      width_mask = 16'h000f;
            8 :      width_mask = 16'h00ff;
            16 :     width_mask = 16'hffff;
            default: width_mask = 16'h0001;
        endcase
        hw_auto_reg = {width_mask, 4'h0, speed_val, 6'h0, change_width, change_speed};
        `CFG_WR_BDF(downstream_id, vend_cap_addr + 12'h010, 4'hf, hw_auto_reg);
        `CFG_RD_BDF(downstream_id, pcie_cap_addr + 12'h010, 4'hf, read_data);
        curr_speed = read_data[19:16];
        curr_width = read_data[25:20];
        if (change_width)
            if (curr_width !== width[5:0])
            begin
                $display("%m: ERROR: Resulting Width from Width Change should be %0d, Was %0d",
                          width, curr_width
                          );
                `INC_ERRORS;
            end
        if (change_speed)
            if (curr_speed !== speed[3:0])
            begin
                $display("%m: ERROR: Resulting Speed from Speed Change should be %s, Was %s",
                          (speed == 1) ? "2.5G" : (speed == 2) ? "5G" : (speed == 3) ? "8G": "XX",
                          (curr_speed == 1) ? "2.5G" : (curr_speed == 2) ? "5G" : (curr_speed == 3) ? "8G": "XX",
                          );
                `INC_ERRORS;
            end
    end
endtask

task change_speed;
input [3:0] initial_speed;

reg [15:0] ds_bdf;
reg [11:0] cap_addr;
reg        poll_done;
reg [31:0] read_data;
reg [3:0]  curr_speed;
reg [5:0]  curr_width;

    begin
        ds_bdf = `BFM_ID;

        // Read current link width and speed from DUT Link Status
        cap_addr = get_cap_pcie_addr(`DUT_ID);
        cfg_read_bdf(`DUT_ID, cap_addr + 12'h012, 9, 0, read_data);
        curr_width = read_data[9:4];
        curr_speed = read_data[3:0];

        if (initial_speed == curr_speed)
            $display("%m: Skipping Speed Change since we are already at the target initial speed");
        else
        begin
            $display("%m: Initiating Speed Change from %0s to Target Speed: %0s",
                      curr_speed == 4'd1 ? "2.5G" : curr_speed == 4'd2 ? "5G" : "8G",
                      initial_speed == 4'd1 ? "2.5G" : initial_speed == 4'd2 ? "5G" : "8G",
                      );

            // Specify the Target Link Speed for the Retrain
            // Write to Link Control 2 Register (30h) in the BFM
            //   [3:0] Target Link Speed
            //     [4] Enter Compliance
            //     [5] HW Autonomous Speed Disable
            //     [6] Selectable Deemphasis
            //   [9:7] Transmit Margin
            //    [10] Enter Modified Compliance
            //    [11] Compliance SOS
            // [15:12] Compliance Preset/De-Emphasis
            cap_addr = get_cap_pcie_addr(ds_bdf);
            cfg_rmw_bdf(ds_bdf, cap_addr + 12'h030, 3, 0, initial_speed);

            // Retrain the Link
            // Write a 1 to bit 5 of the Link Control Register (10h) in the BFM
            cap_addr = get_cap_pcie_addr(ds_bdf);
            cfg_rmw_bdf(ds_bdf, cap_addr + 12'h010, 5, 5, 1'b1);

            // Wait until we've completed training
            // Poll Link Status Register, bit 11 (Link  Training)
            poll_done = 1'b0;
            while (poll_done == 1'b0)
            begin
                cap_addr = get_cap_pcie_addr(ds_bdf);
                cfg_read_bdf(ds_bdf, cap_addr + 12'h012, 11, 11, read_data);  // bit 11 starting at byte offset offset 0x12
                poll_done = ~read_data[0];
            end

            // Check if we are at the correct target speed
            cap_addr = get_cap_pcie_addr(`DUT_ID);
            cfg_read_bdf(`DUT_ID, cap_addr + 12'h012, 9, 0, read_data);
            curr_speed = read_data[3:0];
            if (curr_speed != initial_speed) begin
                $display  ("%m : ERROR : Failed to reach target speed.");
                `INC_ERRORS;
            end else begin
                $display  ("%m : Reached Target Speed.");
            end
        end
    end
endtask

task retrain_link;
reg [11:0]  cap_addr;
reg         poll_done;
reg [31:0]  read_data;
reg [15:0] ds_bdf;
    begin
        ds_bdf = `BFM_ID;
        // Retrain the Link
        // Write a 1 to bit 5 of the Link Control Register (10h) in the BFM
        cap_addr = get_cap_pcie_addr(ds_bdf);
        cfg_rmw_bdf(ds_bdf, cap_addr + 12'h010, 5, 5, 1'b1);

        // Wait until we've completed training
        // Poll Link Status Register, bit 11 (Link  Training)
        poll_done = 1'b0;
        while (poll_done == 1'b0)
        begin
            cfg_read_bdf(ds_bdf, cap_addr + 12'h012, 11, 11, read_data);  // bit 11 starting at byte offset offset 0x12
            poll_done = ~read_data[0];
        end
    end
endtask

task perform_rx_equalization;
input fail_int;
reg [11:0]  cap_addr;
reg [15:0] ds_bdf;
    begin
        ds_bdf = `BFM_ID;
        // Write a 1 to bit 0 of the Link Control 3 Register (Perform Equalization)
        // Write a 1 to bit 1 of the same register if we want to generate an interrupt on the DS Port
        cap_addr = get_cap_sec_pcie_addr(ds_bdf);
        cfg_rmw_bdf(ds_bdf, cap_addr + 12'h004, 1, 0, {fail_int,1'b1});

        //            // Retrain to 8G autonomously
        //            case (curr_width)
        //                6'h01 :  hw_auto_reg  = {16'h0001, 4'h0, 4'd3, 7'h0, 1'b1};
        //                6'h02 :  hw_auto_reg  = {16'h0003, 4'h0, 4'd3, 7'h0, 1'b1};
        //                6'h04 :  hw_auto_reg  = {16'h000f, 4'h0, 4'd3, 7'h0, 1'b1};
        //                6'h08 :  hw_auto_reg  = {16'h00ff, 4'h0, 4'd3, 7'h0, 1'b1};
        //                6'h10 :  hw_auto_reg  = {16'hffff, 4'h0, 4'd3, 7'h0, 1'b1};
        //                default: hw_auto_reg  = {16'h0001, 4'h0, 4'd3, 7'h0, 1'b1};
        //            endcase
        //            cap_addr = get_cap_ven_addr(`DUT_ID);
        //            `CFG_WR_BDF(`DUT_ID, cap_addr + 12'h010, 4'hf, hw_auto_reg);

        // Specify the Target Link Speed for the Retrain (8G)
        // Write to Link Control 2 Register (30h) in the BFM
        //   [3:0] Target Link Speed
        //     [4] Enter Compliance
        //     [5] HW Autonomous Speed Disable
        //     [6] Selectable Deemphasis
        //   [9:7] Transmit Margin
        //    [10] Enter Modified Compliance
        //    [11] Compliance SOS
        // [15:12] Compliance Preset/De-Emphasis
        cap_addr = get_cap_pcie_addr(ds_bdf);
        cfg_rmw_bdf(ds_bdf, cap_addr + 12'h030, 3, 0, 3);

        retrain_link;
    end
endtask

task check_eq_results;
input [3:0] initial_speed;
input       skip_phases_2_3;
input       fail_test;
input [1:0] fail_phase;
input       int_status;
input       fail_int;

reg [11:0] cap_addr;
reg [31:0] read_data;
reg [3:0]  curr_speed;
reg [5:0]  curr_width;
reg [31:0] exp_result;
reg [15:0] bdf;
integer    k;


    begin
        // Confirm all equalization phases passed
        // Link Status 2: (PCIe Capability, Offset 0x32)
        // [0] = Cur Deemph(5G),
        // [1] = Equalization Complete,
        // [2] = Phase 1 Pass,
        // [3] = Phase 2 Pass
        // [4] = Phase 3 Pass
        // [5] = Link Equalization Request
        for (k=0; k < 2; k = k + 1)
        begin
            bdf = (k == 0) ? `BFM_ID : `DUT_ID;
            cap_addr = get_cap_pcie_addr(bdf);
            cfg_read_bdf(bdf, cap_addr + 12'h032, 5, 0, read_data);

            if (fail_test & ~skip_phases_2_3)
                // Fail in Phase 2 or 3
                case(fail_phase)
                    2'd2:      exp_result[4:0] = 5'b1_0011;
                    2'd3:      exp_result[4:0] = 5'b1_0111;
                    default:   exp_result[4:0] = 5'b1_0001;
                endcase
            else
            begin
                if (skip_phases_2_3)
                    // Passed with Phases 2 & 3 Skipped
                    // DS Port shows this as all phases passed, US shows as only Phase 1 Pass
                    exp_result[4:0] = (k==0) ? 5'b0_1111 : 5'b0_0011;
                else
                    // Pass all phases
                    exp_result[4:0] = 5'b0_1111;
            end
            if (read_data[5:1] != exp_result[4:0])
            begin
                $display("%m: Error: %0s Equalization Results Incorrect: %0s, %0s, Phase 1: %0s, Phase 2: %0s, Phase 3: %0s (Should be %0s, %0s, Phase 1: %0s, Phase 2: %0s, Phase 3: %0s)",
                          k ? "DUT" : "BFM",
                          read_data[1] ? "Complete" : "Incomplete",
                          read_data[5] ? "Link EQ Req" : "No Link EQ Req",
                          read_data[2] ? "Pass" : "Failed",
                          read_data[3] ? "Pass" : "Failed",
                          read_data[4] ? "Pass" : "Failed",
                          exp_result[0] ? "Complete" : "Incomplete",
                          exp_result[4] ? "Link EQ Req" : "No Link EQ Req",
                          exp_result[1] ? "Pass" : "Failed",
                          exp_result[2] ? "Pass" : "Failed",
                          exp_result[3] ? "Pass" : "Failed"
                          );
                `INC_ERRORS;
            end
            if (k==0)
            begin
                // Check Interrupt Status on DS Port, then clear the interrupt
                if (int_status !== (exp_result[4] & fail_int))
                begin
                    $display("%m: Error: DS Port Interrupt Status (%b) not as expected (%b)",
                              int_status,
                              exp_result[4] & fail_int);
                    `INC_ERRORS;
                end
                // Clear the interrupt
                cfg_rmw_bdf(bdf, cap_addr + 12'h032, 5, 5, 1);
            end
        end

        if (~fail_test | skip_phases_2_3)
            exp_result[3:0] = 4'd3; // Should finish at 8G if we passed Phases 2/3 (or they were not run)
        else
            if (initial_speed < 3)
                exp_result[3:0] = initial_speed;
            else
                exp_result[3:0] = 4'd1; // Spec calls for fallback to 2.5G if Equalization fails when started from L0 in 8G.

        check_speed_width(exp_result[3:0], 1'bx);
    end
endtask

task check_speed_width;
input [3:0] speed;
input integer width;

reg [11:0] cap_addr;
reg [31:0] read_data;
reg [3:0]  curr_speed;
reg [5:0]  curr_width;
reg [31:0] exp_result;
reg [15:0] bdf;
integer    k;

    begin
        // Confirm we are in the correct speed and width
        // Link Status: (PCIe Capability, Offset 0x12)
        // [3:0] = Link Speed,
        // [9:4] = Link Width,
        case (width)
            1:       exp_result[9:4] = 6'b00_0001;
            2:       exp_result[9:4] = 6'b00_0010;
            4:       exp_result[9:4] = 6'b00_0100;
            8:       exp_result[9:4] = 6'b00_1000;
            16:      exp_result[9:4] = 6'b01_0000;
            32:      exp_result[9:4] = 6'b10_0000;
            default: exp_result[9:4] = 6'bxx_xxxx; // Used when not checking width
        endcase
        exp_result[3:0] = speed;

        for (k=0; k < 2; k = k + 1)
        begin
            bdf = (k == 0) ? `BFM_ID : `DUT_ID;
            cap_addr = get_cap_pcie_addr(bdf);
            cfg_read_bdf(bdf, cap_addr + 12'h012, 9, 0, read_data);
            curr_width = read_data[9:4];
            curr_speed = read_data[3:0];
            if (exp_result[9:4] === 6'bxx_xxxx)
                exp_result[9:4] = read_data[9:4];
            if ({curr_width,curr_speed} !== exp_result[9:0])
            begin
                $display("%m: Error: %0s Link Width, Speed does not match expected.  Got Speed: %0s (%h) Width: %b",
                          k ? "DUT" : "BFM",
                          curr_speed == 4'd1 ? "2.5G" : curr_speed == 4'd2 ? "5G" : curr_speed == 4'd3 ? "8G" : "XX",
                          curr_speed,
                          curr_width,
                          );
                `INC_ERRORS;
            end
        end
    end
endtask

task get_speed_width;
output [3:0] speed;
output integer width;

reg [11:0] cap_addr;
reg [31:0] read_data;
reg [3:0]  curr_speed;
reg [5:0]  curr_width;
reg [31:0] exp_result;
reg [15:0] bdf;
integer    k;

    begin
        // Link Status: (PCIe Capability, Offset 0x12)
        // [3:0] = Link Speed,
        // [9:4] = Link Width,
        cap_addr = get_cap_pcie_addr(`DUT_ID);
        cfg_read_bdf(`DUT_ID, cap_addr + 12'h012, 9, 0, read_data);
        curr_width = read_data[9:4];
        case (curr_width)
            6'b00_0001: width = 1;
            6'b00_0010: width = 2;
            6'b00_0100: width = 4;
            6'b00_1000: width = 8;
            6'b01_0000: width = 16;
            6'b10_0000: width = 32;
            default: width = 0;
        endcase

        speed = read_data[3:0];
    end
endtask



task set_bfm_control;

input   integer                 lsb;
input   integer                 bitsize;
input   [1215:0]                value;

integer                         msb;
reg     [1215:0]                orig_val;
reg     [1215:0]                new_val;
integer i;
    begin
        orig_val = `BFM_PCIE_CORE.mgmt_cfg_control;
        msb = lsb + bitsize - 1;
        for (i=0; i<1216; i=i+1)
            if ((i < lsb) || (i > msb))
                new_val[i] = orig_val[i];
            else
                new_val[i] = value[i-lsb];
        force `BFM_PCIE_CORE.mgmt_cfg_control = new_val;
        @(posedge clk); // delay needed to handle back to back forces properly
    end
endtask


task set_bfm_constants;

input   integer                 lsb;
input   integer                 bitsize;
input   [1023:0]                value;

integer msb;
reg [1023:0] orig_val;
reg [1023:0] new_val;
integer i;
    begin
        orig_val = `RP0_PATH.mgmt_cfg_constants;
        msb = lsb + bitsize - 1;
        for (i=0; i < 1024; i = i + 1)
            if ((i < lsb) || (i > msb))
                new_val[i] = orig_val[i];
            else
                new_val[i] = value[i-lsb];
        force `RP0_PATH.mgmt_cfg_constants = new_val;
        @(posedge clk); // delay needed to handle back to back forces properly
    end
endtask


task set_completion_error_mode;

input ecrc_errors;
input poison_errors;
    begin
        wr_fld("BFM", 0, "mgmt_cfg_constants", "set_ecrc_err_on_ep_set",  ecrc_errors);
        wr_fld("BFM", 0, "mgmt_cfg_constants", "clr_ep_on_ep_set",  ~poison_errors);
    end
endtask

task cfg_rmw_bdf;
    input   [15:0]              bdf;
    input   [15:0]              byte_addr;
    input   [5:0]               msb;
    input   [5:0]               lsb;
    input   [31:0]              wdata;
    begin
        cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,1'b0,wdata);
    end
endtask

task cfg_rmw_chk_bdf;
    input   [15:0]              bdf;
    input   [15:0]              byte_addr;
    input   [5:0]               msb;
    input   [5:0]               lsb;
    input                       chk_data;
    input   [31:0]              wdata;

    reg     [15:0]              dword_aligned_addr;
    reg     [1:0]               offset;
    reg     [6:0]               adj_lsb;
    reg     [6:0]               adj_msb;
    reg     [3:0]               byte_en;
    reg     [31:0]              rdata_32,wdata_32,wdata_32_be;
    integer i,j;

    begin
        dword_aligned_addr = {byte_addr[15:2],2'b00};
        offset = byte_addr[1:0];
        adj_lsb = lsb + (offset * 8);
        adj_msb = msb + (offset * 8);
        if ((adj_lsb > adj_msb) ||
            (adj_lsb) > 31 ||
            (adj_msb) > 31)
        begin
            $display("%m: Illegal address bit spec: byte_addr=0x%h, msb = %d, lsb = %d",byte_addr, msb,lsb);
            `INC_ERRORS;
        end

        // if write is not full bytes, then a read is needed
        if (((lsb % 8) !== 0) || ((msb % 8) !== 7))
            cfg_read_chk_bdf(bdf,dword_aligned_addr,31,0,chk_data,rdata_32);
        else
            rdata_32 = 0;

        byte_en = 4'b0000;
        wdata_32 = rdata_32;
        // Assert only the necessary byte enables
        for (i=0;i<32;i=i+1)
            if ((i >= adj_lsb) && (i <= adj_msb))
            begin
                wdata_32[i] = wdata[i-adj_lsb];
                byte_en[i/8] = 1'b1;
            end

        if (chk_data == 1'b1)
        begin
            // If we are in test mode, write once for each byte enable, to test each byte enable
            for (j=0;j<4;j=j+1)
                if (byte_en[j])
                begin
                    // Invert write data on non-enabled bytes for better testing
                    case (j)
                        0: wdata_32_be = wdata_32 ^ 32'hFFFFFF00;
                        1: wdata_32_be = wdata_32 ^ 32'hFFFF00FF;
                        2: wdata_32_be = wdata_32 ^ 32'hFF00FFFF;
                        3: wdata_32_be = wdata_32 ^ 32'h00FFFFFF;
                    endcase
//                    if (byte_en[0]+byte_en[1]+byte_en[2]+byte_en[3] > 1)
//                        $display("%m: Breaking multi-byte config write up for be testing, testing byte %0d",j);
                    `CFG_WR_BDF(bdf, dword_aligned_addr, 4'b1<<j, wdata_32_be);
                end
        end
        else
        begin
            // Invert write data on non-enabled bytes for better testing
            for (i=0;i<32;i=i+1)
                wdata_32_be[i] = wdata_32[i] ^ (~byte_en[i/8]);

            `CFG_WR_BDF(bdf, dword_aligned_addr, byte_en, wdata_32_be);
        end
    end
endtask

// This task is a wrapper replacement for the BFM cfg_rd_bdf task, used when FAST_CONFIG_READS is defined
task automatic cfg_rd_bdf;

input   [15:0]      bdf;        // DUT ID: {Bus[7:0], Device[4:0], Function[2:0]}
input   [11:0]      addr;       // Cfg Register Byte Address; DWORD resolution; addr[1:0] ignored
input   [3:0]       be;         // Byte enables
output  [31:0]      rd_data;    // Return data that was read

    begin
        cfg_read_chk_bdf(bdf,addr,31,0,1'b0,rd_data);
    end
endtask

reg use_fast_dut_cfg_access = 1'b1;

task cfg_read_bdf;
input   [15:0]  bdf;
input   [15:0]  byte_addr;
input   [5:0]   msb;
input   [5:0]   lsb;
output  [31:0]  rdata;
    begin
        cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,1'b0,rdata);
    end
endtask

task cfg_read_chk_bdf;

input   [15:0]  bdf;
input   [15:0]  byte_addr;
input   [5:0]   msb;
input   [5:0]   lsb;
input           chk_data_in;
output  [31:0]  rdata;

reg     [15:0]  dword_aligned_addr;
reg     [1:0]   offset;
reg     [6:0]   adj_lsb;
reg     [6:0]   adj_msb;
reg     [31:0]  rdata_32;
reg     [3*8:0] bus;
reg             chk_data;
reg   [8*128:0] fieldname;
integer         i;
reg [31:0] rdata_32_chk;
reg fast_read_capable;
    begin
        dword_aligned_addr = {byte_addr[15:2],2'b00};

            chk_data = chk_data_in;

        offset = byte_addr[1:0];
        adj_lsb = lsb + (offset * 8);
        adj_msb = msb + (offset * 8);
        if ((adj_lsb > adj_msb) ||
            (adj_lsb) > 31 ||
            (adj_msb) > 31)
        begin
            $display("%m: Illegal address bit spec: byte_addr=0x%h, msb = %d, lsb = %d",byte_addr, msb,lsb);
            `INC_ERRORS;
        end

        fast_read_capable = 0;
        `RP0_PATH.cfg_rd_bdf(bdf, dword_aligned_addr, 4'b1111, rdata_32);

        if ((fast_read_capable == 1'b1) && (chk_data == 1'b1))
        begin
            if (rdata_32 !== rdata_32_chk)
            begin
                `INC_ERRORS;
                $display  ("%m : ERROR: Config Read from 0x%0h does not match mgmt_cfg_status bus (read: %0h, bus: %0h) at time %0t",
                           dword_aligned_addr, rdata_32, rdata_32_chk,$time);
            end
        end
        rdata = 32'b0;
        for (i=adj_lsb;i<adj_msb+1;i=i+1)
            rdata[i-adj_lsb] = rdata_32[i];
    end
endtask

task cfg_bar_test_bdf;
input [15:0]      bdf;
input [15:0]      byte_addr;
input [8*256-1:0] bar_name;
input [2:0]       bar_num;
input [63:0]      bar_config;
input [31:0]      page_config;
reg io_bar;
reg mem_64bit;
reg mem_prefetch;
reg bar_exp;
integer last_ro;
integer page_size;
reg [63:0] page_vector;

    begin
        if (bar_config[31:0] == 31'b0)
        begin
            $display  ("%m : Testing Disabled BAR: %0s%0d",bar_name,bar_num);
            cfg_test_bdf (bdf,
                          byte_addr,
                          31,0,
                          "Disabled BAR",
                          "RO",
                          0);
        end
        else
        begin
            io_bar = bar_config[0];
            mem_64bit = (bar_config[2:1] == 2'b10);
            mem_prefetch = bar_config[3];
            bar_exp = (bar_num == 6);

            if (~bar_exp & ~io_bar & mem_64bit)
                last_ro = 63;
            else
                last_ro = 31;

            if (bar_num == 0)
                page_vector = page_config << 12; // BAR0 must be at least 2 page sizes in size to account for MSI-X table
            else
                page_vector = page_config << 11;

            while (bar_config[last_ro] & ~page_vector[last_ro])
                last_ro = last_ro - 1;

            if (bar_exp)
            begin
                $display  ("%m : Testing %0s Configured for Size %0d KB",bar_name,2**(last_ro+1-10));
                cfg_test_bdf (bdf,
                              byte_addr,
                              0,0,
                              "Expansion ROM BAR: Enable",
                              "RO",
                              1);
                if (last_ro > 9 && last_ro < 25)
                begin
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  last_ro,1,
                                  "Expansion ROM BAR: Read Only Bits",
                                  "RO",
                                  0);
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  31,last_ro+1,
                                  "Expansion ROM BAR: Read/Write Bits",
                                  "RW",
                                  0);
                end
                else
                begin
                    `INC_ERRORS;
                    $display  ("%m : ERROR: Expansion ROM BAR: Illegal Configuration Size (must be 2K to 16MB) at time %0t",
                               bar_config[31:0],$time);
                end
            end
            else
            begin
            if (~io_bar & mem_64bit)
                $display  ("%m : Testing 64-bit %0s%0d Configured for Size %0d KB",bar_name,bar_num,2**(last_ro+1-10));
            else
                $display  ("%m : Testing %0s%0d using Configured for Size %0d KB",bar_name,bar_num,2**(last_ro+1-10));

                cfg_test_bdf (bdf,
                              byte_addr,
                              0,0,
                              "BAR Memory Space Indicator",
                              "RO",
                              io_bar);

                if (io_bar)
                begin: IO_BAR
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  1,1,
                                  "Reserved",
                                  "RO",
                                  0);
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  last_ro,2,
                                  "IO BAR Read Only Bits",
                                  "RO",
                                  0);
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  31,last_ro+1,
                                  "IO BAR Read/Write Bits",
                                  "RW",
                                  0);
                end
                else
                begin: MEM_BAR
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  2,1,
                                  "MEM BAR Type",
                                  "RO",
                                  mem_64bit ? 2'b10 : 2'b00);
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  3,3,
                                  "MEM Prefetchable",
                                  "RO",
                                  /*mem_64bit ? 1'b1 :*/ mem_prefetch);
                    cfg_test_bdf (bdf,
                                  byte_addr,
                                  (last_ro > 31) ? 31 : last_ro,4,
                                  "MEM BAR Read Only Bits",
                                  "RO",
                                  0);
                    if (last_ro < 31)
                        cfg_test_bdf (bdf,
                                      byte_addr,
                                      31,last_ro+1,
                                      "MEM BAR Read/Write Bits",
                                      "RW",
                                      0);
                    if (mem_64bit)
                    begin
                        if (last_ro > 31)
                            cfg_test_bdf (bdf,
                                          byte_addr+4,
                                          last_ro-32,0,
                                          "MEM Upper BAR Read Only Bits",
                                          "RO",
                                          0);
                        if (last_ro < 63)
                        cfg_test_bdf (bdf,
                                      byte_addr+4,
                                      31,(last_ro > 31) ? (last_ro-32+1) : 0,
                                      "MEM Upper BAR Read/Write Bits",
                                      "RW",
                                      0);
                    end
                end
            end
        end
    end
endtask


task cfg_test_bdf;
input [15:0]      bdf;
input [15:0]      byte_addr;
input [5:0]       msb;
input [5:0]       lsb;
input [8*256-1:0] reg_name;
input [8*16-1:0]  reg_type;
input [31:0]      reg_default;
    begin
        cfg_test_bdf_m(bdf,byte_addr,msb,lsb,reg_name,reg_type,reg_default,32'hFFFF_FFFF);
    end
endtask

task cfg_test_bdf_m;
input [15:0]      bdf;
input [15:0]      byte_addr;
input [5:0]       msb;
input [5:0]       lsb;
input [8*256-1:0] reg_name;
input [8*16-1:0]  reg_type;
input [31:0]      reg_default;
input [31:0]      ro_mask;

reg [31:0]     init_read_data;
reg [31:0]     read_data;
reg [31:0]     reg_default_i;
reg [31:0]     mask;
reg [31:0]     test_data;
reg [8*16-1:0] reg_type_i;
integer        i;
reg [7:0]      b;
reg [4:0]      d;
reg [2:0]      f;
reg            flr_exception;
reg            sticky;
reg            chk_data;
    begin
        chk_data = 1'b1;
        reg_type_i    = reg_type;
        flr_exception = 0;
        sticky        = 0;
        reg_default_i = reg_default;

        // FLR Exceptions include:
        if (reg_type_i[15:0] == "-F")
        begin
            flr_exception = 1;
            reg_type_i = reg_type_i >> 16;
        end
        if (reg_type_i[7:0] == "S")
        begin
            flr_exception = 1;
            sticky = 1;
            reg_type_i = reg_type_i >> 8;
        end

        b = bdf[15:8];
        d = bdf[7:3];
        f = bdf[2:0];
        for (i=0;i<32;i=i+1) mask[i] = (i < (msb-lsb+1)) & ro_mask[i];

        $display  ("%m : Testing %0s at BDF=0x%h, Type %0s, Config Byte Address: 0x%0h, Bits %0d:%0d",
                   reg_name,
                   bdf,
                   reg_type_i,
                   byte_addr,msb,lsb);

        if (ro_mask !== 32'hffff_ffff)
            $display  ("%m : Using Read-Only Bit Mask of 0x%h",ro_mask);

        // Read Initial Register Value
        cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,init_read_data);

        // Default Value Test
        if (reg_default_i[0] !== 1'bx)
            if (init_read_data !== reg_default_i)
            begin: DEFAULT_TEST
                $display  ("%m : ERROR : Register Field %0s not at default value (expected: 0x%0h, got: 0x%0h) at time %0t",
                           reg_name,reg_default_i,init_read_data,$time);
                `INC_ERRORS;
            end

        if (sticky == 1'b1)
        begin
            $display  ("%m : Note : Register Field %0s not sticky tested to avoid multiple Convential Resets during register testing",
                       reg_name,$time);
        end

        case (reg_type_i)
            "RO","HWINIT": begin: READ_ONLY_TEST
                if (flr_exception)
                begin: ROS_FLR_TEST
                    if ((reg_default_i[0] !== 1'bx) && (init_read_data == reg_default_i))
                        $display  ("%m : Note : Register Field %0s could not be FLR tested since it is not controllable and it's initial value is equal to its default value",
                                   reg_name,$time);
                    else
                    begin
                        // Initiate Function Level Reset
                        cfg_rmw_chk_bdf ({b,d,f},
                                         cap_pcie_addr[b][d][f]+12'h8,
                                         15,15,chk_data,
                                         1);
                        // Confirm we are still at the initial value
                        cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);
                        if (read_data !== init_read_data)
                        begin
                            $display  ("%m : ERROR : Register Field %0s not at previous value after FLR (expected: 0x%0h, got: 0x%0h) at time %0t",
                                       reg_name,init_read_data,read_data,$time);
                            `INC_ERRORS;
                        end
                    end
                end
                // Write bits to opposite of read value, then read back
                test_data = init_read_data ^ mask;
                cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,test_data);
                cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);

                if (read_data !== init_read_data)
                begin
                    $display  ("%m : ERROR : Register Field %0s not at initial value (expected: 0x%0h, got: 0x%0h) at time %0t",
                               reg_name,init_read_data,read_data,$time);
                    `INC_ERRORS;
                end
                if (reg_type_i == "HWINIT")
                begin: HWINIT_TEST
                    // Enable HWINIT Programming
                    cfg_rmw_chk_bdf(bdf,cap_ven_addr[b][d][f]+12'h8,0,0,chk_data,1);
                    // Write to inverted value from current
                    test_data = read_data ^ mask;
                    cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,test_data);
                    // Read and confirm inverted value
                    cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);
                    if (read_data !== test_data)
                    begin
                        // Change HWINIT Problems to Warnings instead of Errors until we implement RTL support
                        $display  ("%m : WARNING : Register Field %0s not at inverted value (expected: 0x%0h, got: 0x%0h) at time %0t",
                                   reg_name,test_data,read_data,$time);
                        //`INC_ERRORS;
                    end
                    // Restore correct initial value
                    cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,init_read_data);
                    // Disable HWINIT Programming
                    cfg_rmw_chk_bdf(bdf,cap_ven_addr[b][d][f]+12'h8,0,0,chk_data,0);
                end
            end
            "RW": begin: READ_WRITE_TEST
                // Write bits to opposite of read value, then read back
                test_data = init_read_data ^ mask;
                cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,test_data);
                cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);

                if (read_data !== test_data)
                begin
                    $display  ("%m : ERROR : Register Field %0s not at inverted value (expected: 0x%0h, got: 0x%0h) at time %0t",
                               reg_name,test_data,read_data,$time);
                    `INC_ERRORS;
                end
                if (flr_exception)
                begin: RWS_FLR_TEST
                    // Initiate Function Level Reset
                    cfg_rmw_chk_bdf ({b,d,f},
                                     cap_pcie_addr[b][d][f]+12'h8,
                                     15,15,chk_data,
                                     1);
                    // Confirm we are still at tested data value
                    cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);
                    if (read_data !== test_data)
                    begin
                        $display  ("%m : ERROR : Register Field %0s not at inverted value after FLR (expected: 0x%0h, got: 0x%0h) at time %0t",
                                   reg_name,test_data,read_data,$time);
                        `INC_ERRORS;
                    end
                end
            end
            "RW1C": begin: READ_WRITE_CLR_W_1_TEST
                if (flr_exception)
                begin: RW1CS_FLR_TEST
                    if ((reg_default_i[0] !== 1'bx) && (init_read_data == reg_default_i))
                        $display  ("%m : Note : Register Field %0s could not be FLR tested since it is not controllable and it's initial value is equal to its default value",
                                   reg_name,$time);
                    else
                    begin
                        // Initiate Function Level Reset
                        cfg_rmw_chk_bdf ({b,d,f},
                                         cap_pcie_addr[b][d][f]+12'h8,
                                         15,15,chk_data,
                                         1);
                        // Confirm we are still at the initial value
                        cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);
                        if (read_data !== init_read_data)
                        begin
                            $display  ("%m : ERROR : Register Field %0s not at previous value after FLR (expected: 0x%0h, got: 0x%0h) at time %0t",
                                       reg_name,init_read_data,read_data,$time);
                            `INC_ERRORS;
                        end
                    end
                end

                // Write bits to zero, then read back - make sure no change
                test_data = 0;
                cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,test_data);
                cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);

                if (read_data !== init_read_data)
                begin
                    $display  ("%m : ERROR : Register Field %0s not at original value after write of 0 (expected: 0x%0h, got: 0x%0h) at time %0t",
                               reg_name,init_read_data,read_data,$time);
                    `INC_ERRORS;
                end

                // Write bits to one, then read back - make sure result is 0
                test_data = mask;
                cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,test_data);
                cfg_read_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,read_data);

                if (read_data !== (init_read_data & ~mask))
                begin
                    $display  ("%m : ERROR : Register Field %0s not at zero after write of 1 (expected: 0x%0h, got: 0x%0h) at time %0t",
                               reg_name,(init_read_data & ~mask),read_data,$time);
                    `INC_ERRORS;
                end
                if ((init_read_data & mask) == 0)
                begin
                    $display  ("%m : Note : Register Field %0s could not be reset tested since init value was 0 and is not controllable at time %0t",
                               reg_name,$time);
                end
            end
            default: begin
                $display  ("%m : ERROR : Register Field %0s specified with unknown Register Type (%0s) at time %0t",
                           reg_name,reg_type_i,$time);
                `INC_ERRORS;
            end
        endcase

        // Restore original value to Register
        cfg_rmw_chk_bdf(bdf,byte_addr,msb,lsb,chk_data,init_read_data);
    end
endtask

// --------------
// task reset_dut

// Task resets the DUT & BFM by forcing the primary reset input active on the device downstream from the root port.
task reset_dut;
    begin
        `DUT_RST_N = 1'b0;
        #1000000;
        `DUT_RST_N = 1'b1;
    end
endtask



// -----------------------
// task init_configure_pci

// Inialize Configuration Environment Variables
task init_configure_pci;

    integer b;
    integer d;
    integer f;
    integer r;
    integer i;

    begin
        // Configuration not completed
        pci_enumeration_complete = 1'b0;

        // Initialize state information
        for (b=0; b<MAX_BUS_NUM; b=b+1)
        begin
            for (d=0; d<MAX_DEVICE_NUM; d=d+1)
            begin
                for (f=0; f<MAX_FUNC_NUM; f=f+1)
                begin
                    dev_present        [b][d][f]    = 1'b0;
                    dev_id_for_vf      [b][d][f]    = 16'hFFFF;

                    for (r=0; r<MAX_BARS; r=r+1)
                    begin
                        bar_present         [b][d][f][r] = 1'b0;     // Not present
                        bar_io_mem_n        [b][d][f][r] = 1'b0;     // Memory
                        bar_addr            [b][d][f][r] = 64'h0;    // Default N/A
                        bar_index           [b][d][f][r] = 3'h0;     // Default N/A
                        bar_no_mem64        [b][d][f][r] = 1'b0;     // Default to allowing 64-bit address assignment
                        vf_bar_present      [b][d][f][r] = 1'b0;     // Not present
                        vf_bar_addr         [b][d][f][r] = 64'h0;    // Default N/A
                    end

                    exp_present             [b][d][f]    = 1'b0;     // Not present
                    exp_addr                [b][d][f]    = 32'h0;    // Not present

                    legi_present            [b][d][f]    = 1'b0;
                    legi_dcba               [b][d][f]    = 2'b00;

                    cap_pm_addr             [b][d][f]    = 12'h0;

                    cap_msi_disable         [b][d][f]    = 1'b0;
                    cap_msi_addr            [b][d][f]    = 12'h0;
                    cap_msi_rvec            [b][d][f]    = 8'h0;
                    cap_msi_64              [b][d][f]    = 1'b0;

                    cap_pcie_addr           [b][d][f]    = 12'h0;
                    cap_pcie_intvec         [b][d][f]    = 5'h0;
                    cap_pcie_devtype        [b][d][f]    = 4'h0;
                    cap_pcie_max_pl_size_sup[b][d][f]    = 3'h0;
                    cap_pcie_ex_tag_sup     [b][d][f]    = 1'b0;
                    cap_pcie_aspm_sup       [b][d][f]    = 2'h0;

                    cap_msix_disable        [b][d][f]    = 1'b0;
                    cap_msix_addr           [b][d][f]    = 12'h0;
                    cap_msix_rvec           [b][d][f]    = 12'h0;

                    cap_aer_addr            [b][d][f]    = 12'h0;

                    cap_ven_addr            [b][d][f]    = 12'h0;
                    cap_vsec_addr           [b][d][f]    = 12'h0;
                    cap_sec_pcie_addr       [b][d][f]    = 12'h0;
                    cap_pasid_addr          [b][d][f]    = 12'h0;
                    cap_ari_addr            [b][d][f]    = 12'h0;
                    cap_ats_addr            [b][d][f]    = 12'h0;
                    cap_sriov_addr          [b][d][f]    = 12'h0;
                    cap_tph_addr            [b][d][f]    = 12'h0;
                    cap_dsn_addr            [b][d][f]    = 12'h0;
                    cap_vpd_addr            [b][d][f]    = 12'h0;
                    cap_pb_addr             [b][d][f]    = 12'h0;
                    cap_resize_bar_addr     [b][d][f]    = 12'h0;
                    cap_dpa_addr            [b][d][f]    = 12'h0;
                    cap_l1pmss_addr         [b][d][f]    = 12'h0;
                    cap_ltr_addr            [b][d][f]    = 12'h0;

                    int_mode_msix_msi_leg   [b][d][f]    = INT_MODE_DISABLED;
                    int_num_vectors_req     [b][d][f]    = 12'h0;
                    int_num_vectors_alloc   [b][d][f]    = 12'h0;
                    int_base_vector_num     [b][d][f]    = 12'h0;
                    for (i=0; i<4096; i=i+1)
                        cap_list_status[i] = CAP_CLEARED;
                end
            end
        end

        // Memory is allocated beginning at these addresses and going downwards
        //   as device resources are discovered
        last_mem_bar_64[63:32] = ALLOC_MEM_BAR_64_HI;
        last_mem_bar_64[31: 0] = ALLOC_MEM_BAR_64_LO;
        last_mem_bar_32        = ALLOC_MEM_BAR_32;
        last_io_bar_32         = ALLOC_IO_BAR_32;

        gap_mem_bar            = 0;             //Override elsewhere, if memory gaps between BARs is desired.
        min_pg_size            = MIN_PAGE_SIZE; //Allow BAR_CONFIG tests to change this.
        report_barsize_viol_as_error = 1'b1;

        // Initialize default device variables
        dut_bdf = `DUT_ID;

        int_mode            = INT_MODE_DISABLED;
        int_num_vec_req     = 12'h0;
        int_num_vec_alloc   = 12'h0;
        int_num_base_vector = 12'h0;

        dev_is_present        = 1'b0;

        for (r=0; r<MAX_BARS; r=r+1)
        begin
            bar[r]        = 64'h0;
            bar_exists[r] = 1'b0;
        end

        exp_bar       = 32'h0;

        cap_addr_pm   = 12'h0;
        cap_addr_msi  = 12'h0;
        cap_addr_pcie = 12'h0;
        cap_addr_msix = 12'h0;
        cap_addr_aer  = 12'h0;
        cap_addr_ven  = 12'h0;
    end
endtask



// --------------------------
// task change_default_device

// Changes the default device to the one specified by bdf
//   Loads the new device's BAR, ExpROM, and Capability info
//   from the mult-dimensional arrays conatining all functions
//   into registers that can be conveniently accessed
task change_default_device;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;
    integer         r;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        dut_bdf = bdf;

        int_mode            = get_int_mode           (dut_bdf);
        int_num_vec_req     = get_int_num_vec_req    (dut_bdf);
        int_num_vec_alloc   = get_int_num_vec_alloc  (dut_bdf);
        int_num_base_vector = get_int_base_vector_num(dut_bdf);

        dev_is_present        = dev_present[b][d][f];

        for (r=0; r<MAX_BARS; r=r+1)
        begin
            bar[r]           = bar_addr    [b][d][f][r];
            bar_exists[r]    = bar_present [b][d][f][r];
        end
        exp_bar    = exp_addr [b][d][f];

        cap_addr_pm   = cap_pm_addr   [b][d][f];
        cap_addr_msi  = cap_msi_addr  [b][d][f];
        cap_addr_pcie = cap_pcie_addr [b][d][f];
        cap_addr_msix = cap_msix_addr [b][d][f];
        cap_addr_aer  = cap_aer_addr  [b][d][f];
        cap_addr_ven  = cap_ven_addr  [b][d][f];
        cap_addr_tph  = cap_tph_addr  [b][d][f];
        cap_addr_dsn  = cap_dsn_addr  [b][d][f];
    end
endtask



// ---------------------------
// Interrupt Look-Up Functions

function automatic [1:0] get_int_mode;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_int_mode = int_mode_msix_msi_leg[b][d][f];
    end
endfunction

function automatic [1:0] get_int_pin;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_int_pin = legi_dcba[b][d][f];
    end
endfunction

function automatic [11:0] get_int_num_vec_req;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_int_num_vec_req = int_num_vectors_req[b][d][f];
    end
endfunction

function automatic [11:0] get_int_num_vec_alloc;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_int_num_vec_alloc = int_num_vectors_alloc[b][d][f];
    end
endfunction

function automatic [11:0] get_int_base_vector_num;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_int_base_vector_num = int_base_vector_num[b][d][f];
    end
endfunction
task automatic wait_int;

    input   [15:0]  bdf;            // Function whose interrupt we want to wait for
    input   [11:0]  vector;         // Interrupt vector number to wait for
    input   [31:0]  timeout_clks;   // Number of clocks to wait for an interrupt before timing out
    output          int_status;     // 1 == Received Interrupt; 0 == Time-Out

    reg     [1:0]   int_mode;
    reg     [1:0]   int_pin;
    reg             done;
    reg             timeout;
    reg     [31:0]  tctr;

    begin
        int_mode   = get_int_mode(bdf);
        int_pin    = get_int_pin(bdf);  // Legacy Interrupt Pin used
        done       = 1'b0;
        timeout    = 1'b0;
        int_status = 1'b0; // Default == Timed out
        tctr       = 32'h0;

        if (int_mode == INT_MODE_DISABLED)
        begin
            $display  ("%m : ERROR : Requested to wait for an interrupt for a device that is not allocated any interrupt vectors");
            `INC_ERRORS;
        end
        else
        begin
            while ((done == 1'b0) & (timeout == 1'b0))
            begin
                @(posedge clk);

                tctr = tctr + 32'h1;
                // Check for timeout
                if (tctr == timeout_clks)
                    timeout = 1'b1;

                if      (int_mode == INT_MODE_MSIX)
                begin
                    if (`BFM_INT_MSIX_VECTOR_HIT[vector[11:0]])
                    begin
                        done = 1'b1;
                        if (debug) $display  ("%m : Debug : Received expected MSI-X Interrupt");
                    end
                end
                else if (int_mode == INT_MODE_MSI)
                begin
                    if (`BFM_INT_MSI_VECTOR_HIT[vector[4:0]])
                    begin
                        done = 1'b1;
                        if (debug) $display  ("%m : Debug : Received expected MSI Interrupt");
                    end
                end
                else if (int_mode == INT_MODE_LEGACY)
                begin
                    if (`BFM_INT_LEGI_VECTOR_HIT[int_pin])
                    begin
                        done = 1'b1;
                        if (debug) $display  ("%m : Debug : Received expected Legacy Interrupt");
                    end
                end
                else
                begin
                    $display  ("%m : ERROR : Requested to wait for an interrupt vector for a device that is not allocated any interrupt vectors");
                    `INC_ERRORS;
                end
            end

            if (done == 1'b0)
                int_status = 1'b0; // Timed out waiting for interrupt
            else
                int_status = 1'b1; // Successfully received interrupt
        end
    end
endtask

// ----------------------------
// Capability Look-Up Functions

function automatic [11:0] get_cap_pm_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_pm_addr = cap_pm_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_msi_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_msi_addr = cap_msi_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_pcie_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_pcie_addr = cap_pcie_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_msix_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_msix_addr = cap_msix_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_aer_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_aer_addr = cap_aer_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_ven_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_ven_addr = cap_ven_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_tph_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_tph_addr = cap_tph_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_dsn_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_dsn_addr = cap_dsn_addr[b][d][f];
    end
endfunction

function automatic [11:0] get_cap_sec_pcie_addr;

    input   [15:0]  bdf;

    integer         b;
    integer         d;
    integer         f;

    begin
        b = bdf[15:8];
        d = bdf[ 7:3];
        f = bdf[ 2:0];

        get_cap_sec_pcie_addr = cap_sec_pcie_addr[b][d][f];
    end
endfunction



// ------------------
// task configure_pci

// Configures the PCIe Hierarchy
task automatic configure_pci;

    input   [7:0]       bus;

    reg     [4:0]       max_dev;

    integer             b;
    integer             d;
    integer             f;
    integer             r;

    reg     [7:0]       bnum;
    reg     [4:0]       dnum;
    reg     [2:0]       fnum;
    reg     [15:0]      bdf;

    reg     [31:0]      rd_data;

    begin
        // Inialize Configuration Environment Variables
        init_configure_pci;

        // Make sure we are in L0 and the Data Link Layer is up before continuing
        while ((`RP0_PATH.mgmt_pcie_status[7:2] != 6'h3) | (dl_link_up == 0))
            @(posedge clk);

        // Wait 100 more clocks to give LTSSM opportunity to enter Recovery to change speed
        repeat (100)
            @(posedge clk);

        // -------------------------------
        // Configure PCI Express Hierarchy

        // Only expect one device (the Root Port) to be located on the Host Bus
        max_dev = 0; // 1 Device

        // Configure Bus 0; will configure the entire PCIe hierarchy; configure_bus
        //   calls itself additional times as additional busses are discovered
        configure_bus  (bus,                // bus
                        bus + 1,            // next bus to allocate
                        max_dev,            // Device numbers to scan (0 to max_dev)
                        last_mem_bar_64,    // last_mem_bar_64
                        last_mem_bar_32,    // last_mem_bar_32
                        last_io_bar_32,     // last_io_bar_32
                        0);                 // minumum_cfg (0 = full config, including BARs and SRIOV)

        // ----------------------------------
        // Configure PCI Express Capabilities

        use_fast_dut_cfg_access = 1'b1; // Used only in CSR_CONFIG_ACCESS mode

        begin : pcie_cap

        reg     [2:0]       max_pl_size_sup;
        reg     [2:0]       max_rd_req_size;

            $display  ("%m : Configuring PCI Express Capability of all discovered functions");

            // Determine the highest common Max Payload Size supported
            max_pl_size_sup = BFM_MAX_PAYLOAD_SIZE;
            max_rd_req_size = BFM_MAX_RD_REQ_SIZE;
            for (b=0; b<MAX_BUS_NUM; b=b+1)
            begin
                for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                begin
                    for (f=0; f<MAX_FUNC_NUM; f=f+1)
                    begin
                        // Device and PCIe Capability Present
                        if ((dev_present[b][d][f]) & (cap_pcie_addr[b][d][f] != 12'h0))
                        begin
                            if (cap_pcie_max_pl_size_sup[b][d][f] < max_pl_size_sup)
                                max_pl_size_sup = cap_pcie_max_pl_size_sup[b][d][f];
                        end
                    end
                end
            end

            for (b=0; b<MAX_BUS_NUM; b=b+1)
            begin
                for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                begin
                    for (f=0; f<MAX_FUNC_NUM; f=f+1)
                    begin
                        // Device and PCIe Capability Present
                        if ((dev_present[b][d][f]) & (cap_pcie_addr[b][d][f] != 12'h0))
                        begin
                            bnum = b[7:0];
                            dnum = d[4:0];
                            fnum = f[2:0];
                            bdf  = {bnum, dnum, fnum};

                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : PCIe Cap : Assigning MaxPayloadSize=%d, MaxReadRequestSize=%d, ExtendedTagEnable=%d, EnablePCIeErrReporting", bdf[15:8], bdf[7:3], bdf[2:0], (16'd128<<max_pl_size_sup), (16'd128<<max_rd_req_size), cap_pcie_ex_tag_sup[b][d][f]);

                            // Do Read-Modify-Write
                            //           bdf, addr,                         be,   rd_data
                            `CFG_RD_BDF (bdf, cap_pcie_addr[b][d][f] + 'h8, 4'hf, rd_data);
                            rd_data[14:12] = max_rd_req_size;               // Max Read Request Size
                            rd_data[    8] = cap_pcie_ex_tag_sup[b][d][f];  // Enable Extended Tag Support if it is being advertised
                            rd_data[ 7: 5] = max_pl_size_sup;               // Max Payload Size
                            rd_data[ 3: 0] = 4'hf;                          // Enable PCI Express Error Reporting
                            //           bdf, addr,                         be,   rd_data
                            `CFG_WR_BDF_NULL (bdf, cap_pcie_addr[b][d][f] + 'h8, 4'h3, rd_data);
                        end
                    end
                end
            end
        end
        // ------------------------
        // Configure AER Capability

        begin : aer_cap

        reg     [31:0]      ecrc_enable;

            $display  ("%m : Configuring AER Capability of all discovered functions");

            for (b=0; b<MAX_BUS_NUM; b=b+1)
            begin
                for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                begin
                    for (f=0; f<MAX_FUNC_NUM; f=f+1)
                    begin
                        bnum = b[7:0];
                        dnum = d[4:0];
                        fnum = f[2:0];
                        bdf  = {bnum, dnum, fnum};

                        if (cap_aer_addr[b][d][f] != 12'h0) // Device has AER Capability
                        begin
                            //           bdf, addr,                       be,   rd_data
                            `CFG_RD_BDF (bdf, cap_aer_addr[b][d][f]+'h18, 4'hf, rd_data);
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : AER Cap : ECRC Generation Capable=%d, ECRC Check Capable=%d", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[5], rd_data[7]);

                            if ( ( ((DUT_ECRC_GEN_ON   != 0) & (bdf[15:8] == dut_bdf[15:8])) |
                                   ((BFM_ECRC_GEN_ON   != 0) & (bdf       == `BFM_ID      )) ) & rd_data[5]) // ECRC Generation Capable and configured to enable
                                ecrc_enable = 32'h00000040; // Set ECRC Generation Enable
                            else
                                ecrc_enable = 32'h00000000;

                            if ( ( ((DUT_ECRC_CHECK_ON != 0) & (bdf[15:8] == dut_bdf[15:8])) |
                                   ((BFM_ECRC_CHECK_ON != 0) & (bdf       == `BFM_ID      )) ) & rd_data[7]) // ECRC Check Capable and configured to enable
                                ecrc_enable = ecrc_enable | 32'h00000100; // Set ECRC Check Enable

                            if (ecrc_enable != 32'h0)
                            begin
                                //           bdf, addr,                       be,   wr_data
                                `CFG_WR_BDF_NULL (bdf, cap_aer_addr[b][d][f]+'h18, 4'hf, ecrc_enable[31:0]);
                            end

                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : AER Cap : ECRC Generation Enable=%d, ECRC Check Enable=%d", bdf[15:8], bdf[7:3], bdf[2:0], ecrc_enable[6], ecrc_enable[8]);
                        end
                    end
                end
            end
        end

        // --------------
        // Enable Devices

        // Note: Need to perform this step before MSI-X Interrupt allocation because Memory Writes must be able
        //   to traverse the PCIe hierarchy to setup the MSI-X tables
        $display  ("%m : Enable SERR#, PERR#, Bus Master, Memory, and I/O for all discovered devices");
        // Enable Memory & I/O Windows of all discovered devices
        for (b=0; b<MAX_BUS_NUM; b=b+1)
        begin
            for (d=0; d<MAX_DEVICE_NUM; d=d+1)
            begin
                for (f=0; f<MAX_FUNC_NUM; f=f+1)
                begin
                    if (dev_present[b][d][f])
                    begin
                        bnum = b[7:0];
                        dnum = d[4:0];
                        fnum = f[2:0];
                        bdf  = {bnum, dnum, fnum};
                        // Enable target to respond to Memory Reads/Writes and to perform Bus Master Transactions
                        //           bdf, addr,    be,   wr_data
                        `CFG_WR_BDF_NULL (bdf, 12'h004, 4'h3, 32'h00000147);
                        // Enable Exp ROM (if present)
                        if (exp_present[b][d][f]) begin
                            `CFG_RD_BDF(bdf, 12'h00c, 4'hf, rd_data);
                            if (rd_data[22:16] == 7'h0) // header_type 0
                                `CFG_WR_BDF_NULL (bdf, 12'h030, 4'h1, 32'h1);
                            else
                                `CFG_WR_BDF_NULL (bdf, 12'h038, 4'h1, 32'h1);
                        end
                        // Enable VF Memory Space
                        if (cap_sriov_addr[b][d][f] != 12'h0) begin
                            `CFG_RD_BDF (bdf, cap_sriov_addr[b][d][f] + 12'h008, 4'hf, rd_data);
                            `CFG_WR_BDF_NULL (bdf, cap_sriov_addr[b][d][f] + 12'h008, 4'hf, rd_data | 32'h8);
                        end
                    end
                end
            end
        end
        repeat (100)
            @(posedge clk);     // Wait some time for the config writes to complete (Memory must be enabled for MSIX table writes)

        // --------------------------
        // Configure MSI-X Interrupts

        // Check for Global MSI-X Interrupt Disable
        if (ENABLE_MSIX_INT_ALLOCATION != 0)
        begin : msix_cap

        reg                 done;
        reg     [31:0]      max_vectors;
        reg     [31:0]      num_vectors_req;
        integer             b;
        integer             d;
        integer             f;
        reg     [11:0]      func_vectors_req;
        reg     [11:0]      limit_vectors_req;
        reg     [31:0]      bar_offset;

        reg     [31:0]      avail_vectors;
        reg     [63:0]      bfm_msix_addr;
        reg     [63:0]      vector_table_base_addr;
        reg     [63:0]      vector_pba_base_addr;

        reg     [31:0]      msix_curr_vector;
        reg     [63:0]      msix_curr_addr;

        reg     [31:0]      base_vector_index;
        reg     [63:0]      base_vector_addr;

        reg     [31:0]      curr_vector_index;
        reg     [63:0]      curr_vector_addr;

        integer             i;
        reg     [32767:0]   payload;

            $display  ("%m : Configuring MSI-X Capability of all discovered functions");

            // Limit the number of MSI-X Vectors allocated per function as necessary to use <= MAX_MSIX_VECTORS
            done        = 1'b0;
            max_vectors = MAX_MSIX_VECTORS;
            while (done == 1'b0)
            begin
                num_vectors_req = 32'h0;
                for (b=0; b<MAX_BUS_NUM; b=b+1)
                begin
                    for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                    begin
                        for (f=0; f<MAX_FUNC_NUM; f=f+1)
                        begin
                            // Check whether Device has MSI-X Capability, is enabled to be allocated MSI-X Interrupts, and is not already allocated interrupts
                            if ((cap_msix_addr[b][d][f] != 12'h0) & (cap_msix_disable[b][d][f] == 1'b0) & (int_mode_msix_msi_leg[b][d][f] == INT_MODE_DISABLED))
                            begin
                                // Number of vectors requested by the function
                                func_vectors_req = cap_msix_rvec[b][d][f];

                                // Limit requested vectors to maximum allowed per function
                                if (func_vectors_req <= MAX_MSIX_VECTORS_PER_FUNCTION)
                                    limit_vectors_req = func_vectors_req;
                                else
                                    limit_vectors_req = MAX_MSIX_VECTORS_PER_FUNCTION;

                                // Limit allocated vectors to current value of max_vectors
                                if (limit_vectors_req > max_vectors)
                                    limit_vectors_req = max_vectors;

                                // Accumulate MSI-X Vector requests from all functions
                                num_vectors_req = num_vectors_req + {20'h0, limit_vectors_req};
                            end
                        end
                    end
                end

                // Each function will be alloacted the lesser of its requested vectors or max_vectors
                if (num_vectors_req <= MAX_MSIX_VECTORS)
                    done = 1'b1;
                // Functions are requesting more vectors than present, lower maximum per function allocation and retry allocation
                else
                begin
                    // If max_vectors == 32'h1 and the above comparison still fails then not enough MSI-X vectors are available
                    //   to assign all MSI-X requesting functions an MSI-X vector; exit loop; the following logic will allocate
                    //   MSI-X vectors at one per function until they run out
                    if (max_vectors == 32'h1)
                        done = 1'b1;
                    else
                        max_vectors = max_vectors >> 1;
                end
            end

            // Configure BFM MSI-X Interrupt Controller
            `BFM_INT_MSIX_ADDR        = {64{1'b1}};       // MSI-X Interrupt Controller Base Address[63:0]; default disabled
            `BFM_INT_MSIX_NUM_VECTORS = MAX_MSIX_VECTORS; // MSI-X Interrupt Controller Number of Vectors to implement

            avail_vectors             = MAX_MSIX_VECTORS;

            if (avail_vectors > 32'h0)
            begin
                // Get starting MSI-X Address to assign to vectors
                if (MSIX_ADDR_64_32_N == 0) // Assign 32-bit MSI-X Address
                begin
                    bfm_msix_addr[63:32] = 32'h0;
                    bfm_msix_addr[31: 0] = BFM_BASE_ADDR_BAR0_MSIX;
                end
                else                        // Assign 64-bit MSI-X Address
                begin
                    bfm_msix_addr[63:32] = BFM_BASE_ADDR_BAR1_MSIX_HI;
                    bfm_msix_addr[31: 0] = BFM_BASE_ADDR_BAR1_MSIX_LO;
                end

                // Configure BFM MSI-X Interrupt Controller with its base address
                `BFM_INT_MSIX_ADDR = bfm_msix_addr[63:0];  // MSI-X Interrupt Controller Base Address[63:0]

                // Initialize to beginning of Root Complex MSI-X Table
                msix_curr_vector = 32'h0;
                msix_curr_addr   = bfm_msix_addr;

                // Loop through discovered devices and allocate MSI-X Vectors
                for (b=0; b<MAX_BUS_NUM; b=b+1)
                begin
                    for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                    begin
                        for (f=0; f<MAX_FUNC_NUM; f=f+1)
                        begin
                            bnum = b[7:0];
                            dnum = d[4:0];
                            fnum = f[2:0];
                            bdf  = {bnum, dnum, fnum};

                            if (avail_vectors > 32'h0)
                            begin
                                // Check whether Device has MSI-X Capability, is enabled to be allocated MSI-X Interrupts, and is not already allocated interrupts
                                if ((cap_msix_addr[b][d][f] != 12'h0) & (cap_msix_disable[b][d][f] == 1'b0) & (int_mode_msix_msi_leg[b][d][f] == INT_MODE_DISABLED))
                                begin
                                    func_vectors_req = cap_msix_rvec[b][d][f];

                                    // Limit number of vectors allocated to each function to max_vectors
                                    if (func_vectors_req <= max_vectors)
                                        limit_vectors_req = func_vectors_req;
                                    else
                                        limit_vectors_req = max_vectors;

                                    //           bdf, addr,                         be,   rd_data
                                    `CFG_RD_BDF (bdf, cap_msix_addr[b][d][f] + 'h4, 4'hf, rd_data);
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI-X Cap : TableBIR=%x, TableOffset=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[2:0], {rd_data[31:3], 3'b000});
                                    vector_table_base_addr = {64{1'b1}};
                                    bar_offset = {rd_data[31:3], 3'b000};
                                    if (dev_id_for_vf[b][d][f] != 16'hFFFF) // Virtual Function
                                    begin
                                        if ((bar_offset % (4096 << vf_page_size[b][d][f])) != 0) begin
                                            $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : MSI-X TableOffset for this Virtual Function is not a multiple of the System Page Size (%0d KB)",
                                                       bnum, dnum, fnum, 4 << vf_page_size[b][d][f]);
                                            `INC_ERRORS;
                                        end
                                    end

                                    for (r=0; r<6; r=r+1)
                                    begin
                                        if (bar_present[b][d][f][r] & (bar_index[b][d][f][r] == rd_data[2:0]) & ~bar_io_mem_n[b][d][f][r]) // Look for BAR present matching TableBIR and is type Memory
                                        begin
                                            vector_table_base_addr = bar_addr[b][d][f][r] + {32'h0, rd_data[31:3], 3'b000};
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :             TableBaseAddr==0x%x = (bar[%x]==0x%x) + Offset=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], vector_table_base_addr, r[2:0], bar_addr[1][d][f][r], {rd_data[31:3], 3'b000});
                                        end
                                    end
                                    if (vector_table_base_addr == 64'hffffffff_ffffffff) // Still at its default value
                                    begin
                                        $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] :             TableBIR=%x does not specify a valid Memory BAR location (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[2:0], $time);
                                        `INC_ERRORS;
                                    end

                                    //           bdf, addr,                         be,   rd_data
                                    `CFG_RD_BDF (bdf, cap_msix_addr[b][d][f] + 'h8, 4'hf, rd_data);
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] :             PBABIR=%x, PBAOffset=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[2:0], {rd_data[31:3], 3'b000});
                                    vector_pba_base_addr = {64{1'b1}};
                                    for (r=0; r<6; r=r+1)
                                    begin
                                        if (bar_present[b][d][f][r] & (bar_index[b][d][f][r] == rd_data[2:0]) & ~bar_io_mem_n[b][d][f][r]) // Look for BAR present matching TableBIR and is type Memory
                                        begin
                                            vector_pba_base_addr = bar_addr[b][d][f][r] + {rd_data[31:3], 3'b000};
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :             PbaBaseAddr==0x%x = (bar[%x]==0x%x) + Offset=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], vector_pba_base_addr, r[3:0], bar_addr[b][d][f][r], {rd_data[31:3], 3'b000});
                                        end
                                    end
                                    if (vector_pba_base_addr == 64'hffffffff_ffffffff) // Still at its default value
                                    begin
                                        $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] :             PBA_BIR=%x does not specify a valid Memory BAR location (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[2:0], $time);
                                        `INC_ERRORS;
                                    end

                                    // Fill in MSI-X Table with Address and Data Values
                                    if (func_vectors_req == limit_vectors_req)
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :             Filling in MSI-X Table : MsiXTableBaseAddr=0x%x, ReqVectors=0x%x, AllocVectors=0x%x : Allocating unique vectors", bdf[15:8], bdf[7:3], bdf[2:0], vector_table_base_addr, func_vectors_req, limit_vectors_req);
                                    else
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :             Filling in MSI-X Table : MsiXTableBaseAddr=0x%x, ReqVectors=0x%x, AllocVectors=0x%x : Sharing one or more vectors",                           bdf[15:8], bdf[7:3], bdf[2:0], vector_table_base_addr, func_vectors_req, limit_vectors_req);

                                    if (MSIX_CHECK_TABLE != 0)
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :               After writing the MSI-X Table, the MSI-X table will be read to verify the writes occurred successfully", bdf[15:8], bdf[7:3], bdf[2:0]);

                                    if (limit_vectors_req > 12'd32)
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :               A large number (%4d) of MSI-X vectors is allocated; setting up the MSI-X Table will take a while...", bdf[15:8], bdf[7:3], bdf[2:0], limit_vectors_req);


                                    // Get starting vector index for this function; used when vectors are aliased
                                    base_vector_index = msix_curr_vector;
                                    base_vector_addr  = msix_curr_addr;

                                    curr_vector_index = base_vector_index;
                                    curr_vector_addr  = base_vector_addr;

                                    for (i=0; i<func_vectors_req; i=i+1)
                                    begin
                                        if (MSIX_BURST_TABLE != 0)
                                        begin
                                            // Write MSI-X Table one vector (4 DWORDs) at a time
                                            payload            = 0;
                                            payload[  31:   0] = curr_vector_addr[31: 0];
                                            payload[  63:  32] = curr_vector_addr[63:32];
                                            payload[  95:  64] = curr_vector_index;
                                            payload[ 127:  96] = 32'h00000000;
                                            // `MEM_WRITE_BURST (tc,     addr,                              length, first_dw_be, last_dw_be, payload
                                            `MEM_WRITE_BURST    (3'b000, vector_table_base_addr + (i * 16), 4,      4'hf,        4'hf,       payload);
                                        end
                                        else
                                        begin
                                            // `MEM_WRITE_DWORD (tc,     addr,                                    data,                    be);
                                            `MEM_WRITE_DWORD    (3'b000, vector_table_base_addr + (i * 16) + 'h0, curr_vector_addr[31: 0], 4'hf); // MSI-X Addres[31: 0] - Vector Address[31: 0]
                                            `MEM_WRITE_DWORD    (3'b000, vector_table_base_addr + (i * 16) + 'h4, curr_vector_addr[63:32], 4'hf); // MSI-X Addres[63:32] - Vector Address[63:32]
                                            `MEM_WRITE_DWORD    (3'b000, vector_table_base_addr + (i * 16) + 'h8, curr_vector_index,       4'hf); // MSI-X Data == Vector Number
                                            `MEM_WRITE_DWORD    (3'b000, vector_table_base_addr + (i * 16) + 'hC, 32'h00000000,            4'hf); // Not masked
                                        end

                                        // Do reads to verify that the table writes occurred properly only if the following parameter is non-zero
                                        if (MSIX_CHECK_TABLE != 0)
                                        begin
                                            if (MSIX_BURST_TABLE != 0)
                                            begin
                                                // Check MSI-X Table one vector (4 DWORDs) at a time (should match payload written)
                                                //                    tc,     addr,                                             length, check_data, first_dw_be, last_dw_be, payload
                                                `MEM_READ_BURST_FAST (3'b000, vector_table_base_addr + (i * 16), 4,      1'b1,       4'hf,        4'hf,       payload);
                                            end
                                            else
                                            begin
                                                //                    tc,     addr,                                    expect_data,             check_data
                                                `MEM_READ_DWORD_FAST (3'b000, vector_table_base_addr + (i * 16) + 'h0, curr_vector_addr[31: 0], 1'b1);
                                                `MEM_READ_DWORD_FAST (3'b000, vector_table_base_addr + (i * 16) + 'h4, curr_vector_addr[63:32], 1'b1);
                                                `MEM_READ_DWORD_FAST (3'b000, vector_table_base_addr + (i * 16) + 'h8, curr_vector_index,       1'b1);
                                                `MEM_READ_DWORD_FAST (3'b000, vector_table_base_addr + (i * 16) + 'hC, 32'h00000000,            1'b1);
                                            end
                                        end

                                        // Alias vectors on allocated vector boundary if fewer vectors allocated than requested
                                        if (((i+1) % limit_vectors_req) == 0)
                                        begin
                                            curr_vector_index = base_vector_index;
                                            curr_vector_addr  = base_vector_addr;
                                        end
                                        //   Otherwise increment to the next vector
                                        else
                                        begin
                                            curr_vector_index = curr_vector_index + 32'h1;
                                            curr_vector_addr  = curr_vector_addr  + 64'h4;
                                        end

                                        // Increment MSI-X Vector counts only for non-aliased vectors
                                        if (i < limit_vectors_req)
                                        begin
                                            msix_curr_vector  = msix_curr_vector  + 32'h1;
                                            msix_curr_addr    = msix_curr_addr    + 64'h4;
                                            avail_vectors     = avail_vectors     + 32'h1;
                                        end
                                    end

                                    // Do a "non-fast" read of the last MSI-X Table location to flush the writes through to their destination prior to disabling memory accesses
                                    //`MEM_READ_DWORD (tc,     addr,                                                     expect_data,  check_be, rd_data);
                                    `MEM_READ_DWORD   (3'b000, (vector_table_base_addr + (func_vectors_req * 16)) - 'h4, 32'h00000000, 4'h0,     rd_data);

                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] :             Enabling MSI-X Interrupts; VectorsRequested=%d, VectorsAllocated=%d, MSIXEn=1; FunctionMask=0 (not masked)", bdf[15:8], bdf[7:3], bdf[2:0], func_vectors_req, limit_vectors_req);
                                    //           bdf, addr,                   be,   wr_data
                                    `CFG_WR_BDF_NULL (bdf, cap_msix_addr[b][d][f], 4'h8, {1'b1, 1'b0, 6'h0, 8'h0, 8'h0, 8'h0});

                                    // Record that this device is being configured to use MSI-X interrupts
                                    int_mode_msix_msi_leg[b][d][f] = INT_MODE_MSIX;
                                    int_num_vectors_req  [b][d][f] = func_vectors_req;
                                    int_num_vectors_alloc[b][d][f] = limit_vectors_req;
                                    int_base_vector_num  [b][d][f] = base_vector_index[11:0]; // First vector assigned to this device
                                end
                                // Capability is present but function is disabled from being allocated MSI-X Interrupts
                                else if ((cap_msix_addr[b][d][f] != 12'h0) & (cap_msix_disable[b][d][f] == 1'b1))
                                begin
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI-X Cap : MSI-X Interrupt allocation is disabled for this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                end
                                // Capability is present and function is enabled for being allocated MSI-X Interrupts, but device already has been assigned interrupts
                                else if ((cap_msix_addr[b][d][f] != 12'h0) & (cap_msix_disable[b][d][f] == 1'b0) & (int_mode_msix_msi_leg[b][d][f] != INT_MODE_DISABLED))
                                begin
                                    case (int_mode_msix_msi_leg[b][d][f])
                                        INT_MODE_MSIX   : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI-X Cap : MSI-X Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                        INT_MODE_MSI    : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI-X Cap : MSI Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                        INT_MODE_LEGACY : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI-X Cap : Legacy Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                        default         : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : MSI-X Cap; Unexpected value on int_mode_msix_msi_leg[b][d][f]; skipping ", bdf[15:8], bdf[7:3], bdf[2:0]);
                                    endcase
                                end
                            end
                            else
                            begin
                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI-X Cap : No MSI-X vectors are available to allocate to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                            end
                        end
                    end
                end
            end
            else
            begin
                $display  ("%m : No MSI-X vectors are available to allocate to any function; skipping MSI-X Configuration");
            end
        end
        else
        begin
            $display  ("%m : MSI-X interrupt configuration is globally disabled; ignoring MSI-X Capability of all discovered functions");
        end

        // ------------------------
        // Configure MSI Interrupts

        if (ENABLE_MSI_INT_ALLOCATION != 0)
        begin : msi_cap

        reg     [31:0]      avail_vectors;
        reg     [15:0]      msi_curr_vector;
        reg     [63:0]      msi_curr_addr;
        reg                 done;
        reg     [31:0]      max_vectors;

        reg     [31:0]      num_vectors_req;
        reg     [7:0]       func_vectors_req;
        reg     [7:0]       limit_vectors_req;
        reg     [4:0]       base_vector_index;

        reg     [2:0]       msi_allocated_vectors_encoded;

            $display  ("%m : Configuring MSI Capability of all discovered functions");

            // Configure BFM MSI-X Interrupt Controller
            `BFM_INT_MSI_ADDR        = {64{1'b1}};      // MSI Interrupt Controller Base Addr[63:0]; default disabled
            `BFM_INT_MSI_DATA        = {16{1'b1}};      // MSI Interrupt Controller Base Data[15:0]; default disabled
            `BFM_INT_MSI_NUM_VECTORS = MAX_MSI_VECTORS; // MSI Interrupt Controller Number of Vectors to implement

            avail_vectors            = MAX_MSI_VECTORS;

            if (avail_vectors > 32'h0)
            begin
                // Get starting MSI Address to assign to vectors
                if (MSI_ADDR_64_32_N == 0) // Assign 32-bit MSI Address
                begin
                    bfm_msi_addr[63:32] = 32'h0;
                    bfm_msi_addr[31: 0] = BFM_BASE_ADDR_BAR0_MSI;
                end
                else                        // Assign 64-bit MSI Address
                begin
                    bfm_msi_addr[63:32] = BFM_BASE_ADDR_BAR1_MSI_HI;
                    bfm_msi_addr[31: 0] = BFM_BASE_ADDR_BAR1_MSI_LO;
                end

                // Initialize to beginning of Root Complex MSI Table; note bits[7:5] == 000 so that after math, vector overflows can be detected by bit[5]==1
                msi_curr_addr   = bfm_msi_addr;
                msi_curr_vector = {MSI_DATA_VALUE, 8'h00};

                // Configure BFM MSI-X Interrupt Controller
                `BFM_INT_MSI_ADDR = msi_curr_addr;   // MSI Interrupt Controller Base Addr[63:0]; default disabled
                `BFM_INT_MSI_DATA = msi_curr_vector; // MSI Interrupt Controller Base Data[15:0]; default disabled

                // Limit the number of MSI Vectors allocated per function as necessary to use <= MAX_MSI_VECTORS
                done        = 1'b0;
                max_vectors = MAX_MSI_VECTORS;
                while (done == 1'b0)
                begin
                    num_vectors_req = 32'h0;
                    for (b=0; b<MAX_BUS_NUM; b=b+1)
                    begin
                        for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                        begin
                            for (f=0; f<MAX_FUNC_NUM; f=f+1)
                            begin
                                // Whether this device can be assigned an MSI interrupt
                                if ( (cap_msi_addr         [b][d][f] != 12'h0            ) &                 // Device has MSI Capability
                                     (cap_msi_disable      [b][d][f] == 1'b0             ) &                 // Device is enabled to be allocated MSI Interrupts
                                     (int_mode_msix_msi_leg[b][d][f] == INT_MODE_DISABLED) &                 // Device is not already allocated interrupts
                                     ( ( msi_curr_addr[63:32] == 32'h0) |                                    // 32-bit Root Complex MSI Address or
                                       ((msi_curr_addr[63:32] != 32'h0) & (cap_msi_64[b][d][f] == 1'b1)) ) ) //   64-bit Root Complex MSI Address and Function's MSI is 64-bit address capable
                                begin
                                    // Number of vectors requested by the function
                                    func_vectors_req = cap_msi_rvec[b][d][f];

                                    // Limit requested vectors to maximum allowed per function
                                    if (func_vectors_req <= MAX_MSI_VECTORS_PER_FUNCTION)
                                        limit_vectors_req = func_vectors_req;
                                    else
                                        limit_vectors_req = MAX_MSI_VECTORS_PER_FUNCTION;

                                    // Limit allocated vectors to current value of max_vectors
                                    if (limit_vectors_req > max_vectors)
                                        limit_vectors_req = max_vectors;

                                    // Increase the current vector requested count up to a binary multiple
                                    //   of the maximum number of vectors that will be allocated to the function
                                    case (limit_vectors_req)
                                        32      : if (num_vectors_req[4:0] != 5'h0) num_vectors_req = num_vectors_req + (32 - num_vectors_req[4:0]);
                                        16      : if (num_vectors_req[3:0] != 4'h0) num_vectors_req = num_vectors_req + (16 - num_vectors_req[3:0]);
                                        8       : if (num_vectors_req[2:0] != 3'h0) num_vectors_req = num_vectors_req + (8  - num_vectors_req[2:0]);
                                        4       : if (num_vectors_req[1:0] != 2'h0) num_vectors_req = num_vectors_req + (4  - num_vectors_req[1:0]);
                                        2       : if (num_vectors_req[  0] != 1'h0) num_vectors_req = num_vectors_req + (2  - num_vectors_req[  0]);
                                        default :                                   num_vectors_req = num_vectors_req;
                                    endcase

                                    // Accumulate MSI Vector requests from all functions
                                    num_vectors_req = num_vectors_req + {20'h0, limit_vectors_req};
                                end
                            end
                        end
                    end

                    // Each function will be alloacted the lesser of its requested vectors or max_vectors
                    if (num_vectors_req <= MAX_MSI_VECTORS)
                        done = 1'b1;
                    // Functions are requesting more vectors than present, lower maximum per function allocation and retry allocation
                    else
                    begin
                        // If max_vectors == 32'h1 and the above comparison still fails then not enough MSI vectors are available
                        //   to assign all MSI requesting functions an MSI vector; exit loop; the following logic will allocate
                        //   MSI vectors at one per function until they run out
                        if (max_vectors == 32'h1)
                            done = 1'b1;
                        else
                            max_vectors = max_vectors >> 1;
                    end
                end

                // Loop through discovered devices and allocate MSI Vectors
                for (b=0; b<MAX_BUS_NUM; b=b+1)
                begin
                    for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                    begin
                        for (f=0; f<MAX_FUNC_NUM; f=f+1)
                        begin
                            bnum = b[7:0];
                            dnum = d[4:0];
                            fnum = f[2:0];
                            bdf  = {bnum, dnum, fnum};

                            base_vector_index = msi_curr_vector[4:0];

                            if (avail_vectors > 32'h0)
                            begin
                                // Whether this device can be assigned an MSI interrupt
                                if ( (cap_msi_addr         [b][d][f] !=             12'h0) &                     // Device has MSI Capability
                                     (cap_msi_disable      [b][d][f] ==             1'b0 ) &                     // Device is enabled to be allocated MSI Interrupts
                                     (int_mode_msix_msi_leg[b][d][f] == INT_MODE_DISABLED) &                     // Device is not already allocated MSI-X interrupts
                                     ( ( msi_curr_addr[63:32] == 32'h0) |                                    // 32-bit Root Complex MSI Address or
                                       ((msi_curr_addr[63:32] != 32'h0) & (cap_msi_64[b][d][f] == 1'b1)) ) ) //   64-bit Root Complex MSI Address and Function's MSI is 64-bit address capable
                                begin
                                    func_vectors_req = cap_msi_rvec[b][d][f];

                                    // Limit number of vectors allocated to each function to max_vectors
                                    if (func_vectors_req <= max_vectors)
                                        limit_vectors_req = func_vectors_req;
                                    else
                                        limit_vectors_req = max_vectors;

                                    // Increase the current vector requested count up to a binary multiple
                                    //   of the maximum number of vectors that will be allocated to the function
                                    case (limit_vectors_req)
                                        32      : if (msi_curr_vector[4:0] != 5'h0) msi_curr_vector = msi_curr_vector + (32 - msi_curr_vector[4:0]);
                                        16      : if (msi_curr_vector[3:0] != 4'h0) msi_curr_vector = msi_curr_vector + (16 - msi_curr_vector[3:0]);
                                        8       : if (msi_curr_vector[2:0] != 3'h0) msi_curr_vector = msi_curr_vector + (8  - msi_curr_vector[2:0]);
                                        4       : if (msi_curr_vector[1:0] != 2'h0) msi_curr_vector = msi_curr_vector + (4  - msi_curr_vector[1:0]);
                                        2       : if (msi_curr_vector[  0] != 1'h0) msi_curr_vector = msi_curr_vector + (2  - msi_curr_vector[  0]);
                                        default :                                   msi_curr_vector = msi_curr_vector;
                                    endcase

                                    msi_allocated_vectors_encoded =  (limit_vectors_req == 8'd1 ) ? 3'b000 :
                                                                     ((limit_vectors_req == 8'd2 ) ? 3'b001 :
                                                                      ((limit_vectors_req == 8'd4 ) ? 3'b010 :
                                                                       ((limit_vectors_req == 8'd8 ) ? 3'b011 :
                                                                        ((limit_vectors_req == 8'd16) ? 3'b100 : 3'b101))));

                                    // Make sure that there are vectors available before allocating them
                                    if ((msi_curr_vector[7:0] + limit_vectors_req) <= MAX_MSI_VECTORS)
                                    begin
                                        if (msi_curr_addr[63:32] == 32'h0)  // 32-bit Root Complex MSI Address
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : Assign MSI 32-bit Vector Address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], msi_curr_addr);
                                        else                                // 64-bit Root Complex MSI Address
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : Assign MSI 64-bit Vector Address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], msi_curr_addr);

                                        //           bdf, addr,                      be,   wr_data
                                        `CFG_WR_BDF_NULL (bdf, cap_msi_addr[b][d][f]+'h4, 4'hf, msi_curr_addr[31: 0]          );
                                        `CFG_WR_BDF_NULL (bdf, cap_msi_addr[b][d][f]+'h8, 4'hf, msi_curr_addr[63:32]          );
                                        `CFG_WR_BDF      (bdf, cap_msi_addr[b][d][f]+'hc, 4'hf, {16'h0, msi_curr_vector[15:0]});

                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :           Enabling MSI Interrupts; VectorsRequested=%d, VectorsAllocated=%d, VectorAddress=0x%x, VectorData=0x%x, MSIEn=1", bdf[15:8], bdf[7:3], bdf[2:0], func_vectors_req, limit_vectors_req, msi_curr_addr, msi_curr_vector[15:0]);
                                        //           bdf, addr,                      be,   wr_data
                                        `CFG_WR_BDF_NULL (bdf, cap_msi_addr[b][d][f],     4'h4, {8'h0, 1'b0, msi_allocated_vectors_encoded[2:0], 3'h0, 1'b1, 8'h0, 8'h0});

                                        if (MSI_CHECK_CFG != 0)
                                        begin
                                            //           bdf, addr,                      be,   rd_data
                                            `CFG_RD_BDF (bdf, cap_msi_addr[b][d][f]+'h4, 4'hf, rd_data);
                                            if (rd_data != msi_curr_addr[31: 0])
                                                $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] :           Readback of MSI Cfg failed; Expected=%x, Read=%x", bdf[15:8], bdf[7:3], bdf[2:0], msi_curr_addr[31: 0], rd_data);

                                            `CFG_RD_BDF (bdf, cap_msi_addr[b][d][f]+'h8, 4'hf, rd_data);
                                            if (rd_data != msi_curr_addr[63:32])
                                                $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] :           Readback of MSI Cfg failed; Expected=%x, Read=%x", bdf[15:8], bdf[7:3], bdf[2:0], msi_curr_addr[63:32], rd_data);

                                            `CFG_RD_BDF (bdf, cap_msi_addr[b][d][f]+'hc, 4'hf, rd_data);
                                            if (rd_data[15:0] != msi_curr_vector[15:0])
                                                $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] :           Readback of MSI Cfg failed; Expected=%x, Read=%x", bdf[15:8], bdf[7:3], bdf[2:0], msi_curr_vector[15:0], rd_data);
                                        end

                                        // Advance vector to include vectors just allocated
                                        msi_curr_vector = msi_curr_vector + limit_vectors_req;

                                        // Record that this device is being configured to use MSI interrupts
                                        int_mode_msix_msi_leg[b][d][f] = INT_MODE_MSI;
                                        int_num_vectors_req  [b][d][f] = func_vectors_req;
                                        int_num_vectors_alloc[b][d][f] = limit_vectors_req;
                                        int_base_vector_num  [b][d][f] = {7'h0, base_vector_index[4:0]}; // First vector assigned to this device
                                    end
                                    else
                                    begin
                                        $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : MSI Cap : Unexpected shortage of MSI vectors : MAX_MSI_VECTORS=%d, Need=%d", bdf[15:8], bdf[7:3], bdf[2:0], MAX_MSI_VECTORS, (msi_curr_vector[7:0] + limit_vectors_req));
                                        `INC_ERRORS;
                                    end
                                end
                                // Capability is present but function is disabled from being allocated MSI Interrupts
                                else if ((cap_msi_addr[b][d][f] != 12'h0) & (cap_msi_disable[b][d][f] == 1'b1))
                                begin
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : MSI Interrupt allocation is disabled for this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                end
                                // Capability is present and function is enabled for being allocated MSI Interrupts, but device already has been assigned interrupts
                                else if ((cap_msi_addr[b][d][f] != 12'h0) & (cap_msi_disable[b][d][f] == 1'b0) & (int_mode_msix_msi_leg[b][d][f] != INT_MODE_DISABLED))
                                begin
                                    case (int_mode_msix_msi_leg[b][d][f])
                                        INT_MODE_MSIX   : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : MSI-X Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                        INT_MODE_MSI    : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : MSI Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                        INT_MODE_LEGACY : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : Legacy Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                        default         : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : MSI Cap; Unexpected value on int_mode_msix_msi_leg[b][d][f]; skipping ", bdf[15:8], bdf[7:3], bdf[2:0]);
                                    endcase
                                end
                            end
                            else
                            begin
                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : MSI Cap : No MSI vectors are available to allocate to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                            end
                        end
                    end
                end
            end
            else
            begin
                $display  ("%m : No MSI vectors are available to allocate to any function; skipping MSI Configuration");
            end
        end
        else
        begin
            $display  ("%m : MSI interrupt configuration is globally disabled; ignoring MSI Capability of all discovered functions");
        end

        // ---------------------------
        // Configure Legacy Interrupts

        if (ENABLE_LEGACY_INT_ALLOCATION != 0)
        begin : legi_cap

        reg     [7:0]       legi_line;

            $display  ("%m : Configuring Legacy Interrupts of all discovered functions");

            legi_line = 8'h01;
            for (b=0; b<MAX_BUS_NUM; b=b+1)
            begin
                for (d=0; d<MAX_DEVICE_NUM; d=d+1)
                begin
                    for (f=0; f<MAX_FUNC_NUM; f=f+1)
                    begin
                        bnum = b[7:0];
                        dnum = d[4:0];
                        fnum = f[2:0];
                        bdf  = {bnum, dnum, fnum};

                        // Device and PCIe Capability Present
                        if (legi_present[b][d][f] & (int_mode_msix_msi_leg[b][d][f] == INT_MODE_DISABLED))
                        begin
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Enabling Legacy Interrupts; InterruptLine=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], legi_line);
                            //           bdf, addr,    be,   wr_data
                            `CFG_WR_BDF_NULL (bdf, 12'h03c, 4'h1, legi_line);

                            // Check interrupt line write occurs if enabled
                            if (LEGI_CHECK_CFG != 0)
                            begin
                                `CFG_WR_BDF (bdf, 12'h03c, 4'h1, legi_line);
                                //           bdf, addr,    be,   rd_data
                                `CFG_RD_BDF (bdf, 12'h03c, 4'hf, rd_data);
                                if (rd_data[7:0] != legi_line)
                                begin
                                    $display ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : Readback of Interrupt Line (0x%x) does not match value written (0x%x) (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[7:0], legi_line, $time);
                                    `INC_ERRORS;
                                end
                            end

                            legi_line = legi_line + 8'h01;

                            // Record that this device is being configured to use Legacy interrupts
                            int_mode_msix_msi_leg[b][d][f] = INT_MODE_LEGACY;
                            int_num_vectors_req  [b][d][f] = 12'h1;
                            int_num_vectors_alloc[b][d][f] = 12'h1;
                            int_base_vector_num  [b][d][f] = 12'h0; // 3 == INTD, 2 == INTC, 1 == INTB, 0 == INTA vector assigned to this device
                        end
                        else if (legi_present[b][d][f] & (int_mode_msix_msi_leg[b][d][f] != INT_MODE_DISABLED))
                        begin
                            case (int_mode_msix_msi_leg[b][d][f])
                                INT_MODE_MSIX   : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Legacy Int : MSI-X Interrupts have already been allocated to this function; skipping", bdf[15:8], bdf[7:3], bdf[2:0]);
                                INT_MODE_MSI    : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Legacy Int : MSI Interrupts have already been allocated to this function; skipping",   bdf[15:8], bdf[7:3], bdf[2:0]);
                                INT_MODE_LEGACY : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : Legacy Int : Unexpected value on int_mode_msix_msi_leg[b][d][f]; skipping",    bdf[15:8], bdf[7:3], bdf[2:0]);
                                default         : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : Legacy Int : Unexpected value on int_mode_msix_msi_leg[b][d][f]; skipping ",   bdf[15:8], bdf[7:3], bdf[2:0]);
                            endcase
                        end
                    end
                end
            end
        end
        else
        begin
            $display  ("%m : Legacy Int configuration globally disabled; ignoring Legacy Int capability of all discovered functions");
            $display  ("%m : Legacy interrupt configuration is globally disabled; ignoring Legacy Interrupt capability of all discovered functions");
        end

        // -------------------------------------------------
        // Load default device into "quick-access" variables

        change_default_device (`DUT_ID);

        // ---------------------
        // Enumeration Completed

        $display  ("%m : Enumeration Completed");

        // Separate Test Sequences
        repeat (100)
            @(posedge clk);

        pci_enumeration_complete = 1;
        use_fast_dut_cfg_access = 1'b0; // Used only in CSR_CONFIG_ACCESS mode
    end
endtask



// ------------------
// task configure_bus

// Scans the Configuration Space of one Bus Segment and configures the device's found; task
//   must be automatic because it calls itself to configure any additional busses discovered
task automatic configure_bus;

    inout   [7:0]       bus;                // Input  : Bus Number to Scan
                                            // Output : Highest Bus Number discovered on this or subordinate busses

    input   [7:0]       next_bus;           // Input  : Next bus number to allocate

    input   [4:0]       last_device;        // Input  : Device numbers 0 to last_device will be scanned for possible devices

    inout   [63:0]      last_mem_bar_64;    // Input  : Last 64-bit Memory Base Address allocated
                                            // Output : Last 64-bit Memory Base Address allocated after allocating resources
                                            //          to all devices discovered on this or subordinate busses
    inout   [63:0]      last_mem_bar_32;    // Input  : Last 32-bit Memory Base Address allocated
                                            // Output : Last 32-bit Memory Base Address allocated after allocating resources
                                            //          to all devices discovered on this or subordinate busses
    inout   [63:0]      last_io_bar_32;     // Input  : Last 32-bit IO Base Address allocated
                                            // Output : Last 32-bit IO Base Address allocated after allocating resources
                                            //          to all devices discovered on this or subordinate busses
    input               minimum_cfg;

    integer             b;
    integer             d;
    integer             f;
    integer             r;

    reg                 done;

    reg     [15:0]      bdf;
    reg     [31:0]      rd_data;

    integer             funcs_found;
    integer             num_funcs_to_scan;

    reg     [15:0]      vendor_id;
    reg     [15:0]      device_id;

    reg                 multi_function;
    reg                 header_type;

    integer             num_bars;
    reg     [11:0]      exp_rom_offset;

    reg     [7:0]       bus_primary;
    reg     [7:0]       bus_secondary;
    reg     [7:0]       bus_subordinate;

    reg     [63:20]     bus_pf_mem_limit;
    reg     [31:20]     bus_mem_limit;
    reg     [31:12]     bus_io_limit;

    reg     [63:20]     bus_pf_mem_base;
    reg     [31:20]     bus_mem_base;
    reg     [31:12]     bus_io_base;

    reg     [4:0]       max_dev;

    reg     [11:0]      bar_offset;
    reg     [1:0]       bar_type;
    reg                 bar64;
    reg                 bar_ok;
    reg     [63:0]      size32_vf_all;
    reg     [63:0]      save_bar;

    reg     [63:0]      size;
    reg     [31:0]      size32;
    reg     [63:0]      bar_value;
    reg     [63:0]      bar_osize;
    reg     [63:0]      bar_size;
    reg     [1:0]       bar_text;

    reg                 legacy_int_present;
    reg     [1:0]       legacy_int_dcba;

    reg     [11:0]      curr_cap_ptr;
    reg     [11:0]      next_cap_ptr;
    reg                 msi_64;
    reg     [7:0]       msi_rvec;
    reg     [11:0]      msix_rvec;

    reg     [3:0]       device_type;
    reg                 slot_implemented;
    reg     [4:0]       interrupt_message_number;
    reg     [2:0]       max_payload_size_supported;

    reg     [3:0]       maximum_link_speed;
    reg     [5:0]       maximum_link_width;
    reg     [1:0]       aspm_support;
    reg                 aspm_optionality_compliance;

    reg                 ecap_ptr_first;
    reg     [8*64:0]    field_name;
    reg     [31:0]      field_data;

    begin
        $display  ("%m : Bus[%d] : ** Begin Scanning for Devices **", bus);

        // Start with input Bus Number
        b = bus;

        // Scan bus and configure discovered devices
        done = 0;
        d    = 0;
        while (~done & (d<=last_device))
//        for (d=0; d<=last_device; d=d+1)
        begin
            // Start with function 0
            f = 0;

            funcs_found       = 0;
            num_funcs_to_scan = 1;

            $display  ("%m : Bus[%d], Dev[%d] : Begin Scanning for Functions", b[7:0], d[4:0]);

            while (f < num_funcs_to_scan) // Scan possible function locations for devices
            begin

              bdf = {b[7:0], d[4:0], f[2:0]};

              // Don't scan for devices that have already been found (due to SRIOV device enumeration)
              if (dev_present[b][d][f] == 1'b0)
              begin
                // Read until CRS Status is not received (32'hffff0001 is received for CRS status)
                rd_data = 32'hffff0001;

                // Always do this read unaccellerated for CRS testing
                use_fast_dut_cfg_access = 1'b0;

                while (rd_data == 32'hffff0001)
                begin
                    // Disable BFM Cfg Completion ID checking since the following read occurs before we have assigned the target function an ID value
                    `BFM_INIT_TAG_IS_CFG_EN = 1'b0;

                    // Do a read to see if a device exists at this location
                    //           bdf, addr,    be,   rd_data

                    `CFG_RD_BDF (bdf, 12'h000, 4'hf, rd_data);
                    if (rd_data == 32'hffff0001)
                    begin
                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Configuration Request Retry Response Received - Wait 5uS and then Retry transaction", bdf[15:8], bdf[7:3], bdf[2:0]);
                        #5000000;
                    end

                    // Re-Enable BFM Cfg Completion ID checking
                    `BFM_INIT_TAG_IS_CFG_EN = 1'b1;
                end

                if ((rd_data == {32{1'b1}}) | (rd_data == {32{1'b0}})) // No device at this location
                begin
                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : No function discovered", bdf[15:8], bdf[7:3], bdf[2:0]);
                end
                else
                begin // Discovered a Device
                    // Do a dummy cfg write to assign the device (if it exists) it's ID value
                    //           bdf, addr,    be,   wr_data
                    // Always do this write unaccellerated so the DUT bus number can be programmed
                    use_fast_dut_cfg_access = 1'b0;

                    `CFG_WR_BDF (bdf, 12'h000, 4'h0, 32'h0);

                    use_fast_dut_cfg_access = 1'b1;

                    `CFG_RD_BDF (bdf, 12'h000, 4'hf, rd_data);

                    // Save Vendor and Device ID
                    vendor_id = rd_data[15: 0];
                    device_id = rd_data[31:16];

                    funcs_found = funcs_found + 1;

                    dev_present[b][d][f] = 1'b1; // Present

                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Function discovered : VendorID=0x%x, DeviceID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], vendor_id, device_id);

                    // Check for a multi-function device & header type
                    //           bdf, addr,    be,   rd_data
                    `CFG_RD_BDF (bdf, 12'h00c, 4'hf, rd_data);
                    multi_function = rd_data[23];       // Device is multi-function if this bit is set

                    if (multi_function)
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : Header Type == 0x%x indicates multiple functions are present", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[23:16]);
                    else
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : Header Type == 0x%x indicates only a single function is present", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[23:16]);

                    if (rd_data[22:16] == 7'h0)
                        header_type = 1'b0;
                    else if (rd_data[22:16] == 7'h1)
                        header_type = 1'b1;
                    else
                    begin
                        $display ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : Unrecognized Header Type == 7'b%b discovered", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[22:16]);
                        header_type = 1'b0;
                    end

                    // Get number of BARs to scan for
                    if (header_type == 1'b0)    // Device is Type 0 Header (Endpoint)
                    begin
                        num_bars        = 6;        // Number of BARs that may be present
                        exp_rom_offset  = 12'h030;  // Address offset for Expansion ROM
                    end
                    else                        // Device is Type 1 Header (Switch/Bridge)
                    begin
                        num_bars        = 2;        // Number of BARs that may be present
                        exp_rom_offset  = 12'h038;  // Address offset for Expansion ROM
                    end

                    // If Function Number 0 and indicating this is a multi-function device, then increase
                    //   num_funcs_to_scan to scan for all 8 possible functions
                    if ((f == 0) & multi_function)
                        num_funcs_to_scan = 8;

                    // ------------------------------------
                    // Configure BARs for Discovered Device

                    for (r=0; ((r<num_bars) && (minimum_cfg == 1'b0)); r=r+1) // Check all base address register locations
                    begin
                        // Get address offset for BAR location
                        bar_offset = (r+4) << 2;

                        // Write all 1's to the BAR and read to determine BAR size
                        //           bdf, addr,       be,   wr_data
                        `CFG_WR_BDF (bdf, bar_offset, 4'hf, 32'hffffffff);
                        //   Now read to see a BAR exists and its size
                        //           bdf, addr,       be,   rd_data
                        `CFG_RD_BDF (bdf, bar_offset, 4'hf, rd_data);

                        // Prefetchable bit is [3], mem/io_n is [0]
                        bar_type = {rd_data[3], rd_data[0]};

                        // Check for at least 1 address bit being programmable as an indication of a BAR being present
                        if ((rd_data != {32{1'b0}}) && (rd_data != {32{1'b1}})) // A BAR was found
                        begin

                            if (rd_data[2:0] == 3'b100)
                                bar64 = 1;
                            else
                                bar64 = 0;

                            case (bar_type)
                                2'b00   :   begin   // Mem, not prefetchable
                                                size = {32'hffffffff, rd_data[31:4], 4'b0};       // Mask off non-address portion
                                            end

                                2'b01   :   begin   // I/O
                                                size = {32'hffffffff, rd_data[31:2], 2'b0};       // Mask off non-address portion
                                            end

                                2'b10   :   begin   // Mem, prefetchable
                                                size = {32'hffffffff, rd_data[31:4], 4'b0};       // Mask off non-address portion
                                            end

                                2'b11   :   begin   // Reserved combination (closest to I/O)
                                                size = {32'hffffffff, rd_data[31:2], 2'b0};       // Mask off non-address portion
                                            end
                            endcase

                            // Configure a 64 bit memory BAR in the > 4GB region only if enabled by (bar_no_mem64[b][d][f][r] == 1'b0)
                            //   or if the BAR is too big for 32-bit address space
                            if (bar64 & ((bar_no_mem64[b][d][f][r] == 1'b0) | (size[31:0] == 32'h0)) & ((r+1)<6))
                            begin
                                if (bar64 & (bar_no_mem64[b][d][f][r] == 1'b1) & (size[31:0] == 32'h0))
                                begin
                                    $display  ("%m : WARNING : Bus[%d], Dev[%d], Func[%d] : A 64-bit BAR was requested to be placed into 32-bit address space, but the BAR is too big to fit in 32-bit address space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                    $display  ("%m :           Bus[%d], Dev[%d], Func[%d] :   BAR will be placed into 64-bit address space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                end

                                // Write all 1's to the upper portion of the BAR and read to determine BAR size
                                //           bdf, addr,               be,   wr_data
                                `CFG_WR_BDF (bdf, bar_offset + 12'h4, 4'hf, 32'hffffffff);
                                //           bdf, addr,               be,   rd_data
                                `CFG_RD_BDF (bdf, bar_offset + 12'h4, 4'hf, rd_data);

                                // Reset upper portion of size from previous read
                                size[63:32] = rd_data;

                                bar_osize = (~size+1);
                                bar_size  = bar_osize;
                                bar_value                    = ((last_mem_bar_64 - gap_mem_bar) & size) - bar_size;

                                bar_present     [b][d][f][r] = 1'b1; // Present
                                bar_io_mem_n    [b][d][f][r] = 1'b0; // Memory
                                bar_addr        [b][d][f][r] = bar_value;
                                bar_addr_end    [b][d][f][r] = bar_value + bar_size - 1;
                                bar_index       [b][d][f][r] = r;
                                last_mem_bar_64              = bar_value;

                                // Assign BAR Address
                                //           bdf, addr,               be,   wr_data
                                `CFG_WR_BDF_NULL (bdf, bar_offset        , 4'hf, bar_value[31: 0]);
                                `CFG_WR_BDF_NULL (bdf, bar_offset + 12'h4, 4'hf, bar_value[63:32]);

                                // Display BAR Discovery
                                if (bar_size >= 32'h40000000)
                                begin
                                    bar_size = bar_size >> 30; // Represent as GBytes
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BARs[%1d:%1d], Memory, Size=0x%x (%3d GByte) configured to 64-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r+1, r, bar_osize[63:0], bar_size, bar_value[63:0]);
                                end
                                else if (bar_size >= 32'h00100000)
                                begin
                                    bar_size = bar_size >> 20; // Represent as MBytes
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BARs[%1d:%1d], Memory, Size=0x%x (%3d MByte) configured to 64-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r+1, r, bar_osize[63:0], bar_size, bar_value[63:0]);
                                end
                                else if (bar_size >= 32'h00000400)
                                begin
                                    bar_size = bar_size >> 10; // Represent as KBytes
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BARs[%1d:%1d], Memory, Size=0x%x (%3d KByte) configured to 64-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r+1, r, bar_osize[63:0], bar_size, bar_value[63:0]);
                                end
                                else
                                begin                          // Represent as Bytes
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BARs[%1d:%1d], Memory, Size=0x%x (%3d  Byte) configured to 64-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r+1, r, bar_osize[63:0], bar_size, bar_value[63:0]);
                                end

                                // Increment bar one additional time since two BAR regions have been processed in this loop
                                r = r + 1;
                            end
                            // Configure as a 32-bit BAR in the < 4GB region
                            else
                            begin
                                if (bar64 & (r == 5))
                                begin
                                    $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : 64-bit BAR detected, but first 32-bits of BAR register is at the end of BAR space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                    $display  ("%m           Bus[%d], Dev[%d], Func[%d] :   BAR will be placed into 32-bit address space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                    `INC_ERRORS;
                                    bar64 = 0;
                                end
                                save_bar = last_mem_bar_32;
                                last_mem_bar_32 = (last_mem_bar_32 - gap_mem_bar) & {32'h0, size[31:0]} ; //If gap_mem_bar is non-zero, a PCIe memory region gap will be forced.
                                // Get BAR size
                                size32 = ~size[31:0] + 1;

                                //If it doesn't fit, disable the bar and report either a warning or error depending upon report_barsize_viol_as_error setting.
                                if ((save_bar == 0) || (size32  > last_mem_bar_32))
                                begin
                                    //Can't configure this bar, its too large, either report an error or a warning as defined by report_barsize_viol_as_error.
                                    $display ("%m : %s ,  Bus[%d], Dev[%d], Func[%d] : 32-bit BAR %d does not fit in remaining memory space and won't be configured (time %t)",
                                            (report_barsize_viol_as_error ? "ERROR" : "WARNING"),bdf[15:8], bdf[7:3], bdf[2:0], r, $time);
                                    if(report_barsize_viol_as_error) `INC_ERRORS;
                                    last_mem_bar_32 = save_bar;
                                    `CFG_WR_BDF_NULL (bdf, bar_offset, 4'hf, 32'h0);
                                end
                                else
                                begin
                                    // Assign memory region according to type of BAR memory
                                    case (bar_type)

                                        2'b00   :   begin   // Mem, not prefetchable
                                                        bar_value                 = (last_mem_bar_32 & {32'h0, size[31:0]}) - {32'h0, size32};
                                                        bar_present  [b][d][f][r] = 1'b1; // Present
                                                        bar_io_mem_n [b][d][f][r] = 1'b0; // Memory
                                                        bar_addr     [b][d][f][r] = bar_value;
                                                        bar_addr_end [b][d][f][r] = bar_value + size32 - 1;
                                                        bar_index    [b][d][f][r] = r;
                                                        last_mem_bar_32           = bar_value;
                                                    end

                                        2'b01   :   begin   // I/O
                                                        bar_value                 = (last_io_bar_32  & {32'h0, size[31:0]}) - {32'h0, size32};
                                                        bar_present  [b][d][f][r] = 1'b1; // Present
                                                        bar_io_mem_n [b][d][f][r] = 1'b1; // I/O
                                                        bar_addr     [b][d][f][r] = bar_value;
                                                        bar_addr_end [b][d][f][r] = bar_value + size32 - 1;
                                                        bar_index    [b][d][f][r] = r;
                                                        last_io_bar_32            = bar_value;
                                                    end

                                        2'b10   :   begin   // Mem, prefetchable
                                                        bar_value                 = (last_mem_bar_32 & {32'h0, size[31:0]}) - {32'h0, size32};
                                                        bar_present  [b][d][f][r] = 1'b1; // Present
                                                        bar_io_mem_n [b][d][f][r] = 1'b0; // Memory
                                                        bar_addr     [b][d][f][r] = bar_value;
                                                        bar_addr_end [b][d][f][r] = bar_value + size32 - 1;
                                                        bar_index    [b][d][f][r] = r;
                                                        last_mem_bar_32           = bar_value;
                                                    end

                                        2'b11   :   begin   // Reserved combination (closest to I/O)
                                                        $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : BAR is not a defined type; BAR read data = 0x%x (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data, $time);
                                                        $display  ("%m           Bus[%d], Dev[%d], Func[%d] :   BAR will be placed into 32-bit I/O space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                                        `INC_ERRORS;
                                                        bar_value                 = (last_io_bar_32  & {32'h0, size[31:0]}) - {32'h0, size32};
                                                        bar_present  [b][d][f][r] = 1'b1; // Present
                                                        bar_io_mem_n [b][d][f][r] = 1'b1; // I/O
                                                        bar_addr     [b][d][f][r] = bar_value;
                                                        bar_addr_end [b][d][f][r] = bar_value + size32 - 1;
                                                        bar_index    [b][d][f][r] = r;
                                                        last_io_bar_32            = bar_value;
                                                    end

                                    endcase

                                    // Assign BAR Address
                                    //           bdf, addr,       be,   wr_data
                                    `CFG_WR_BDF_NULL (bdf, bar_offset, 4'hf, bar_value[31:0]);
                                    // if BAR is 64-bit, but assigned 32-bit address, then zero upper BAR
                                    if (bar64)
                                    begin
                                        //           bdf, addr,               be,   wr_data
                                        `CFG_WR_BDF_NULL (bdf, bar_offset + 12'h4, 4'hf, 32'h0);
                                    end

                                    bar_osize = (~size+1);
                                    bar_size  = (~size+1);

                                    if (bar_size >= 32'h40000000)
                                    begin
                                        bar_size = bar_size >> 30; // Represent as GBytes
                                        bar_text = 2'h3;
                                    end
                                    else if (bar_size >= 32'h00100000)
                                    begin
                                        bar_size = bar_size >> 20; // Represent as MBytes
                                        bar_text = 2'h2;
                                    end
                                    else if (bar_size >= 32'h00000400)
                                    begin
                                        bar_size = bar_size >> 10; // Represent as KBytes
                                        bar_text = 2'h1;
                                    end
                                    else
                                    begin
                                        bar_text = 2'h0;           // Represent as Bytes
                                    end

                                    //If the BAR belongs to the PCIE BFM, then set the bfm_bar0 value to this bar value
                                    if(((bar_type & 2'b01) == 2'b0) && (bdf == `BFM_ID) && (r == 0))
                                    begin
                                        bfm_bar0 = bar_value[31:0];
                                        `BFM_INT_BASE_ADDR32 = bfm_bar0; // Assign BFM BAR variable to where it was located after Configuration
                                    end

                                    case (bar_type)
                                        2'b00 : // Mem, not prefetchable
                                                begin
                                                    case (bar_text)
                                                        2'b11 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Not Prefetchable, Size=0x%x (%3d GBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b10 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Not Prefetchable, Size=0x%x (%3d MBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b01 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Not Prefetchable, Size=0x%x (%3d KBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b00 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Not Prefetchable, Size=0x%x (%3d  Bytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                    endcase
                                                end

                                        2'b01 : // I/O
                                                begin
                                                    case (bar_text)
                                                        2'b11 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], I/O, Size=0x%x (%3d GBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b10 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], I/O, Size=0x%x (%3d MBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b01 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], I/O, Size=0x%x (%3d KBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b00 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], I/O, Size=0x%x (%3d  Bytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                    endcase
                                                end

                                        2'b10 : // Mem, prefetchable
                                                begin
                                                    case (bar_text)
                                                        2'b11 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Prefetchable, Size=0x%x (%3d GBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b10 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Prefetchable, Size=0x%x (%3d MBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b01 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Prefetchable, Size=0x%x (%3d KBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b00 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Memory, Prefetchable, Size=0x%x (%3d  Bytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                    endcase
                                                end

                                        2'b11 : // Reserved combination (closest to I/O)
                                                begin
                                                    case (bar_text)
                                                        2'b11 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Invalid, assuming I/O, Size=0x%x (%3d GBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b10 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Invalid, assuming I/O, Size=0x%x (%3d MBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b01 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Invalid, assuming I/O, Size=0x%x (%3d KBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                        2'b00 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : BAR[%1d], Invalid, assuming I/O, Size=0x%x (%3d  Bytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], r, bar_osize[31:0], bar_size, bar_value[31:0]);
                                                    endcase
                                                end
                                    endcase

                                    if (bar64)
                                    begin
                                        // Increment bar one additional time since two BAR regions have been processed in this loop
                                        r = r + 1;
                                    end
                                end
                            end
                        end // if ((rd_data != {32{1'b0}}) && (rd_data != {32{1'b1}})) // A BAR was found
                    end // for (r=0; r<num_bars; r=r+1) // Check all base address register locations

                    // ---------------------------------------------
                    // Configure Expansion ROM for Discovered Device

                    if (minimum_cfg == 1'b0)
                    begin
                        // Check for an Expansion ROM being present
                        //   Write 1's to [31:11] which are the bits indicating the size of requested expansion ROM
                        //           bdf, addr,           be,   wr_data
                        `CFG_WR_BDF (bdf, exp_rom_offset, 4'hf, 32'hfffff800);
                        //   Now read to see if the expansion ROM exists and its size
                        //           bdf, addr,           be,   rd_data
                        `CFG_RD_BDF (bdf, exp_rom_offset, 4'hf, rd_data);

                        // Check for at least 1 address bit being programmable as an indication of an Expansion ROM being present
                        if (rd_data[31:11] != 21'h0) // If Expansion ROM Found
                        begin
                            // Determine size of requested region
                            size = {32'hffffffff, rd_data[31:11], 11'h0}; // Mask off non-address portion
                            save_bar = last_mem_bar_32;
                            //Align to new boundary and make a memory gap if gap_mem_bar is 1
                            last_mem_bar_32 = (last_mem_bar_32 - gap_mem_bar) & {32'h0, size[31:0]};
                            // Get BAR size
                            size32 = ~size[31:0] + 1;
                            //If it doesn't fit, disable the bar and report either a warning or error depending upon report_barsize_viol_as_error setting.
                            if ((save_bar == 0) || (size32  > last_mem_bar_32))
                            begin
                                //Can't configure this bar, its too large, either report an error or a warning as defined by report_barsize_viol_as_error.
                                $display ("%m : %s ,  Bus[%d], Dev[%d], Func[%d] : 32-bit EXPANSION_ROM BAR %d does not fit in remaining memory space and won't be configured (time %t)",
                                         (report_barsize_viol_as_error ? "ERROR" : "WARNING"),bdf[15:8], bdf[7:3], bdf[2:0], r, $time);
                                if(report_barsize_viol_as_error) `INC_ERRORS;
                                last_mem_bar_32 = save_bar;  //No other cleanup. The expansion ROM won't be enabled by the enumeration code.
                            end
                            else
                            begin
                                // Allocate expansion ROM a 32-bit memory address region
                                bar_value            = last_mem_bar_32 - {32'h0, size32};
                                exp_present[b][d][f] = 1'b1;
                                exp_addr   [b][d][f] = bar_value[31:0];
                                last_mem_bar_32      = bar_value[31:0];

                                // Assign Expansion ROM Address; but don't enable the Expansion ROM yet
                                //           bdf, addr,           be,   wr_data
                                `CFG_WR_BDF_NULL (bdf, exp_rom_offset, 4'hf, {bar_value[31:1], 1'b0});

                                // Display Expansion ROM Discovery
                                bar_osize = (~size+1);  // Original Size
                                bar_size  = (~size+1);  // Display Size

                                if (bar_size >= 32'h40000000)
                                begin
                                    bar_size = bar_size >> 30; // Represent as GBytes
                                    bar_text = 2'h3;
                                end
                                else if (bar_size >= 32'h00100000)
                                begin
                                    bar_size = bar_size >> 20; // Represent as MBytes
                                    bar_text = 2'h2;
                                end
                                else if (bar_size >= 32'h00000400)
                                begin
                                    bar_size = bar_size >> 10; // Represent as KBytes
                                    bar_text = 2'h1;
                                end
                                else
                                begin
                                    bar_text = 2'h0;           // Represent as Bytes
                                end

                                case (bar_text)
                                    2'h3 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ExpROM, Memory, Not Prefetchable, Size=0x%x (%3d GBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], bar_osize[31:0], bar_size, bar_value[31:0]);
                                    2'h2 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ExpROM, Memory, Not Prefetchable, Size=0x%x (%3d MBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], bar_osize[31:0], bar_size, bar_value[31:0]);
                                    2'h1 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ExpROM, Memory, Not Prefetchable, Size=0x%x (%3d KBytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], bar_osize[31:0], bar_size, bar_value[31:0]);
                                    2'h0 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ExpROM, Memory, Not Prefetchable, Size=0x%x (%3d  Bytes) configured to 32-bit base address=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], bar_osize[31:0], bar_size, bar_value[31:0]);
                                endcase
                            end
                        end
                    end

                    // ---------------------------
                    // Configure Legacy Interrupts

                    // Read Interrupt Pin
                    //           bdf, addr,    be,   rd_data
                    `CFG_RD_BDF (bdf, 12'h03C, 4'hf, rd_data);
                    case (rd_data[15:8])
                        8'h0    :   begin $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Interrupt Pin is 0x%x (No Legacy Interrupt Support)",            bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:8]); legacy_int_present = 1'b0; legacy_int_dcba = 2'b00; end
                        8'h1    :   begin $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Interrupt Pin is 0x%x (Device Legacy Interrupt Support - INTA)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:8]); legacy_int_present = 1'b1; legacy_int_dcba = 2'b00; end
                        8'h2    :   begin $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Interrupt Pin is 0x%x (Device Legacy Interrupt Support - INTB)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:8]); legacy_int_present = 1'b1; legacy_int_dcba = 2'b01; end
                        8'h3    :   begin $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Interrupt Pin is 0x%x (Device Legacy Interrupt Support - INTC)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:8]); legacy_int_present = 1'b1; legacy_int_dcba = 2'b10; end
                        8'h4    :   begin $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Interrupt Pin is 0x%x (Device Legacy Interrupt Support - INTD)", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:8]); legacy_int_present = 1'b1; legacy_int_dcba = 2'b11; end
                        default :   begin
                                        $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : Interrupt Pin set to an invalid value (0x%x) (time %t)",  bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:8], $time);
                                        `INC_ERRORS;
                                        legacy_int_present = 1'b0;
                                        legacy_int_dcba    = 2'b00;
                                    end
                    endcase
                    legi_present[b][d][f] = legacy_int_present;
                    legi_dcba   [b][d][f] = legacy_int_dcba;

                    // ---------------------------
                    // Discover Capabilities Items

                    // Default to Device Type == Legacy PCI Express Endpoint; this will be changed to the advertised type if a PCIe Capability is present
                    device_type = 4'b0001;

                    // Read start of capabilities pointer list
                    //           bdf, addr,    be,   rd_data
                    `CFG_RD_BDF (bdf, 12'h034, 4'hf, rd_data);
                    curr_cap_ptr = {4'h0, rd_data[7:0]};

                    while (curr_cap_ptr != 12'h000)
                    begin
                        //           bdf, addr,         be,   rd_data
                        `CFG_RD_BDF (bdf, curr_cap_ptr, 4'hf, rd_data);
                        next_cap_ptr = {4'h0, rd_data[15:8]};
                        cap_list_status[curr_cap_ptr] = CAP_FOUND;

                        case (rd_data[7:0]) // Capability ID

                            8'h01 : begin // Power Management
                                        cap_pm_addr[b][d][f] = curr_cap_ptr;

                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Power Management Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Power Management Capability : Supports PME from {D0, D1, D2, D3hot, D3cold} = {%d, %d, %d, %d, %d}", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[27], rd_data[28], rd_data[29], rd_data[30], rd_data[31]);
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Power Management Capability : Supports {D1, D2, D3hot} = {%d, %d, %d}", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[25], rd_data[26], 1'b1);
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Power Management Capability : Aux_Current=0x%x, DSI=0x%x, PME_Clock=0x%x, Version=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[24:22], rd_data[21], rd_data[19], rd_data[18:16]);
                                    end

                            8'h02 : begin // AGP
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AGP Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h03 : begin // VPD
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found VPD Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                        cap_vpd_addr[b][d][f] = curr_cap_ptr;
                                    end

                            8'h04 : begin // Slot Identification
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Slot Identification Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h05 : begin // MSI
                                        msi_64                = rd_data[23];
                                        msi_rvec              = 16'h1 << rd_data[19:17];  // Number of MSI Vectors requested by this function
                                        cap_msi_addr[b][d][f] = curr_cap_ptr;
                                        cap_msi_rvec[b][d][f] = msi_rvec;
                                        cap_msi_64  [b][d][f] = msi_64;
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found MSI Capability : Offset=0x%x, CapID=0x%x, PVM=%x, 64bit=%x, ReqVectors=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0], rd_data[24], msi_64, msi_rvec[7:0]);
                                    end

                            8'h06 : begin // Compact PCI Hot Swap
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Compact PCI Hot Swap Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h07 : begin // PCI-X
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI-X Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h08 : begin // Reserved for AMD
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Reserved for AMD Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h09 : begin // Vendor-Specific
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Vendor-Specific Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h0A : begin // Debug Port
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Debug Port Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h0B : begin // CompactPCI Central Resource Control
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found CompactPCI Central Resource Control Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h0C : begin // PCI Hot Plug
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Hot Plug Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h0D : begin // Bridge Subsystem Vendor ID
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Bridge Subsystem Vendor ID Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h0E : begin // AGP 8x
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AGP 8x Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h0F : begin // Secure Device
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Secure Device Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                            8'h10 : begin // PCI Express
                                        device_type               = rd_data[23:20];
                                        slot_implemented          = rd_data[   24];
                                        interrupt_message_number  = rd_data[29:25];
                                        cap_pcie_addr   [b][d][f] = curr_cap_ptr;
                                        cap_pcie_intvec [b][d][f] = interrupt_message_number;
                                        cap_pcie_devtype[b][d][f] = device_type;

                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Capability : Offset=0x%x, CapID=0x%x, Version=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0], rd_data[19:16]);
                                        case (device_type)
                                            4'b0000 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (PCI Express Endpoint)",                   bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b0001 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Legacy PCI Express Endpoint)",            bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b0100 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Root Port of PCI Express Root Complex)",  bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b0101 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Upstream Port of PCI Express Switch)",    bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b0110 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Downstream Port of PCI Express Switch)",  bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b0111 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (PCI Express to PCI/PCI-X Bridge)",        bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b1000 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (PCI/PCI-X to PCI Express Bridge)",        bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b1001 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Root Complex Integrated Endpoint)",       bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            4'b1010 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Root Complex Event Collector)",           bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                            default : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Unknown)",                                bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                        endcase
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : SlotImplemented=0x%x, InterruptMessageNumber=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], slot_implemented, interrupt_message_number);

                                        if ((header_type == 1'b1) & (device_type == 4'b0100)) // (Root Port of PCI Express Root Complex)
                                        begin
                                            $display ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Root Port : Enable CRS Software Visibility", bdf[15:8], bdf[7:3], bdf[2:0]);
                                            `CFG_RD_BDF (bdf, curr_cap_ptr + 'h1C, 4'hf,  rd_data);
                                            `CFG_WR_BDF_NULL (bdf, curr_cap_ptr + 'h1C, 4'h1, (rd_data | 32'h10)); // Set CRS Software Visibility Enable
                                        end
                                        if (header_type == 1'b1)    // (Root Port of PCI Express Root Complex or switch port)
                                        begin
                                             br_pcie_cap_bdf = bdf;          //Used to enable ARI forwarding, if an endpoint supporting SRIOV is found
                                             br_pcie_cap_ptr = curr_cap_ptr; //" "
                                        end
                                        //           bdf, addr,               be,   rd_data
                                        `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                        max_payload_size_supported        = rd_data[2:0];
                                        cap_pcie_max_pl_size_sup[b][d][f] = max_payload_size_supported;
                                        cap_pcie_ex_tag_sup     [b][d][f] = rd_data[5];
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxPayloadSizeSupported=%d Bytes, Extended Tag Field Supported=%d", bdf[15:8], bdf[7:3], bdf[2:0], (16'd128<<max_payload_size_supported), cap_pcie_ex_tag_sup[b][d][f]);

                                        // Get ASPM Support from Link Capabilities
                                        //           bdf, addr,               be,   rd_data
                                        `CFG_RD_BDF (bdf, curr_cap_ptr + 'hc, 4'hf, rd_data);
                                        maximum_link_speed                = rd_data[3:0];
                                        maximum_link_width                = rd_data[9:4];
                                        aspm_support                      = rd_data[11:10];
                                        aspm_optionality_compliance       = rd_data[22];
                                        cap_pcie_aspm_sup[b][d][f]        = aspm_support;

                                        if (maximum_link_speed == 4'h1)
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=2.5G, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);
                                        else if (maximum_link_speed == 4'h2)
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=5.0G, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);
                                        else if (maximum_link_speed == 4'h3)
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=8.0G, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);
                                        else
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=UnknownValue, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);

                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : SupportsASPM[L1,L0s]=[%b,%b], ASPMOptionalityCompliance=%b", bdf[15:8], bdf[7:3], bdf[2:0], aspm_support[1], aspm_support[0], aspm_optionality_compliance);

                                        // Get Support Info from Device Capabilities 2
                                        `CFG_RD_BDF (bdf, curr_cap_ptr + 'h24, 4'hf,  rd_data);  //Read Device Capabilities 2 Register
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : DevCap2 LTR Mechanism Supported=%0b", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[11]);
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : DevCap2 ARI Forwarding Supported=%0b", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[ 5]);
                                        // Enable LTR on Function 0 if Supported
                                        if (rd_data[11] == 1'b1 && f==0)
                                        begin
                                           `CFG_RD_BDF (bdf, curr_cap_ptr + 'h28, 4'hf,  rd_data);
                                           `CFG_WR_BDF (bdf, curr_cap_ptr + 'h28, 4'h2, (rd_data | 32'h400)); // Enable LTR in Bit 10
                                        end
                                    end

                            8'h11 : begin // MSI-X
                                        msix_rvec                 = {1'b0, rd_data[26:16]} + 12'h1; // Number of MSI-X Vectors requested by this function
                                        cap_msix_addr   [b][d][f] = curr_cap_ptr;
                                        cap_msix_rvec   [b][d][f] = msix_rvec;
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found MSI-X Capability : Offset=0x%x, CapID=0x%x, ReqVectors=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0], msix_rvec);
                                    end

                            default :
                                    begin
                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Unknown Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                    end

                        endcase

                        // Advance to next capability
                        curr_cap_ptr = next_cap_ptr;
                    end

                    // -------------------------------------
                    // Configure Enhanced Capabilities Items

                    // Read start of enhanced capabilities pointer list
                    ecap_ptr_first = 1'b1;
                    curr_cap_ptr  = 12'h100;

                    while (curr_cap_ptr != 12'h000)
                    begin
                        if (curr_cap_ptr < 12'h100)
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : Enhanced Capabilities Pointer == 0x%x; Enhanced Capabilities must be located at addresses >= 0x100", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr);

                        //           bdf, addr,         be,   rd_data
                        `CFG_RD_BDF (bdf, curr_cap_ptr, 4'hf, rd_data);
                        next_cap_ptr = rd_data[31:20];

                        if (rd_data[31:0] == 32'h0)
                        begin
                            if (ecap_ptr_first == 1'b1)
                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : No Enhanced Capabilities Found : Offset=0x%x, ReadData=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[31:0]);
                            else
                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : Next Enhanced Capabilities Pointer pointed to invalid address : Offset=0x%x, ReadData=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[31:0]);
                        end
                        else
                        begin
                            cap_list_status[curr_cap_ptr] = CAP_FOUND;
                            case (rd_data[15:0]) // Extended Capability ID

                                16'h0001 :  begin // Advanced Error Reporting Capability
                                                if (rd_data[19:16] == 4'h1)
                                                begin
                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AER Enhanced Capability : Offset=0x%x, CapVersion=0x%x (PCIe 2.0/1.1)", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[19:16]);
                                                end
                                                else if (rd_data[19:16] == 4'h2)
                                                begin
                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AER Enhanced Capability : Offset=0x%x, CapVersion=0x%x (PCIe 3.0)", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[19:16]);
                                                end
                                                else
                                                begin
                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AER Enhanced Capability : Offset=0x%x, CapVersion=0x%x (Unknown Version)", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[19:16]);
                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ** WARNING ** : AER Enhanced Capability cannot be setup because version is not recognized", bdf[15:8], bdf[7:3], bdf[2:0]);
                                                end

                                                // Setup capability if it is a known version
                                                if ((rd_data[19:16] == 4'h1) | (rd_data[19:16] == 4'h2))
                                                begin
                                                    // Record starting address of Capability
                                                    cap_aer_addr[b][d][f] = curr_cap_ptr;
                                                end
                                            end

                                16'h0002,
                                16'h0009 :  begin // Virtual Channel Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Virtual Channel Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h0003 :  begin // Device Serial Number Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Device Serial Number Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                                dev_serial_num[b][d][f][31:0] = rd_data[31:0];
                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h8, 4'hf, rd_data);
                                                dev_serial_num[b][d][f][63:32] = rd_data[31:0];
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Device Serial Number Extended Capability : Dev_Ser_Num=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], dev_serial_num[b][d][f]);
                                                cap_dsn_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0004 :  begin // Power Budgeting Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Power Budgeting Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_pb_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0005 :  begin // PCI Express Root Complex Link Declaration Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Root Complex Link Declaration Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h0006 :  begin // PCI Express Root Complex Internal Link Control Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Root Complex Internal Link Control Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h0007 :  begin // PCI Express Root Complex Event Collector Endpoint Association Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Root Complex Event Collector Endpoint Association Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h0008 :  begin // Multi-Function Virtual Channel Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Multi-Function Virtual Channel Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h000A :  begin // RCRB Header Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found RCRB Header Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h000B :  begin // Vendor-Specific Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Vendor-Specific Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                //           bdf, addr,               be,   rd_data
                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Vendor-Specific Capability : VSEC_ID=0x%x, VSEC_Rev=0x%x, VSEC_Length=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:0], rd_data[19:16], rd_data[31:20]);
                                                if (rd_data[15:0] == 1) // NWL VSEC ID == 1
                                                    cap_ven_addr[b][d][f] = curr_cap_ptr;
                                                else
                                                    cap_vsec_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h000D :  begin // ACS Extended Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found ACS Extended Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h000E :  begin // ARI Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found ARI Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_ari_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h000F :  begin // ATS Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found ATS Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_ats_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0010 :  begin // SR-IOV Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found SR-IOV Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_sriov_addr[b][d][f] = curr_cap_ptr;

                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h0C, 4'hf, rd_data);
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       SR-IOV Capability : TotalVFs=0x%x, InitialVFs=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[31:16], rd_data[15:0]);
                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h14, 4'hf, rd_data);
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       SR-IOV Capability : VFStride=0x%x, VFOffset=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[31:16], rd_data[15:0]);
                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h1C, 4'hf, rd_data);
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       SR-IOV Capability : SupportedPageSizes=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[31:0]);
                                                `CFG_RD_BDF (br_pcie_cap_bdf, br_pcie_cap_ptr + 'h24, 4'hf,  rd_data);  //Read Device Capabilities 2 Register of the immediately upstream ROOT_PORT  or switch.
                                                if (rd_data & 32'h20)   //Test ARI forwarding supported (can only be set for a PCIe Root complex or Downstream switch port)
                                                begin
                                                   `CFG_RD_BDF (br_pcie_cap_bdf, br_pcie_cap_ptr + 'h28, 4'hf,  rd_data);
                                                   `CFG_WR_BDF (br_pcie_cap_bdf, br_pcie_cap_ptr + 'h28, 4'h1, (rd_data | 32'h20)); // Set ARI Forwarding Enable to allow SRIOV endpoints
                                                end
                                            end

                                16'h0012 :  begin // Multicast Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Multicast Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            end

                                16'h0015 :  begin // Resizable BAR Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Resizable BAR Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_resize_bar_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0016 :  begin // Dynamic Power Allocation (DPA) Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Dynamic Power Allocation (DPA) Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_dpa_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0017 :  begin // TPH Requester Extended Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found TPH Requester Extended Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                //           bdf, addr,               be,   rd_data
                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       TPH Requester Extended Capability : ST_Size=0x%x, ST_Loc=0x%x, Ext_TPH=0x%x, ST_Modes=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[26:16], rd_data[10:9], rd_data[8], rd_data[2:0]);
                                                cap_tph_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0018 :  begin // Latency Tolerance Reporting (LTR) Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Latency Tolerance Reporting (LTR) Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_ltr_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h0019 :  begin // Secondary PCI Express Extended Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Secondary PCI Express Extended Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_sec_pcie_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h001B :  begin // PASID Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PASID Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_pasid_addr[b][d][f] = curr_cap_ptr;
                                            end

                                16'h001E :  begin // L1 PM Substates Capability
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found L1 PM Substates Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                cap_l1pmss_addr[b][d][f] = curr_cap_ptr;
                                            end

                                default :
                                        begin
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Unknown Enhanced Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                            `INC_ERRORS;
                                            cap_list_status[curr_cap_ptr] = CAP_CLEARED;
                                        end

                            endcase
                        end

                        // Advance to next capability
                        curr_cap_ptr   = next_cap_ptr;
                        ecap_ptr_first = 1'b0;
                    end

                    // Configure SRIOV
                    if (cap_sriov_addr[b][d][f] != 12'h0)
                    begin : vf_bar_cfg

                        reg     [11:0]      sriov_addr;
                        integer             vf_total;
                        integer             vf_offset;
                        integer             vf_stride;
                        reg     [15:0]      vf_num;
                        integer             vf_limit;
                        integer             vf;
                        reg     [63:0]      vf_size;
                        reg     [31:0]      save_data;

                        sriov_addr = cap_sriov_addr[b][d][f];
                        num_bars = 6;
                        `CFG_RD_BDF (bdf, sriov_addr + 12'h00c, 4'hf, rd_data);
                        vf_total = rd_data[31:16];
                        `CFG_RD_BDF (bdf, sriov_addr + 12'h014, 4'hf, rd_data);
                        vf_offset = rd_data[15:0];
                        vf_stride = rd_data[31:16];
                        vf_num = 16'h0;
                        vf_limit = (cap_ari_addr[b][d][f] !== 0) ? 255 : 7;
                        if (ENABLE_ARI_CAPABLE_HIERARCHY == 1)
                        begin
                            // Write ARI Capable Hierarchy bit in Function 0
                            if ((f==0) & (cap_ari_addr[b][d][f] !== 0))
                                //`CFG_WR_BDF_NULL (bdf, sriov_addr + 12'h008, 4'hf, 32'h00000010);
                                `CFG_WR_BDF (bdf, sriov_addr + 12'h008, 4'hf, 32'h00000010);
                        end
                        else
                        begin
                            vf_limit = 7;
                        end
                        // Calculate number of VFs to enable
                        for (vf = 0; vf<vf_total; vf=vf+1) begin
                            if ((f + vf_offset + (vf_stride * vf)) <= vf_limit)
                                vf_num = vf_num + 16'h1;
                        end

                        if (vf_num > VF_ENABLE_LIMIT)
                            vf_num = VF_ENABLE_LIMIT; // Test Configuration Imposed Limit on Number of VFs to Enable Per PF

                        // Only setup SRIOV if there is at least one function being allocated
                        if (vf_num == 0)
                        begin
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       SR-IOV Capability : Setting VFNum=0x%x; no VF will be enabled for this PF", bdf[15:8], bdf[7:3], bdf[2:0], vf_num);
                        end
                        else
                        begin
                            `CFG_WR_BDF_NULL (bdf, sriov_addr + 12'h010, 4'hf, {16'h0, vf_num});
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       SR-IOV Capability : Setting VFNum=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], vf_num);

                            // Set page Size
                            `CFG_RD_BDF (bdf, sriov_addr + 12'h01c, 4'hf, rd_data);
                            // Pick the smallest supported page size
                            vf_page_size[b][d][f] = min_pg_size;
                            while (((rd_data >> vf_page_size[b][d][f]) & 32'b1) == 32'b0)
                            begin
                                vf_page_size[b][d][f] = vf_page_size[b][d][f] + 1;
                                if (vf_page_size[b][d][f] == 31)
                                begin
                                    $display  ("%m : ERROR: Bus[%d], Dev[%d], Func[%d] : Supported Page Sizes cannot be 0", bdf[15:8], bdf[7:3], bdf[2:0]);
                                    `INC_ERRORS;
                                end
                            end

                            `CFG_WR_BDF_NULL (bdf, sriov_addr + 12'h020, 4'hf, 1 << vf_page_size[b][d][f]);
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       SR-IOV Capability : Setting PageSize = %0d KB", bdf[15:8], bdf[7:3], bdf[2:0], 4 << vf_page_size[b][d][f]);

                            for (r=0; ((r<num_bars) && (minimum_cfg == 0)); r=r+1) // Check all base address register locations
                            begin
                                // Get address offset for BAR location
                                bar_offset = (r+9) << 2;

                                // Write all 1's to the BAR and read to determine BAR size
                                //           bdf, addr,       be,   wr_data
                                `CFG_WR_BDF (bdf, sriov_addr + bar_offset, 4'hf, 32'hffffffff);
                                //   Now read to see a BAR exists and its size
                                //           bdf, addr,       be,   rd_data
                                `CFG_RD_BDF (bdf, sriov_addr + bar_offset, 4'hf, rd_data);

                                // Prefetchable bit is [3], mem/io_n is [0]
                                bar_type = {rd_data[3], rd_data[0]};

                                // Check for at least 1 address bit being programmable as an indication of a BAR being present
                                if ((rd_data != {32{1'b0}}) && (rd_data != {32{1'b1}})) // A BAR was found
                                begin

                                    bar_ok = 1;  //Will turn-off later, if not OK.
                                    if (rd_data[2:0] == 3'b100)
                                        bar64 = 1;
                                    else
                                        bar64 = 0;

                                    // Get BAR size, adjust for page size, multiply by
                                    // scale factor (for multiple VFs)
                                    save_data = rd_data;
                                    size = {32'hffffffff, rd_data[31:4], 4'b0};
                                    vf_size = ~size + 64'h1;

                                    // Configure a 64 bit memory BAR for each VF in the > 4GB region only if enabled by (bar_no_mem64[b][d][f][r] == 1'b0)
                                    //   or if the BAR is too big for 32-bit address space
                                    if (bar64 & ((bar_no_mem64[b][d][f][r] == 1'b0) | (size[31:0] == 32'h0)) & ((r+1)<6))
                                    begin
                                        if (bar64 & (bar_no_mem64[b][d][f][r] == 1'b1) & (size[31:0] == 32'h0))
                                        begin
                                            $display  ("%m : WARNING : Bus[%d], Dev[%d], Func[%d] : A 64-bit BAR was requested to be placed into 32-bit address space, but the BAR is too big to fit in 32-bit address space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                            $display  ("%m :           Bus[%d], Dev[%d], Func[%d] :   BAR will be placed into 64-bit address space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                        end

                                        // Write all 1's to the upper portion of the BAR and read to determine BAR size
                                        //           bdf, addr,               be,   wr_data
                                        `CFG_WR_BDF (bdf, sriov_addr + bar_offset + 12'h4, 4'hf, 32'hffffffff);
                                        //           bdf, addr,               be,   rd_data
                                        `CFG_RD_BDF (bdf, sriov_addr + bar_offset + 12'h4, 4'hf, rd_data);

                                        // Reset upper portion of size from previous read
                                        size = {rd_data, save_data[31:4], 4'b0};
                                        vf_size = ~size + 64'h1;


                                        last_mem_bar_64  = last_mem_bar_64  - gap_mem_bar;   //If gap_mem_bar is non-zero, a PCIe memory region gap will be forced.
                                        repeat (vf_num)
                                        begin
                                            bar_value       = (last_mem_bar_64 & size) - vf_size;
                                            last_mem_bar_64 = bar_value;
                                        end
                                    end
                                    // Configure as a 32-bit BAR in the < 4GB region
                                    else
                                    begin
                                        if (bar64 & (r == 5))
                                        begin
                                            $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : 64-bit BAR detected, but first 32-bits of BAR register is at the end of BAR space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                            $display  ("%m           Bus[%d], Dev[%d], Func[%d] :   BAR will be placed into 32-bit address space (time %t)", bdf[15:8], bdf[7:3], bdf[2:0], $time);
                                            `INC_ERRORS;
                                            bar64 = 0;
                                        end
                                        //We could be here due to a "64-bit" VF_BAR[5] ... so if we don't have enough 32-bit space, simply don't configure the BAR.
                                        save_bar = last_mem_bar_32;
                                        last_mem_bar_32 = (last_mem_bar_32 - gap_mem_bar) & {size[31:0]};  //If gap_mem_bar is non-zero, a PCIe memory region gap will be forced.
                                        size32_vf_all = (~size + 1) * vf_num;  //Calculate the overall vf bar range. Use 64-bit arithmetic to cover extending beyond a 32-bit number.
                                        if ((save_bar == 0) || (size32_vf_all  > last_mem_bar_32))
                                        begin
                                            //Can't configure this bar, its too large, either report an error or a warning as defined by report_barsize_viol_as_error.
                                            $display ("%m : %s ,  Bus[%d], Dev[%d], Func[%d] : 32-bit BAR %d does not fit in remaining memory space and won't be configured (time %t)",
                                                     (report_barsize_viol_as_error ? "ERROR" : "WARNING"),bdf[15:8], bdf[7:3], bdf[2:0], r, $time);
                                            if(report_barsize_viol_as_error) `INC_ERRORS;
                                            last_mem_bar_32 = save_bar;
                                            bar_ok = 0;
                                            `CFG_WR_BDF (bdf, sriov_addr + bar_offset, 4'hf, 32'h0);
                                        end else
                                        begin
                                            bar_value = last_mem_bar_32 - size32_vf_all;
                                            last_mem_bar_32 = bar_value;
                                        end
                                    end
                                    if(bar_ok) begin
                                        // Assign BAR Address
                                        //           bdf, addr,       be,   wr_data
                                        `CFG_WR_BDF_NULL (bdf, sriov_addr + bar_offset, 4'hf, bar_value[31:0]);
                                        // if BAR is 64-bit, assign upper bar address as well
                                        if (bar64)
                                        begin
                                            //           bdf, addr,               be,   wr_data
                                            `CFG_WR_BDF_NULL (bdf, sriov_addr + bar_offset + 12'h4, 4'hf, bar_value[63:32]);
                                        end

                                        vf_bar_present  [b][d][f][r] = 1'b1; // Present
                                        vf_bar_addr     [b][d][f][r] = bar_value;
                                        vf_bar_size     [b][d][f][r] = vf_size;
                                        vf_bar_vfnum    [b][d][f][r] = vf_num;

                                        if ((bar_value % (4096 << vf_page_size[b][d][f])) != 0)
                                        begin
                                            $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : Virtual Function BAR[%0d] Address is not aligned to a System Page Size (%0d KB) Boundary",
                                                       b,d,f,r, 4 << vf_page_size[b][d][f]);
                                            `INC_ERRORS;
                                        end
                                        if ((vf_size % (4096 << vf_page_size[b][d][f])) != 0)
                                        begin
                                            $display  ("%m : ERROR : Bus[%d], Dev[%d], Func[%d] : Virtual Function BAR[%0d] Size is not a multiple of the System Page Size (%0d KB)",
                                                       b,d,f,r,4 << vf_page_size[b][d][f]);
                                            `INC_ERRORS;
                                        end

                                        bar_osize = (~size+1);
                                        bar_size  = (~size+1);

                                        if (bar_size >= 32'h40000000)
                                        begin
                                            bar_size = bar_size >> 30; // Represent as GBytes
                                            bar_text = 2'h3;
                                        end
                                        else if (bar_size >= 32'h00100000)
                                        begin
                                            bar_size = bar_size >> 20; // Represent as MBytes
                                            bar_text = 2'h2;
                                        end
                                        else if (bar_size >= 32'h00000400)
                                        begin
                                            bar_size = bar_size >> 10; // Represent as KBytes
                                            bar_text = 2'h1;
                                        end
                                        else
                                        begin
                                            bar_text = 2'h0;           // Represent as Bytes
                                        end

                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : VF_BAR[%1d], Memory, %0s, Size=0x%0x_%x (%3d %0sBytes) configured to base address=0x%x_%x",
                                                   bdf[15:8], bdf[7:3], bdf[2:0], r,
                                                   bar_type[1] ? "Prefetchable" : "Not Prefetchable",
                                                   bar_osize[63:32],bar_osize[31:0],
                                                   bar_size,
                                                   bar_text == 2'b11 ? "G" : bar_text == 2'b10 ? "M" : bar_text == 2'b01 ? "K" : " " ,
                                                   bar_value[63:32],bar_value[31:0]);

                                        if (bar64)
                                        begin
                                            // Increment bar one additional time since two BAR regions have been processed in this loop
                                            r = r + 1;
                                        end
                                    end
                                end // if ((rd_data != {32{1'b0}}) && (rd_data != {32{1'b1}})) // A BAR was found
                                else
                                begin
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : VF_BAR[%1d] - BAR location is unused", bdf[15:8], bdf[7:3], bdf[2:0], r);
                                end
                            end // for (r=0; r<num_bars; r=r+1) // Check all base address register locations

                            // Enable VFs
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Set VF Enable to enable Virtual Functions", bdf[15:8], bdf[7:3], bdf[2:0]);
                            `CFG_RD_BDF (bdf, sriov_addr + 12'h008, 4'hf, rd_data);
                            `CFG_WR_BDF (bdf, sriov_addr + 12'h008, 4'hf, rd_data | 32'h1);

                            // Scan VF config space
                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Scan VF Configuration Space", bdf[15:8], bdf[7:3], bdf[2:0]);
                            vf = f + vf_offset;
                            while (vf <= (f + vf_offset + (vf_stride * (vf_num - 1))))
                            begin
                                bdf = {b[7:0], vf[7:0]};

                                `CFG_RD_BDF (bdf, 12'h0, 4'hf, rd_data);
                                if ((rd_data != {32{1'b1}}))
                                begin
                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : No VF found", bdf[15:8], bdf[7:3], bdf[2:0]);
                                    dev_present   [b][vf[7:3]][vf[2:0]] = 1'b0;
                                end
                                else
                                begin
                                    dev_present   [b][vf[7:3]][vf[2:0]] = 1'b1;
                                    dev_id_for_vf [b][vf[7:3]][vf[2:0]] = {b[7:0], d[4:0], f[2:0]};
                                    vf_page_size  [b][vf[7:3]][vf[2:0]] = vf_page_size[b][d][f];

                                    // Copy BAR data from PF SR-IOV Capability
                                    for (r=0; r<num_bars; r=r+1)
                                    begin
                                         if (vf_bar_present [b][d][f][r] == 1'b1)
                                         begin
                                             bar_present  [b][vf[7:3]][vf[2:0]][r] = 1'b1;
                                             bar_addr     [b][vf[7:3]][vf[2:0]][r] = vf_bar_addr [b][d][f][r] + ((vf-f-vf_offset)/vf_stride) * vf_bar_size [b][d][f][r];
                                             bar_index    [b][vf[7:3]][vf[2:0]][r] = r;
                                             bar_io_mem_n [b][vf[7:3]][vf[2:0]][r] = 1'b0; // Memory BAR only for VF
                                         end
                                    end

                                    // ---------------------------
                                    // Discover Capabilities Items

                                    // Device Type must be PCIe Endpoint
                                    device_type = 4'b0000;

                                    // Read start of capabilities pointer list
                                    //           bdf, addr,    be,   rd_data
                                    `CFG_RD_BDF (bdf, 12'h034, 4'hf, rd_data);
                                    curr_cap_ptr = {4'h0, rd_data[7:0]};

                                    while (curr_cap_ptr != 12'h000)
                                    begin
                                        //           bdf, addr,         be,   rd_data
                                        `CFG_RD_BDF (bdf, curr_cap_ptr, 4'hf, rd_data);
                                        next_cap_ptr = {4'h0, rd_data[15:8]};

                                        case (rd_data[7:0]) // Capability ID

                                            8'h01 : begin // Power Management
                                                        cap_pm_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;

                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Power Management Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Power Management Capability : Supports PME from {D0, D1, D2, D3hot, D3cold} = {%d, %d, %d, %d, %d}", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[27], rd_data[28], rd_data[29], rd_data[30], rd_data[31]);
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Power Management Capability : Supports {D1, D2, D3hot} = {%d, %d, %d}", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[25], rd_data[26], 1'b1);
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Power Management Capability : Aux_Current=0x%x, DSI=0x%x, PME_Clock=0x%x, Version=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[24:22], rd_data[21], rd_data[19], rd_data[18:16]);
                                                    end

                                            8'h02 : begin // AGP
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AGP Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h03 : begin // VPD
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found VPD Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h04 : begin // Slot Identification
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Slot Identification Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h05 : begin // MSI
                                                        msi_64                = rd_data[23];
                                                        msi_rvec              = 16'h1 << rd_data[19:17];  // Number of MSI Vectors requested by this function
                                                        cap_msi_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                        cap_msi_rvec[b][vf[7:3]][vf[2:0]] = msi_rvec;
                                                        cap_msi_64  [b][vf[7:3]][vf[2:0]] = msi_64;
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found MSI Capability : Offset=0x%x, CapID=0x%x, PVM=%x, 64bit=%x, ReqVectors=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0], rd_data[24], msi_64, msi_rvec[7:0]);
                                                    end

                                            8'h06 : begin // Compact PCI Hot Swap
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Compact PCI Hot Swap Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h07 : begin // PCI-X
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI-X Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h08 : begin // Reserved for AMD
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Reserved for AMD Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h09 : begin // Vendor-Specific
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Vendor-Specific Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h0A : begin // Debug Port
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Debug Port Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h0B : begin // CompactPCI Central Resource Control
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found CompactPCI Central Resource Control Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h0C : begin // PCI Hot Plug
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Hot Plug Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h0D : begin // Bridge Subsystem Vendor ID
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Bridge Subsystem Vendor ID Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h0E : begin // AGP 8x
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AGP 8x Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h0F : begin // Secure Device
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Secure Device Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                            8'h10 : begin // PCI Express
                                                        device_type               = rd_data[23:20];
                                                        slot_implemented          = rd_data[   24];
                                                        interrupt_message_number  = rd_data[29:25];
                                                        cap_pcie_addr   [b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                        cap_pcie_intvec [b][vf[7:3]][vf[2:0]] = interrupt_message_number;
                                                        cap_pcie_devtype[b][vf[7:3]][vf[2:0]] = device_type;

                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Capability : Offset=0x%x, CapID=0x%x, Version=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0], rd_data[19:16]);
                                                        case (device_type)
                                                            4'b0000 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (PCI Express Endpoint)",                   bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b0001 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Legacy PCI Express Endpoint)",            bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b0100 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Root Port of PCI Express Root Complex)",  bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b0101 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Upstream Port of PCI Express Switch)",    bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b0110 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Downstream Port of PCI Express Switch)",  bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b0111 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (PCI Express to PCI/PCI-X Bridge)",        bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b1000 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (PCI/PCI-X to PCI Express Bridge)",        bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b1001 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Root Complex Integrated Endpoint)",       bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            4'b1010 : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (Root Complex Event Collector)",           bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                            default : $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : Device/PortType=%bb (ERROR: Unknown)",                                bdf[15:8], bdf[7:3], bdf[2:0], device_type);
                                                        endcase
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : SlotImplemented=0x%x, InterruptMessageNumber=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], slot_implemented, interrupt_message_number);

                                                        //           bdf, addr,               be,   rd_data
                                                        `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                                        max_payload_size_supported        = rd_data[2:0];
                                                        cap_pcie_max_pl_size_sup[b][vf[7:3]][vf[2:0]] = max_payload_size_supported;
                                                        cap_pcie_ex_tag_sup     [b][vf[7:3]][vf[2:0]] = rd_data[5];
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxPayloadSizeSupported=%d Bytes", bdf[15:8], bdf[7:3], bdf[2:0], (16'd128<<max_payload_size_supported));

                                                        // Get ASPM Support from Link Capabilities
                                                        //           bdf, addr,               be,   rd_data
                                                        `CFG_RD_BDF (bdf, curr_cap_ptr + 'hc, 4'hf, rd_data);
                                                        maximum_link_speed                = rd_data[3:0];
                                                        maximum_link_width                = rd_data[9:4];
                                                        aspm_support                      = rd_data[11:10];
                                                        aspm_optionality_compliance       = rd_data[22];
                                                        cap_pcie_aspm_sup[b][vf[7:3]][vf[2:0]] = aspm_support;

                                                        if (maximum_link_speed == 4'h1)
                                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=2.5G, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);
                                                        else if (maximum_link_speed == 4'h2)
                                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=5.0G, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);
                                                        else if (maximum_link_speed == 4'h3)
                                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=8.0G, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);
                                                        else
                                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : MaxLinkSpeed=UnknownValue, MaxLinkWidth=%2d", bdf[15:8], bdf[7:3], bdf[2:0], maximum_link_width);

                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       PCI Express Capability : SupportsASPM[L1,L0s]=[%b,%b], ASPMOptionalityCompliance=%b", bdf[15:8], bdf[7:3], bdf[2:0], aspm_support[1], aspm_support[0], aspm_optionality_compliance);
                                                    end

                                            8'h11 : begin // MSI-X
                                                        msix_rvec                 = {1'b0, rd_data[26:16]} + 12'h1; // Number of MSI-X Vectors requested by this function
                                                        cap_msix_addr   [b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                        cap_msix_rvec   [b][vf[7:3]][vf[2:0]] = msix_rvec;
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found MSI-X Capability : Offset=0x%x, CapID=0x%x, ReqVectors=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0], msix_rvec);
                                                    end

                                            default :
                                                    begin
                                                        $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Unknown Capability : Offset=0x%x, CapID=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[7:0]);
                                                    end

                                        endcase

                                        // Advance to next capability
                                        curr_cap_ptr = next_cap_ptr;
                                    end

                                    // -------------------------------------
                                    // Configure Enhanced Capabilities Items

                                    // Read start of enhanced capabilities pointer list
                                    ecap_ptr_first = 1'b1;
                                    curr_cap_ptr  = 12'h100;

                                    while (curr_cap_ptr != 12'h000)
                                    begin
                                        if (curr_cap_ptr < 12'h100)
                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : Enhanced Capabilities Pointer == 0x%x; Enhanced Capabilities must be located at addresses >= 0x100", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr);

                                        //           bdf, addr,         be,   rd_data
                                        `CFG_RD_BDF (bdf, curr_cap_ptr, 4'hf, rd_data);
                                        next_cap_ptr = rd_data[31:20];

                                        if (rd_data[31:0] == 32'h0)
                                        begin
                                            if (ecap_ptr_first == 1'b1)
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : No Enhanced Capabilities Found : Offset=0x%x, ReadData=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[31:0]);
                                            else
                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ERROR : Next Enhanced Capabilities Pointer pointed to invalid address : Offset=0x%x, ReadData=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[31:0]);
                                        end
                                        else
                                        begin
                                            case (rd_data[15:0]) // Extended Capability ID

                                                16'h0001 :  begin // Advanced Error Reporting Capability
                                                                if (rd_data[19:16] == 4'h1)
                                                                begin
                                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AER Enhanced Capability : Offset=0x%x, CapVersion=0x%x (PCIe 2.0/1.1)", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[19:16]);
                                                                end
                                                                else if (rd_data[19:16] == 4'h2)
                                                                begin
                                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AER Enhanced Capability : Offset=0x%x, CapVersion=0x%x (PCIe 3.0)", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[19:16]);
                                                                end
                                                                else
                                                                begin
                                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found AER Enhanced Capability : Offset=0x%x, CapVersion=0x%x (Unknown Version)", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[19:16]);
                                                                    $display  ("%m : Bus[%d], Dev[%d], Func[%d] : ** WARNING ** : AER Enhanced Capability cannot be setup because version is not recognized", bdf[15:8], bdf[7:3], bdf[2:0]);
                                                                end

                                                                // Setup capability if it is a known version
                                                                if ((rd_data[19:16] == 4'h1) | (rd_data[19:16] == 4'h2))
                                                                begin
                                                                    // Record starting address of Capability
                                                                    cap_aer_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                                end
                                                            end

                                                16'h0002,
                                                16'h0009 :  begin // Virtual Channel Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Virtual Channel Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0003 :  begin // Device Serial Number Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Device Serial Number Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0004 :  begin // Power Budgeting Capability
                                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Power Budgeting Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0005 :  begin // PCI Express Root Complex Link Declaration Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Root Complex Link Declaration Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0006 :  begin // PCI Express Root Complex Internal Link Control Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Root Complex Internal Link Control Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0007 :  begin // PCI Express Root Complex Event Collector Endpoint Association Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PCI Express Root Complex Event Collector Endpoint Association Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0008 :  begin // Multi-Function Virtual Channel Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Multi-Function Virtual Channel Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h000A :  begin // RCRB Header Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found RCRB Header Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h000B :  begin // Vendor-Specific Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Vendor-Specific Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                                //           bdf, addr,               be,   rd_data
                                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       Vendor-Specific Capability : VSEC_ID=0x%x, VSEC_Rev=0x%x, VSEC_Length=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[15:0], rd_data[19:16], rd_data[31:20]);
                                                                if (rd_data[15:0] == 1) // NWL VSEC ID == 1
                                                                    cap_ven_addr[b][d][f] = curr_cap_ptr;
                                                                else
                                                                    cap_vsec_addr[b][d][f] = curr_cap_ptr;
                                                           end

                                                16'h000D :  begin // ACS Extended Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found ACS Extended Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h000E :  begin // ARI Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found ARI Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                                cap_ari_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                            end

                                                16'h000F :  begin // ATS Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found ATS Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                                cap_ats_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                            end

                                                16'h0010 :  begin // SR-IOV Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found SR-IOV Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0012 :  begin // Multicast Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Multicast Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0015 :  begin // Resizable BAR Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Resizable BAR Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0016 :  begin // Dynamic Power Allocation (DPA) Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Dynamic Power Allocation (DPA) Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0017 :  begin // TPH Requester Extended Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found TPH Requester Extended Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                                //           bdf, addr,               be,   rd_data
                                                                `CFG_RD_BDF (bdf, curr_cap_ptr + 'h4, 4'hf, rd_data);
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] :       TPH Requester Extended Capability : ST_Size=0x%x, ST_Loc=0x%x, Ext_TPH=0x%x, ST_Modes=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], rd_data[26:16], rd_data[10:9], rd_data[8], rd_data[2:0]);
                                                                cap_tph_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                            end

                                                16'h0018 :  begin // Latency Tolerance Reporting (LTR) Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Latency Tolerance Reporting (LTR) Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                16'h0019 :  begin // Secondary PCI Express Extended Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Secondary PCI Express Extended Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                                cap_sec_pcie_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                            end

                                                16'h001B :  begin // PASID Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found PASID Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                                cap_pasid_addr[b][vf[7:3]][vf[2:0]] = curr_cap_ptr;
                                                            end

                                                16'h001E :  begin // L1 PM Substates Capability
                                                                $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found L1 PM Substates Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                            end

                                                default :
                                                        begin
                                                            $display  ("%m : Bus[%d], Dev[%d], Func[%d] : Found Unknown Enhanced Capability : Offset=0x%x, CapID=0x%x, CapVersion=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], curr_cap_ptr, rd_data[15:0], rd_data[19:16]);
                                                        end

                                            endcase
                                        end

                                        // Advance to next capability
                                        curr_cap_ptr   = next_cap_ptr;
                                        ecap_ptr_first = 1'b0;
                                    end
                                end
                                // Increase to next VF
                                vf = vf + vf_stride;
                            end // vf loop
                        end

                    end // SRIOV

                    // ----------------------------------
                    // Type 1 Switch/Bridge Configuration

                    if (header_type == 1'b1) // Found Switch/Bridge device
                    begin
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : Device is Type 1 (Switch/Bridge)", bdf[15:8], bdf[7:3], bdf[2:0]);

                        bus_primary      = b;
                        // Assign discovered Secondary Bus the next bus number
                        bus              = next_bus;
                        next_bus         = next_bus + 1;
                        bus_secondary    = bus;
                        // Subordinate Bus Number is temporarily assigned its maximum value since we don't know how many busses are behind
                        //   the switch/bridge yet and we need discovery configuration writes/reads to be able to reach devices behind the
                        //   switch/bridge; we will program the correct Subordinate Bus Number later when we know it
                        bus_subordinate  = 8'hff;

                        // Truncate the last used address to the resolution of the base/limit registers
                        last_mem_bar_64 = last_mem_bar_64 & {{(64-20){1'b1}}, {20{1'b0}}};
                        last_mem_bar_32 = last_mem_bar_32 & {{(32-20){1'b1}}, {20{1'b0}}};
                        last_io_bar_32  = last_io_bar_32  & {{(32-12){1'b1}}, {12{1'b0}}};

                        // Save address limits; the Switch/Bridge limit must be set to less than the last assigned base address;
                        //   If no devices are discovered behind the bus of one of these region types, then this will also guarantee
                        //   that limit < base so that the region will be disabled
                        bus_pf_mem_limit = last_mem_bar_64[63:20] - 44'h1;
                        bus_mem_limit    = last_mem_bar_32[31:20] - 12'h1;
                        bus_io_limit     = last_io_bar_32 [31:12] - 20'h1;

                        // Write Subordinate, Secondary, and Primary Bus Numbers so that configuration transactions
                        //   can be routed to discover devices behind the switch/bridge; Secondary Latency Timer is
                        //   not implemented for PCI Express Devices, but write 0x40 in case it is implemented
                        //           bdf, addr,    be,   wr_data
                        `CFG_WR_BDF (bdf, 12'h018, 4'hf, {8'h40, bus_subordinate, bus_secondary, bus_primary});

                        // If the device is an Upstream Switch Port or a PCI Express to PCI/PCI-X Bridge then scan for MAX_DEVICE_NUM devices
                        if ( (device_type == 4'b0101) |    // Upstream Port of PCI Express Switch
                             (device_type == 4'b0111) )    // PCI Express to PCI/PCI-X Bridge
                            max_dev = MAX_DEVICE_NUM - 1;
                        // Otherwise there should be only 1 device below this device
                        else
                            max_dev = 5'h0;

                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : Pause bus configuration to configure subordinate bus", bdf[15:8], bdf[7:3], bdf[2:0]);
                        // Configure newly discovered Bus; will also configure discovered busses downstream of the discovered
                        //    device, since configure_bus calls itself additional times as additional busses are discovered
                        configure_bus  (bus,                // bus
                                        next_bus,           // next_bus to allocate
                                        max_dev,            // Device numbers to scan (0 to max_dev)
                                        last_mem_bar_64,    // last_mem_bar_64
                                        last_mem_bar_32,    // last_mem_bar_32
                                        last_io_bar_32,     // last_io_bar_32
                                        minimum_cfg);       // write minumum configuration

                        next_bus = bus + 1;                 // Advance to next bus number

                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : Resume bus configuration after configuring subordinate bus", bdf[15:8], bdf[7:3], bdf[2:0]);

                        // Truncate the last used address to the resolution of the base/limit registers
                        last_mem_bar_64 = last_mem_bar_64 & {{(64-20){1'b1}}, {20{1'b0}}};
                        last_mem_bar_32 = last_mem_bar_32 & {{(32-20){1'b1}}, {20{1'b0}}};
                        last_io_bar_32  = last_io_bar_32  & {{(32-12){1'b1}}, {12{1'b0}}};

                        // Assign values to program into Switch/Bridge Configuration Registers
                        bus_subordinate = bus;
                        bus_pf_mem_base = last_mem_bar_64[63:20];
                        bus_mem_base    = last_mem_bar_32[31:20];
                        bus_io_base     = last_io_bar_32 [31:12];

                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : Configure Switch/Bridge to map discovered subordinate bus resources", bdf[15:8], bdf[7:3], bdf[2:0]);

                        // Write Subordinate, Secondary, and Primary Bus Numbers
                        //           bdf, addr,    be,   wr_data
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : bus_primary=0x%x, bus_secondary=0x%x, bus_subordinate=0x%x", bdf[15:8], bdf[7:3], bdf[2:0], bus_primary, bus_secondary, bus_subordinate);
                        `CFG_WR_BDF_NULL (bdf, 12'h018, 4'hf, {8'h40, bus_subordinate, bus_secondary, bus_primary});

                        // Write Prefetchable Memory Base & Limit
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : bus_pf_mem_limit=0x%x_00000, bus_pf_mem_base=0x%x_00000", bdf[15:8], bdf[7:3], bdf[2:0], bus_pf_mem_limit, bus_pf_mem_base);
                        //           bdf, addr,    be,   wr_data
                        `CFG_WR_BDF_NULL  (bdf, 12'h024, 4'hf, {bus_pf_mem_limit[31:20], 4'h0, bus_pf_mem_base[31:20], 4'h0});
                        `CFG_WR_BDF_NULL  (bdf, 12'h028, 4'hf, bus_pf_mem_base [63:32]);
                        `CFG_WR_BDF_NULL  (bdf, 12'h02c, 4'hf, bus_pf_mem_limit[63:32]);

                        // Write Mem Base & Limit
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : bus_mem_limit=0x%x_00000, bus_mem_base=0x%x_00000", bdf[15:8], bdf[7:3], bdf[2:0], bus_mem_limit, bus_mem_base);
                        //           bdf, addr,    be,   wr_data
                        `CFG_WR_BDF_NULL  (bdf, 12'h020, 4'hf, {bus_mem_limit[31:20], 4'h0, bus_mem_base[31:20], 4'h0});

                        // Write I/O Base & Limit
                        $display ("%m : Bus[%d], Dev[%d], Func[%d] : (Switch/Bridge) : bus_io_limit=0x%x_000, bus_io_base=0x%x_000", bdf[15:8], bdf[7:3], bdf[2:0], bus_io_limit, bus_io_base);
                        //           bdf, addr,    be,   wr_data
                        `CFG_WR_BDF_NULL  (bdf, 12'h01C, 4'h3, {16'h0, bus_io_limit[15:12], 4'h0, bus_io_base[15:12], 4'h0});
                        `CFG_WR_BDF (bdf, 12'h030, 4'hf, {bus_io_limit[31:16], bus_io_base[31:16]});
                    end

                end

              end // (dev_present[b][d][f] == 1'b0)
              else
              begin
                $display ("%m : Bus[%d], Dev[%d], Func[%d] : Skipped : A VF that was part of a prior PF's SRIOV Capability was already found at this location", bdf[15:8], bdf[7:3], bdf[2:0]);
              end

              // Increase to next function number
              f = f + 1;

              // Stop scanning Device Numbers if the current Device had no functions
              if (funcs_found == 0)
                  done = 1;

            end // while (f < num_funcs_to_scan) // Scan possible function locations for devices

            // Increase to next device number
            d = d + 1;
        end
        use_fast_dut_cfg_access = 1'b0;
    end
endtask


// -------------
// Configure DMA

// Scans for DUT DMA Engine Support and sets up
//   BFM environment variables used in testing;
//   DUT must be configured before calling this task
task configure_dma;

    integer         i;
    reg     [31:0]  read_data;

    begin
        // -----------------------------
        // Inititalize DMA Engine values

        g3_num_c2s            = 0;
        g3_num_s2c            = 0;
        g3_num_com            = 0;
        g3_int_vec            = 0;
        g3_smallest_card_addr = 0;
        g3_max_bcount         = 0;
        g3_com_bar            = 0;

        for (i=0; i<MAX_C2S_DMA_ENGINES; i=i+1)
        begin
            g3_c2s_cap[i]         = 32'h0;
            g3_c2s_pkt_block_n[i] = 1'b0;
            g3_c2s_reg_base[i]    = 64'h0;
            g3_c2s_pat_base[i]    = 64'h0;
            g3_c2s_int_vector[i]  = 12'h0;
        end

        for (i=0; i<MAX_S2C_DMA_ENGINES; i=i+1)
        begin
            g3_s2c_cap[i]         = 32'h0;
            g3_s2c_pkt_block_n[i] = 1'b0;
            g3_s2c_reg_base[i]    = 64'h0;
            g3_s2c_pat_base[i]    = 64'h0;
            g3_s2c_int_vector[i]  = 12'h0;
        end

        // ----------------
        // DMA Engine Setup

        $display  ("%m : Scan to determine how many engines are present and their capabilities");

        g3_num_c2s  = 0;
        g3_num_s2c  = 0;
        g3_num_com  = 0;
        g3_int_vec  = 0;

        g3_smallest_card_addr = 8'hff;

        // Check all possible DMA Engine locations in the selected ranges for DMA Engine Register sets
        for (i=G3_RANGE1_LO; i<=G3_RANGE1_HI; i=i+1)
        begin
            //`MEM_READ_DWORD   (tc,     addr,         expect_data,  check_be, read_data);
            `MEM_READ_DWORD     (3'b000, bar[0]+(i*256), 32'h00000000, 4'h0,     read_data);

            if (read_data[0] == 1'b1) // Test for engine present
            begin
                // Increment engine count
                if (read_data[1]) // Test for engine type: 1 == C2S, 0 == S2C
                begin
                    if (read_data[7:4] == 4'h0)
                        $display  ("%m : Found Card to System Block DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h1)
                        $display  ("%m : Found Card to System Packet DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h3)
                        $display  ("%m : Found Card to System Packet DMA Engine (with addressable packet support); Capabilities == %x", read_data);
                    else
                        $display  ("%m : Found Card to System DMA Engine of unknown type; Capabilities == %x", read_data);

                    g3_c2s_cap[g3_num_c2s]         = read_data;
                    g3_c2s_pkt_block_n[g3_num_c2s] = read_data[4];
                    g3_c2s_reg_base[g3_num_c2s]    = bar[0] + (i*DMA_REG_BYTE_SIZE);
                    g3_c2s_pat_base[g3_num_c2s]    = g3_c2s_reg_base[g3_num_c2s] + 16'hA000; // Pattern generator registers
                    g3_c2s_int_vector[g3_num_c2s]  = int_num_base_vector + g3_int_vec; // Interrupt vectors are and must be assigned the same way as in the DMA BE
                    g3_int_vec = g3_int_vec + 1;
                    // Alias vectors if fewer are allocated than requested
                    if (int_num_vec_alloc <= g3_int_vec)
                        g3_int_vec = 0;
                    g3_num_c2s = g3_num_c2s + 1;
                end
                else
                begin
                    if (read_data[7:4] == 4'h0)
                        $display  ("%m : Found System to Card Block DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h1)
                        $display  ("%m : Found System to Card Packet DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h3)
                        $display  ("%m : Found System to Card Packet DMA Engine (with addressable packet support); Capabilities == %x", read_data);
                    else
                        $display  ("%m : Found System to Card DMA Engine of unknown type; Capabilities == %x", read_data);

                    g3_s2c_cap[g3_num_s2c]         = read_data;
                    g3_s2c_pkt_block_n[g3_num_s2c] = read_data[4];
                    g3_s2c_reg_base[g3_num_s2c]    = bar[0] + (i*DMA_REG_BYTE_SIZE);
                    g3_s2c_pat_base[g3_num_s2c]    = g3_s2c_reg_base[g3_num_s2c] + 16'hA000; // Pattern generator registers
                    g3_s2c_int_vector[g3_num_s2c]  = int_num_base_vector + g3_int_vec; // Interrupt vectors are and must be assigned the same way as in the DMA BE
                    g3_int_vec = g3_int_vec + 1;
                    // Alias vectors if fewer are allocated than requested
                    if (int_num_vec_alloc <= g3_int_vec)
                        g3_int_vec = 0;
                    g3_num_s2c = g3_num_s2c + 1;
                end

                if (read_data[5:4] == 2'h1) // Packet DMA
                begin
                    // Write DMA Interrupt Control register with desired interrupt behavior
                    // `MEM_WRITE_DWORD (tc,     addr,                data,                  be);
                    `MEM_WRITE_DWORD    (3'b000, bar[0]+(i*256)+'h20, DMA_INTERRUPT_CONTROL, 4'hf);
                end

                // Keep track of the smallest advertised card address size
                if (read_data[23:16] < g3_smallest_card_addr)
                    g3_smallest_card_addr = read_data[23:16];
            end
        end

        for (i=G3_RANGE2_LO; i<=G3_RANGE2_HI; i=i+1)
        begin
            //`MEM_READ_DWORD   (tc,     addr,         expect_data,  check_be, read_data);
            `MEM_READ_DWORD     (3'b000, bar[0]+(i*256), 32'h00000000, 4'h0,     read_data);

            if (read_data[0] == 1'b1) // Test for engine present
            begin
                // Increment engine count
                if (read_data[1]) // Test for engine type: 1 == C2S, 0 == S2C
                begin
                    if (read_data[7:4] == 4'h0)
                        $display  ("%m : Found Card to System Block DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h1)
                        $display  ("%m : Found Card to System Packet DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h3)
                        $display  ("%m : Found Card to System Packet DMA Engine (with addressable packet support); Capabilities == %x", read_data);
                    else
                        $display  ("%m : Found Card to System DMA Engine of unknown type; Capabilities == %x", read_data);

                    g3_c2s_cap[g3_num_c2s]         = read_data;
                    g3_c2s_pkt_block_n[g3_num_c2s] = read_data[4];
                    g3_c2s_reg_base[g3_num_c2s]    = bar[0] + (i*DMA_REG_BYTE_SIZE);
                    g3_c2s_pat_base[g3_num_c2s]    = g3_c2s_reg_base[g3_num_c2s] + 16'hA000; // Pattern generator registers
                    g3_c2s_int_vector[g3_num_c2s]  = int_num_base_vector + g3_int_vec; // Interrupt vectors are and must be assigned the same way as in the DMA BE
                    g3_int_vec = g3_int_vec + 1;
                    // Alias vectors if fewer are allocated than requested
                    if (int_num_vec_alloc <= g3_int_vec)
                        g3_int_vec = 0;
                    g3_num_c2s = g3_num_c2s + 1;
                end
                else
                begin
                    if (read_data[7:4] == 4'h0)
                        $display  ("%m : Found System to Card Block DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h1)
                        $display  ("%m : Found System to Card Packet DMA Engine; Capabilities == %x", read_data);
                    else if (read_data[7:4] == 4'h3)
                        $display  ("%m : Found System to Card Packet DMA Engine (with addressable packet support); Capabilities == %x", read_data);
                    else
                        $display  ("%m : Found System to Card DMA Engine of unknown type; Capabilities == %x", read_data);

                    g3_s2c_cap[g3_num_s2c]         = read_data;
                    g3_s2c_pkt_block_n[g3_num_s2c] = read_data[4];
                    g3_s2c_reg_base[g3_num_s2c]    = bar[0] + (i*DMA_REG_BYTE_SIZE);
                    g3_s2c_pat_base[g3_num_s2c]    = g3_s2c_reg_base[g3_num_s2c] + 16'hA000; // Pattern generator registers
                    g3_s2c_int_vector[g3_num_s2c]  = int_num_base_vector + g3_int_vec; // Interrupt vectors are and must be assigned the same way as in the DMA BE
                    g3_int_vec = g3_int_vec + 1;
                    // Alias vectors if fewer are allocated than requested
                    if (int_num_vec_alloc <= g3_int_vec)
                        g3_int_vec = 0;
                    g3_num_s2c = g3_num_s2c + 1;
                end

                if (read_data[5:4] == 2'h1) // Packet DMA
                begin
                    // Write DMA Interrupt Control register with desired interrupt behavior
                    // `MEM_WRITE_DWORD (tc,     addr,                data,                  be);
                    `MEM_WRITE_DWORD    (3'b000, bar[0]+(i*256)+'h20, DMA_INTERRUPT_CONTROL, 4'hf);
                end

                // Keep track of the smallest advertised card address size
                if (read_data[23:16] < g3_smallest_card_addr)
                    g3_smallest_card_addr = read_data[23:16];
            end
        end

        // Calculate the largest number of engine pairs
        g3_num_com = (g3_num_c2s > g3_num_s2c) ? g3_num_s2c : g3_num_c2s;

        // Calculate maximum byte count that should be used
        //   assume worst case that all engines share the same card address region
        g3_max_bcount = 1 << g3_smallest_card_addr;

        if (g3_num_com == 0) // Test for no common DMA pairs
            g3_max_bcount = 0;
        else
            // Divide available card to system space by number of pairs;
            //   assumes DMA tests will assign equal share of card address
            //   space to each engine
            g3_max_bcount = g3_max_bcount / g3_num_com;

        // Locate G3 DMA Common Register Block Base Address
        g3_com_bar = bar[0]+'h4000;
    end
endtask
task chk_cap_state;
    input   chk_tph_enab;            // Indicator to check that the TPH capability is enabled
    input   chk_dsn_enab;            // Indicator to check that the DSN capability is enabled
    input   chk_vpd_enab;            // Indicator to check that the VPD capability is enabled
    input   chk_uvsec_enab;          // Indicator to check that the User VSEC capability is enabled
    input   chk_ari_enab;            // Indicator to check that the ARI capability is enabled
    input   chk_pasid_enab;          // Indicator to check that the PASID capability is enabled
    input   chk_ats_enab;            // Indicator to check that the ATS capability is enabled
    input   chk_sriov_enab;          // Indicator to check that the SRIOV capability is enabled
    input   chk_nvsec_enab;          // Indicator to check that the NWL VSEC capability is enabled
    input   chk_msix_enab;           // Indicator to check that the NWL MSIX capability is enabled
    input   chk_msi_enab;            // Indicator to check that the NWL MSI capability is enabled
    input   chk_tph_disab;           // Indicator to check that the TPH capability is disabled
    input   chk_dsn_disab;           // Indicator to check that the DSN capability is disabled
    input   chk_vpd_disab;           // Indicator to check that the VPD capability is disabled
    input   chk_uvsec_disab;         // Indicator to check that the User VSEC capability is disabled
    input   chk_ari_disab;           // Indicator to check that the ARI capability is disabled
    inout   chk_pasid_disab;         // Indicator to check that the PASID capability is disabled
    input   chk_ats_disab;           // Indicator to check that the ATS capability is disabled
    input   chk_sriov_disab;         // Indicator to check that the SRIOV capability is disabled
    input   chk_nvsec_disab;         // Indicator to check that the NWL VSEC capability is disabled
    input   chk_msix_disab;          // Indicator to check that the NWL MSIX capability is disabled
    input   chk_msi_disab;           // Indicator to check that the NWL MSI capability is disabled
    input reg [7:0]  b;         // PCIe Bus Number
    input reg [4:0]  d;         // PCIe Device Number
    input reg [2:0]  f;         // PCIe Function Number

    begin
    //
    // Handle the Check Enable "flags", if they are set!
    //
    if(debug) begin
       $display ("%m : DEBUG : chk_tph_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_tph_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_dsn_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_dsn_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_vpd_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_vpd_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_uvsec_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_uvsec_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_ari_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_ari_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_pasid_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_pasid_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_ats_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_ats_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_sriov_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_sriov_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_nvsec_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_nvsec_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_msix_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_msix_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_msi_enab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_msi_enab, b, d, f, $time);
       $display ("%m : DEBUG : chk_tph_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_tph_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_dsn_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_dsn_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_vpd_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_vpd_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_uvsec_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_uvsec_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_ari_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_ari_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_pasid_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_pasid_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_ats_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_ats_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_sriov_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_sriov_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_nvsec_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_nvsec_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_msix_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_msix_disab, b, d, f, $time);
       $display ("%m : DEBUG : chk_msi_disab = %0b, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", chk_msi_disab, b, d, f, $time);
    end

    if(chk_tph_enab)
       if(cap_tph_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : TPH Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_dsn_enab)
       if(cap_dsn_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : DSN Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_vpd_enab)
       if(cap_vpd_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : VPD Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_uvsec_enab)
       if(cap_vsec_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : User VSEC Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_ari_enab)
       if(cap_ari_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : ARI Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_pasid_enab)
       if(cap_pasid_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : PASID Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_ats_enab)
       if(cap_ats_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : ats capability was not enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_sriov_enab)
       if(cap_sriov_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : SR-IOV Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_nvsec_enab)
       if(cap_ven_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : NWL VSEC Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_msi_enab)
       if(cap_msi_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : MSI Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    if(chk_msix_enab)
       if(cap_msix_addr[b][d][f] == 12'b0) begin
          $display ("%m : ERROR : MSIX Capability Was Not Enabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
       end

    //
    // Handle the Check Disable "flags", if they are set or if a virtual function is being tested and the capability should not be present just the same!
    //
    if(chk_tph_disab || !chk_tph_disab && !chk_tph_enab)
       if(cap_tph_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : TPH Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_tph_disab  = %b, chk_tph_enab = %d, (time %0t)", chk_tph_disab, chk_tph_enab, $time);
       end

    if(chk_dsn_disab || !chk_dsn_disab && !chk_dsn_enab)
       if(cap_dsn_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : DSN Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_dsn_disab  = %b, chk_dsn_enab = %d, (time %0t)", chk_dsn_disab, chk_dsn_enab, $time);
       end

    if(chk_vpd_disab || !chk_vpd_disab && !chk_vpd_enab)
       if(cap_vpd_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : VPD Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_vpd_disab  = %b, chk_vpd_enab = %d, (time %0t)", chk_vpd_disab, chk_vpd_enab, $time);
       end

    if(chk_uvsec_disab || !chk_uvsec_disab && !chk_uvsec_enab)
       if(cap_vsec_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : User VSEC Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_uvsec_disab  = %b, chk_uvsec_enab = %d, (time %0t)", chk_uvsec_disab, chk_uvsec_enab, $time);
       end

    if(chk_ari_disab || !chk_ari_disab && !chk_ari_enab)
       if(cap_ari_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : ARI Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_ari_disab  = %b, chk_ari_enab = %d, (time %0t)", chk_ari_disab, chk_ari_enab, $time);
       end

    if(chk_pasid_disab || !chk_pasid_disab && !chk_pasid_enab)
       if(cap_pasid_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : PASID Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_pasid_disab  = %b, chk_pasid_enab = %d, (time %0t)", chk_pasid_disab, chk_pasid_enab, $time);
       end

    if(chk_ats_disab || !chk_ats_disab && !chk_ats_enab)
       if(cap_ats_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : ATS Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_ats_disab  = %b, chk_ats_enab = %d, (time %0t)", chk_ats_disab, chk_ats_enab, $time);
       end

    if(chk_sriov_disab || !chk_sriov_disab && !chk_sriov_enab)
       if(cap_sriov_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : SR-IOV Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_sriov_disab  = %b, chk_sriov_enab = %d, (time %0t)", chk_sriov_disab, chk_sriov_enab, $time);
       end

    if(chk_nvsec_disab || !chk_nvsec_disab && !chk_nvsec_enab)
       if(cap_ven_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : NWL VSEC Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_nvsec_disab  = %b, chk_nvsec_enab = %d, (time %0t)", chk_nvsec_disab, chk_nvsec_enab, $time);
       end

    if(chk_msi_disab || !chk_msi_disab && !chk_msi_enab)
       if(cap_msi_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : MSI Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_msi_disab  = %b, chk_msi_enab = %d, (time %0t)", chk_msi_disab, chk_msi_enab, $time);
       end

    if(chk_msix_disab || !chk_msix_disab && !chk_msix_enab)
       if(cap_msix_addr[b][d][f] != 12'b0) begin
          $display ("%m : ERROR : MSIX Capability Was Not Disabled as expected, Bus(%0d), Device(%0d) and Function(%0d), (time %0t)", b, d, f, $time);
          `INC_ERRORS;
          if(debug)
             $display ("%m :     DEBUG : chk_msix_disab  = %b, chk_msix_enab = %d, (time %0t)", chk_msix_disab, chk_msix_enab, $time);
       end
    end

endtask


task automatic wait_dut_idle
    (
     input exp_idle
     );
reg dut_idle;
    begin
        dut_idle = ~exp_idle;
        while (dut_idle !== exp_idle)
        begin
            dut_idle = (`TOP_PATH.dut_to_model_p === `TOP_PATH.dut_to_model_n);
            @(posedge clk);
        end
    end
endtask

// Waits for the LTS SM to reach the specified state (for LTR_TEST)
task automatic wait_for_lts_state (
    input          bfm_dutN,
    input    [5:0] exp_state,
    input   [15:0] exp_substate,
    input   [31:0] timeout
);
reg  [31:0]  stimer;
reg   [4:0]  state;
reg   [15:0] substate;
reg   [5:0] clk_period;
    begin
        stimer = 0;

        if (bfm_dutN)
        begin
            state    = `RP0_PATH.mgmt_pcie_status[7:2];
            substate = `RP0_PATH.mgmt_pcie_status[959:944];
        end
        else
        begin
            state = 6'h3f;
        end
        if (state === 6'h3f)
        begin
            $display  ("%m : ERROR : This task is not supported for DUT with PCIe Hard Core Configurations");
            `INC_ERRORS;
        end
        else
        begin
            while ((stimer < timeout) && !((state === exp_state) &&
                                           ((exp_substate == 16'h0) || (exp_substate == substate))
                                           )
                   )
            begin
                if (bfm_dutN)
                    @(posedge clk);
                else
                    @(posedge `DUT_CLK);
                if (bfm_dutN)
                begin
                    state    = `RP0_PATH.mgmt_pcie_status[7:2];
                    substate = `RP0_PATH.mgmt_pcie_status[959:944];
                    clk_period = `BFM_PCIE_CORE.clk_period_in_ns[5:0];
                end
                else
                begin
                    stimer = stimer + clk_period;
                end
            end
            if (state != exp_state)
            begin
                $display  ("%m : ERROR : %s LTSSM state=0x%0h did not reach state=0x%0h within timeout period at time %0t", bfm_dutN? "BFM": "DUT", state, exp_state, $time);
                `INC_ERRORS;
            end
            else if ((exp_substate != 16'h0) && (substate != exp_substate))
            begin
                $display  ("%m : ERROR : %s LTSSM substate=0x%0h did not reach substate=0x%0h within timeout period at time %0t", bfm_dutN? "BFM": "DUT", substate, exp_substate, $time);
                `INC_ERRORS;
            end
        end
    end
endtask

// Task for Latency Tolerance Reporting Test (LTR_TEST)
task bfm_chk_ltr_msg (
    input [31:0] expect_data,
    input [31:0] timeout
);
    reg          done;
    reg  [127:0] msg_data;
    reg   [31:0] timer;
begin

    expect_data = {expect_data[23:16],expect_data[31:24],expect_data[7:0],expect_data[15:8]};   //reorder bytes
    done=0;
    while (done == 1'b0)
    begin
        @(posedge `BFM_CLK);
        if (`BFM_MSG_EN === 1'b1)
        begin
            msg_data = `BFM_MSG_DATA;
            if(debug) $display  ("%m : Message received at BFM at time = %0t",$time);
            if(debug) $display  ("%m : Dword %0d: data = 0x%h", 0, msg_data[(0+1)*32-1:0*32]);
            if(debug) $display  ("%m : Dword %0d: data = 0x%h", 1, msg_data[(1+1)*32-1:1*32]);
            if(debug) $display  ("%m : Dword %0d: data = 0x%h", 2, msg_data[(2+1)*32-1:2*32]);
            if(debug) $display  ("%m : Dword %0d: data = 0x%h", 3, msg_data[(3+1)*32-1:3*32]);
            done = 1'b1;
            if (msg_data[4*32-1:3*32] !== expect_data) begin
                $display  ("%m : ERROR: LTR Message payload=%x (expected=%x) at time %0t", msg_data[4*32-1:3*32], expect_data, $time);
                `INC_ERRORS;
            end
            done = 1;
        end
        if (timer == timeout)
        begin
            $display  ("%m : ERROR : BFM failed to receive a message on the Message Interface (time %0t)", $time);
            `INC_ERRORS;
            done = 1'b1;
        end
        timer = timer+1;
    end
end
endtask


// --------------
// Task err_check

task err_check;

input           err_nfat;
input           err_fat;
input           err_cor;

input           exp_nfat;
input           exp_fat;
input           exp_cor;
input           exp_ur;
input           exp_adv;
input           masked;
input [4:0]     err_ucor_bit;

input [127:0]   aer_header;
input [127:0]   aer_header_mask;

reg             aer_present;
reg   [31:0]    err_ucor_bit_mask;
reg   [31:0]    adv_bit_mask;
reg   [31:0]    read_data;
reg   [31:0]    ucor_status;
reg   [31:0]    corr_status;
reg   [31:0]    ucor_mask;
reg   [31:0]    ucor_bits;
reg   [31:0]    corr_bits;
reg   [4:0]     first_error_pointer;
reg   [31:0]    first_error_pointer_pos;
reg   [127:0]   read_aer_header;
reg   [15:0]    ldut_bdf;

begin
    aer_present = (cap_addr_aer != 12'h0);
    err_ucor_bit_mask = 32'b1 << err_ucor_bit;
    adv_bit_mask  = 32'b00000000_00000000_00100000_00000000;
    ucor_bits     = 32'b00000011_11111111_11110000_00110000;
    corr_bits     = 32'b00000000_00000000_11110001_11000001;
    ldut_bdf = `DUT_ID;

    // ----------------------------------
    // Check for expected errors messages

    begin   // aer and non-aer
        if (err_nfat && ~exp_nfat) begin
            $display  ("ERROR : Received ERR_NON_FATAL message when none expected (time %t)", $time);
            `INC_ERRORS;
        end
        if (~err_nfat && exp_nfat && !masked) begin
            $display  ("ERROR : Did not receive ERR_NON_FATAL message as expected (time %t)", $time);
            `INC_ERRORS;
        end
        if (err_cor && ~exp_cor) begin
            $display  ("ERROR : Received ERR_COR message when none expected (time %t)", $time);
            `INC_ERRORS;
        end
        if (~err_cor && exp_cor && !masked) begin
            $display  ("ERROR : Did not receive ERR_COR message as expected (time %t)", $time);
            `INC_ERRORS;
        end
        if (err_fat && ~exp_fat) begin
            $display  ("ERROR : Received ERR_FATAL message when none expected (time %t)", $time);
            `INC_ERRORS;
        end
        if (~err_fat && exp_fat && !masked) begin
            $display  ("ERROR : Did not receive ERR_FATAL message as expected (time %t)", $time);
            `INC_ERRORS;
        end

        // Check PCI Status
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_pcie + 'h8, 4'hF, read_data);

        if (read_data[19] && ~exp_ur) begin
            $display  ("ERROR : Expected Unsupported Request Status to be clear; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (~read_data[19] && exp_ur) begin
            $display  ("ERROR : Expected Unsupported Request Status to be set; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (read_data[18] && ~exp_fat) begin
            $display  ("ERROR : Expected Fatal_Error_Reported Status to be clear; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (~read_data[18] && exp_fat) begin
            $display  ("ERROR : Expected Fatal_Error_Reported Status to be set; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (read_data[17] && ~exp_nfat) begin
            $display  ("ERROR : Expected Non_Fatal_Error_Reported Status to be clear; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (~read_data[17] && exp_nfat) begin
            $display  ("ERROR : Expected Non_Fatal_Error_Reported Status to be set; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (read_data[16] && ~exp_cor) begin
            $display  ("ERROR : Expected Correctable Error Reported Status to be clear; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
        if (~read_data[16] && exp_cor) begin
            $display  ("ERROR : Expected Correctable Error Reported Status to be set; PCIe Device Status_Control = %x_%x (time %t)",
                              read_data[31:16], read_data[15:0], $time);
            `INC_ERRORS;
        end
    end

    if (aer_present) begin  // aer only
        // AER: Check and clear all reported AER errors

        // Read Uncorrectable Error Status
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h04, 4'hF, ucor_status);

        if ((ucor_status & err_ucor_bit_mask) != err_ucor_bit_mask) begin
            $display  ("ERROR : Uncorrectable Error Status is not set as expected; Uncorrectable Error Status = 0x%x (time %t)", ucor_status, $time);
            `INC_ERRORS;
        end
        if ((ucor_status & ucor_bits & ~err_ucor_bit_mask) != 32'h0) begin
            $display  ("ERROR : Uncorrectable Error Status = 0x%x; Expected = 0x%x; Too many bits set (time %t)", ucor_status, err_ucor_bit_mask, $time);
            `INC_ERRORS;
        end

        // Read First_Error_Pointer
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h18, 4'hF, read_data);
        first_error_pointer = read_data[4:0];

        // Read Header Log Registers
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h1c, 4'hF, read_aer_header[31:0]);
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h20, 4'hF, read_aer_header[63:32]);
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h24, 4'hF, read_aer_header[95:64]);
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h28, 4'hF, read_aer_header[127:96]);

        // Check for First_Error_Pointer and Header Log Register having expected values
        if (~masked & ((ucor_status & ucor_bits) != 32'h0)) begin

            // Check Header Log Register
            if (first_error_pointer == err_ucor_bit) begin  // matching ucor error
                if ((read_aer_header & aer_header_mask) != (aer_header & aer_header_mask)) begin
                    $display  ("ERROR : Header Log Register == 0x%x_%x_%x_%x; Expected == 0x%x_%x_%x_%x; Expected Mask == 0x%x_%x_%x_%x (time %t)",
                        read_aer_header[127:96], read_aer_header[ 95: 64], read_aer_header[ 63: 32], read_aer_header[ 31:  0],
                             aer_header[127:96],      aer_header[ 95: 64],      aer_header[ 63: 32],      aer_header[ 31:  0],
                        aer_header_mask[127:96], aer_header_mask[ 95: 64], aer_header_mask[ 63: 32], aer_header_mask[ 31:  0], $time);
                    `INC_ERRORS;
                end

                // Received expected error status and First Error Pointer; now clear status
                `CFG_WR_BDF (ldut_bdf, cap_addr_aer + 'h04, 4'hf, err_ucor_bit_mask);
            end
            else begin
                $display  ("ERROR : First_Error_Pointer == %d; Expected == %d (time %t)", first_error_pointer, 5'd12, $time);
                `INC_ERRORS;

                $display  ("        Header Log Register == 0x%x_%x_%x_%x; Expected == 0x%x_%x_%x_%x; Expected Mask == 0x%x_%x_%x_%x (time %t)",
                    read_aer_header[127:96], read_aer_header[ 95: 64], read_aer_header[ 63: 32], read_aer_header[ 31:  0],
                         aer_header[127:96],      aer_header[ 95: 64],      aer_header[ 63: 32],      aer_header[ 31:  0],
                    aer_header_mask[127:96], aer_header_mask[ 95: 64], aer_header_mask[ 63: 32], aer_header_mask[ 31:  0], $time);

                if ((read_aer_header & aer_header_mask) == (aer_header & aer_header_mask)) begin
                    $display  ("ERROR : First_Error_Pointer != Expected Error, but Header Log Register has the expected Unsupported Request Header (time %t)", first_error_pointer, 5'd20, $time);
                    `INC_ERRORS;
                end
            end
        end

        // Clear remaining Uncorrectable Errors; expected errors should already have been cleared

        // Read Uncorrectable Error Mask
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h08, 4'hF, ucor_mask);

        // Read Uncorrectable Error Status
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h04, 4'hF, ucor_status);

        // If one or more status bits are set that are not masked, then clear the errors
        while ((ucor_status & ucor_bits & ~ucor_mask) != 32'h0) begin
            // Read First_Error_Pointer
            //                 bdf,   addr,                be,      rd_data
            `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h18, 4'hF, read_data);

            first_error_pointer     = read_data[4:0];
            first_error_pointer_pos = (1 << first_error_pointer);

            // Read Header Log Registers
            //                 bdf,   addr,                be,      rd_data
            `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h1c, 4'hF, read_aer_header[31:0]);
            `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h20, 4'hF, read_aer_header[63:32]);
            `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h24, 4'hF, read_aer_header[95:64]);
            `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h28, 4'hF, read_aer_header[127:96]);

            $display  ("ERROR : Clearing unexpected error; First_Error_Pointer == %d; Header Log Register == 0x%x_%x_%x_%x (time %t)",
                first_error_pointer, read_aer_header[127:96], read_aer_header[ 95: 64], read_aer_header[ 63: 32], read_aer_header[ 31:  0], $time);
            `INC_ERRORS;
            if (first_error_pointer != 5'h0)
                // Clear Status corresponding to First Error Pointer
                `CFG_WR_BDF (ldut_bdf, cap_addr_aer + 'h04, 4'hf, first_error_pointer_pos);
            else
                // Clear all ucor error bits
                `CFG_WR_BDF (ldut_bdf, cap_addr_aer + 'h04, 4'hf, ucor_mask);

            // Read Uncorrectable Error Status
            //                 bdf,   addr,                be,      rd_data
            `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h04, 4'hF, ucor_status);
        end

        // Clear any remaining status bits
        `CFG_WR_BDF (ldut_bdf, cap_addr_aer + 'h04, 4'hf, ucor_bits);

        // Check Correctable Error Status
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h10, 4'hF, corr_status);

        if (exp_adv && ((corr_status & corr_bits) != adv_bit_mask)) begin
            $display  ("ERROR : Correctable Error Status == 0x%x; Expected == 0x%x == Advisory Non_Fatal_Error (time %t)", corr_status, adv_bit_mask, $time);
            `INC_ERRORS;
        end
        if (exp_adv & ((corr_status & corr_bits & ~adv_bit_mask) != 32'h0)) begin
            $display  ("ERROR : Correctable Error Status == 0x%x; Expected == 0x%x; Too many bits set (time %t)", corr_status, adv_bit_mask, $time);
            `INC_ERRORS;
        end
        if (~exp_adv & ((corr_status & corr_bits) != 32'h0)) begin
            $display  ("ERROR : Correctable Error Status == 0x%x; Expected == 0x%x (time %t)", corr_status, 32'h0, $time);
            `INC_ERRORS;
        end

        // Clear expected error in Correctable Error Status
        if (exp_adv & ((corr_status & corr_bits) == adv_bit_mask))
            `CFG_WR_BDF (ldut_bdf, cap_addr_aer + 'h10, 4'hf, adv_bit_mask);

        // Clear remaining Correctable Errors; expected errors should already have been cleared
        // Read Correctable Error Status
        //                 bdf,   addr,                be,      rd_data
        `CFG_RD_BDF  (ldut_bdf, cap_addr_aer + 'h10, 4'hF, corr_status);
        if ((corr_status & corr_bits) != 32'h0) begin
            $display  ("ERROR : Clearing unexpected correctable errors; Correct Error Status before clear == 0x%x (time %t)", corr_status, $time);
            `INC_ERRORS;
            `CFG_WR_BDF (ldut_bdf, cap_addr_aer + 'h10, 4'hf, corr_status);
        end
    end

    // Clear any pending satus & enable error reporting for UR, FAT, NFAT, & COR
    //                 bdf,   addr,                be,      rd_data
    `CFG_RD_BDF  (ldut_bdf, cap_addr_pcie + 'h8, 4'hF, read_data);
    read_data = read_data | 32'h000f000f;
    //                 bdf,   addr,      be,                data
    `CFG_WR_BDF (ldut_bdf, cap_addr_pcie + 'h8, 4'h4, read_data);
end

endtask

task clear_err_status;
    reg     [8:0]   f;
    reg     [15:0]  f_bdf;

    reg     [11:0]  pcie_cap_addr;
    reg     [11:0]  aer_cap_addr;

    reg     [31:0]  read_data;
    reg     [31:0]  ucor_status;
    reg     [31:0]  corr_status;
    reg     [31:0]  root_status;
    reg             aer_present;

    begin
        f = 0;
        f_bdf = dut_bdf;
        while ((dev_present[f_bdf[15:8]][f_bdf[7:3]][f_bdf[2:0]] == 1'b1) & (f<256)) begin     // Loop over all functions in device (up to 256)
            // Get capability addreses
            pcie_cap_addr = get_cap_pcie_addr(f_bdf);
            aer_cap_addr  = get_cap_aer_addr (f_bdf);
            // Clear error status
            aer_present = (aer_cap_addr != 12'h0);
            `CFG_RD_BDF (f_bdf, pcie_cap_addr + 'h08, 4'hf, read_data);
            if(read_data[31:16] & 32'hffcf) //Save some simulation time: only write if a RW1C bit is set.
            begin
                `CFG_WR_BDF (f_bdf, pcie_cap_addr + 'h08, 4'hc, read_data);
            end
            // Clear AER status
            if (aer_present) begin
                `CFG_RD_BDF (f_bdf, aer_cap_addr  + 'h04, 4'hf, ucor_status);
                `CFG_RD_BDF (f_bdf, aer_cap_addr  + 'h10, 4'hf, corr_status);
                `CFG_WR_BDF (f_bdf, aer_cap_addr  + 'h04, 4'hf, ucor_status);
                `CFG_WR_BDF (f_bdf, aer_cap_addr  + 'h10, 4'hf, corr_status);
            end

            f_bdf = f_bdf + 16'h1;
            f = f + 1;
        end
    end
endtask

task watch_error_msgs;
    input   [7:0]   func;
    input           exp_cor;
    input           exp_nfat;
    input           exp_fat;

    integer         ctr;
    integer         err_cor_ctr;
    integer         err_nfat_ctr;
    integer         err_fat_ctr;
    integer         err_func_num;

    begin
        err_cor_ctr  = 0;
        err_nfat_ctr = 0;
        err_fat_ctr  = 0;
        err_func_num = 0;
        for (ctr=0; ctr<500; ctr=ctr+1) begin
            @(posedge clk)
            if (watch_error_msgs_flag == 1)
                ctr = 0;
            if ((`BFM_MSG_EN == 1'b1) & (`BFM_MSG_DATA[6:0] == 7'h30) & (`BFM_MSG_DATA[63:56] == 8'h30)) // ERR_COR
                err_cor_ctr  = err_cor_ctr + 1;
            if ((`BFM_MSG_EN == 1'b1) & (`BFM_MSG_DATA[6:0] == 7'h30) & (`BFM_MSG_DATA[63:56] == 8'h31)) // ERR_NONFATAL
                err_nfat_ctr = err_nfat_ctr + 1;
            if ((`BFM_MSG_EN == 1'b1) & (`BFM_MSG_DATA[6:0] == 7'h30) & (`BFM_MSG_DATA[63:56] == 8'h33)) // ERR_FATAL
                err_fat_ctr  = err_fat_ctr + 1;
            if ((`BFM_MSG_EN == 1'b1) & (`BFM_MSG_DATA[6:0] == 7'h30) & (`BFM_MSG_DATA[47:40] != func))  // check function number
                err_func_num = 1;
        end
        // Check for excessive messages
        if (((err_cor_ctr > 0) & ~exp_cor) | (err_cor_ctr > 1)) begin
            $display  ("ERROR : Received %d ERR_COR messages; when %d expected (time %t)", err_cor_ctr, exp_cor ? 1'b1 :1'b0, $time);
            `INC_ERRORS;
        end
        if (((err_nfat_ctr > 0) & ~exp_nfat) | (err_nfat_ctr > 1)) begin
            $display  ("ERROR : Received %d ERR_NON_FATAL messages; when %d expected (time %t)", err_nfat_ctr, exp_nfat ? 1'b1 : 1'b0, $time);
            `INC_ERRORS;
        end
        if (((err_fat_ctr > 0) & ~exp_fat) | (err_fat_ctr > 1)) begin
            $display  ("ERROR : Received %d ERR_FATAL messages; when %d expected (time %t)", err_fat_ctr, exp_fat ? 1'b1 : 1'b0, $time);
            `INC_ERRORS;
        end
        if (err_func_num) begin
            $display  ("ERROR : Received error message; from unexpected function (time %t)", $time);
            `INC_ERRORS;
        end
    end
endtask


task quick_err_check;
    input   [7:0]   func;

    input           exp_corr;   // General errors
    input           exp_nfat;
    input           exp_fat;
    input           exp_ur;
    input   [31:0]  exp_corr_bits;
    input   [31:0]  exp_ucor_bits;
    input           exp_f_corr; // function specific errors
    input           exp_f_nfat;
    input           exp_f_fat;
    input           exp_f_ur;
    input   [31:0]  exp_f_corr_bits;
    input   [31:0]  exp_f_ucor_bits;

    input   [4:0]   error_bit;
    input   [127:0] error_header;
    input   [127:0] error_header_mask;

    reg     [15:0]  f_bdf;
    reg             virtual_function;
    reg             target_function;

    reg     [11:0]  pcie_cap_addr;
    reg     [11:0]  aer_cap_addr;

    reg     [31:0]  read_data;
    reg     [15:0]  dev_status;
    reg     [31:0]  ucor_status;
    reg     [31:0]  corr_status;
    reg             aer_present;

    reg             corr;
    reg             nfat;
    reg             fat;
    reg             ur;
    reg     [31:0]  u_bits;
    reg     [31:0]  c_bits;

    reg     [4:0]   first_error_pointer;
    reg     [127:0] hdr_log;

    integer         f;

    begin
        f = 0;
        f_bdf = dut_bdf;
        while ((dev_present[f_bdf[15:8]][f_bdf[7:3]][f_bdf[2:0]] == 1'b1) & (f<256)) begin     // Loop over all functions in device (up to 256)
            pcie_cap_addr    = get_cap_pcie_addr(f_bdf);
            aer_cap_addr     = get_cap_aer_addr (f_bdf);
            aer_present      = (aer_cap_addr != 12'h0);
            virtual_function = (dev_id_for_vf[f_bdf[15:8]][f_bdf[7:3]][f_bdf[2:0]] != 16'hffff);
            target_function  = (f_bdf == (dut_bdf + {8'h0, func}));

            `CFG_RD_BDF (f_bdf, pcie_cap_addr + 'h08, 4'hf, read_data);
            dev_status = read_data[31:16];

            // Select values to check against
            case ({target_function, virtual_function})
                2'b00 : begin corr = exp_corr;
                              nfat = exp_nfat;
                              fat = exp_fat;
                              ur = exp_ur;
                              u_bits = exp_ucor_bits;
                              c_bits = exp_corr_bits;
                        end  // physical, not target
                2'b01 : begin corr = 1'b0;
                              nfat = 1'b0;
                              fat = 1'b0;
                              ur = 1'b0;
                              u_bits = 32'h0;
                              c_bits = 32'h0;
                        end  // virtual, not target
                2'b10 : begin corr = exp_corr | exp_f_corr;
                              nfat = exp_nfat | exp_f_nfat;
                              fat = exp_fat | exp_f_fat;
                              ur = exp_ur | exp_f_ur;
                              u_bits = exp_ucor_bits | exp_f_ucor_bits;
                              c_bits = exp_corr_bits | exp_f_corr_bits;
                        end  // physical, target
                2'b11 : begin corr = exp_f_corr;
                              nfat = exp_f_nfat;
                              fat = exp_f_fat;
                              ur = exp_f_ur;
                              u_bits = exp_f_ucor_bits;
                              c_bits = exp_f_corr_bits;
                        end  // virtual, target
            endcase

            if (dev_status[0] != corr) begin
                $display ("%m : ERROR : Wrong Correctable_Error Status on func %d (time : %t)", f_bdf-dut_bdf, $time);
                `INC_ERRORS;
            end
            if (dev_status[1] != nfat) begin
                $display ("%m : ERROR : Wrong Non-Fatal_Error Status on func %d (time : %t)", f_bdf-dut_bdf, $time);
                `INC_ERRORS;
            end
            if (dev_status[2] != fat) begin
                $display ("%m : ERROR : Wrong Fatal_Error Status on func %d (time : %t)", f_bdf-dut_bdf, $time);
                `INC_ERRORS;
            end
            if (dev_status[3] != ur) begin
                $display ("%m : ERROR : Wrong Unsupported Request Detect Status on func %d (time : %t)", f_bdf-dut_bdf, $time);
                `INC_ERRORS;
            end
            `CFG_WR_BDF (f_bdf, pcie_cap_addr + 'h08, 4'hc, {dev_status, 16'h0});

            if (aer_present) begin
                `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h04, 4'hf, ucor_status);
                `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h10, 4'hf, corr_status);

                if (error_header_mask != 128'h0) begin
                    `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h18, 4'hf, read_data);
                    first_error_pointer = read_data[4:0];
                    `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h1c, 4'hf, hdr_log[ 31: 0]);
                    `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h20, 4'hf, hdr_log[ 63:32]);
                    `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h24, 4'hf, hdr_log[ 95:64]);
                    `CFG_RD_BDF (f_bdf, aer_cap_addr + 'h28, 4'hf, hdr_log[127:96]);

                    if (ucor_status != 32'h0) begin      // Check header and first values for Uncorrectable Errors
                        if (first_error_pointer == error_bit) begin
                            if ((error_header & error_header_mask) != (hdr_log & error_header_mask)) begin
                                $display  ("ERROR : Header Log does not match (time : %t)", $time);
                                `INC_ERRORS;
                            end
                        end
                        else if (error_bit != 5'h0) begin
                            $display  ("ERROR : First Error indicator does not match (time : %t)", $time);
                            `INC_ERRORS;
                        end
                    end
                    else if ((corr_status & c_bits) != 32'h0) begin  // Check header for Correctable Error (ANF unmasked)
                        if ((error_header & error_header_mask) != (hdr_log & error_header_mask)) begin
                            $display  ("ERROR : Header Log does not match (time : %t)", $time);
                            `INC_ERRORS;
                        end
                    end
                end

                if (ucor_status != u_bits) begin
                    $display ("%m : ERROR : Wrong AER Uncorrectable Error Status on func %d (time : %t)", f_bdf-dut_bdf, $time);
                    `INC_ERRORS;
                end
                if (corr_status != c_bits) begin
                    $display ("%m : ERROR : Wrong AER Correctable Error Status on func %d (time : %t)", f_bdf-dut_bdf, $time);
                    `INC_ERRORS;
                end

                `CFG_WR_BDF (f_bdf, aer_cap_addr  + 'h04, 4'hf, ucor_status);
                `CFG_WR_BDF (f_bdf, aer_cap_addr  + 'h10, 4'hf, corr_status);
            end

        f_bdf = f_bdf + 16'h1;  // Advance to next function
        f = f + 1;
        end
    end

endtask


//
// The following task and function definitions are used register accesses
//

//
// task to set the bus_opt value
//
task automatic set_bus_opt_value;
    input    [8*64:0]  reg_bus;
    output     [31:0]  bus_opt;

    begin
        if (reg_bus == "AXI")
        begin
            // $display  ("%m : Using AXI bus to access registers.");
            bus_opt = 0;
            // $display  ("%m :    Bus option value = 0x%08h.", bus_opt);
        end
        else if (reg_bus == "PCIe")
        begin
            // $display  ("%m : Using PCIe bus to access registers.");
            bus_opt[15:0]  = dut_bdf;
            // $display  ("%m :    Bus option value = 0x%08h.", bus_opt);
        end
        else
        begin
            $display  ("%m : ERROR : Detected bad input parameter.");
            `INC_ERRORS;
        end
    end


endtask



//
//  support functions
//


//
// function to randomly select a value within the specified inclusive range
//
function integer random_range;
    input         integer    min;
    input         integer    max;

    integer temp, delta;

    begin
        if (min < 0)
            min = 0;

        if (max < 0)
            max = 0;

        if (min > max)
        begin
            temp = min;
            min = max;
            max = temp;
        end

        if (min == max)
            random_range = min;
        else
            begin
               delta = max - min + 1;
               temp = $random(random_seed);
               if (temp < 0)
                  temp = - temp;
               random_range = min + (temp % delta);
            end
    end
endfunction


//
// function to randomly select a set bit for the input 64-bit reg and
// return its index value
//
function integer select_one_bit;
    input     [63:0]  select_value;

    integer           set_bit_cnt;
    integer           index;
    integer           picked_cnt;


    begin

        set_bit_cnt = 0;
        for (index = 0; index < 64 ; index = index + 1)
            if (select_value[index] == 1)
                set_bit_cnt = set_bit_cnt + 1;

        if (set_bit_cnt == 0)
            select_one_bit = -1;
        else
            begin
                picked_cnt = random_range(0, set_bit_cnt - 1);
                set_bit_cnt = 0;
                for ( index = 0 ; ((set_bit_cnt != picked_cnt) || (select_value[index] != 1)) ; index = index + 1)
                    if (select_value[index] == 1)
                        set_bit_cnt = set_bit_cnt + 1;
                select_one_bit = index;
            end
    end
endfunction



//
// function to randomly generate an endpoint request ID
//
// Bus number must not be zero.
//
function [15:0] random_endpoint_reqID;
    input         integer    foo_bar;

    reg   [7:0] bus_number;
    reg   [7:0] dev_func;


    begin
        // bus_number = random_range(1, 255);
        // dev_func  = $random(random_seed);

        // Using known good value during debug
        bus_number = 1;
        dev_func   = 0;
        random_endpoint_reqID =  {bus_number, dev_func};
    end

endfunction


//
// task to delay the specified number of clocks
//
task automatic clock_delay;
    input  integer clock_no;

    begin
       if (clock_no > 0)
           repeat (clock_no)
               @(posedge clk);
    end
endtask


//
// task to delay a random number of clocks within
// the specified range
//
task automatic random_delay;
    input integer min_value;
    input integer max_value;

    integer rand_delay;

    begin
        rand_delay = random_range(min_value, max_value);
        clock_delay(rand_delay);
    end
endtask



//
// task to delay a random number of clocks chosen from an
// exponential distribution of values with the given average value
//
task automatic expo_delay;
    input integer avg_value;

    integer rand_delay;

    begin
        if (avg_value === 32'hx)
            $stop;
        rand_delay = $dist_exponential(expo_random_seed, avg_value);
        clock_delay(rand_delay);
    end
endtask


//
// task to create and send the specified message
//
task  send_std_msg;
    input  integer  std_msg;
    input  [15:0]   reqID;

    reg          data_present;
    reg    [1:0] data_count;
    reg    [2:0] msg_routing;
    reg    [7:0] msg_code;
    reg    [7:0] info_index;
    reg    [7:0] data_index;
    reg   [63:0] msg_info;
    reg  [127:0] msg_data;

    reg  [`STD_MSG_SIZE - 1 : 0] msg_buffer;


    begin
        // $display ("%m : Message index = %2d.  Time is %0t ps.", std_msg, $time);
        if ((std_msg > `NO_OF_STD_MSGS) || (std_msg < 1))
        begin
            $display ("%m : ERROR : Index is out of range.");
            $stop;
        end
        else
        begin
            msg_buffer = msg_heap[std_msg];
            {data_present, data_count, msg_routing, msg_code, info_index, data_index} = msg_buffer;
            if ((info_index < 1) || (info_index >  `NO_OF_MSG_INFO) || (data_index < 1) || (data_index > `NO_OF_MSG_DATA))
            begin
                $display ("%m : ERROR : A sub-index is out of range.");
                $stop;
            end
            else
            begin
                msg_info = msg_info_heap[info_index];
                msg_data = msg_data_heap[data_index];
                // $display ("%m :     msg_code = 0x%2h.  msg_tag = %3d.  msg_routing = 0b%3b.  ", msg_code, std_msg, msg_routing);
                // $display ("%m :     msg_info = 0x%016h.", msg_info);
                // $display ("%m :     data_present = %1d.  data_count = %1d.", data_present, data_count);
                // $display ("%m :     msg_data = 0x%032h.", msg_data);
                `RP0_PATH.transmit_msg(0, data_present, data_count + 1, msg_routing, msg_code, std_msg, msg_info, msg_data);
                expo_delay(25);
            end
        end
    end

endtask



//
// function to determine is the specified message will be filtered
//
function is_message_filtered;
    input         integer    std_msg_index;
    input         integer    filter_option;

    reg          data_present;
    reg    [1:0] data_count;
    reg    [2:0] msg_routing;
    reg    [7:0] msg_code;
    reg    [7:0] info_index;
    reg    [7:0] data_index;
    reg   [63:0] msg_info;
    reg   [15:0] msg_vendor_id;
    reg  [`STD_MSG_SIZE - 1 : 0] msg_buffer;


    begin
        msg_buffer = msg_heap[std_msg_index];

        {data_present, data_count, msg_routing, msg_code, info_index, data_index} = msg_buffer;
        msg_info = msg_info_heap[info_index];
        msg_vendor_id = msg_info[47:32];


        case (filter_option)

            `NO_MSGS_FILTERED        :  is_message_filtered = 0;

            `MSGS_W_CODE_7_ONLY      :  if (msg_code[7:4] == 4'H7) is_message_filtered = 0;
                                        else                       is_message_filtered = 1;

            `MSGS_W_CODE_5_ONLY      :  if (msg_code[7:4] == 4'H5)  is_message_filtered = 0;
                                        else                        is_message_filtered = 1;

            `MSGS_W_CODE_3_ONLY      :  if (msg_code[7:4] == 4'H3)  is_message_filtered = 0;
                                        else                        is_message_filtered = 1;

            `MSGS_W_CODE_2_ONLY      :  if (msg_code[7:4] == 4'H2)  is_message_filtered = 0;
                                        else                        is_message_filtered = 1;

            `MSGS_W_CODE_1_ONLY      :  if (msg_code[7:4] == 4'H1)  is_message_filtered = 0;
                                        else                        is_message_filtered = 1;

            `MSGS_W_CODES_75321_ONLY :  if ((msg_code[7:4] == 4'H7) || (msg_code[7:4] == 4'H5) || (msg_code[7:4] == 4'H3) ||
                                            (msg_code[7:4] == 4'H2) || (msg_code[7:4] == 4'H1))
                                            is_message_filtered = 0;
                                        else
                                            is_message_filtered = 1;

            `MSGS_WO_CODE_7          :  if (msg_code[7:4] == 4'H7) is_message_filtered = 1;
                                        else                       is_message_filtered = 0;

            `MSGS_WO_CODE_5          :  if (msg_code[7:4] == 4'H5) is_message_filtered = 1;
                                        else                       is_message_filtered = 0;

            `MSGS_WO_CODE_3          :  if (msg_code[7:4] == 4'H3) is_message_filtered = 1;
                                        else                       is_message_filtered = 0;

            `MSGS_WO_CODE_2          :  if (msg_code[7:4] == 4'H2) is_message_filtered = 1;
                                        else                       is_message_filtered = 0;

            `MSGS_WO_CODE_1          :  if (msg_code[7:4] == 4'H1) is_message_filtered = 1;
                                        else                       is_message_filtered = 0;


            `MSGS_WO_CODES_75321     :  if ((msg_code[7:4] == 4'H7) || (msg_code[7:4] == 4'H5) || (msg_code[7:4] == 4'H3) ||
                                            (msg_code[7:4] == 4'H2) || (msg_code[7:4] == 4'H1))
                                            is_message_filtered = 1;
                                        else
                                            is_message_filtered = 0;

            `MSGS_W_CODE_7_W_ID      :  if ((msg_code[7:1] == 7'H3F) && (rsvd_vendor_id == msg_vendor_id))
                                            is_message_filtered = 0;
                                        else
                                            is_message_filtered = 1;

            `MSGS_W_CODE_7_WO_ID     :  if ((msg_code[7:1] == 7'H3F) && (rsvd_vendor_id != msg_vendor_id))
                                            is_message_filtered = 0;
                                        else
                                            is_message_filtered = 1;

            `ALL_MSGS_FILTERED       :  is_message_filtered = 1;

                             default :
                                        begin
                                            $display ("%m : ERROR : Specified filter scenario is not supported.");
                                            $stop;
                                        end

        endcase
    end
endfunction



//
// task to set the message filtering for the specified option
//

task  set_message_filtering;
    input  integer  filter_opt;

    begin

        case (filter_opt)

            `NO_MSGS_FILTERED        :  program_message_filtering( 1, 1, 1, 1, 1, 1, 0, 0, 0 );

            `MSGS_W_CODE_7_ONLY      :  program_message_filtering( 0, 0, 0, 0, 1, 0, 0, 0, 0 );

            `MSGS_W_CODE_5_ONLY      :  program_message_filtering( 0, 0, 0, 1, 0, 0, 0, 0, 0 );

            `MSGS_W_CODE_3_ONLY      :  program_message_filtering( 0, 0, 1, 0, 0, 0, 0, 0, 0 );

            `MSGS_W_CODE_2_ONLY      :  program_message_filtering( 0, 1, 0, 0, 0, 0, 0, 0, 0 );

            `MSGS_W_CODE_1_ONLY      :  program_message_filtering( 1, 0, 0, 0, 0, 0, 0, 0, 0 );

            `MSGS_W_CODES_75321_ONLY :  program_message_filtering( 1, 1, 1, 1, 1, 0, 0, 0, 0 );

            `MSGS_WO_CODE_7          :  program_message_filtering( 1, 1, 1, 1, 0, 1, 0, 0, 0 );

            `MSGS_WO_CODE_5          :  program_message_filtering( 1, 1, 1, 0, 1, 1, 0, 0, 0 );

            `MSGS_WO_CODE_3          :  program_message_filtering( 1, 1, 0, 1, 1, 1, 0, 0, 0 );

            `MSGS_WO_CODE_2          :  program_message_filtering( 1, 0, 1, 1, 1, 1, 0, 0, 0 );

            `MSGS_WO_CODE_1          :  program_message_filtering( 0, 1, 1, 1, 1, 1, 0, 0, 0 );

            `MSGS_WO_CODES_75321     :  program_message_filtering( 0, 0, 0, 0, 0, 1, 0, 0, 0 );

            `MSGS_W_CODE_7_W_ID      :  program_message_filtering( 0, 0, 0, 0, 0, 0, 1, 0, rsvd_vendor_id );

            `MSGS_W_CODE_7_WO_ID     :  program_message_filtering( 0, 0, 0, 0, 0, 0, 1, 1, rsvd_vendor_id );

            `ALL_MSGS_FILTERED       :  program_message_filtering( 0, 0, 0, 0, 0, 0, 0, 0, 0 );

            default :
                begin
                    $display ("%m : ERROR : Specified filter scenario is not supported.");
                    $stop;
                end

        endcase
    end

endtask


//
//  program filter - low level
//
task program_message_filtering;
    input          pm_msg_fwd;
    input          int_msg_fwd;
    input          err_msg_fwd;
    input          slt_msg_fwd;
    input          ven_msg_fwd;
    input          oth_msg_fwd;
    input          ven_id_msg_fwd;
    input          inv_ven_id_msg_fwd;
    input   [15:0] ven_id;

    reg [31:0] write_data;


    begin
    end

endtask


// Config space access using CSRs
//
// vend_cap_addr         = 'h150
// cfg_vend_wr_addr_ctrl = 'h150 + 'h14
// cfg_vend_wr_data      = 'h150 + 'h18
// cfg_vend_rd_addr_ctrl = 'h150 + 'h1c
// cfg_vend_rd_data      = 'h150 + 'h20
//
// mod_addr              = 4'h0;        // expresso CSR
//                       = 4'h1         // dma CSR
// grp_addr              = 4'h0;        // mgmt_cfg_constants
//                       = 4'h1         // mgmt_cfg_8g_constants
//                       = 4'h2         // mgmt_cfg_control
//                       = 4'h3         // mgmt_rp_status
//                       = 4'h4         // mgmt_cfg_status
//                       = 4'h5         // mgmt_cfg_estatus
//                       = 4'h6         // mgmt_pcie_status
//
// reg_addr              = mod32 + offset(msb:lsb)
//
// To access mgmt_cfg_constants[371]:
//   mod_addr = 0, grp_addr = 0, reg_addr = 11, msb = 19, lsb = 19

task csr_reg_rd;
   input  [15:0]   bdf;
   input   [3:0]   mod_addr;
   input   [3:0]   grp_addr;
   input   [5:0]   reg_addr;
   output [31:0]   read_data;


   reg    [11:0]   pcie_cap_addr;
   reg    [11:0]   vend_cap_addr;

   reg    [31:0]   read_data;
   reg    [15:0]   csr_addr;
   reg    [15:0]   csr_enable;
   reg    [15:0]   csr_done;

   begin

      // Look up DUT addresses
      pcie_cap_addr = get_cap_pcie_addr(bdf);
      vend_cap_addr = get_cap_ven_addr(bdf);

      // Read Config Space from CSRs
      csr_enable = 16'h4000;  // read/write enable bit
      csr_done   = 16'h8000;  // read/write done bit

      csr_addr   = {mod_addr, grp_addr, reg_addr};
      //$display ("%m:  csr_addr:%x", csr_addr);
      // Issue Read
      `CFG_WR_BDF(bdf, vend_cap_addr + 12'h01c, 4'hf, {csr_enable, csr_addr});
      // Check status
      `CFG_RD_BDF(bdf, vend_cap_addr + 12'h01c, 4'hf, read_data);
      while ((read_data[31:16] & csr_done) == 0)
        `CFG_RD_BDF(bdf, vend_cap_addr + 12'h01c, 4'hf, read_data);
      // Read Result
      `CFG_RD_BDF(bdf, vend_cap_addr + 12'h020, 4'hf, read_data);


   end
endtask

task csr_reg_wr;
   input  [15:0]   bdf;
   input   [3:0]   mod_addr;
   input   [3:0]   grp_addr;
   input   [5:0]   reg_addr;
   input   [5:0]   msb;
   input   [5:0]   lsb;
   input  [31:0]   write_data;


   reg    [11:0]   pcie_cap_addr;
   reg    [11:0]   vend_cap_addr;

   reg    [31:0]   read_data;
   reg    [31:0]   write_data_32;
   reg    [15:0]   csr_addr;
   reg    [15:0]   csr_enable;
   reg    [15:0]   csr_done;
   reg     [3:0]   byte_en;

   integer         i;

   begin
      if ((lsb > msb) ||
          (lsb) > 31 ||
          (msb) > 31)
        begin
           $display("%m: Illegal data bits specified: addr=0x%h, msb = %d, lsb = %d",reg_addr, msb,lsb);
           `INC_ERRORS;
        end

      // if write is not full bytes, then a read is needed
      if (((lsb % 8) !== 0) || ((msb % 8) !== 7))
        csr_reg_rd(bdf,mod_addr,grp_addr,reg_addr,read_data);
      else
        read_data = 0;

      byte_en       = 4'b0000;
      write_data_32 = read_data;
      // Assert only the necessary byte enables
      for (i=0;i<32;i=i+1)
        if ((i >= lsb) && (i <= msb))
          begin
             write_data_32[i] = write_data[i-lsb];
             byte_en[i/8]     = 1'b1;
          end


      // Look up DUT addresses
      pcie_cap_addr = get_cap_pcie_addr(bdf);
      vend_cap_addr = get_cap_ven_addr(bdf);

      // Write Config Space from CSRs
      csr_enable = 16'h4000;  // read/write enable bit
      csr_done   = 16'h8000;  // read/write done bit

      csr_addr   = {mod_addr, grp_addr, reg_addr};
      $display ("%m: vend_cap_addr:0x%x,  csr_addr:0x%x, byte_en:0b%b, write_data:0x%x", vend_cap_addr, csr_addr, byte_en, write_data_32);
      // Setup Data
      `CFG_WR_BDF(bdf, vend_cap_addr + 12'h018, byte_en, write_data_32);
      // Issue Write
      `CFG_WR_BDF(bdf, vend_cap_addr + 12'h014, 4'hf, {csr_enable | byte_en, csr_addr});
      // Check status
      `CFG_RD_BDF(bdf, vend_cap_addr + 12'h014, 4'hf, read_data);
      while ((read_data[31:16] & csr_done) == 0)
         `CFG_RD_BDF(bdf, vend_cap_addr + 12'h014, 4'hf, read_data);
   end
endtask



// --------------------------------------
// Test Case Execution Control Parameters

// Test cases begin with "RUN_"; parameters to modify test case behavior follow the related test case(s)
//   and are indented to indicate that they are modifying parameters rather than tests;
//   A test case is enabled/disabled by setting its "RUN_" parameter: (1) Execute; (0) Bypass
//   Test execution and modifying behavior parameters are inteneded to be over-ridden by simulation
//   scripts or on the command line to select test behavior rather than being set in this file

// PCI Express Tests





    // -------------------
    // RUN_REPORT_CFG_REGS

    // Tests config reads of first 128 32-bit PCIe Configuration Registers.

parameter RUN_REPORT_CFG_REGS = 0;

task report_cfg_regs;

        integer     i;
        reg [11:0]  addr;
        reg [31:0]  read_data;

begin
        $display  ("%m : ** Reporting Configuration Register Values at time %0t **", $time);

        // Read first 128 32-bit Configuration Space Regs
        for (i = 0 ; i < 128 ; i = i + 4)
        begin
            addr = i;
            `CFG_RD_BDF  (dut_bdf, addr, 4'hF, read_data);
        end

        // Separate Test Sequences
        repeat (100)
            @(posedge clk);

end // RUN_REPORT_CFG_REGS
endtask
    // ----------------------
    // RUN_BAR0_REGISTER_TEST

    // Test BAR0 Register and Scratchpad functionality in the DUT Reference Design

parameter RUN_BAR0_REGISTER_TEST = 0;

task bar0_register_test;

        integer     i;
        reg [63:0]  base_addr;
        reg [31:0]  read_data;
        reg [32767:0] payload;

begin
        if (bar_exists[0])
        begin
            $display  ("%m : ** BAR0 Register Test at time %0t **", $time);

            payload   = 'b0;
            base_addr = bar[0] + 64'h8000;

            $display  ("%m : Dump first 12 DWORDs of user Register Space");
            for (i=0; i<12; i=i+1)
            begin
                //`MEM_READ_DWORD (tc,     addr,            expect_data,  check_be, read_data);
                `MEM_READ_DWORD   (3'b000, base_addr+(i*4), 32'h00010000, 4'h0,     read_data);
            end

            $display  ("%m : Do same operation but use one burst read");
            //`MEM_READ_BURST   (tc,     addr,      length, check_data, first_dw_be, last_dw_be, payload
            `MEM_READ_BURST     (3'b000, base_addr, 12,     0,          4'hf,        4'hf,       payload);

            $display  ("%m : Test Reference Design : Register Example : Scratchpad Registers");
            base_addr = base_addr + 'h80;

            $display  ("%m : Single DWORD Writes");
            // `MEM_WRITE_DWORD (tc,     addr,        data,         be);
            `MEM_WRITE_DWORD    (3'b000, base_addr+'h0,  32'h00010000, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, base_addr+'h4,  32'h00030002, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, base_addr+'h8,  32'h00050004, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, base_addr+'hC,  32'h00070006, 4'hf);

            $display  ("%m : Single DWORD Reads");
            //`MEM_READ_DWORD   (tc,     addr,        expect_data,  check_be, read_data);
            `MEM_READ_DWORD     (3'b000, base_addr+'h0,  32'h00010000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, base_addr+'h4,  32'h00030002, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, base_addr+'h8,  32'h00050004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, base_addr+'hC,  32'h00070006, 4'hf,     read_data);

            $display  ("%m : 5 DWORD packet burst writes");
            // `MEM_WRITE_BURST_PATTERN (tc,     addr,            length,             first_dw_be, last_dw_be, start_data,   pattern);
            `MEM_WRITE_BURST_PATTERN    (3'b000, base_addr+'h000, 2,                  4'hf,        4'hf,       32'h00010000, PAT_INC_WORD);
            `MEM_WRITE_BURST_PATTERN    (3'b000, base_addr+'h008, 2,                  4'hf,        4'hf,       32'h00050004, PAT_INC_WORD);

            // Check data
            //`MEM_READ_BURST_PATTERN   (tc,     addr,            length, check_data, first_dw_be, last_dw_be, start_data,   pattern);
            `MEM_READ_BURST_PATTERN     (3'b000, base_addr+'h000, 4,      1'b1,       4'hf,        4'hf,       32'h00010000, PAT_INC_WORD);

            $display  ("%m : Burst DWORD Writes");
            // `MEM_WRITE_BURST_PATTERN (tc,     addr,            length,             first_dw_be, last_dw_be, start_data,   pattern);
            `MEM_WRITE_BURST_PATTERN    (3'b000, base_addr+'h000, 4,                 4'hf,        4'hf,       32'h40014000, PAT_INC_WORD);

            $display  ("%m : Burst DWORD Reads");
            //`MEM_READ_BURST_PATTERN   (tc,     addr,            length, check_data, first_dw_be, last_dw_be, start_data,   pattern);
            `MEM_READ_BURST_PATTERN     (3'b000, base_addr+'h000, 4,      1'b1,       4'hf,        4'hf,       32'h40014000, PAT_INC_WORD);

            $display  ("%m : Odd address alignment Burst DWORD Writes");
            // `MEM_WRITE_BURST_PATTERN (tc,     addr,            length,             first_dw_be, last_dw_be, start_data,   pattern);
            `MEM_WRITE_BURST_PATTERN    (3'b000, base_addr+'h004, 3,                  4'hf,        4'hf,       32'hC001C000, PAT_INC_WORD);

            $display  ("%m : Odd address alignment Burst DWORD Reads");
            //`MEM_READ_BURST_PATTERN   (tc,     addr,            length, check_data, first_dw_be, last_dw_be, start_data,   pattern);
            `MEM_READ_BURST_PATTERN     (3'b000, base_addr+'h004, 3,      1'b1,       4'hf,        4'hf,       32'hC001C000, PAT_INC_WORD);
        end
        else
        begin
            $display  ("%m : ** BAR0 Register Test - Skipped - No BAR to test - time %0t **", $time);
        end
end // RUN_BAR0_REGISTER_TEST
endtask


    // --------------------
    // RUN_BAR_MEMORY_TEST

    // Tests reads and writes to the BAR number specified by BAR_TO_TEST
    // Verifies uniqueness across all functions

parameter RUN_BAR_MEMORY_TEST = 1;

task bar_memory_test;

        integer         i;
        integer         func_limit;
        integer         f;
        reg     [63:0]  b_addr;
        reg     [63:0]  b_addr1;
        reg     [63:0]  b_addr2;
        reg     [63:0]  b_addr3;
        reg     [31:0]  read_data;
        reg     [32767:0]   payload;
        reg     [7:0]       tag1;
        reg     [7:0]       tag2;
        reg     [7:0]       tag3;

begin
        i = BAR_TO_TEST;

        func_limit = 256;

        for (f=0; f<func_limit; f=f+1)
        begin
            if (dev_present[dut_bdf[15:8]][f[7:3]][f[2:0]])
            begin
                if (bar_present[dut_bdf[15:8]][f[7:3]][f[2:0]][i])
                begin
                    b_addr = bar_addr[dut_bdf[15:8]][f[7:3]][f[2:0]][i];

                    $display  ("%m : ** Function %0d - BAR%1d Memory Test at time %0t **", f, i, $time);

                    $display  ("%m : Single DWORD Writes");
                    // `MEM_WRITE_DWORD (tc,     addr,        data,           be);
                    `MEM_WRITE_DWORD    (3'b000, b_addr+'h0,  32'h00010000+f, 4'hf);
                    `MEM_WRITE_DWORD    (3'b000, b_addr+'h4,  32'h00030002+f, 4'hf);
                    `MEM_WRITE_DWORD    (3'b000, b_addr+'h8,  32'h00050004+f, 4'hf);
                    `MEM_WRITE_DWORD    (3'b000, b_addr+'hC,  32'h00070006+f, 4'hf);

                    $display  ("%m : Single DWORD Reads");
                    //`MEM_READ_DWORD   (tc,     addr,        expect_data,    check_be, read_data);
                    `MEM_READ_DWORD     (3'b000, b_addr+'h0,  32'h00010000+f, 4'hf,     read_data);
                    `MEM_READ_DWORD     (3'b000, b_addr+'h4,  32'h00030002+f, 4'hf,     read_data);
                    `MEM_READ_DWORD     (3'b000, b_addr+'h8,  32'h00050004+f, 4'hf,     read_data);
                    `MEM_READ_DWORD     (3'b000, b_addr+'hC,  32'h00070006+f, 4'hf,     read_data);

                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);

                    $display  ("%m : 5 DWORD packet burst writes");
                    // `MEM_WRITE_BURST_PATTERN (tc,     addr,         length,             first_dw_be, last_dw_be, start_data,   pattern);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h000, 2,                  4'hf,        4'hf,       32'h00010000, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h008, 2,                  4'hf,        4'hf,       32'h00050004, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h010, 2,                  4'hf,        4'hf,       32'h00090008, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h018, 2,                  4'hf,        4'hf,       32'h000D000C, PAT_INC_WORD);

                    // Check data
                    //`MEM_READ_BURST_PATTERN   (tc,     addr,         length, check_data, first_dw_be, last_dw_be, start_data,   pattern);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h000, 8,      1'b1,       4'hf,        4'hf,       32'h00010000, PAT_INC_WORD);

                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);

                    $display  ("%m : Burst DWORD Writes");
                    // `MEM_WRITE_BURST_PATTERN (tc,     addr,         length,             first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h000, 32,                 4'hf,        4'hf,       32'h40014000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h080, 32,                 4'hf,        4'hf,       32'h50015000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h100, 32,                 4'hf,        4'hf,       32'h60016000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h180, 32,                 4'hf,        4'hf,       32'h70017000+f, PAT_INC_WORD);

                    $display  ("%m : Burst DWORD Reads");
                    //`MEM_READ_BURST_PATTERN   (tc,     addr,         length, check_data, first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h000, 32,     1,          4'hf,        4'hf,       32'h40014000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h080, 32,     1,          4'hf,        4'hf,       32'h50015000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h100, 32,     1,          4'hf,        4'hf,       32'h60016000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h180, 32,     1,          4'hf,        4'hf,       32'h70017000+f, PAT_INC_WORD);

                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);

                    $display  ("%m : Odd address alignment Burst DWORD Writes");
                    // `MEM_WRITE_BURST_PATTERN (tc,     addr,         length,             first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h004, 32,                 4'hf,        4'hf,       32'hC001C000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h088, 32,                 4'hf,        4'hf,       32'hD001D000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'b000, b_addr+'h10c, 32,                 4'hf,        4'hf,       32'hE001E000+f, PAT_INC_WORD);

                    $display  ("%m : Odd address alignment Burst DWORD Reads");
                    //`MEM_READ_BURST_PATTERN   (tc,     addr,         length, check_data, first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h004, 32,     1,          4'hf,        4'hf,       32'hC001C000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h088, 32,     1,          4'hf,        4'hf,       32'hD001D000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'b000, b_addr+'h10c, 32,     1,          4'hf,        4'hf,       32'hE001E000+f, PAT_INC_WORD);
                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);
                end
                else
                begin
                    $display  ("%m : ** Function %0d - BAR%1d Memory Test - Skipped - No BAR to test - time %0t **", f, i, $time);
                end
            end
        end
end // BAR Memory Test
endtask


    // --------------------
    // RUN_BAR_MEMORY_TEST

    // Tests reads and writes to the BAR number specified by BAR_TO_TEST
    // Verifies uniqueness across all functions

parameter RUN_BAR_MEMORY_TEST_TC = 0;

task bar_memory_test_tc;

        integer         i;
        integer         func_limit;
        integer         f;
        reg     [63:0]  b_addr;
        reg     [63:0]  b_addr1;
        reg     [63:0]  b_addr2;
        reg     [63:0]  b_addr3;
        reg     [31:0]  read_data;
        reg     [32767:0]   payload;
        reg     [7:0]       tag1;
        reg     [7:0]       tag2;
        reg     [7:0]       tag3;

begin
        i = BAR_TO_TEST;

        func_limit = 256;

        for (f=0; f<func_limit; f=f+1)
        begin
            if (dev_present[dut_bdf[15:8]][f[7:3]][f[2:0]])
            begin
                if (bar_present[dut_bdf[15:8]][f[7:3]][f[2:0]][i])
                begin
                    b_addr = bar_addr[dut_bdf[15:8]][f[7:3]][f[2:0]][i];

                    $display  ("%m : ** Function %0d - BAR%1d Memory Test using Different Traffic Classes at time %0t **", f, i, $time);

                    $display  ("%m : Single DWORD Writes");
                    // `MEM_WRITE_DWORD (tc,   addr,        data,           be);
                    `MEM_WRITE_DWORD    (3'd0, b_addr+'h0,  32'h00010000+f, 4'hf);
                    `MEM_WRITE_DWORD    (3'd3, b_addr+'h4,  32'h00030002+f, 4'hf);
                    `MEM_WRITE_DWORD    (3'd4, b_addr+'h8,  32'h00050004+f, 4'hf);
                    `MEM_WRITE_DWORD    (3'd7, b_addr+'hC,  32'h00070006+f, 4'hf);

                    $display  ("%m : Single DWORD Reads");
                    //`MEM_READ_DWORD   (tc,   addr,        expect_data,    check_be, read_data);
                    `MEM_READ_DWORD     (3'd1, b_addr+'h0,  32'h00010000+f, 4'hf,     read_data);
                    `MEM_READ_DWORD     (3'd2, b_addr+'h4,  32'h00030002+f, 4'hf,     read_data);
                    `MEM_READ_DWORD     (3'd5, b_addr+'h8,  32'h00050004+f, 4'hf,     read_data);
                    `MEM_READ_DWORD     (3'd6, b_addr+'hC,  32'h00070006+f, 4'hf,     read_data);

                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);

                    $display  ("%m : 5 DWORD packet burst writes");
                    // `MEM_WRITE_BURST_PATTERN (tc,   addr,         length,             first_dw_be, last_dw_be, start_data,   pattern);
                    `MEM_WRITE_BURST_PATTERN    (3'd0, b_addr+'h000, 2,                  4'hf,        4'hf,       32'h00010000, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd1, b_addr+'h008, 2,                  4'hf,        4'hf,       32'h00050004, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd2, b_addr+'h010, 2,                  4'hf,        4'hf,       32'h00090008, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd3, b_addr+'h018, 2,                  4'hf,        4'hf,       32'h000D000C, PAT_INC_WORD);

                    // Check data
                    //`MEM_READ_BURST_PATTERN   (tc,   addr,         length, check_data, first_dw_be, last_dw_be, start_data,   pattern);
                    `MEM_READ_BURST_PATTERN     (3'd6, b_addr+'h000, 8,      1'b1,       4'hf,        4'hf,       32'h00010000, PAT_INC_WORD);

                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);

                    $display  ("%m : Burst DWORD Writes");
                    // `MEM_WRITE_BURST_PATTERN (tc,   addr,         length,             first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_WRITE_BURST_PATTERN    (3'd4, b_addr+'h000, 32,                 4'hf,        4'hf,       32'h40014000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd5, b_addr+'h080, 32,                 4'hf,        4'hf,       32'h50015000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd6, b_addr+'h100, 32,                 4'hf,        4'hf,       32'h60016000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd7, b_addr+'h180, 32,                 4'hf,        4'hf,       32'h70017000+f, PAT_INC_WORD);

                    $display  ("%m : Burst DWORD Reads");
                    //`MEM_READ_BURST_PATTERN   (tc,   addr,         length, check_data, first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_READ_BURST_PATTERN     (3'd7, b_addr+'h000, 32,     1,          4'hf,        4'hf,       32'h40014000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'd6, b_addr+'h080, 32,     1,          4'hf,        4'hf,       32'h50015000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'd5, b_addr+'h100, 32,     1,          4'hf,        4'hf,       32'h60016000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'd4, b_addr+'h180, 32,     1,          4'hf,        4'hf,       32'h70017000+f, PAT_INC_WORD);

                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);

                    $display  ("%m : Odd address alignment Burst DWORD Writes");
                    // `MEM_WRITE_BURST_PATTERN (tc,   addr,         length,             first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_WRITE_BURST_PATTERN    (3'd4, b_addr+'h004, 32,                 4'hf,        4'hf,       32'hC001C000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd0, b_addr+'h088, 32,                 4'hf,        4'hf,       32'hD001D000+f, PAT_INC_WORD);
                    `MEM_WRITE_BURST_PATTERN    (3'd1, b_addr+'h10c, 32,                 4'hf,        4'hf,       32'hE001E000+f, PAT_INC_WORD);

                    $display  ("%m : Odd address alignment Burst DWORD Reads");
                    //`MEM_READ_BURST_PATTERN   (tc,   addr,         length, check_data, first_dw_be, last_dw_be, start_data,     pattern);
                    `MEM_READ_BURST_PATTERN     (3'd1, b_addr+'h004, 32,     1,          4'hf,        4'hf,       32'hC001C000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'd5, b_addr+'h088, 32,     1,          4'hf,        4'hf,       32'hD001D000+f, PAT_INC_WORD);
                    `MEM_READ_BURST_PATTERN     (3'd2, b_addr+'h10c, 32,     1,          4'hf,        4'hf,       32'hE001E000+f, PAT_INC_WORD);
                    // Separate Test Sequences
                    repeat (100)
                        @(posedge clk);
                end
                else
                begin
                    $display  ("%m : ** Function %0d - BAR%1d Memory Test - Skipped - No BAR to test - time %0t **", f, i, $time);
                end
            end
        end
end // BAR Memory Test
endtask



    // ------------------------
    // RUN_STANDARD_TARGET_TEST

    // Basic test of target accesses on DUT, various burst lengths

parameter RUN_STANDARD_TARGET_TEST = 0;

task standard_target_test;

        reg  [31:0]      read_data;
        reg  [32767:0]   payload;
        reg  [32767:0]   init_payload;
        integer          i,j,k;

        //Initialize pattern
begin
        payload          = 0;
        payload[ 31:  0] = 32'h00010000;
        payload[ 63: 32] = 32'h00030002;
        payload[ 95: 64] = 32'h00050004;
        payload[127: 96] = 32'h00070006;
        payload[159:128] = 32'h10011000;
        payload[191:160] = 32'h10031002;
        payload[223:192] = 32'h10051004;
        payload[255:224] = 32'h10071006;
        payload[287:256] = 32'h20012000;
        payload[319:288] = 32'h20032002;
        payload[351:320] = 32'h20052004;
        payload[383:352] = 32'h20072006;
        payload[415:384] = 32'h30013000;
        payload[447:416] = 32'h30033002;
        payload[479:448] = 32'h30053004;
        payload[511:480] = 32'h30073006;

        init_payload[511:0] = 512'h0;

        i = BAR_TO_TEST;

        if (bar_exists[i])
        begin
            $display  ("%m : ** Standard Target Write Read Tests at time %0t **", $time);

            $display  ("%m : ** Alternate DWORD write read Test **");
            //DWORD writes filling target byte with pattern
            for (j = 0 ; j < 4 ; j = j + 1)
            begin
                $display  ("%m : Single DWORD Write");
                // `MEM_WRITE_DWORD (tc,     addr,            data,         be);
                `MEM_WRITE_DWORD    (3'b000, bar[i]+'h0+j*8,  32'h00010000, 4'hf);
                $display  ("%m : Single DWORD Read");
                //`MEM_READ_DWORD   (tc,     addr,            expect_data,  check_be, read_data);
                `MEM_READ_DWORD     (3'b000, bar[i]+'h0+j*8,  32'h00010000, 4'hf,     read_data);
             end

            for (j = 0 ; j < 4 ; j = j + 1)
            begin
                $display  ("%m : Single DWORD Write");
                `MEM_WRITE_DWORD     (3'b000, bar[i]+'h20+j*8,  32'h00050004, 4'hf);
                $display  ("%m : Single DWORD Fast Read");
                `MEM_READ_DWORD_FAST (3'b000, bar[i]+'h20+j*8,  32'h00050004, 4'hf);
            end

            // Dummy Read to allow the last step to finish
            `MEM_READ_DWORD (3'b000, bar[i]+'h20, 32'h00050004, 4'hf, read_data);

            $display  ("%m : ** Write DWORDS, Read BURST Test **");
            $display  ("%m : Single DWORD Writes");
            // `MEM_WRITE_DWORD (tc,     addr,         data,         be);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h0,   32'h00010000, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h4,   32'h00030002, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h8,   32'h00050004, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'hC,   32'h00070006, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h10,  32'h10011000, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h14,  32'h10031002, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h18,  32'h10051004, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h1C,  32'h10071006, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h20,  32'h20012000, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h24,  32'h20032002, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h28,  32'h20052004, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h2C,  32'h20072006, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h30,  32'h30013000, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h34,  32'h30033002, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h38,  32'h30053004, 4'hf);
            `MEM_WRITE_DWORD    (3'b000, bar[i]+'h3C,  32'h30073006, 4'hf);
            //Read back with different burst sizes
            $display  ("%m : BURSTS Reads of different sizes");
            //`MEM_READ_BURST   (tc,     addr,         length, check_data, first_dw_be, last_dw_be, payload
            `MEM_READ_BURST     (3'b000, bar[i]+'h000, 2,      1'b1,       4'hf,        4'hf,       payload[63:0]);
            `MEM_READ_BURST     (3'b000, bar[i]+'h008, 4,      1'b1,       4'hf,        4'hf,       payload[191:64]);
            `MEM_READ_BURST     (3'b000, bar[i]+'h018, 8,      1'b1,       4'hf,        4'hf,       payload[447:192]);
            `MEM_READ_BURST     (3'b000, bar[i]+'h000, 16,     1'b1,       4'hf,        4'hf,       payload);

            // Separate Test Sequences
            repeat (1000)
                @(posedge clk);


            $display  ("%m : ** Write BURSTS, Read DWORDS Test **");
            // Write Bursts of different sizes
            // `MEM_WRITE_BURST (tc,     addr,         length, first_dw_be, last_dw_be, payload
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h000, 2,      4'hf,        4'hf,       payload[63:0]);
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h008, 4,      4'hf,        4'hf,       payload[191:64]);
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h018, 8,      4'hf,        4'hf,       payload[447:192]);
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h040, 16,     4'hf,        4'hf,       payload);

            //Read back with DWORD reads
            //`MEM_READ_DWORD   (tc,     addr,        expect_data,  check_be, read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h000,  32'h00010000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h004,  32'h00030002, 4'hf,     read_data);

            `MEM_READ_DWORD     (3'b000, bar[i]+'h008,  32'h00050004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h00C,  32'h00070006, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h010,  32'h10011000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h014,  32'h10031002, 4'hf,     read_data);

            `MEM_READ_DWORD     (3'b000, bar[i]+'h018,  32'h10051004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h01C,  32'h10071006, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h020,  32'h20012000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h024,  32'h20032002, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h028,  32'h20052004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h02C,  32'h20072006, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h030,  32'h30013000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h034,  32'h30033002, 4'hf,     read_data);

            `MEM_READ_DWORD     (3'b000, bar[i]+'h040,  32'h00010000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h044,  32'h00030002, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h048,  32'h00050004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h04C,  32'h00070006, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h050,  32'h10011000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h054,  32'h10031002, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h058,  32'h10051004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h05C,  32'h10071006, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h060,  32'h20012000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h064,  32'h20032002, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h068,  32'h20052004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h06C,  32'h20072006, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h070,  32'h30013000, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h074,  32'h30033002, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h078,  32'h30053004, 4'hf,     read_data);
            `MEM_READ_DWORD     (3'b000, bar[i]+'h07C,  32'h30073006, 4'hf,     read_data);

            // Separate Test Sequences
            repeat (100)
                @(posedge clk);


            $display  ("%m : ** Write Read BURSTS of varying sizes Test **");
            // Write Bursts of different sizes
            // `MEM_WRITE_BURST (tc,     addr,         length, first_dw_be, last_dw_be, payload
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h000, 2,      4'hf,        4'hf,       payload[63:0]);
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h008, 4,      4'hf,        4'hf,       payload[191:64]);
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h018, 8,      4'hf,        4'hf,       payload[447:192]);
            `MEM_WRITE_BURST    (3'b000, bar[i]+'h040, 16,     4'hf,        4'hf,       payload);

            //`MEM_READ_BURST   (tc,     addr,         length, check_data, first_dw_be, last_dw_be, payload
            `MEM_READ_BURST     (3'b000, bar[i]+'h000, 2,      1'b1,       4'hf,        4'hf,       payload[63:0]);
            `MEM_READ_BURST     (3'b000, bar[i]+'h008, 4,      1'b1,       4'hf,        4'hf,       payload[191:64]);
            `MEM_READ_BURST     (3'b000, bar[i]+'h018, 8,      1'b1,       4'hf,        4'hf,       payload[447:192]);
            `MEM_READ_BURST     (3'b000, bar[i]+'h040, 16,     1'b1,       4'hf,        4'hf,       payload);

            // Separate Test Sequences
            repeat (100)
                @(posedge clk);
        end
        else
        begin
            $display  ("%m : ** Standard Target Write Read Tests - Skipped - No BAR to test - time %0t **", $time);
        end
end // Standard Target Test
endtask



    // ------------
    // RUN_DWORD_BE

    //   Test of DWORD transactions with disabled bytes
    //   1) Initialize target with pattern of target bytes at zero (44332200, 44330011, 44002211, 00332211)
    //   2) DWORD Write target with pattern filling target byte with pattern using byte enables (00000011, 00002200, 00330000, 44000000)
    //   3) DWORD Read verifying DWORDS
parameter RUN_DWORD_BE = 0;

task dword_be;

        integer             i,j,k;
        reg     [31:0]      read_data;
        reg     [32767:0]   payload;

begin
        k = BAR_TO_TEST;

        if (bar_exists[k])
        begin
            $display  ("%m : ** Dword Byte Enable Test at time %0t **", $time);

            //Initialize pattern
            payload          = 0;
            payload[ 31:  0] = 32'h44332200;
            payload[ 63: 32] = 32'h44330011;
            payload[ 95: 64] = 32'h44002211;
            payload[127: 96] = 32'h00332211;
            // `MEM_WRITE_BURST (tc,     addr,         length, first_dw_be, last_dw_be, payload
            `MEM_WRITE_BURST    (3'b000, bar[k]+'h000, 4,      4'hf,        4'hf,       payload);

            //DWORD writes filling target byte with pattern
            for (i = 0 ; i < 4 ; i = i + 1)
            begin
                j = i + 1;
                `MEM_WRITE_DWORD (3'b000, bar[k]+i*4, {j[3:0],j[3:0]} << (i*8), 1 << i);
            end

            //Read back
            for (i = 0 ; i < 4 ; i = i + 1)
            begin
                //`MEM_READ_DWORD   (tc,     addr,        expect_data,  check_be, read_data);
                `MEM_READ_DWORD     (3'b000, bar[k]+i*4,  32'h44332211, 4'hf,     read_data);
            end

            // Separate Test Sequences
            repeat (100)
                @(posedge clk);
        end
        else
        begin
            $display  ("%m : ** Dword Byte Enable Test - Skipped - No BAR to test - time %0t **", $time);
        end
end //RUN_DWORD_BE
endtask



    // ------------
    // RUN_BURST_BE

    //   Test of BURST transactions with disabled bytes at beginning and end of a burst
    //   1) Initialize target with pattern of target bytes at zero for first DWORD of bursts (44332200, 44330011, 44002211, 00332211)
    //   2) Burst write target with pattern filling target byte with pattern using byte enables (00000011, 00002200, 00330000, 44000000)
    //   3) Burst read verifying expected pattern
    //   4) Repeat steps 2 and 3 at last DWORD of burst
parameter RUN_BURST_BE = 0;

task burst_be;

        integer             i,j,k;
        reg     [31:0]      read_data;
        reg     [32767:0]   payload;

begin
        k = BAR_TO_TEST;

        if (bar_exists[k])
        begin
            $display  ("%m : ** Burst Byte Enable Test at time %0t **", $time);

            //Initialize pattern
            payload          = 0;
            payload[ 31:  0] = 32'h44332200;
            payload[ 63: 32] = 32'haaaaaaaa;
            payload[ 95: 64] = 32'haaaaaaaa;
            payload[127: 96] = 32'haaaaaaaa;
            payload[159:128] = 32'h44330011;
            payload[191:160] = 32'haaaaaaaa;
            payload[223:192] = 32'haaaaaaaa;
            payload[255:224] = 32'haaaaaaaa;
            payload[287:256] = 32'h44002211;
            payload[319:288] = 32'haaaaaaaa;
            payload[351:320] = 32'haaaaaaaa;
            payload[383:352] = 32'haaaaaaaa;
            payload[415:384] = 32'h00332211;
            payload[447:416] = 32'haaaaaaaa;
            payload[479:448] = 32'haaaaaaaa;
            payload[511:480] = 32'haaaaaaaa;
            // `MEM_WRITE_BURST (tc,     addr,         length, first_dw_be, last_dw_be, payload
            `MEM_WRITE_BURST    (3'b000, bar[k]+'h000, 16,     4'hf,        4'hf,       payload);

            //Burst writes filling target byte in first dword with pattern
            for (i = 0 ; i < 4 ; i = i + 1)
            begin
                j = i + 1;
                payload          = 0;
                payload[ 31:  0] = {j[3:0],j[3:0]} << (i*8);
                payload[ 63: 32] = 32'h55555555;
                payload[ 95: 64] = 32'h55555555;
                payload[127: 96] = 32'h55555555;
                // `MEM_WRITE_BURST (tc,     addr,         length, first_dw_be, last_dw_be, payload
                `MEM_WRITE_BURST    (3'b000, bar[k]+i*16,  4,      'hf << i,    4'hf,       payload);
            end

           // Insert a slow "READ" delay
           `MEM_READ_DWORD     (3'b000, bar[k]+i*4,  32'h44332211, 4'h0,     read_data);

            //Read back
            payload          = 0;
            payload[ 31:  0] = 32'h00000011;
            payload[ 63: 32] = 32'h55555555;
            payload[ 95: 64] = 32'h55555555;
            payload[127: 96] = 32'h55555555;
            payload[159:128] = 32'h00002211;
            payload[191:160] = 32'h55555555;
            payload[223:192] = 32'h55555555;
            payload[255:224] = 32'h55555555;
            payload[287:256] = 32'h00332211;
            payload[319:288] = 32'h55555555;
            payload[351:320] = 32'h55555555;
            payload[383:352] = 32'h55555555;
            payload[415:384] = 32'h44332211;
            payload[447:416] = 32'h55555555;
            payload[479:448] = 32'h55555555;
            payload[511:480] = 32'h55555555;
            //`MEM_READ_BURST   (tc,     addr,         length, check_data, first_dw_be, last_dw_be, payload
            `MEM_READ_BURST     (3'b000, bar[k]+'h000, 16,     1'b1,       4'hf,        4'hf,       payload);

            // Separate Test Sequences
            repeat (100)
                @(posedge clk);
        end
        else
        begin
            $display  ("%m : ** Burst Byte Enable Test - Skipped - No BAR to test - time %0t **", $time);
        end
end //RUN_BURST_BE
endtask


    // ---------------------
    // RUN_EXP_ROM_READ_TEST

    // Data Initialized in BAR1
    // Expansion ROM Read Test 1024 back-to-back DWORD Memory Reads
    // Assumes Expansion ROM is mapped to BAR1 space for testing

parameter RUN_EXP_ROM_READ_TEST = 0;

task exp_rom_read_test;

    reg [31:0]  write_data;
    reg [31:0]  read_data;
    integer     i;
    reg [31:0]  r;

begin
        if (exp_bar == 0)
            $display  ("%m : ** Expansion ROM Read Test - Skipping - No Expansion ROM BAR **");
        else
        begin
            $display  ("%m : ** Expansion ROM Read Test at time %0t **", $time);

            // Enable expansion rom decoder
            `CFG_WR_BDF(`DUT_ID, 12'h030, 4'h1, 32'h1);

            for (i=0; i<1024; i=i+1)
            begin : wr_loop
                write_data = 17*(i+1);
                `MEM_WRITE_DWORD  (3'b000, bar[1] + (i*4), write_data, 4'hf);
            end

            for (i=0; i<1024; i=i+1)
            begin : rd_loop
                write_data = 17*(i+1);
                `MEM_READ_DWORD_FAST (3'b000, exp_bar+(i*4), write_data, 1'b1);
            end

            @(posedge clk);
        end
end // RUN_EXP_ROM_READ_TEST
endtask



    // -----------------------
    // RUN_USER_INTERRUPT_TEST

    // Test the optional user interrupt in the DMA Back End

parameter RUN_USER_INTERRUPT_TEST = 0;

task user_interrupt_test;

        reg     [31:0]  timeout_clks;
        reg     [10:0]  user_vec;
        integer         i;
        reg             user_int_enable;
        reg             dma_int_enable;
        reg     [31:0]  rd_data;
        reg     [31:0]  sv_data;
        reg     [31:0]  wr_data;
        reg             int_status;

begin
        timeout_clks = 32'd700;     // Clocks to wait for interrupts before assuming they won't happen
        user_vec     = g3_int_vec;  // User Interrupt is the next vector after the DMA engines
        int_status   = 1'b0;

        if (int_mode == INT_MODE_DISABLED)
        begin
            $display  ("%m : ** USER INTERRUPT TEST FOR DMA BACK-END - Skipped - Function not enabled to generate interrupts **");
        end
        else
        begin
            $display  ("%m : ** USER INTERRUPT TEST FOR DMA BACK-END at time %0t **", $time);

            if (debug) $display  ("%m : Debug : Save original value for Interrupt Enable register");
            `MEM_READ_DWORD  (3'b000, g3_com_bar, 32'h0, 32'h0, rd_data);
            sv_data = rd_data;

            if (debug) $display  ("%m : Debug : UserIntEn masks user interrupts; when masked user interrupts should be pended and then asserted once unmasked");
            if (debug) $display  ("%m : Debug : DMAIntEn should have no affect on user_interrupt");

            // Do loop several times testing different conditions:
            for (i=0; i<4; i=i+1)
            begin
                if      (i == 0)
                begin
                    user_int_enable = 1'b0;
                    dma_int_enable  = 1'b0;
                end
                else if (i == 1)
                begin
                    user_int_enable = 1'b0;
                    dma_int_enable  = 1'b1;
                end
                else if (i == 2)
                begin
                    user_int_enable = 1'b1;
                    dma_int_enable  = 1'b0;
                end
                else
                begin
                    user_int_enable = 1'b1;
                    dma_int_enable  = 1'b1;
                end

                $display  ("%m : Iteration[%d], UserIntEn=%d, DMAIntEn=%d", i[2:0], user_int_enable, dma_int_enable);

                if (debug) $display  ("%m : Debug : Clear interrupt status and set/clear interrupt enable as directed");
                wr_data[31:0] = 32'h0;           // Don't set other bits
                wr_data[   5] = 1'b1;            // Clear interrupt status
                wr_data[   4] = user_int_enable; // Set/clear interrupt enable as directed
                wr_data[   0] = dma_int_enable;  // Set/clear interrupt enable as directed
                `MEM_WRITE_DWORD (3'b000, g3_com_bar, wr_data, 4'hf);

                `MEM_READ_DWORD  (3'b000, g3_com_bar, 32'h0, 32'h0, rd_data);
                if (rd_data[5] != 1'b0)
                begin
                    $display  ("%m : ERROR :User interrupt status bit is incorrectly set in the Common DMA register (time %t)", $time);
                    `INC_ERRORS;
                end

                fork
                begin : wait_for_int
                    //        bdf,     vector,   timeout_clks, int_status
                    wait_int (dut_bdf, user_vec, timeout_clks, int_status);
                end
                begin : generate_int
                    if (debug) $display  ("%m : Debug : Force a User Interrupt to be generated");
                    @(posedge `DUT_CLK);
                    `DUT_PATH.user_interrupt = 1'b1;
                    @(posedge `DUT_CLK);
                    `DUT_PATH.user_interrupt = 1'b0;
                end
                join

                if (user_int_enable) // Expecting interrupt
                begin
                    if (int_status == 1'b1)
                    begin
                        $display  ("%m : User Interrupt received as expected");
                    end
                    else
                    begin
                        $display  ("%m : ERROR : User Interrupt was not asserted as expected (time %t)", $time);
                        `INC_ERRORS;
                    end
                end
                else                 // Not expecting interrupt
                begin
                    if (int_status == 1'b1)
                    begin
                        $display  ("%m : ERROR : User Interrupt was asserted when it should have been masked (time %t)", $time);
                        `INC_ERRORS;
                    end
                    else
                    begin
                        $display  ("%m : User Interrupt masked as expected");
                    end
                end

                if (debug) $display  ("%m : Debug : Verify user interrupt status bit is asserted in Common DMA register");
                `MEM_READ_DWORD  (3'b000, g3_com_bar, 32'h0, 32'h0, rd_data);
                if (rd_data[5] != 1'b1)
                begin
                    $display  ("%m : ERROR : User Interrupt status bit not set in common DMA register (time %t)", $time);
                    `INC_ERRORS;
                end

                if (user_int_enable) // Expecting interrupt
                begin
                    if (debug) $display  ("%m : Debug : Clear interrupt status and leave interrupt enables same as directed at start of iteration");
                    wr_data[31:0] = 32'h0;           // Don't set other bits
                    wr_data[   5] = 1'b1;            // Clear interrupt status
                    wr_data[   4] = user_int_enable; // Set/clear interrupt enable as directed
                    wr_data[   0] = dma_int_enable; // Set/clear interrupt enable as directed
                    `MEM_WRITE_DWORD (3'b000, g3_com_bar, wr_data, 4'hf);

                    if (debug) $display  ("%m : Debug : Verify user interrupt status bit is cleared in DMA register");
                    `MEM_READ_DWORD  (3'b000, g3_com_bar, 32'h0, 32'h0, rd_data);
                    if (rd_data[5] != 1'b0)
                    begin
                        $display  ("%m : ERROR : User Interrupt status bit is not cleared in DMA register (time %t)", $time);
                        `INC_ERRORS;
                    end

                    if (int_mode == INT_MODE_LEGACY) // Only do this check for Legacy Mode Interrupts
                    begin
                        if (debug) $display  ("%m : Debug : Verify interrupt is not still asserted");
                        // Note: Interrupt status bit MEM_READ_DWORD should have forced interrupt clear to have occurred
                        //        bdf,     vector,   timeout_clks, int_status
                        wait_int (dut_bdf, user_vec, 32'd1,        int_status); // Expect no interrupt
                        if (int_status != 1'b0)
                        begin
                            $display  ("%m : ERROR : User Interrupt did not get de-asserted over the PCI Express bus (time %t)", $time);
                            `INC_ERRORS;
                        end
                    end
                end
                else                 // Not expecting interrupt
                begin
                    if (debug) $display  ("%m : Debug : Unmask interrupts; unmasking the interrupt should cause the masked and held interrupt to be asserted");
                    wr_data[31:0] = 32'h0;           // Don't set other bits
                    wr_data[   5] = 1'b0;            // Clear interrupt status
                    wr_data[   4] = 1'b1;            // Set interrupt enable
                    wr_data[   0] = dma_int_enable; // Set/clear interrupt enable as directed
                    `MEM_WRITE_DWORD (3'b000, g3_com_bar, wr_data, 4'hf);

                    //        bdf,     vector,   timeout_clks, int_status
                    wait_int (dut_bdf, user_vec, timeout_clks, int_status); // Expect interrupt

                    if (int_status == 1'b1)
                    begin
                        $display  ("%m : User Interrupt received as expected");
                    end
                    else
                    begin
                        $display  ("%m : ERROR : User Interrupt was not asserted as expected (time %t)", $time);
                        `INC_ERRORS;
                    end

                    if (debug) $display  ("%m : Debug : Verify user interrupt status bit is asserted in Common DMA register");
                    `MEM_READ_DWORD  (3'b000, g3_com_bar, 32'h0, 32'h0, rd_data);
                    if (rd_data[5] != 1'b1)
                    begin
                        $display  ("%m : ERROR : User Interrupt status bit not set in common DMA register (time %t)", $time);
                        `INC_ERRORS;
                    end

                    if (debug) $display  ("%m : Debug : Clear interrupt status and leave interrupt enables same as directed at start of iteration");
                    wr_data[31:0] = 32'h0;           // Don't set other bits
                    wr_data[   5] = 1'b1;            // Clear interrupt status
                    wr_data[   4] = user_int_enable; // Set/clear interrupt enable as directed
                    wr_data[   0] = dma_int_enable; // Set/clear interrupt enable as directed
                    `MEM_WRITE_DWORD (3'b000, g3_com_bar, wr_data, 4'hf);

                    if (debug) $display  ("%m : Debug : Verify user interrupt status bit is cleared in DMA register");
                    `MEM_READ_DWORD  (3'b000, g3_com_bar, 32'h0, 32'h0, rd_data);
                    if (rd_data[5] != 1'b0)
                    begin
                        $display  ("%m : ERROR : User Interrupt status bit is not cleared in DMA register (time %t)", $time);
                        `INC_ERRORS;
                    end
                end
            end

            if (debug) $display  ("%m : Debug : Restore original value for Interrupt Enable register");
            `MEM_WRITE_DWORD (3'b000, g3_com_bar, sv_data, 4'hf);
        end
end
endtask
// Packet DMA Test Cases
    // ---------------------
    // Packet DMA Test Cases

    // --------------
    // RUN_DMA_REG_G3

    // DMA Register Access test for Packet DMA
    // Byte enables also tested

parameter RUN_DMA_REG_G3 = 0;

task dma_reg_g3;

        integer             i;
        reg     [63:0]      pattern;
        reg     [31:0]      read_data;
        reg     [32767:0]   payload;

begin
        $display  ("%m : ** BAR0 Register Test at time %0t **", $time);

        // Write Descriptor pointer registers to known values
        for (i=0; i<g3_num_s2c; i=i+1)
        begin
            pattern[15: 0] = (i*4);
            pattern[31:16] = (i*4)+1;
            pattern[47:32] = (i*4)+2;
            pattern[63:48] = (i*4)+3;

            $display  ("%m : Write Descriptor Pointer; S2C Discovered Engine #%d", i[7:0]);
            // `MEM_WRITE_DWORD (tc,     addr,                      data,           be);
            `MEM_WRITE_DWORD    (3'b000, g3_s2c_reg_base[i]+'h0008, pattern[31: 0], 4'hf);
        end

        for (i=0; i<g3_num_c2s; i=i+1)
        begin
            pattern[15: 0] = ((i+32)*4);
            pattern[31:16] = ((i+32)*4)+1;
            pattern[47:32] = ((i+32)*4)+2;
            pattern[63:48] = ((i+32)*4)+3;

            $display  ("%m : Write Descriptor Pointer; C2S Discovered Engine #%d", i[7:0]);
            // `MEM_WRITE_DWORD (tc,     addr,                      data,           be);
            `MEM_WRITE_DWORD    (3'b000, g3_c2s_reg_base[i]+'h0008, pattern[31: 0], 4'hf);
        end

        // Read Back Descriptor Pointer Registers and check for errors
        for (i=0; i<g3_num_s2c; i=i+1)
        begin
            pattern[15: 0] = (i*4);
            pattern[31:16] = (i*4)+1;
            pattern[47:32] = (i*4)+2;
            pattern[63:48] = (i*4)+3;

            $display  ("%m : Read Descriptor Pointer; S2C Discovered Engine #%d", i[7:0]);
            //`MEM_READ_DWORD (tc,     addr,                      expect_data,    check_be, read_data);
            `MEM_READ_DWORD   (3'b000, g3_s2c_reg_base[i]+'h0008, pattern[31: 0], 4'hf,     read_data);
        end

        for (i=0; i<g3_num_c2s; i=i+1)
        begin
            pattern[15: 0] = ((i+32)*4);
            pattern[31:16] = ((i+32)*4)+1;
            pattern[47:32] = ((i+32)*4)+2;
            pattern[63:48] = ((i+32)*4)+3;

            $display  ("%m : Read Descriptor Pointer; C2S Discovered Engine #%d", i[7:0]);
            //`MEM_READ_DWORD (tc,     addr,                      expect_data,    check_be, read_data);
            `MEM_READ_DWORD   (3'b000, g3_c2s_reg_base[i]+'h0008, pattern[31: 0], 4'hf,     read_data);
        end

        for (i=0; i<g3_num_c2s; i=i+1)
        begin
            $display  ("%m : ** C2S Register Byte Enable Test **");

            //Initialize pattern
            payload        = 0;
            payload[31: 0] = 32'h44002200;
            payload[63:32] = 32'h00770055;
            // `MEM_WRITE_BURST (tc,     addr,                     length, first_dw_be, last_dw_be, payload
            `MEM_WRITE_BURST    (3'b000, g3_c2s_reg_base[i]+'h008, 2,      4'hf,        4'hf,       payload);

            //DWORD writes filling target byte with pattern
            // `MEM_WRITE_DWORD (tc,     addr,                     data,         be);
            `MEM_WRITE_DWORD    (3'b000, g3_c2s_reg_base[i]+'h008, 32'h00330011, 4'h5);

            // `MEM_READ_DWORD  (tc,     addr,                     expect_data,  check_be, read_data);
            `MEM_READ_DWORD     (3'b000, g3_c2s_reg_base[i]+'h008, 32'h44332211, 4'hf,     read_data);
        end

        for (i=0; i<g3_num_s2c; i=i+1)
        begin
            $display  ("%m : ** S2C Register Byte Enable Test **");

            //Initialize pattern
            payload        = 0;
            payload[31: 0] = 32'h44002200;
            payload[63:32] = 32'h00770055;
            // `MEM_WRITE_BURST (tc,     addr,                     length, first_dw_be, last_dw_be, payload
            `MEM_WRITE_BURST    (3'b000, g3_s2c_reg_base[i]+'h008, 2,      4'hf,        4'hf,       payload);

            //DWORD writes filling target byte with pattern
            // `MEM_WRITE_DWORD (tc,     addr,                     data,         be);
            `MEM_WRITE_DWORD    (3'b000, g3_s2c_reg_base[i]+'h008, 32'h00330011, 4'h5);

            // `MEM_READ_DWORD  (tc,     addr,                     expect_data,  check_be, read_data);
            `MEM_READ_DWORD     (3'b000, g3_s2c_reg_base[i]+'h008, 32'h44332211, 4'hf,     read_data);
        end

        // Separate Test Sequences
        repeat (1000)
            @(posedge clk);

end // RUN_DMA_REG_G3
endtask




    // --------------------
    // RUN_DMA_SHORT_PKT_G3

    // A Quick test that checks for basic functionality of small packet sizes.
    //
    // Test Packet DMA using packet sizes above, equal, and below Descriptor size; choose Descriptor
    //   size to be below Streaming FIFO depth (typical minimum is 2-8KBytes) to test operation when
    //   packet quanitity rather than packet data throttle the availability of the Packet Streaming FIFOs.

parameter RUN_DMA_SHORT_PKT_G3 = 1;

task dma_short_pkt_g3;

    reg [63:0]  system_max_bsize;    // BFM memory size to reserve for each engine; each engine needs its own area to keep from conflicting with other engines
    reg [63:0]  desc_bsize;          // Descriptor typical byte size
    reg [63:0]  desc_max_bsize;      // BFM memory size to reserve for each engine; each engine needs its own area to keep from conflicting with other engines
    reg         done_wait;           // 1-wait for DMA completion interrupt; 0-dont wait
    reg [31:0]  bfm_memory_size;

    integer     i;
    reg [63:0]  reg_base;
    reg [63:0]  pat_base;
    reg         pkt_block_n;
    reg         cap;
    reg [11:0]  int_vector;

    reg [63:0]  system_addr;    // Starting System Address
    reg [63:0]  desc_ptr;       // DMA Queue Base Address
    reg [31:0]  total_bcount;

    reg [11:0]  bfm_pcie_cap_addr;

begin
        $display  ("%m : ** Short Packet DMA Engine Test at time %0t **", $time);

        system_max_bsize = 64'h10000;                                // 64KByte BFM memory space to reserve for each engine's DMA data
        desc_bsize       = 64'h00100;                                // Use 256 Byte typical Descriptor size
        desc_max_bsize   = ((system_max_bsize/desc_bsize) + 2) * 32; // BFM memory space to reserve for each engine's Descriptors (each Descriptor takes 32 bytes); +2 for partial start and ending Descriptors
        done_wait        = 1'b1;                                     // Wait for DMA to complete and check for correct DMA completion
        bfm_memory_size  = `BFM_MEM_BSIZE;

        // Run test for all System to Card and Card to System Engines
        for (i=0; i<g3_num_s2c+g3_num_c2s; i=i+1)
        begin
            if (i<g3_num_s2c) // Current test is for System to Card DMA Engine
            begin
                reg_base    = g3_s2c_reg_base   [i];
                pat_base    = g3_s2c_pat_base   [i];
                pkt_block_n = g3_s2c_pkt_block_n[i];
                cap         = g3_s2c_cap        [i];
                int_vector  = g3_s2c_int_vector [i];
            end
            else // Current test is for Card to System DMA Engine
            begin
                reg_base    = g3_c2s_reg_base   [i-g3_num_s2c];
                pat_base    = g3_c2s_pat_base   [i-g3_num_s2c];
                pkt_block_n = g3_c2s_pkt_block_n[i-g3_num_s2c];
                cap         = g3_c2s_cap        [i-g3_num_s2c];
                int_vector  = g3_c2s_int_vector [i-g3_num_s2c];
            end

            if (pkt_block_n == 1'b1)
            begin
                system_addr = bfm_bar0 + (i * system_max_bsize);                                              // Use unique, contiguous system addresses for each engine
                desc_ptr    = bfm_bar0 + ((g3_num_s2c+g3_num_c2s) * system_max_bsize) + (i * desc_max_bsize); // Keep Descriptors above DMA memory area; use unique system address for each engine

                if ((system_addr - bfm_bar0) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA data buffer end address offset == %x) exceeds (BFM memory size == %x)", (system_addr - bfm_bar0), bfm_memory_size);
                else if ((desc_ptr - bfm_bar0) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA Descriptor table end address offset == %x) exceeds (BFM memory size == %x)", (desc_ptr - bfm_bar0), bfm_memory_size);
                else
                begin
                    // DMA Engine Task for Packet DMA
                    `DO_PKT_DMA_CHAIN(system_addr,      // [63:0] system_addr (DMA data buffer starting address in BFM system memory)
                                      system_max_bsize, // [63:0] system_max_bsize (Max allowed DMA data buffer size in bytes)
                                      desc_ptr,         // [63:0] desc_ptr (DMA Descriptor table start address in BFM system memory)
                                      desc_max_bsize,   // [63:0] desc_max_bsize (Max allowed DMA Descriptor table size in bytes)
                                      desc_bsize,       // [63:0] desc_bsize (Max Descriptor size; the DMA buffer is fragemented into Descriptors on this address boundary)
                                      g3_com_bar,       // [63:0] reg_com_bar (DMA Back-End Common Register Block Base Address)
                                      reg_base,         // [63:0] reg_dma_bar (DMA Engine Register Block Base Address; selects which engine to use)
                                      pat_base,         // [63:0] reg_pat_bar (DMA Engine Pattern Generator Register Block Base Address; selects which pattern generator to use)
                                      int_vector,       // [11:0] int_vector (Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine)
                                      2'h3,             // [1:0]  pat_length_entries (Number of packet length table entries to use = pat_length_entries+1
                                      3'h3,             // [2:0]  pat_data_type (Data pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b0,             //        pat_data_cont (1==Continue data pattern accross packet boundaries; 0==restart data pattern for each packet)
                                      3'h3,             // [2:0]  pat_user_status_type (UserStatus pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b1,             //        pat_user_status_cont (1==Continue user_status pattern accross packet boundaries; 0==restart user_status pattern for each packet)
                                      8'h1,             // [7:0]  pat_active_clocks   (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      8'h0,             // [7:0]  pat_inactive_clocks (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      32'h5,            // [31:0] pat_num_packets (number of packets to generate)
                                      32'h00000000,     // [31:0] pat_data_seed (data pattern starting seed value)
                                      32'hF0000000,     // [31:0] pat_user_status_seed (user_status pattern starting seed value)
                                      20'h00080,        // [19:0] pat_length0 (byte length of generated packets; packet length table[0]; always used)
                                      20'h00100,        // [19:0] pat_length1 (byte length of generated packets; packet length table[1]; used if pat_length_entries > 0)
                                      20'h00200,        // [19:0] pat_length2 (byte length of generated packets; packet length table[2]; used if pat_length_entries > 1)
                                      20'h00400,        // [19:0] pat_length3 (byte length of generated packets; packet length table[3]; used if pat_length_entries > 2)
                                      32'd2,            // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                      1'b1,             //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                      1'b1,             //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                      32'h00010000,     //        timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                      check_status,
                                      total_bcount);    // [31:0] total number of bytes transferred

                    // Same test, but at 1/4 data rate
                    `DO_PKT_DMA_CHAIN(system_addr,      // [63:0] system_addr (DMA data buffer starting address in BFM system memory)
                                      system_max_bsize, // [63:0] system_max_bsize (Max allowed DMA data buffer size in bytes)
                                      desc_ptr,         // [63:0] desc_ptr (DMA Descriptor table start address in BFM system memory)
                                      desc_max_bsize,   // [63:0] desc_max_bsize (Max allowed DMA Descriptor table size in bytes)
                                      desc_bsize,       // [63:0] desc_bsize (Max Descriptor size; the DMA buffer is fragemented into Descriptors on this address boundary)
                                      g3_com_bar,       // [63:0] reg_com_bar (DMA Back-End Common Register Block Base Address)
                                      reg_base,         // [63:0] reg_dma_bar (DMA Engine Register Block Base Address; selects which engine to use)
                                      pat_base,         // [63:0] reg_pat_bar (DMA Engine Pattern Generator Register Block Base Address; selects which pattern generator to use)
                                      int_vector,       // [11:0] int_vector (Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine)
                                      2'h3,             // [1:0]  pat_length_entries (Number of packet length table entries to use = pat_length_entries+1
                                      3'h3,             // [2:0]  pat_data_type (Data pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b0,             //        pat_data_cont (1==Continue data pattern accross packet boundaries; 0==restart data pattern for each packet)
                                      3'h3,             // [2:0]  pat_user_status_type (UserStatus pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b1,             //        pat_user_status_cont (1==Continue user_status pattern accross packet boundaries; 0==restart user_status pattern for each packet)
                                      8'h1,             // [7:0]  pat_active_clocks   (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      8'h3,             // [7:0]  pat_inactive_clocks (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      32'h5,            // [31:0] pat_num_packets (number of packets to generate)
                                      32'h00000000,     // [31:0] pat_data_seed (data pattern starting seed value)
                                      32'hF0000000,     // [31:0] pat_user_status_seed (user_status pattern starting seed value)
                                      20'h00080,        // [19:0] pat_length0 (byte length of generated packets; packet length table[0]; always used)
                                      20'h00100,        // [19:0] pat_length1 (byte length of generated packets; packet length table[1]; used if pat_length_entries > 0)
                                      20'h00200,        // [19:0] pat_length2 (byte length of generated packets; packet length table[2]; used if pat_length_entries > 1)
                                      20'h00400,        // [19:0] pat_length3 (byte length of generated packets; packet length table[3]; used if pat_length_entries > 2)
                                      32'd2,            // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                      1'b1,             //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                      1'b1,             //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                      32'h00010000,     //        timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                      check_status,
                                      total_bcount);    // [31:0] total number of bytes transferred
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine %d since its not a Packet DMA Engine; Capabilities=%x", i, cap);
            end
        end
end // RUN_DMA_SHORT_PKT_G3
endtask




    // -------------------------
    // RUN_DMA_SHORT_PKT_LPBK_G3

    // A Quick test that checks for basic functionality of Packet DMA using
    //   built-in packet Loopback.

parameter RUN_DMA_SHORT_PKT_LPBK_G3 = 1;

task dma_short_pkt_lpbk_g3;

    integer         a;
    reg     [31:0]  axi_pcie_n;

    reg     [31:0]  circular_buffer_size;
    reg     [31:0]  desc_max_bsize;
    reg     [31:0]  desc_min_bsize;
    reg     [31:0]  desc_max_num;
    integer         desc_size;
    reg     [31:0]  bfm_memory_size;

    reg     [31:0]  pkt_max_bsize;
    reg     [31:0]  pkt_num_packets;

    integer     i;

    reg     [63:0]  s2c_rbuf_system_addr;
    reg     [63:0]  s2c_rbuf_system_bsize;
    reg     [63:0]  s2c_rbuf_desc_ptr;
    reg     [31:0]  s2c_rbuf_desc_max_bsize;
    reg     [31:0]  s2c_rbuf_desc_min_bsize;
    reg     [31:0]  s2c_rbuf_desc_max_num;

    reg     [63:0]  c2s_rbuf_system_addr;
    reg     [63:0]  c2s_rbuf_system_bsize;
    reg     [63:0]  c2s_rbuf_desc_ptr;
    reg     [31:0]  c2s_rbuf_desc_max_bsize;
    reg     [31:0]  c2s_rbuf_desc_min_bsize;
    reg     [31:0]  c2s_rbuf_desc_max_num;

    reg     [19:0]  byte_alignment;

begin
      $display  ("%m : ** Short Packet DMA Engine Loopback Test at time %0t **", $time);

      for (a=0; a<1; a=a+1)
      begin
        axi_pcie_n = a;

        circular_buffer_size = 32'h00010000;        // Circular buffer size to use (32'h00001000 == 64 KByte)
        desc_max_bsize       = 32'h00001000;        // Max Descriptor size to use when making circular buffer (32'h00001000 == 4 KByte)
        desc_min_bsize       = CORE_BE_WIDTH;       // Min Descriptor size to use when making circular buffer (32'h00001000 == 4 KByte)
        desc_max_num         = 32'h00000010;        // Max number of Descriptors to use for the Circular Buffers
        desc_size            = 32;                  // Descriptors are 32 bytes each
        bfm_memory_size      = `BFM_MEM_BSIZE;      // Size of BFM memory; don't want to exceed

        pkt_max_bsize        = desc_max_bsize * 3;  // Maximum packet size in bytes; packet size is randomized up to this size
        pkt_num_packets      = 8;                   // Number of packets to transmit/receive; this many packets are transmitted and received before ending the task

        byte_alignment       = 20'h1;               // Use 1-byte DWORD alignment; note alignments < 4 bytes always use incrementing byte byte pattern for data

        // Run test for all pairs of DMA Engines
        for (i=0; i<g3_num_com; i=i+1)
        begin
            if ((g3_c2s_pkt_block_n[i] == 1'b1) && (g3_s2c_pkt_block_n[i] == 1'b1)) // Only run test if the engine pair are both Packet DMA
            begin
                // Place BFM DMA and Descriptor regions adjacent to one another
                s2c_rbuf_system_addr    = bfm_bar0;
                s2c_rbuf_system_bsize   = circular_buffer_size;

                c2s_rbuf_system_addr    = s2c_rbuf_system_addr + s2c_rbuf_system_bsize;
                c2s_rbuf_system_bsize   = circular_buffer_size;

                s2c_rbuf_desc_ptr       = c2s_rbuf_system_addr + c2s_rbuf_system_bsize;
                s2c_rbuf_desc_max_bsize = desc_max_bsize;
                s2c_rbuf_desc_min_bsize = desc_min_bsize;
                s2c_rbuf_desc_max_num   = desc_max_num;

                c2s_rbuf_desc_ptr       = s2c_rbuf_desc_ptr + (desc_max_num * desc_size);
                c2s_rbuf_desc_max_bsize = desc_max_bsize;
                c2s_rbuf_desc_min_bsize = desc_min_bsize;
                c2s_rbuf_desc_max_num   = desc_max_num;

                if (((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA BFM Memory end address offset == %x) exceeds (BFM memory size == %x)", ((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)), bfm_memory_size);
                else
                begin
                    // DMA Engine Task for Packet DMA Loopback
                    `DO_PKT_DMA_LOOPBACK(s2c_rbuf_system_addr,      // [63:0] s2c_rbuf_system_addr    : S2C DMA Ring Buffer : Starting System Address
                                         s2c_rbuf_system_bsize,     // [63:0] s2c_rbuf_system_bsize   : S2C DMA Ring Buffer : Buffer size in bytes
                                         s2c_rbuf_desc_ptr,         // [63:0] s2c_rbuf_desc_ptr       : S2C DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         s2c_rbuf_desc_max_bsize,   // [31:0] s2c_rbuf_desc_max_bsize : S2C DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         s2c_rbuf_desc_min_bsize,   // [31:0] s2c_rbuf_desc_min_bsize : S2C DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         s2c_rbuf_desc_max_num,     // [31:0] s2c_rbuf_desc_max_num   : S2C DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         c2s_rbuf_system_addr,      // [63:0] c2s_rbuf_system_addr    : C2S DMA Ring Buffer : Starting System Address
                                         c2s_rbuf_system_bsize,     // [63:0] c2s_rbuf_system_bsize   : C2S DMA Ring Buffer : Buffer size in bytes
                                         c2s_rbuf_desc_ptr,         // [63:0] c2s_rbuf_desc_ptr       : C2S DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         c2s_rbuf_desc_max_bsize,   // [31:0] c2s_rbuf_desc_max_bsize : C2S DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         c2s_rbuf_desc_min_bsize,   // [31:0] c2s_rbuf_desc_min_bsize : C2S DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         c2s_rbuf_desc_max_num,     // [31:0] c2s_rbuf_desc_max_num   : C2S DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         byte_alignment,            // [19:0] byte_alignment          : Byte alignment to enforce for Packet Length, Descriptor System Addresses, and Descriptor Byte Counts; must be a positive power of 2
                                         g3_com_bar,                // [63:0] reg_com_bar             : DMA Common Register Block Base Address; needed to set global enables
                                         int_mode,                  // [1:0]  int_mode                : Interrupt mode in use for this engine pair: 2 == MSI-X, 1 == MSI, 0 == Legacy
                                         g3_s2c_reg_base[i],        // [63:0] reg_s2c_dma_bar         : S2C DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_s2c_pat_base[i],        // [63:0] reg_s2c_pat_bar         : S2C DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_s2c_int_vector[i],      // [11:0] s2c_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         g3_c2s_reg_base[i],        // [63:0] reg_c2s_dma_bar         : C2S DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_c2s_pat_base[i],        // [63:0] reg_c2s_pat_bar         : C2S DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_c2s_int_vector[i],      // [11:0] c2s_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         pkt_max_bsize,             // [31:0] pkt_max_bsize           : Maximum packet size in bytes; packet size is randomize up to this size
                                         pkt_num_packets,           // [31:0] pkt_num_packets         : Number of packets to transmit/receive; this many packets are transmitted and received before enging the task
                                         32'hf0000000,              // [31:0] pat_user_seed           : Seed value for user_status/control pattern; subsequent data continues from packet to packet
                                         3'h3,                      // [ 2:0] pat_user_type           : User status/control pattern: 0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD
                                         32'h03020100,              // [31:0] pat_data_seed           : Seed value for data pattern; subsequent data continues from packet to packet
                                         3'h1,                      // [ 2:0] pat_data_type           : Data pattern:                0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD        // Initial value for user_control/status
                                         32'd3,                     // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                         1'b1,                      //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                         1'b1,                      //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                         32'h00010000,              // [31:0] timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                         check_status,
                                         axi_pcie_n);               // 0==PCIe, 1==AXI w/PCIe Int, 2==AXI w/Edge AXI Int; 3==AXI w/Level AXI Int
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine Pair %d since one or both engines are not Packet DMA Engines; S2C_Cap=%x, C2S_Cap=0x%x", i, g3_s2c_cap[i], g3_c2s_cap[i]);
            end
        end
      end
end // RUN_DMA_SHORT_PKT_LPBK_G3
endtask




    // ------------------------------
    // RUN_DMA_SMALL_UNALIGNED_PKT_G3

    // A Quick test that checks small unaligned packets are handled correctly;
    //   Requires the Pattern Generator and Pattern Checker Loopback functionality
    //   from a pair of DMA Engines.

parameter RUN_DMA_SMALL_UNALIGNED_PKT_G3 = 0;

task dma_small_unaligned_pkt_g3;

    integer         a;
    reg     [31:0]  axi_pcie_n;

    reg     [31:0]  circular_buffer_size;
    reg     [31:0]  desc_max_bsize;
    reg     [31:0]  desc_min_bsize;
    reg     [31:0]  desc_max_num;
    integer         desc_size;
    reg     [31:0]  bfm_memory_size;

    reg     [31:0]  pkt_max_bsize;
    reg     [31:0]  pkt_num_packets;

    integer     i;

    reg     [63:0]  s2c_rbuf_system_addr;
    reg     [63:0]  s2c_rbuf_system_bsize;
    reg     [63:0]  s2c_rbuf_desc_ptr;
    reg     [31:0]  s2c_rbuf_desc_max_bsize;
    reg     [31:0]  s2c_rbuf_desc_min_bsize;
    reg     [31:0]  s2c_rbuf_desc_max_num;

    reg     [63:0]  c2s_rbuf_system_addr;
    reg     [63:0]  c2s_rbuf_system_bsize;
    reg     [63:0]  c2s_rbuf_desc_ptr;
    reg     [31:0]  c2s_rbuf_desc_max_bsize;
    reg     [31:0]  c2s_rbuf_desc_min_bsize;
    reg     [31:0]  c2s_rbuf_desc_max_num;

    reg     [19:0]  byte_alignment;

begin
      $display  ("%m : ** Packet DMA Engine - Small Unaligned Loopback Test at time %0t **", $time);

      for (a=0; a<1; a=a+1)
      begin
        axi_pcie_n = a;

        circular_buffer_size = 32'h00001000;        // Circular buffer size to use (32'h00001000 == 4 KByte)
        desc_max_bsize       = 32'h00000040;        // Max Descriptor size to use when making circular buffer (32'h00001000 == 4 KByte)
        desc_min_bsize       = 32'h0000003c;        // Max Descriptor size to use when making circular buffer (32'h00001000 == 4 KByte)
        desc_max_num         = 32'h00000010;        // Max number of Descriptors to use for the Circular Buffers
        desc_size            = 32;                  // Descriptors are 32 bytes each
        bfm_memory_size      = `BFM_MEM_BSIZE;      // Size of BFM memory; don't want to exceed
        pkt_max_bsize        = desc_max_bsize * 3;  // Maximum packet size in bytes; packet size is randomized up to this size
        pkt_num_packets      = 64;                  // Number of packets to transmit/receive; this many packets are transmitted and received before ending the task

        byte_alignment       = 20'h1;               // Use 1-byte DWORD alignment; note alignments < 4 bytes always use incrementing byte byte pattern for data

        // Run test for all pairs of DMA Engines
        for (i=0; i<g3_num_com; i=i+1)
        begin
            if ((g3_c2s_pkt_block_n[i] == 1'b1) && (g3_s2c_pkt_block_n[i] == 1'b1)) // Only run test if the engine pair are both Packet DMA
            begin
                // Place BFM DMA and Descriptor regions adjacent to one another
                s2c_rbuf_system_addr    = bfm_bar0 + 2;
                s2c_rbuf_system_bsize   = circular_buffer_size - 2;

                c2s_rbuf_system_addr    = s2c_rbuf_system_addr + s2c_rbuf_system_bsize;
                c2s_rbuf_system_bsize   = circular_buffer_size;

                s2c_rbuf_desc_ptr       = c2s_rbuf_system_addr + c2s_rbuf_system_bsize;
                s2c_rbuf_desc_max_bsize = desc_max_bsize;
                s2c_rbuf_desc_min_bsize = desc_min_bsize;
                s2c_rbuf_desc_max_num   = desc_max_num;

                c2s_rbuf_desc_ptr       = s2c_rbuf_desc_ptr + (desc_max_num * desc_size);
                c2s_rbuf_desc_max_bsize = desc_max_bsize;
                c2s_rbuf_desc_min_bsize = desc_min_bsize;
                c2s_rbuf_desc_max_num   = desc_max_num;

                if (((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA BFM Memory end address offset == %x) exceeds (BFM memory size == %x)", ((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)), bfm_memory_size);
                else
                begin
                    // DMA Engine Task for Packet DMA Loopback
                    `DO_PKT_DMA_LOOPBACK(s2c_rbuf_system_addr,      // [63:0] s2c_rbuf_system_addr    : S2C DMA Ring Buffer : Starting System Address
                                         s2c_rbuf_system_bsize,     // [63:0] s2c_rbuf_system_bsize   : S2C DMA Ring Buffer : Buffer size in bytes
                                         s2c_rbuf_desc_ptr,         // [63:0] s2c_rbuf_desc_ptr       : S2C DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         s2c_rbuf_desc_max_bsize,   // [31:0] s2c_rbuf_desc_max_bsize : S2C DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         s2c_rbuf_desc_min_bsize,   // [31:0] s2c_rbuf_desc_min_bsize : S2C DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         s2c_rbuf_desc_max_num,     // [31:0] s2c_rbuf_desc_max_num   : S2C DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         c2s_rbuf_system_addr,      // [63:0] c2s_rbuf_system_addr    : C2S DMA Ring Buffer : Starting System Address
                                         c2s_rbuf_system_bsize,     // [63:0] c2s_rbuf_system_bsize   : C2S DMA Ring Buffer : Buffer size in bytes
                                         c2s_rbuf_desc_ptr,         // [63:0] c2s_rbuf_desc_ptr       : C2S DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         c2s_rbuf_desc_max_bsize,   // [31:0] c2s_rbuf_desc_max_bsize : C2S DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         c2s_rbuf_desc_min_bsize,   // [31:0] c2s_rbuf_desc_min_bsize : C2S DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         c2s_rbuf_desc_max_num,     // [31:0] c2s_rbuf_desc_max_num   : C2S DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         byte_alignment,            // [19:0] byte_alignment          : Byte alignment to enforce for Packet Length, Descriptor System Addresses, and Descriptor Byte Counts; must be a positive power of 2
                                         g3_com_bar,                // [63:0] reg_com_bar             : DMA Common Register Block Base Address; needed to set global enables
                                         int_mode,                  // [1:0]  int_mode                : Interrupt mode in use for this engine pair: 2 == MSI-X, 1 == MSI, 0 == Legacy
                                         g3_s2c_reg_base[i],        // [63:0] reg_s2c_dma_bar         : S2C DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_s2c_pat_base[i],        // [63:0] reg_s2c_pat_bar         : S2C DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_s2c_int_vector[i],      // [11:0] s2c_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         g3_c2s_reg_base[i],        // [63:0] reg_c2s_dma_bar         : C2S DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_c2s_pat_base[i],        // [63:0] reg_c2s_pat_bar         : C2S DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_c2s_int_vector[i],      // [11:0] c2s_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         pkt_max_bsize,             // [31:0] pkt_max_bsize           : Maximum packet size in bytes; packet size is randomize up to this size
                                         pkt_num_packets,           // [31:0] pkt_num_packets         : Number of packets to transmit/receive; this many packets are transmitted and received before enging the task
                                         32'hf0000000,              // [31:0] pat_user_seed           : Seed value for user_status/control pattern; subsequent data continues from packet to packet
                                         3'h3,                      // [ 2:0] pat_user_type           : User status/control pattern: 0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD
                                         32'h03020100,              // [31:0] pat_data_seed           : Seed value for data pattern; subsequent data continues from packet to packet
                                         3'h1,                      // [ 2:0] pat_data_type           : Data pattern:                0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD        // Initial value for user_control/status
                                         32'd2,                     // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                         1'b1,                      //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                         1'b1,                      //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                         32'h00010000,              // [31:0] timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                         check_status,
                                         axi_pcie_n);               // 0==PCIe, 1==AXI w/PCIe Int, 2==AXI w/Edge AXI Int; 3==AXI w/Level AXI Int
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine Pair %d since one or both engines are not Packet DMA Engines; S2C_Cap=%x, C2S_Cap=0x%x", i, g3_s2c_cap[i], g3_c2s_cap[i]);
            end
        end
      end
end // RUN_DMA_SMALL_UNALIGNED_PKT_G3
endtask


    // --------------------------
    // RUN_DMA_SHORT_ADR_PKT_TEST

    // Short Addressable Packet DMA Test
    // First Engine Pair Tested

parameter RUN_DMA_SHORT_ADR_PKT_TEST = 0;

task dma_short_adr_pkt_test;
        reg     [63:0]      system_addr;
        reg     [35:0]      card_addr;
        reg     [3:0]       s2c_desc_num;
        reg     [31:0]      s2c_desc_base;
        reg     [3:0]       c2s_desc_num;
        reg     [31:0]      c2s_desc_base;
        integer             desc_count;
        reg     [31:0]      bfm_dword_addr;
        reg     [31:0]      xfer_bcount;
        reg     [31:0]      xfer2_bcount;
        reg     [31:0]      desc_max;
        reg     [31:0]      desc_bcount;
        reg     [31:0]      left_bcount;
        reg     [31:0]      offset;
        reg     [19:0]      first_bcount;
        reg     [19:0]      second_bcount;
        reg     [19:0]      third_bcount;
        reg     [63:0]      user_control;
        reg     [7:0]       control_flags;
        reg     [7:0]       byteval;
        reg     [31:0]      write_data;
        reg     [63:0]      s2c_dma_bar;
        reg     [63:0]      s2c_reg_cap;
        reg     [63:0]      s2c_reg_cst;
        reg     [63:0]      s2c_reg_ndp;
        reg     [63:0]      s2c_reg_sdp;
        reg     [63:0]      s2c_reg_cdp;
        reg     [63:0]      s2c_reg_int;
        reg     [63:0]      s2c_pat_ctl;
        reg     [63:0]      c2s_dma_bar;
        reg     [63:0]      c2s_reg_cap;
        reg     [63:0]      c2s_reg_cst;
        reg     [63:0]      c2s_reg_ndp;
        reg     [63:0]      c2s_reg_sdp;
        reg     [63:0]      c2s_reg_cdp;
        reg     [63:0]      c2s_reg_int;
        reg     [63:0]      c2s_pat_ctl;
        reg     [31:0]      read_data;
        reg                 done;
        integer             i,j;

begin
        $display  ("%m : ** Short Addressable Packet DMA Test at time %0t **", $time);

        // S2C
        system_addr = bfm_bar1 + 64'h1000;
        card_addr   = 36'h410;
        xfer_bcount = 32'h1000;
        user_control = 64'h1234567887654321;
        s2c_desc_base = bfm_bar0 + 64'h100;
        c2s_desc_base = bfm_bar0 + 64'h400;
        desc_count = 16;

        // Initialize data memory
        byteval = 8'h00;
        for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
            write_data[ 7: 0] = byteval;
            write_data[15: 8] = byteval+1;
            write_data[23:16] = byteval+2;
            write_data[31:24] = byteval+3;
            `BFM_MEM[j] = write_data;
            byteval = byteval +4;
        end

        // Select DMA destination as memory
        `MEM_WRITE_DWORD (3'b000, g3_s2c_pat_base[0], 32'h00000004, 4'hf);
        `MEM_READ_DWORD  (3'b000, g3_s2c_pat_base[0], 32'h00000004, 4'hf, read_data);

        // Select DMA destination as memory
        `MEM_WRITE_DWORD (3'b000, g3_c2s_pat_base[0], 32'h00000004, 4'hf);
        `MEM_READ_DWORD  (3'b000, g3_c2s_pat_base[0], 32'h00000004, 4'hf, read_data);

        // Enable interrupts from DMA engines
        `MEM_WRITE_DWORD (3'b000, g3_com_bar, 32'h01, 4'h1);

        // Initialize the DMA engine
        s2c_dma_bar = g3_s2c_reg_base[0];
        s2c_reg_cap = s2c_dma_bar + 'h00;
        s2c_reg_cst = s2c_dma_bar + 'h04;
        s2c_reg_ndp = s2c_dma_bar + 'h08;
        s2c_reg_sdp = s2c_dma_bar + 'h0c;
        s2c_reg_cdp = s2c_dma_bar + 'h10;
        s2c_reg_int = s2c_dma_bar + 'h20;
        `MEM_WRITE_DWORD (3'b000, s2c_reg_cdp, 32'h0,           4'hf); // Zero completed Descriptor Pointer
        `MEM_WRITE_DWORD (3'b000, s2c_reg_sdp, s2c_desc_base,   4'hf); // End of chain is marked with ndp==0, so this register is not used
        `MEM_WRITE_DWORD (3'b000, s2c_reg_ndp, s2c_desc_base,   4'hf); // Start of DMA chain
        `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'h00000101,    4'hf); // Start the DMA engine; enable interrupts
        `MEM_WRITE_DWORD (3'b000, s2c_reg_int, 32'h2,           4'hf); // Interrupt on EOP

        // Initialize the DMA engine
        c2s_dma_bar = g3_c2s_reg_base[0];
        c2s_reg_cap = c2s_dma_bar + 'h00;
        c2s_reg_cst = c2s_dma_bar + 'h04;
        c2s_reg_ndp = c2s_dma_bar + 'h08;
        c2s_reg_sdp = c2s_dma_bar + 'h0c;
        c2s_reg_cdp = c2s_dma_bar + 'h10;
        c2s_reg_int = c2s_dma_bar + 'h20;
        `MEM_WRITE_DWORD (3'b000, c2s_reg_cdp, 32'h0,           4'hf); // Zero completed Descriptor Pointer
        `MEM_WRITE_DWORD (3'b000, c2s_reg_sdp, c2s_desc_base,   4'hf); // End of chain is marked with ndp==0, so this register is not used
        `MEM_WRITE_DWORD (3'b000, c2s_reg_ndp, c2s_desc_base,   4'hf); // Start of DMA chain
        `MEM_WRITE_DWORD (3'b000, c2s_reg_cst, 32'h00000101,    4'hf); // Start the DMA engine; enable interrupts
        `MEM_WRITE_DWORD (3'b000, c2s_reg_int, 32'h2,           4'hf); // Interrupt on EOP


        // Initialize descriptors
        s2c_desc_num = 0;
        bfm_dword_addr = s2c_desc_base[23:0] >> 2;
        for (i=0; i<desc_count; i=i+1) begin
            `BFM_MEM[bfm_dword_addr+0] = 32'h0; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
            `BFM_MEM[bfm_dword_addr+1] = 32'h0;   // S2CDescUserControl[31: 0]
            `BFM_MEM[bfm_dword_addr+2] = 32'h0;
            `BFM_MEM[bfm_dword_addr+3] = 32'h0;       // DescCardAddr
            `BFM_MEM[bfm_dword_addr+4] = 32'h0; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
            `BFM_MEM[bfm_dword_addr+5] = 32'h0;    // System Address[31: 0]
            `BFM_MEM[bfm_dword_addr+6] = 32'h0;    // System Address[63:32]
            `BFM_MEM[bfm_dword_addr+7] = s2c_desc_base + (((i+1) % desc_count) * 32'h20);
            bfm_dword_addr = bfm_dword_addr + 8;
        end

        // Initialize descriptors
        c2s_desc_num = 0;
        bfm_dword_addr = c2s_desc_base[23:0] >> 2;
        for (i=0; i<desc_count; i=i+1) begin
            `BFM_MEM[bfm_dword_addr+0] = 32'h0; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
            `BFM_MEM[bfm_dword_addr+1] = 32'h0;   // S2CDescUserControl[31: 0]
            `BFM_MEM[bfm_dword_addr+2] = 32'h0;
            `BFM_MEM[bfm_dword_addr+3] = 32'h0;       // DescCardAddr
            `BFM_MEM[bfm_dword_addr+4] = 32'h0; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
            `BFM_MEM[bfm_dword_addr+5] = 32'h0;    // System Address[31: 0]
            `BFM_MEM[bfm_dword_addr+6] = 32'h0;    // System Address[63:32]
            `BFM_MEM[bfm_dword_addr+7] = c2s_desc_base + (((i+1) % desc_count) * 32'h20);
            bfm_dword_addr = bfm_dword_addr + 8;
        end


        xfer_bcount = 32'h200;
        card_addr   = 32'h0;
        system_addr = bfm_bar1 + 64'h1000;
        desc_max    = 32'h1000;

        $display  ("%m : INFO : System:%h  Card:%h  Length:%h ",system_addr, card_addr, xfer_bcount);
        // First Descriptor
        if (xfer_bcount > desc_max) begin
            desc_bcount = desc_max;
            control_flags = {1'b1, 1'b0, 6'h0};
        end
        else begin
            desc_bcount = xfer_bcount;
            control_flags = {1'b1, 1'b1, 6'h0};
        end
        bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
        `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, desc_bcount[19:0]}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
        `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0];       // DescCardAddr
        `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], 20'h1000}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
        `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];    // System Address[31: 0]
        `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
        s2c_desc_num = (s2c_desc_num + 1) % desc_count;
        left_bcount = xfer_bcount - desc_bcount;
        offset = desc_bcount;
        while (left_bcount >0) begin
            bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
            if (left_bcount >= desc_max)
                desc_bcount = desc_max;
            else
                desc_bcount = left_bcount;
            if (left_bcount > desc_max)
                control_flags = {1'b0, 1'b0, 6'h0};
            else
                control_flags = {1'b0, 1'b1, 6'h0};
            `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, desc_bcount[19:0]};
            `BFM_MEM[bfm_dword_addr+3] = 32'h0;
            `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], 4'h0, 20'h1000};
            `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + offset;
            `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];
            s2c_desc_num = (s2c_desc_num + 1) % desc_count;
            left_bcount = left_bcount - desc_bcount;
            offset = offset + desc_bcount;
        end

        // Extra packet
        bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
        control_flags = {1'b1, 1'b1, 6'h0};
        xfer2_bcount = 32'h3;
        `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, xfer2_bcount[19:0]}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
        `BFM_MEM[bfm_dword_addr+3] = 32'h0;       // DescCardAddr
        `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], 4'h0, 20'h1000}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
        `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + xfer_bcount;    // System Address[31: 0]
        `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
        s2c_desc_num = (s2c_desc_num + 1) % desc_count;


        // Start the DMA engine
        `MEM_WRITE_DWORD (3'b000, s2c_reg_sdp, s2c_desc_base + (32'h20 * s2c_desc_num), 4'hf);

        // wait for interrupt
        wait_int(dut_bdf, g3_s2c_int_vector[0], 32'd4000, done);
        // clear interrupt
        `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'hff, 4'h1);

        // Wait for descriptor to finish
        while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
            @(posedge clk);

        // C2S
        system_addr = system_addr + 64'h2000;

        // Write descriptor for c2s
        if (xfer_bcount > desc_max) begin
            desc_bcount = desc_max;
            control_flags = {1'b1, 1'b0, 6'h0};
        end
        else begin
            desc_bcount = xfer_bcount;
            control_flags = {1'b1, 1'b1, 6'h0};
        end
        bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
        `BFM_MEM[bfm_dword_addr+0] = 32'h0;
        `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0];
        `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], desc_bcount[19:0]};
        `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];
        `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];
        c2s_desc_num = (c2s_desc_num + 1) % desc_count;
        left_bcount = xfer_bcount - desc_bcount;
        offset = desc_bcount;
        while (left_bcount >0) begin
            bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
            if (left_bcount >= desc_max)
                desc_bcount = desc_max;
            else
                desc_bcount = left_bcount;
            if (left_bcount > desc_max)
                control_flags = {1'b0, 1'b0, 6'h0};
            else
                control_flags = {1'b0, 1'b1, 6'h0};
            `BFM_MEM[bfm_dword_addr+0] = 32'h0;
            `BFM_MEM[bfm_dword_addr+3] = 32'h0;
            `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], 4'h0, desc_bcount[19:0]};
            `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + offset;
            `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];
            c2s_desc_num = (c2s_desc_num + 1) % desc_count;
            left_bcount = left_bcount - desc_bcount;
            offset = offset + desc_bcount;
        end

        // Start the DMA engine
        `MEM_WRITE_DWORD (3'b000, c2s_reg_sdp, c2s_desc_base + (c2s_desc_num * 32'h20), 4'hf);

        // wait for interrupt
        wait_int(dut_bdf, g3_s2c_int_vector[0], 32'd4000, done);
        // clear interrupt
        `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'hff, 4'h1);

        // Wait for descriptor to finish
        while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
            @(posedge clk);

        // Check Data
        for (j=system_addr[23:0]; j<system_addr[23:0]+xfer_bcount; j=j+1) begin
            read_data = `BFM_MEM[j >> 2];
            case (j % 4)
                0 : byteval = read_data[7:0];
                1 : byteval = read_data[15:8];
                2 : byteval = read_data[23:16];
                default : byteval = read_data[31:24];
            endcase
            if (byteval != (j % 256)) begin
                $display ("%m : ERROR : Address == %h : Expected Data == %h, memory -- %h (time %0t)",j, (j % 256), byteval, $time);
                `INC_ERRORS;
            end
        end

       `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'h00000000,    4'hf); // Disable the DMA engine; disable interrupts
       `MEM_WRITE_DWORD (3'b000, c2s_reg_cst, 32'h00000000,    4'hf); // Disable the DMA engine; disable interrupts

end // DMA_SHORT_ADR_PKT_TEST
endtask



    // --------------------
    // RUN_DMA_ADR_PKT_TEST

    // Addressable Packet DMA Test.  All DMA Engine Pairs tested (in sequence)

parameter RUN_DMA_ADR_PKT_TEST = 0;
parameter     DMA_ADR_PKT_LOOP_COUNT                  = 4;
parameter     DMA_ADR_PKT_EXTRAS                      = 0;

task dma_adr_pkt_test;

        reg     [63:0]      system_addr;
        reg     [35:0]      card_addr;
        reg     [3:0]       s2c_desc_num;
        reg     [31:0]      s2c_desc_base;
        reg     [3:0]       c2s_desc_num;
        reg     [31:0]      c2s_desc_base;
        integer             desc_count;
        reg     [31:0]      bfm_dword_addr;
        reg     [31:0]      xfer_bcount;
        reg     [31:0]      xfer2_bcount;
        reg     [31:0]      desc_max;
        reg     [31:0]      desc_bcount;
        reg     [31:0]      left_bcount;
        reg     [31:0]      offset;
        reg     [19:0]      first_bcount;
        reg     [19:0]      second_bcount;
        reg     [19:0]      third_bcount;
        reg     [63:0]      user_control;
        reg     [7:0]       control_flags;
        reg     [7:0]       byteval;
        reg     [31:0]      write_data;
        reg     [63:0]      s2c_dma_bar;
        reg     [63:0]      s2c_reg_cap;
        reg     [63:0]      s2c_reg_cst;
        reg     [63:0]      s2c_reg_ndp;
        reg     [63:0]      s2c_reg_sdp;
        reg     [63:0]      s2c_reg_cdp;
        reg     [63:0]      s2c_reg_int;
        reg     [63:0]      s2c_pat_ctl;
        reg     [63:0]      c2s_dma_bar;
        reg     [63:0]      c2s_reg_cap;
        reg     [63:0]      c2s_reg_cst;
        reg     [63:0]      c2s_reg_ndp;
        reg     [63:0]      c2s_reg_sdp;
        reg     [63:0]      c2s_reg_cdp;
        reg     [63:0]      c2s_reg_int;
        reg     [63:0]      c2s_pat_ctl;
        reg     [31:0]      read_data;
        reg                 done;
        integer             i,j,k;
        reg     [31:0]      axi_pcie_n;

begin
        $display  ("%m : ** DMA Addressable Packet DMA Test at time %0t **", $time);

        // Run test for all pairs of DMA Engines
        for (k=0; k<g3_num_com; k=k+1)
        begin

          if ((g3_c2s_pkt_block_n[k] == 1'b1) && (g3_s2c_pkt_block_n[k] == 1'b1))
          begin // Only run test if the engine pair are both Packet DMA


            $display  ("%m : Begin packet DMA Engine Pair %d", k);

            // S2C
            system_addr = bfm_bar1 + 64'h1000;
            card_addr   = 36'h410;
            xfer_bcount = 32'ha000;
            user_control = 64'h1234567887654321;
            s2c_desc_base = bfm_bar0 + 64'h100;
            c2s_desc_base = bfm_bar0 + 64'h400;
            desc_count = 16;

            // Initialize data memory
            byteval = 8'h00;
            for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                write_data[ 7: 0] = byteval;
                write_data[15: 8] = byteval+1;
                write_data[23:16] = byteval+2;
                write_data[31:24] = byteval+3;
                `BFM_MEM[j] = write_data;
                byteval = byteval +4;
            end

            // Select DMA destination as memory
            `MEM_WRITE_DWORD (3'b000, g3_s2c_pat_base[k], 32'h00000004, 4'hf);
            `MEM_READ_DWORD  (3'b000, g3_s2c_pat_base[k], 32'h00000004, 4'hf, read_data);

            // Select DMA destination as memory
            `MEM_WRITE_DWORD (3'b000, g3_c2s_pat_base[k], 32'h00000004, 4'hf);
            `MEM_READ_DWORD  (3'b000, g3_c2s_pat_base[k], 32'h00000004, 4'hf, read_data);

            // Enable interrupts from DMA engines
            `MEM_WRITE_DWORD (3'b000, g3_com_bar, 32'h01, 4'h1);

            // Initialize the DMA engine
            s2c_dma_bar = g3_s2c_reg_base[k];
            s2c_reg_cap = s2c_dma_bar + 'h00;
            s2c_reg_cst = s2c_dma_bar + 'h04;
            s2c_reg_ndp = s2c_dma_bar + 'h08;
            s2c_reg_sdp = s2c_dma_bar + 'h0c;
            s2c_reg_cdp = s2c_dma_bar + 'h10;
            s2c_reg_int = s2c_dma_bar + 'h20;
            begin
                `MEM_WRITE_DWORD (3'b000, s2c_reg_cdp, 32'h0,           4'hf); // Zero completed Descriptor Pointer
                `MEM_WRITE_DWORD (3'b000, s2c_reg_sdp, s2c_desc_base,   4'hf); // End of chain is marked with ndp==0, so this register is not used
                `MEM_WRITE_DWORD (3'b000, s2c_reg_ndp, s2c_desc_base,   4'hf); // Start of DMA chain
                `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'h00000101,    4'hf); // Start the DMA engine; enable interrupts
                `MEM_WRITE_DWORD (3'b000, s2c_reg_int, 32'h2,           4'hf); // Interrupt on EOP
            end

            // Initialize the DMA engine
            c2s_dma_bar = g3_c2s_reg_base[k];
            c2s_reg_cap = c2s_dma_bar + 'h00;
            c2s_reg_cst = c2s_dma_bar + 'h04;
            c2s_reg_ndp = c2s_dma_bar + 'h08;
            c2s_reg_sdp = c2s_dma_bar + 'h0c;
            c2s_reg_cdp = c2s_dma_bar + 'h10;
            c2s_reg_int = c2s_dma_bar + 'h20;
            begin
                `MEM_WRITE_DWORD (3'b000, c2s_reg_cdp, 32'h0,           4'hf); // Zero completed Descriptor Pointer
                `MEM_WRITE_DWORD (3'b000, c2s_reg_sdp, c2s_desc_base,   4'hf); // End of chain is marked with ndp==0, so this register is not used
                `MEM_WRITE_DWORD (3'b000, c2s_reg_ndp, c2s_desc_base,   4'hf); // Start of DMA chain
                `MEM_WRITE_DWORD (3'b000, c2s_reg_cst, 32'h00000101,    4'hf); // Start the DMA engine; enable interrupts
                `MEM_WRITE_DWORD (3'b000, c2s_reg_int, 32'h2,           4'hf); // Interrupt on EOP
            end

            // Initialize descriptors
            s2c_desc_num = 0;
            bfm_dword_addr = s2c_desc_base[23:0] >> 2;
            for (i=0; i<desc_count; i=i+1) begin
                `BFM_MEM[bfm_dword_addr+0] = 32'h0; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+1] = 32'h0;   // S2CDescUserControl[31: 0]
                `BFM_MEM[bfm_dword_addr+2] = 32'h0;
                `BFM_MEM[bfm_dword_addr+3] = 32'h0;       // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = 32'h0; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = 32'h0;    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = 32'h0;    // System Address[63:32]
                `BFM_MEM[bfm_dword_addr+7] = s2c_desc_base + (((i+1) % desc_count) * 32'h20);
                bfm_dword_addr = bfm_dword_addr + 8;
            end

            // Initialize descriptors
            c2s_desc_num = 0;
            bfm_dword_addr = c2s_desc_base[23:0] >> 2;
            for (i=0; i<desc_count; i=i+1) begin
                `BFM_MEM[bfm_dword_addr+0] = 32'h0; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+1] = 32'h0;   // S2CDescUserControl[31: 0]
                `BFM_MEM[bfm_dword_addr+2] = 32'h0;
                `BFM_MEM[bfm_dword_addr+3] = 32'h0;       // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = 32'h0; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = 32'h0;    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = 32'h0;    // System Address[63:32]
                `BFM_MEM[bfm_dword_addr+7] = c2s_desc_base + (((i+1) % desc_count) * 32'h20);
                bfm_dword_addr = bfm_dword_addr + 8;
            end


            for (i = 0; i<DMA_ADR_PKT_LOOP_COUNT; i=i+1) begin      // loop over packets
                xfer_bcount = $random & 32'h1fff;
                card_addr   = $random & 32'hfff;
                system_addr = bfm_bar1 + ($random & 32'hfff) + 32'h1000;
                desc_max    = 32'h1000;

                $display  ("%m : INFO : System:%h  Card:%h  Length:%h ",system_addr, card_addr, xfer_bcount);
                // First Descriptor
                if (xfer_bcount > desc_max) begin
                    desc_bcount = desc_max;
                    control_flags = {1'b1, 1'b0, 6'h0};
                end
                else begin
                    desc_bcount = xfer_bcount;
                    control_flags = {1'b1, 1'b1, 6'h0};
                end
                bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, desc_bcount[19:0]}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0];       // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], 20'h1000}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
                s2c_desc_num = (s2c_desc_num + 1) % desc_count;
                left_bcount = xfer_bcount - desc_bcount;
                offset = desc_bcount;
                while (left_bcount >0) begin
                    bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
                    if (left_bcount >= desc_max)
                        desc_bcount = desc_max;
                    else
                        desc_bcount = left_bcount;
                    if (left_bcount > desc_max)
                        control_flags = {1'b0, 1'b0, 6'h0};
                    else
                        control_flags = {1'b0, 1'b1, 6'h0};
                    `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, desc_bcount[19:0]};
                    `BFM_MEM[bfm_dword_addr+3] = 32'h0;
                    `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], 20'h1000};
                    `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + offset;
                    `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];
                    s2c_desc_num = (s2c_desc_num + 1) % desc_count;
                    left_bcount = left_bcount - desc_bcount;
                    offset = offset + desc_bcount;
                end

                // Extra packet
                bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
                control_flags = {1'b1, 1'b1, 6'h0};
                xfer2_bcount = 32'h3;
                `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, xfer2_bcount[19:0]}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0] + xfer_bcount;       // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], 20'h1000}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + xfer_bcount;    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
                s2c_desc_num = (s2c_desc_num + 1) % desc_count;


                // Start the DMA engine
                `MEM_WRITE_DWORD (3'b000, s2c_reg_sdp, s2c_desc_base + (32'h20 * s2c_desc_num), 4'hf);

                // wait for interrupt
                wait_int(dut_bdf, g3_s2c_int_vector[k], 32'd4000, done);
                // clear interrupt
                `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'hff, 4'h1);

                // Wait for descriptor to finish
                while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
                    @(posedge clk);

                // C2S
                system_addr = system_addr + 64'h2000;

                // Write descriptor for c2s
                if (xfer_bcount > desc_max) begin
                    desc_bcount = desc_max;
                    control_flags = {1'b1, 1'b0, 6'h0};
                end
                else begin
                    desc_bcount = xfer_bcount;
                    control_flags = {1'b1, 1'b1, 6'h0};
                end
                bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = 32'h0;
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0];
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], desc_bcount[19:0]};
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];
                c2s_desc_num = (c2s_desc_num + 1) % desc_count;
                left_bcount = xfer_bcount - desc_bcount;
                offset = desc_bcount;
                while (left_bcount >0) begin
                    bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
                    if (left_bcount >= desc_max)
                        desc_bcount = desc_max;
                    else
                        desc_bcount = left_bcount;
                    if (left_bcount > desc_max)
                        control_flags = {1'b0, 1'b0, 6'h0};
                    else
                        control_flags = {1'b0, 1'b1, 6'h0};
                    `BFM_MEM[bfm_dword_addr+0] = 32'h0;
                    `BFM_MEM[bfm_dword_addr+3] = 32'h0;
                    `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], desc_bcount[19:0]};
                    `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + offset;
                    `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];
                    c2s_desc_num = (c2s_desc_num + 1) % desc_count;
                    left_bcount = left_bcount - desc_bcount;
                    offset = offset + desc_bcount;
                end

                // Start the DMA engine
               `MEM_WRITE_DWORD (3'b000, c2s_reg_sdp, c2s_desc_base + (c2s_desc_num * 32'h20), 4'hf);

                // wait for interrupt
                wait_int(dut_bdf, g3_c2s_int_vector[k], 32'd4000, done);
                // clear interrupt
                `MEM_WRITE_DWORD (3'b000, c2s_reg_cst, 32'hff, 4'h1);

                // Wait for descriptor to finish
                while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
                    @(posedge clk);

                // Check Data
                for (j=system_addr[23:0]; j<system_addr[23:0]+xfer_bcount; j=j+1) begin
                    read_data = `BFM_MEM[j >> 2];
                    case (j % 4)
                        0 : byteval = read_data[7:0];
                        1 : byteval = read_data[15:8];
                        2 : byteval = read_data[23:16];
                        default : byteval = read_data[31:24];
                    endcase
                    if (byteval != (j % 256)) begin
                        $display ("%m : ERROR : Address == %h : Expected Data == %h, memory -- %h (time %t)",j, (j % 256), byteval, $time);
                        `INC_ERRORS;
                    end
                end

            end

            if (DMA_ADR_PKT_EXTRAS == 1) begin

                // Do a large DMA in each direction
                // S2C
                system_addr = bfm_bar1 + 64'h1003;
                card_addr   = 36'h413;
                xfer_bcount = 32'h6000;

                // Select DMA destination as memory
                `MEM_WRITE_DWORD (3'b000, g3_s2c_pat_base[k], 32'h00000004, 4'hf);
                `MEM_READ_DWORD  (3'b000, g3_s2c_pat_base[k], 32'h00000004, 4'hf, read_data);

                // Write descriptor for s2c
                first_bcount = 20'h5;
                control_flags = {1'b1, 1'b0, 6'h0};
                bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, first_bcount}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0];       // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], first_bcount}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
                s2c_desc_num = (s2c_desc_num + 1) % desc_count;
                control_flags = {1'b0, 1'b1, 6'h1};
                bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, xfer_bcount[19:0] - first_bcount}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0] + first_bcount;       // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], xfer_bcount[19:0] - first_bcount}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + first_bcount;    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
                s2c_desc_num = (s2c_desc_num + 1) % desc_count;

                // Initialize data memory
                write_data = 32'h0;
                for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                    `BFM_MEM[j] = write_data;
                    write_data = write_data + 1;
                end

                // Start the DMA engine
                `MEM_WRITE_DWORD (3'b000, s2c_reg_sdp, s2c_desc_base + (s2c_desc_num * 32'h20), 4'hf);

                // Wait for descriptor to finish
                while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
                    @(posedge clk);

                // C2S
                system_addr = bfm_bar1 + 64'h3003;
                xfer_bcount = 32'h6000;

                // Select DMA destination as memory
                `MEM_WRITE_DWORD (3'b000, g3_c2s_pat_base[k], 32'h00000004, 4'hf);
                `MEM_READ_DWORD  (3'b000, g3_c2s_pat_base[k], 32'h00000004, 4'hf, read_data);

                // Write descriptor for c2s
                first_bcount = 20'h5;
                second_bcount = 20'h197;
                control_flags = {1'b1, 1'b0, 6'h0};
                bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = 32'h0;             // {C2SDescStatusFlags[7:0], Reserved[3:0], C2SDescByteCount[19:0]} - Status so clear
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0];   // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], first_bcount}; // {C2SDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];     // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];     // System Address[63:32]
                c2s_desc_num = (c2s_desc_num + 1) % desc_count;
                control_flags = {1'b0, 1'b0, 6'h0};
                bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = 32'h0;
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0] + first_bcount;       // DescCardAddr
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], second_bcount}; // {C2SDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + first_bcount;    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
                c2s_desc_num = (c2s_desc_num + 1) % desc_count;
                control_flags = {1'b0, 1'b1, 6'h1};
                bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = 32'h0;
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0] + first_bcount + second_bcount;       // DescCardAddr
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], xfer_bcount[19:0] - first_bcount - second_bcount}; // {C2SDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0] + first_bcount + second_bcount;    // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];    // System Address[63:32]
                c2s_desc_num = (c2s_desc_num + 1) % desc_count;

                // Initialize data memory
                for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                    `BFM_MEM[j] = 32'h0;
                end

                // Start the DMA engine
                `MEM_WRITE_DWORD (3'b000, c2s_reg_sdp, c2s_desc_base + (c2s_desc_num * 32'h20), 4'hf);

                // Wait for descriptor to finish
                while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
                    @(posedge clk);

                // Check memory
                write_data = 32'h0;
                for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                    if (`BFM_MEM[j] != write_data) begin
                        $display  ("%m : ERROR: Address == %h : Expected Data == %h, memory == %h (time %t)", j, write_data, `BFM_MEM[j], $time);
                        `INC_ERRORS;
                    end
                    write_data = write_data + 1;
                end

                // Now do a large Loopback DMA (non-addressed)
                system_addr = bfm_bar1 + 64'h1000;
                xfer_bcount = 32'h6000;

                // Select DMA destination as packet
                `MEM_WRITE_DWORD (3'b000, g3_s2c_pat_base[k], 32'h00000002, 4'hf);
                `MEM_READ_DWORD  (3'b000, g3_s2c_pat_base[k], 32'h00000002, 4'hf, read_data);

                // Write descriptor for s2c
                control_flags = {1'b1, 1'b1, 6'h0};             // One descriptor transfer (eop is true)
                bfm_dword_addr = (s2c_desc_base[23:0] >> 2) + (s2c_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = {8'h0, 4'h0, xfer_bcount[19:0]}; // {S2CDescStatusFlags[7:0], Reserved[3:0], S2CDescByteCount[19:0]} - Status so clear except bcount which is bytes to use in this descriptor
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0]; // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], xfer_bcount[19:0]}; // {S2CDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];     // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];     // System Address[63:32]
                s2c_desc_num = (s2c_desc_num + 1) % desc_count;

                // Initialize data memory
                write_data = 32'h0;
                for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                    `BFM_MEM[j] = write_data;
                    write_data = write_data + 1;
                end

                // Start the DMA engine
                `MEM_WRITE_DWORD (3'b000, s2c_reg_sdp, s2c_desc_base + (s2c_desc_num * 32'h20), 4'hf);

                system_addr = bfm_bar1 + 64'h13000;
                xfer_bcount = 32'h6000;

                // Select DMA source as packet
                `MEM_WRITE_DWORD (3'b000, g3_c2s_pat_base[k], 32'h00000002, 4'hf);
                `MEM_READ_DWORD  (3'b000, g3_c2s_pat_base[k], 32'h00000002, 4'hf, read_data);

                // Write descriptor for c2s
                control_flags = {1'b1, 1'b1, 6'h0};             // One descriptor transfer (eop is true)
                bfm_dword_addr = (c2s_desc_base[23:0] >> 2) + (c2s_desc_num * 8);
                `BFM_MEM[bfm_dword_addr+0] = 32'h0; // {C2SDescStatusFlags[7:0], Reserved[3:0], C2SDescByteCount[19:0]} - Status so clear
                `BFM_MEM[bfm_dword_addr+3] = card_addr[31:0]; // DescCardAddr; unused
                `BFM_MEM[bfm_dword_addr+4] = {control_flags[7:0], card_addr[35:32], xfer_bcount[19:0]}; // {C2SDescControlFlags[7:0], DescCardAddr[35:32], DescByteCount[19:0]} - Control
                `BFM_MEM[bfm_dword_addr+5] = system_addr[31: 0];     // System Address[31: 0]
                `BFM_MEM[bfm_dword_addr+6] = system_addr[63:32];     // System Address[63:32]
                c2s_desc_num = (c2s_desc_num + 1) % desc_count;

                // Initialize data memory
                for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                    `BFM_MEM[j] = 32'h0;
                end

                // Start the DMA engine
                `MEM_WRITE_DWORD (3'b000, c2s_reg_sdp, c2s_desc_base + (c2s_desc_num * 32'h20), 4'hf);

                // Wait for descriptor to finish
                while (((`BFM_MEM[bfm_dword_addr+0] & 32'hff000000) == 0))
                    @(posedge clk);

                // Check memory
                write_data = 32'h0;
                for (j=system_addr[23:0]/4; j<(system_addr[23:0] + xfer_bcount)/4; j=j+1) begin
                    if (`BFM_MEM[j] != write_data) begin
                        $display  ("%m : ERROR: Address == %h : Expected Data == %h, memory == %h (time %t)", j, write_data, `BFM_MEM[j], $time);
                        `INC_ERRORS;
                    end
                    write_data = write_data + 1;
                end
            end // extras

            begin
                // Read to flush any pending interrupts/status
                `MEM_READ_DWORD  (3'b000, s2c_reg_cst, 32'h00000000, 4'h0, read_data);
                `MEM_READ_DWORD  (3'b000, c2s_reg_cst, 32'h00000000, 4'h0, read_data);

                // Disable DMA Engines & Interrupts
                `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'h00000000,    4'hf);
                `MEM_WRITE_DWORD (3'b000, c2s_reg_cst, 32'h00000000,    4'hf);
                // Clear abort status
                `MEM_WRITE_DWORD (3'b000, s2c_reg_cst, 32'h000000fe,    4'hf);
                `MEM_WRITE_DWORD (3'b000, c2s_reg_cst, 32'h000000fe,    4'hf);
            end
          end   // packet engines
          else
          begin
            $display  ("%m : DMA Engine Pair %d skipped; one or both engines in the pair are not Packet DMA Engines", k);
          end
        end     // DMA pairs
end
endtask



    // ----------------------------
    // RUN_DMA_MED_UNALIGNED_PKT_G3

    // A Quick test that checks small unaligned packets are handled correctly;
    //   Requires the Pattern Generator and Pattern Checker Loopback functionality
    //   from a pair of DMA Engines.

parameter RUN_DMA_MED_UNALIGNED_PKT_G3 = 0;

task dma_med_unaligned_pkt_g3;

    integer         a;
    reg     [31:0]  axi_pcie_n;

    reg     [31:0]  circular_buffer_size;
    reg     [31:0]  desc_max_bsize;
    reg     [31:0]  desc_min_bsize;
    reg     [31:0]  desc_max_num;
    integer         desc_size;
    reg     [31:0]  bfm_memory_size;

    reg     [31:0]  pkt_max_bsize;
    reg     [31:0]  pkt_num_packets;

    integer     i;

    reg     [63:0]  s2c_rbuf_system_addr;
    reg     [63:0]  s2c_rbuf_system_bsize;
    reg     [63:0]  s2c_rbuf_desc_ptr;
    reg     [31:0]  s2c_rbuf_desc_max_bsize;
    reg     [31:0]  s2c_rbuf_desc_min_bsize;
    reg     [31:0]  s2c_rbuf_desc_max_num;

    reg     [63:0]  c2s_rbuf_system_addr;
    reg     [63:0]  c2s_rbuf_system_bsize;
    reg     [63:0]  c2s_rbuf_desc_ptr;
    reg     [31:0]  c2s_rbuf_desc_max_bsize;
    reg     [31:0]  c2s_rbuf_desc_min_bsize;
    reg     [31:0]  c2s_rbuf_desc_max_num;

    reg     [19:0]  byte_alignment;

begin
      $display  ("%m : ** Packet DMA Engine - Medium Unaligned Loopback Test at time %0t **", $time);

      for (a=0; a<1; a=a+1)
      begin
        axi_pcie_n = a;

        circular_buffer_size = 32'h00001000;        // Circular buffer size to use (32'h00001000 == 4 KByte)
        desc_max_bsize       = 32'h00000240;        // Max Descriptor size to use when making circular buffer (32'h00001000 == 4 KByte)
        desc_min_bsize       = 32'h0000013c;        // Max Descriptor size to use when making circular buffer (32'h00001000 == 4 KByte)
        desc_max_num         = 32'h00000010;        // Max number of Descriptors to use for the Circular Buffers
        desc_size            = 32;                  // Descriptors are 32 bytes each
        bfm_memory_size      = `BFM_MEM_BSIZE;      // Size of BFM memory; don't want to exceed
        pkt_max_bsize        = desc_max_bsize * 3;  // Maximum packet size in bytes; packet size is randomized up to this size
        pkt_num_packets      = 64;                  // Number of packets to transmit/receive; this many packets are transmitted and received before ending the task

        byte_alignment       = 20'h1;               // Use 1-byte DWORD alignment; note alignments < 4 bytes always use incrementing byte byte pattern for data

        // Run test for all pairs of DMA Engines
        for (i=0; i<g3_num_com; i=i+1)
        begin
            if ((g3_c2s_pkt_block_n[i] == 1'b1) && (g3_s2c_pkt_block_n[i] == 1'b1)) // Only run test if the engine pair are both Packet DMA
            begin
                // Place BFM DMA and Descriptor regions adjacent to one another
                s2c_rbuf_system_addr    = bfm_bar0 + 2;
                s2c_rbuf_system_bsize   = circular_buffer_size - 2;

                c2s_rbuf_system_addr    = s2c_rbuf_system_addr + s2c_rbuf_system_bsize;
                c2s_rbuf_system_bsize   = circular_buffer_size;

                s2c_rbuf_desc_ptr       = c2s_rbuf_system_addr + c2s_rbuf_system_bsize;
                s2c_rbuf_desc_max_bsize = desc_max_bsize;
                s2c_rbuf_desc_min_bsize = desc_min_bsize;
                s2c_rbuf_desc_max_num   = desc_max_num;

                c2s_rbuf_desc_ptr       = s2c_rbuf_desc_ptr + (desc_max_num * desc_size);
                c2s_rbuf_desc_max_bsize = desc_max_bsize;
                c2s_rbuf_desc_min_bsize = desc_min_bsize;
                c2s_rbuf_desc_max_num   = desc_max_num;

                if (((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA BFM Memory end address offset == %x) exceeds (BFM memory size == %x)", ((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)), bfm_memory_size);
                else
                begin
                    // DMA Engine Task for Packet DMA Loopback
                    `DO_PKT_DMA_LOOPBACK(s2c_rbuf_system_addr,      // [63:0] s2c_rbuf_system_addr    : S2C DMA Ring Buffer : Starting System Address
                                         s2c_rbuf_system_bsize,     // [63:0] s2c_rbuf_system_bsize   : S2C DMA Ring Buffer : Buffer size in bytes
                                         s2c_rbuf_desc_ptr,         // [63:0] s2c_rbuf_desc_ptr       : S2C DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         s2c_rbuf_desc_max_bsize,   // [31:0] s2c_rbuf_desc_max_bsize : S2C DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         s2c_rbuf_desc_min_bsize,   // [31:0] s2c_rbuf_desc_min_bsize : S2C DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         s2c_rbuf_desc_max_num,     // [31:0] s2c_rbuf_desc_max_num   : S2C DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         c2s_rbuf_system_addr,      // [63:0] c2s_rbuf_system_addr    : C2S DMA Ring Buffer : Starting System Address
                                         c2s_rbuf_system_bsize,     // [63:0] c2s_rbuf_system_bsize   : C2S DMA Ring Buffer : Buffer size in bytes
                                         c2s_rbuf_desc_ptr,         // [63:0] c2s_rbuf_desc_ptr       : C2S DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         c2s_rbuf_desc_max_bsize,   // [31:0] c2s_rbuf_desc_max_bsize : C2S DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         c2s_rbuf_desc_min_bsize,   // [31:0] c2s_rbuf_desc_min_bsize : C2S DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         c2s_rbuf_desc_max_num,     // [31:0] c2s_rbuf_desc_max_num   : C2S DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         byte_alignment,            // [19:0] byte_alignment          : Byte alignment to enforce for Packet Length, Descriptor System Addresses, and Descriptor Byte Counts; must be a positive power of 2
                                         g3_com_bar,                // [63:0] reg_com_bar             : DMA Common Register Block Base Address; needed to set global enables
                                         int_mode,                  // [1:0]  int_mode                : Interrupt mode in use for this engine pair: 2 == MSI-X, 1 == MSI, 0 == Legacy
                                         g3_s2c_reg_base[i],        // [63:0] reg_s2c_dma_bar         : S2C DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_s2c_pat_base[i],        // [63:0] reg_s2c_pat_bar         : S2C DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_s2c_int_vector[i],      // [11:0] s2c_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         g3_c2s_reg_base[i],        // [63:0] reg_c2s_dma_bar         : C2S DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_c2s_pat_base[i],        // [63:0] reg_c2s_pat_bar         : C2S DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_c2s_int_vector[i],      // [11:0] c2s_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         pkt_max_bsize,             // [31:0] pkt_max_bsize           : Maximum packet size in bytes; packet size is randomize up to this size
                                         pkt_num_packets,           // [31:0] pkt_num_packets         : Number of packets to transmit/receive; this many packets are transmitted and received before enging the task
                                         32'hf0000000,              // [31:0] pat_user_seed           : Seed value for user_status/control pattern; subsequent data continues from packet to packet
                                         3'h3,                      // [ 2:0] pat_user_type           : User status/control pattern: 0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD
                                         32'h03020100,              // [31:0] pat_data_seed           : Seed value for data pattern; subsequent data continues from packet to packet
                                         3'h1,                      // [ 2:0] pat_data_type           : Data pattern:                0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD        // Initial value for user_control/status
                                         32'd2,                     // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                         1'b1,                      //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                         1'b1,                      //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                         32'h00010000,              // [31:0] timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                         check_status,
                                         axi_pcie_n);               // 0==PCIe, 1==AXI w/PCIe Int, 2==AXI w/Edge AXI Int; 3==AXI w/Level AXI Int
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine Pair %d since one or both engines are not Packet DMA Engines; S2C_Cap=%x, C2S_Cap=0x%x", i, g3_s2c_cap[i], g3_c2s_cap[i]);
            end
        end
      end
end // RUN_DMA_MED_UNALIGNED_PKT_G3
endtask



    // -------------------
    // RUN_DMA_LONG_PKT_G3

    // A Quick test that checks for basic functionality of large packet sizes.
    //
    // Test C2S Packet DMA using packet sizes above, equal, and below Descriptor size; choose Descriptor
    //   size to be above C2S Streaming FIFO depth (typical minimum is 2KBytes) to test operation when
    //   packet data rather than packet quantity throttle the availability of the C2S Packet Streaming FIFO.

parameter RUN_DMA_LONG_PKT_G3 = 0;

task dma_long_pkt_g3;

    reg [63:0]  system_max_bsize;    // BFM memory size to reserve for each engine; each engine needs its own area to keep from conflicting with other engines
    reg [63:0]  desc_bsize;          // Descriptor typical byte size
    reg [63:0]  desc_max_bsize;      // BFM memory size to reserve for each engine; each engine needs its own area to keep from conflicting with other engines
    reg         done_wait;           // 1-wait for DMA completion interrupt; 0-dont wait
    reg [31:0]  bfm_memory_size;

    integer     i;
    reg [63:0]  reg_base;
    reg [63:0]  pat_base;
    reg         pkt_block_n;
    reg         cap;
    reg [11:0]  int_vector;

    reg [63:0]  system_addr;    // Starting System Address
    reg [31:0]  desc_ptr;       // DMA Queue Base Address
    reg [31:0]  total_bcount;

begin
        $display  ("%m : ** Long Packet DMA Engine Test at time %0t **", $time);

        system_max_bsize = 64'h080000;                               // 512KB BFM memory space to reserve for each engine's DMA data
        desc_bsize       = 64'h008000;                               // 32KB typical Descriptor size
        desc_max_bsize   = ((system_max_bsize/desc_bsize) + 2) * 32; // BFM memory space to reserve for each engine's Descriptors (each Descriptor takes 32 bytes); +2 for partial start and ending Descriptors
        done_wait        =      1'b1; // Wait for DMA to complete and check for correct DMA completion
        bfm_memory_size  = `BFM_MEM_BSIZE;

        // Run test for all System to Card and Card to System Engines
        for (i=0; i<g3_num_s2c+g3_num_c2s; i=i+1)
        begin
            if (i<g3_num_s2c) // Current test is for System to Card DMA Engine
            begin
                reg_base    = g3_s2c_reg_base   [i];
                pat_base    = g3_s2c_pat_base   [i];
                pkt_block_n = g3_s2c_pkt_block_n[i];
                cap         = g3_s2c_cap        [i];
                int_vector  = g3_s2c_int_vector [i];
            end
            else // Current test is for Card to System DMA Engine
            begin
                reg_base    = g3_c2s_reg_base   [i-g3_num_s2c];
                pat_base    = g3_c2s_pat_base   [i-g3_num_s2c];
                pkt_block_n = g3_c2s_pkt_block_n[i-g3_num_s2c];
                cap         = g3_c2s_cap        [i-g3_num_s2c];
                int_vector  = g3_c2s_int_vector [i-g3_num_s2c];
            end

            if (pkt_block_n == 1'b1)
            begin
                system_addr   = bfm_bar0 + (i * system_max_bsize);                                 // Use unique, contiguous system addresses for each engine
                desc_ptr      = bfm_bar0 + ((g3_num_s2c+g3_num_c2s) * system_max_bsize) + (i * desc_max_bsize); // Keep Descriptors above DMA memory area; use unique system address for each engine

                if ((system_addr - bfm_bar0) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA data buffer end address offset == %x) exceeds (BFM memory size == %x)", (system_addr - bfm_bar0), bfm_memory_size);
                else if ((desc_ptr - bfm_bar0) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA Descriptor table end address offset == %x) exceeds (BFM memory size == %x)", (desc_ptr - bfm_bar0), bfm_memory_size);
                else
                begin
                    // Ramp up packet size (below Desc size, at Desc Size, above Desc Size; repeat twice to include for large->small packet size transition)
                    if (i<g3_num_s2c) // Current test is for System to Card DMA Engine
                        $display  ("%m : S2C : Ramp Up Packet Size - Packet DMA Engine %1d of %1d", (i+1), (g3_num_s2c+g3_num_c2s));
                    else
                        $display  ("%m : C2S : Ramp Up Packet Size - Packet DMA Engine %1d of %1d", (i+1), (g3_num_s2c+g3_num_c2s));
                    `DO_PKT_DMA_CHAIN(system_addr,      // [63:0] system_addr (DMA data buffer starting address in BFM system memory)
                                      system_max_bsize, // [63:0] system_max_bsize (Max allowed DMA data buffer size in bytes)
                                      desc_ptr,         // [63:0] desc_ptr (DMA Descriptor table start address in BFM system memory)
                                      desc_max_bsize,   // [63:0] desc_max_bsize (Max allowed DMA Descriptor table size in bytes)
                                      desc_bsize,       // [63:0] desc_bsize (Max Descriptor size; the DMA buffer is fragemented into Descriptors on this address boundary)
                                      g3_com_bar,       // [63:0] reg_com_bar (DMA Back-End Common Register Block Base Address)
                                      reg_base,         // [63:0] reg_dma_bar (DMA Engine Register Block Base Address; selects which engine to use)
                                      pat_base,         // [63:0] reg_pat_bar (DMA Engine Pattern Generator Register Block Base Address; selects which pattern generator to use)
                                      int_vector,       // [11:0] int_vector (Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine)
                                      2'h3,             // [1:0]  pat_length_entries (Number of packet length table entries to use = pat_length_entries+1
                                      3'h3,             // [2:0]  pat_data_type (Data pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b0,             //        pat_data_cont (1==Continue data pattern accross packet boundaries; 0==restart data pattern for each packet)
                                      3'h3,             // [2:0]  pat_user_status_type (UserStatus pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b1,             //        pat_user_status_cont (1==Continue user_status pattern accross packet boundaries; 0==restart user_status pattern for each packet)
                                      8'h1,             // [7:0]  pat_active_clocks   (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      8'h0,             // [7:0]  pat_inactive_clocks (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      32'h8,            // [31:0] pat_num_packets (number of packets to generate)
                                      32'h00000000,     // [31:0] pat_data_seed (data pattern starting seed value)
                                      32'hF0000000,     // [31:0] pat_user_status_seed (user_status pattern starting seed value)
                                      desc_bsize/2,     // [19:0] pat_length0 (byte length of generated packets; packet length table[0]; always used)
                                      desc_bsize,       // [19:0] pat_length1 (byte length of generated packets; packet length table[1]; used if pat_length_entries > 0)
                                      desc_bsize*2,     // [19:0] pat_length2 (byte length of generated packets; packet length table[2]; used if pat_length_entries > 1)
                                      desc_bsize*3,     // [19:0] pat_length3 (byte length of generated packets; packet length table[3]; used if pat_length_entries > 2)
                                      32'd2,            // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                      1'b1,             //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                      1'b1,             //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                      32'h00010000,     //        timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                      check_status,
                                      total_bcount);    // [31:0] total number of bytes transferred

                    // Ramp down packet size (above, Dec size, at Desc Size, below Desc Size; repeat twice to include for small->large packet size transition)
                    if (i<g3_num_s2c) // Current test is for System to Card DMA Engine
                        $display  ("%m : S2C : Ramp Down Packet Size - Packet DMA Engine %1d of %1d", (i+1), (g3_num_s2c+g3_num_c2s));
                    else
                        $display  ("%m : C2S : Ramp Down Packet Size - Packet DMA Engine %1d of %1d", (i+1), (g3_num_s2c+g3_num_c2s));
                    `DO_PKT_DMA_CHAIN(system_addr,      // [63:0] system_addr (DMA data buffer starting address in BFM system memory)
                                      system_max_bsize, // [63:0] system_max_bsize (Max allowed DMA data buffer size in bytes)
                                      desc_ptr,         // [63:0] desc_ptr (DMA Descriptor table start address in BFM system memory)
                                      desc_max_bsize,   // [63:0] desc_max_bsize (Max allowed DMA Descriptor table size in bytes)
                                      desc_bsize,       // [63:0] desc_bsize (Max Descriptor size; the DMA buffer is fragemented into Descriptors on this address boundary)
                                      g3_com_bar,       // [63:0] reg_com_bar (DMA Back-End Common Register Block Base Address)
                                      reg_base,         // [63:0] reg_dma_bar (DMA Engine Register Block Base Address; selects which engine to use)
                                      pat_base,         // [63:0] reg_pat_bar (DMA Engine Pattern Generator Register Block Base Address; selects which pattern generator to use)
                                      int_vector,       // [11:0] int_vector (Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine)
                                      2'h3,             // [1:0]  pat_length_entries (Number of packet length table entries to use = pat_length_entries+1
                                      3'h3,             // [2:0]  pat_data_type (Data pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b0,             //        pat_data_cont (1==Continue data pattern accross packet boundaries; 0==restart data pattern for each packet)
                                      3'h3,             // [2:0]  pat_user_status_type (UserStatus pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b1,             //        pat_user_status_cont (1==Continue user_status pattern accross packet boundaries; 0==restart user_status pattern for each packet)
                                      8'h1,             // [7:0]  pat_active_clocks   (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      8'h0,             // [7:0]  pat_inactive_clocks (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      32'h8,            // [31:0] pat_num_packets (number of packets to generate)
                                      32'h10000000,     // [31:0] pat_data_seed (data pattern starting seed value)
                                      32'hF1000000,     // [31:0] pat_user_status_seed (user_status pattern starting seed value)
                                      desc_bsize*3,     // [19:0] pat_length0 (byte length of generated packets; packet length table[0]; always used)
                                      desc_bsize*2,     // [19:0] pat_length1 (byte length of generated packets; packet length table[1]; used if pat_length_entries > 0)
                                      desc_bsize,       // [19:0] pat_length2 (byte length of generated packets; packet length table[2]; used if pat_length_entries > 1)
                                      desc_bsize/2,     // [19:0] pat_length3 (byte length of generated packets; packet length table[3]; used if pat_length_entries > 2)
                                      32'd2,            // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                      1'b1,             //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                      1'b1,             //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                      32'h00010000,     //        timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                      check_status,
                                      total_bcount);    // [31:0] total number of bytes transferred

                    // Rapid changes in Packet size above and below Desc size
                    if (i<g3_num_s2c) // Current test is for System to Card DMA Engine
                        $display  ("%m : S2C : Rapid Changes in Packet Size - Packet DMA Engine %1d of %1d", (i+1), (g3_num_s2c+g3_num_c2s));
                    else
                        $display  ("%m : C2S : Rapid Changes in Packet Size - Packet DMA Engine %1d of %1d", (i+1), (g3_num_s2c+g3_num_c2s));
                    `DO_PKT_DMA_CHAIN(system_addr,      // [63:0] system_addr (DMA data buffer starting address in BFM system memory)
                                      system_max_bsize, // [63:0] system_max_bsize (Max allowed DMA data buffer size in bytes)
                                      desc_ptr,         // [63:0] desc_ptr (DMA Descriptor table start address in BFM system memory)
                                      desc_max_bsize,   // [63:0] desc_max_bsize (Max allowed DMA Descriptor table size in bytes)
                                      desc_bsize,       // [63:0] desc_bsize (Max Descriptor size; the DMA buffer is fragemented into Descriptors on this address boundary)
                                      g3_com_bar,       // [63:0] reg_com_bar (DMA Back-End Common Register Block Base Address)
                                      reg_base,         // [63:0] reg_dma_bar (DMA Engine Register Block Base Address; selects which engine to use)
                                      pat_base,         // [63:0] reg_pat_bar (DMA Engine Pattern Generator Register Block Base Address; selects which pattern generator to use)
                                      int_vector,       // [11:0] int_vector (Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine)
                                      2'h3,             // [1:0]  pat_length_entries (Number of packet length table entries to use = pat_length_entries+1
                                      3'h3,             // [2:0]  pat_data_type (Data pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b0,             //        pat_data_cont (1==Continue data pattern accross packet boundaries; 0==restart data pattern for each packet)
                                      3'h3,             // [2:0]  pat_user_status_type (UserStatus pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                      1'b1,             //        pat_user_status_cont (1==Continue user_status pattern accross packet boundaries; 0==restart user_status pattern for each packet)
                                      8'h1,             // [7:0]  pat_active_clocks   (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      8'h0,             // [7:0]  pat_inactive_clocks (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                      32'h8,            // [31:0] pat_num_packets (number of packets to generate)
                                      32'h20000000,     // [31:0] pat_data_seed (data pattern starting seed value)
                                      32'hF2000000,     // [31:0] pat_user_status_seed (user_status pattern starting seed value)
                                      desc_bsize*4,     // [19:0] pat_length0 (byte length of generated packets; packet length table[0]; always used)
                                      desc_bsize/4,     // [19:0] pat_length1 (byte length of generated packets; packet length table[1]; used if pat_length_entries > 0)
                                      desc_bsize*2,     // [19:0] pat_length2 (byte length of generated packets; packet length table[2]; used if pat_length_entries > 1)
                                      desc_bsize/2,     // [19:0] pat_length3 (byte length of generated packets; packet length table[3]; used if pat_length_entries > 2)
                                      32'd2,            // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                      1'b1,             //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                      1'b1,             //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                      32'h00010000,     //        timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                      check_status,
                                      total_bcount);    // [31:0] total number of bytes transferred
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine %d since its not a Packet DMA Engine; Capabilities=%x", i, cap);
            end
        end
end // RUN_DMA_LONG_PKT_G3
endtask



    // -------------------------
    // RUN_DMA_LONG_PKT_LPBK_G3

    // An extended test that test functionality of Packet DMA using
    //   built-in packet Loopback.

parameter RUN_DMA_LONG_PKT_LPBK_G3 = 0;

task dma_long_pkt_lpbk_g3;

    integer         a;
    reg     [31:0]  axi_pcie_n;

    reg     [31:0]  circular_buffer_size;
    reg     [31:0]  desc_max_bsize;
    reg     [31:0]  desc_min_bsize;
    reg     [31:0]  desc_max_num;

    integer         desc_size;
    reg     [31:0]  bfm_memory_size;

    reg     [31:0]  pkt_max_bsize;
    reg     [31:0]  pkt_num_packets;

    integer     i;

    reg     [63:0]  s2c_rbuf_system_addr;
    reg     [63:0]  s2c_rbuf_system_bsize;
    reg     [63:0]  s2c_rbuf_desc_ptr;
    reg     [31:0]  s2c_rbuf_desc_max_bsize;
    reg     [31:0]  s2c_rbuf_desc_min_bsize;
    reg     [31:0]  s2c_rbuf_desc_max_num;

    reg     [63:0]  c2s_rbuf_system_addr;
    reg     [63:0]  c2s_rbuf_system_bsize;
    reg     [63:0]  c2s_rbuf_desc_ptr;
    reg     [31:0]  c2s_rbuf_desc_max_bsize;
    reg     [31:0]  c2s_rbuf_desc_min_bsize;
    reg     [31:0]  c2s_rbuf_desc_max_num;

    reg     [19:0]  byte_alignment;

begin
      $display  ("%m : ** Long Packet DMA Engine Loopback Test at time %0t **", $time);

      for (a=0; a<1; a=a+1)
      begin
        axi_pcie_n = a;

        circular_buffer_size = 32'h00040000;        // Circular buffer size to use (32'h00004000 == 256 KByte)
        desc_max_bsize       = 32'h00004000;        // Max Descriptor size to use when making circular buffer (32'h00004000 == 16 KByte)
        desc_max_num         = 32'h00000040;        // Max number of Descriptors to use for the Circular Buffers
        desc_size            = 32;                  // Descriptors are 32 bytes each
        bfm_memory_size      = `BFM_MEM_BSIZE;      // Size of BFM memory; don't want to exceed

        pkt_max_bsize        = desc_max_bsize * 5;  // Maximum packet size in bytes; packet size is randomized up to this size
        desc_min_bsize       = CORE_BE_WIDTH;
        pkt_num_packets      = 8;                   // Number of packets to transmit/receive; this many packets are transmitted and received before ending the task

        // Run test for all pairs of DMA Engines
        for (i=0; i<g3_num_com; i=i+1)
        begin
            if ((g3_c2s_pkt_block_n[i] == 1'b1) && (g3_s2c_pkt_block_n[i] == 1'b1)) // Only run test if the engine pair are both Packet DMA
            begin
              // Place BFM DMA and Descriptor regions adjacent to one another
                s2c_rbuf_system_addr    = bfm_bar0;
                s2c_rbuf_system_bsize   = circular_buffer_size;

                c2s_rbuf_system_addr    = s2c_rbuf_system_addr + s2c_rbuf_system_bsize;
                c2s_rbuf_system_bsize   = circular_buffer_size;

                s2c_rbuf_desc_ptr       = c2s_rbuf_system_addr + c2s_rbuf_system_bsize;
                s2c_rbuf_desc_max_bsize = desc_max_bsize;
                s2c_rbuf_desc_min_bsize = desc_min_bsize;
                s2c_rbuf_desc_max_num   = desc_max_num;

                c2s_rbuf_desc_ptr       = s2c_rbuf_desc_ptr + (desc_max_num * desc_size);
                c2s_rbuf_desc_max_bsize = desc_max_bsize;
                c2s_rbuf_desc_min_bsize = desc_min_bsize;
                c2s_rbuf_desc_max_num   = desc_max_num;

                byte_alignment          = 20'h1;               // Use 1-byte DWORD alignment; note alignments < 4 bytes always use incrementing byte byte pattern for data

                if (((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA BFM Memory end address offset == %x) exceeds (BFM memory size == %x)", ((c2s_rbuf_desc_ptr - bfm_bar0) + (desc_max_num * desc_size)), bfm_memory_size);
                else
                begin
                    $display  ("%m : Testing Packet DMA Engine Pair %1d of %1d", (i+1), g3_num_com);
                    // DMA Engine Task for Packet DMA Loopback
                    `DO_PKT_DMA_LOOPBACK(s2c_rbuf_system_addr,      // [63:0] s2c_rbuf_system_addr    : S2C DMA Ring Buffer : Starting System Address
                                         s2c_rbuf_system_bsize,     // [63:0] s2c_rbuf_system_bsize   : S2C DMA Ring Buffer : Buffer size in bytes
                                         s2c_rbuf_desc_ptr,         // [63:0] s2c_rbuf_desc_ptr       : S2C DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         s2c_rbuf_desc_max_bsize,   // [31:0] s2c_rbuf_desc_max_bsize : S2C DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         s2c_rbuf_desc_min_bsize,   // [31:0] s2c_rbuf_desc_min_bsize : S2C DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         s2c_rbuf_desc_max_num,     // [31:0] s2c_rbuf_desc_max_num   : S2C DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         c2s_rbuf_system_addr,      // [63:0] c2s_rbuf_system_addr    : C2S DMA Ring Buffer : Starting System Address
                                         c2s_rbuf_system_bsize,     // [63:0] c2s_rbuf_system_bsize   : C2S DMA Ring Buffer : Buffer size in bytes
                                         c2s_rbuf_desc_ptr,         // [63:0] c2s_rbuf_desc_ptr       : C2S DMA Ring Buffer : Starting System Address where Descriptors will be located
                                         c2s_rbuf_desc_max_bsize,   // [31:0] c2s_rbuf_desc_max_bsize : C2S DMA Ring Buffer : Maximum size of each Descriptor in bytes
                                         c2s_rbuf_desc_min_bsize,   // [31:0] c2s_rbuf_desc_min_bsize : C2S DMA Ring Buffer : Minimum size of each Descriptor in bytes
                                         c2s_rbuf_desc_max_num,     // [31:0] c2s_rbuf_desc_max_num   : C2S DMA Ring Buffer : Maximum number of Descriptors to implement in Circular buffer
                                         byte_alignment,            // [19:0] byte_alignment          : Byte alignment to enforce for Packet Length, Descriptor System Addresses, and Descriptor Byte Counts; must be a positive power of 2
                                         g3_com_bar,                // [63:0] reg_com_bar             : DMA Common Register Block Base Address; needed to set global enables
                                         int_mode,                  // [1:0]  int_mode                : Interrupt mode in use for this engine pair: 2 == MSI-X, 1 == MSI, 0 == Legacy
                                         g3_s2c_reg_base[i],        // [63:0] reg_s2c_dma_bar         : S2C DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_s2c_pat_base[i],        // [63:0] reg_s2c_pat_bar         : S2C DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_s2c_int_vector[i],      // [11:0] s2c_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         g3_c2s_reg_base[i],        // [63:0] reg_c2s_dma_bar         : C2S DMA Engine Register Block Base Address; chooses which engine will be used; must use a valid pair connected in loopback
                                         g3_c2s_pat_base[i],        // [63:0] reg_c2s_pat_bar         : C2S DMA Engine Pattern Register Block Base Address; must be the pattern generator connected to used DMA Engine
                                         g3_c2s_int_vector[i],      // [11:0] c2s_int_vector          : Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine
                                         pkt_max_bsize,             // [31:0] pkt_max_bsize           : Maximum packet size in bytes; packet size is randomize up to this size
                                         pkt_num_packets,           // [31:0] pkt_num_packets         : Number of packets to transmit/receive; this many packets are transmitted and received before enging the task
                                         32'hf0000000,              // [31:0] pat_user_seed           : Seed value for user_status/control pattern; subsequent data continues from packet to packet
                                         3'h3,                      // [ 2:0] pat_user_type           : User status/control pattern: 0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD
                                         32'he0000000,              // [31:0] pat_data_seed           : Seed value for data pattern; subsequent data continues from packet to packet
                                         3'h3,                      // [ 2:0] pat_data_type           : Data pattern:                0==CONSTANT, 1==INC BYTE, 2==LFSR; 3==INC_DWORD        // Initial value for user_control/status
                                         32'd2,                     // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                         1'b1,                      //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                         1'b1,                      //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                         32'h00010000,              // [31:0] timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                         check_status,
                                         axi_pcie_n);               // 0==PCIe, 1==AXI w/PCIe Int, 2==AXI w/Edge AXI Int; 3==AXI w/Level AXI Int
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine Pair %d since one or both engines are not Packet DMA Engines; S2C_Cap=%x, C2S_Cap=0x%x", i, g3_s2c_cap[i], g3_c2s_cap[i]);
            end
        end
      end
end // RUN_DMA_LONG_PKT_LPBK_G3
endtask



    // --------------------------
    // RUN_DMA_PKT_PAT_GEN_CHK_G3

    // Test for proper operation using the different options of the Packet Generator

parameter RUN_DMA_PKT_PAT_GEN_CHK_G3 = 0;

task dma_pkt_pat_gen_chk_g3;

    reg [63:0]  system_max_bsize;    // BFM memory size to reserve for each engine; each engine needs its own area to keep from conflicting with other engines
    reg [63:0]  desc_max_bsize;      // BFM memory size to reserve for each engine; each engine needs its own area to keep from conflicting with other engines
    reg [63:0]  desc_bsize;          // Descriptor typical byte size
    reg         done_wait;           // 1-wait for DMA completion interrupt; 0-dont wait
    reg [31:0]  bfm_memory_size;

    integer     i;
    reg [63:0]  reg_base;
    reg [63:0]  pat_base;
    reg         pkt_block_n;
    reg         cap;
    reg [11:0]  int_vector;

    reg [63:0]  system_addr;    // Starting System Address
    reg [31:0]  desc_ptr;       // DMA Queue Base Address

    integer     pat_length_entries;
    integer     pat_data_type;
    integer     pat_data_cont;
    integer     pat_inactive_clocks;
    reg [31:0]  data_seed;
    reg [31:0]  total_bcount;

begin
        $display  ("%m : ** Pattern Generator/Checker Test at time %0t **", $time);

        system_max_bsize = 64'h10000;                                // 64KByte BFM memory space to reserve for each engine's DMA data
        desc_bsize       = 64'h00100;                                // Use 256 Byte typical Descriptor size
        desc_max_bsize   = ((system_max_bsize/desc_bsize) + 2) * 32; // BFM memory space to reserve for each engine's Descriptors (each Descriptor takes 32 bytes); +2 for partial start and ending Descriptors
        done_wait        = 1'b1;                                     // Wait for DMA to complete and check for correct DMA completion
        bfm_memory_size  = `BFM_MEM_BSIZE;

        // Walk through Card to System Engines
        for (i=0; i<g3_num_s2c+g3_num_c2s; i=i+1)
        begin
            if (i<g3_num_s2c) // Current test is for System to Card DMA Engine
            begin
                reg_base    = g3_s2c_reg_base   [i];
                pat_base    = g3_s2c_pat_base   [i];
                pkt_block_n = g3_s2c_pkt_block_n[i];
                cap         = g3_s2c_cap        [i];
                int_vector  = g3_s2c_int_vector [i];
            end
            else // Current test is for Card to System DMA Engine
            begin
                reg_base    = g3_c2s_reg_base   [i-g3_num_s2c];
                pat_base    = g3_c2s_pat_base   [i-g3_num_s2c];
                pkt_block_n = g3_c2s_pkt_block_n[i-g3_num_s2c];
                cap         = g3_c2s_cap        [i-g3_num_s2c];
                int_vector  = g3_c2s_int_vector [i-g3_num_s2c];
            end

            if (pkt_block_n == 1'b1)
            begin
                system_addr   = bfm_bar0 + (i * system_max_bsize);                                 // Use unique, contiguous system addresses for each engine
                desc_ptr      = bfm_bar0 + ((g3_num_s2c+g3_num_c2s) * system_max_bsize) + (i * desc_max_bsize); // Keep Descriptors above DMA memory area; use unique system address for each engine

                if ((system_addr - bfm_bar0) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA data buffer end address offset == %x) exceeds (BFM memory size == %x)", (system_addr - bfm_bar0), bfm_memory_size);
                else if ((desc_ptr - bfm_bar0) > bfm_memory_size)
                    $display  ("%m : Skipping test : (DMA Descriptor table end address offset == %x) exceeds (BFM memory size == %x)", (desc_ptr - bfm_bar0), bfm_memory_size);
                else
                begin
                    for (pat_length_entries=0; pat_length_entries<=3; pat_length_entries=pat_length_entries+1)
                    begin
                        for (pat_data_type=0; pat_data_type<=3; pat_data_type=pat_data_type+1)
                        begin
                            for (pat_data_cont=0; pat_data_cont<=1; pat_data_cont=pat_data_cont+1)
                            begin
                                for (pat_inactive_clocks=0; pat_inactive_clocks<8; pat_inactive_clocks=(((pat_inactive_clocks+1)*2)-1)) // Steps through data rates: 1/1, 1/2, 1/4, to 1/8
                                begin
                                    data_seed = (pat_length_entries + 1) * (pat_data_type + 1) * (pat_data_cont + 1) * (pat_inactive_clocks+1);

                                    // DMA Engine Task for Packet DMA
                                    `DO_PKT_DMA_CHAIN(system_addr,                // [63:0] system_addr (DMA data buffer starting address in BFM system memory)
                                                      system_max_bsize,           // [63:0] system_max_bsize (Max allowed DMA data buffer size in bytes)
                                                      desc_ptr,                   // [63:0] desc_ptr (DMA Descriptor table start address in BFM system memory)
                                                      desc_max_bsize,             // [63:0] desc_max_bsize (Max allowed DMA Descriptor table size in bytes)
                                                      desc_bsize,                 // [63:0] desc_bsize (Max Descriptor size; the DMA buffer is fragemented into Descriptors on this address boundary)
                                                      g3_com_bar,                 // [63:0] reg_com_bar (DMA Back-End Common Register Block Base Address)
                                                      reg_base,                   // [63:0] reg_dma_bar (DMA Engine Register Block Base Address; selects which engine to use)
                                                      pat_base,                   // [63:0] reg_pat_bar (DMA Engine Pattern Generator Register Block Base Address; selects which pattern generator to use)
                                                      int_vector,                 // [11:0] int_vector (Interrupt vector # (MSI-X/MSI only) to watch for interrupts for this engine)
                                                      pat_length_entries[1:0],    // [1:0]  pat_length_entries (Number of packet length table entries to use = pat_length_entries+1
                                                      pat_data_type[2:0],         // [2:0]  pat_data_type (Data pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                                      pat_data_cont[0],           //        pat_data_cont (1==Continue data pattern accross packet boundaries; 0==restart data pattern for each packet)
                                                      (3'h3-pat_data_type[1:0]),  // [2:0]  pat_user_status_type (UserStatus pattern select; 0==CONSTANT; 1==INC_BY_BYTE; 2==INC_BY_WORD; 3==INC_BY_DWORD)
                                                      (1'b1-pat_data_cont[0]),    //        pat_user_status_cont (1==Continue user_status pattern accross packet boundaries; 0==restart user_status pattern for each packet)
                                                      8'h1,                       // [7:0]  pat_active_clocks   (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                                      pat_inactive_clocks[7:0],   // [7:0]  pat_inactive_clocks (pat_active_clock/(pat_active_clock+pat_inactive_clocks) sets the packet generator data ready rate)
                                                      32'h5,                      // [31:0] pat_num_packets (number of packets to generate)
                                                      data_seed,                  // [31:0] pat_data_seed (data pattern starting seed value)
                                                      ~data_seed,                 // [31:0] pat_user_status_seed (user_status pattern starting seed value)
                                                      20'h00080,                  // [19:0] pat_length0 (byte length of generated packets; packet length table[0]; always used)
                                                      20'h00100,                  // [19:0] pat_length1 (byte length of generated packets; packet length table[1]; used if pat_length_entries > 0)
                                                      20'h00200,                  // [19:0] pat_length2 (byte length of generated packets; packet length table[2]; used if pat_length_entries > 1)
                                                      20'h00400,                  // [19:0] pat_length3 (byte length of generated packets; packet length table[3]; used if pat_length_entries > 2)
                                                      32'd2,                      // [31:0] verbose (Display verbosity: 0=errors only; 1=limited; 2=expanded; 3=verbose including data)
                                                      1'b1,                       //        on_err_stop (1=$stop simulation on error; 0=don't $stop on errors)
                                                      1'b1,                       //        timeout_en (1=Enable DMA timeout functionality; 0=Disable)
                                                      32'h00010000,               //        timeout_clocks (If timeout_en==1 and the DMA fails to make progress for timeout_clocks clock cycles, the DMA operation is aborted)
                                                      check_status,
                                                      total_bcount);              // [31:0] total number of bytes transferred
                                end
                            end
                        end
                    end
                end
            end
            else
            begin
                $display  ("%m : Skipping Engine %d since its not a Packet DMA Engine; Capabilities=%x", i, cap);
            end
        end
end // RUN_DMA_PKT_PAT_GEN_CHK_G3
endtask
initial
   begin : init_msg_heap

       integer        index;
       reg     [63:0] tmp_info;

       msg_info_heap[`MSG_INFO_NULL]    = 64'HDEAD_BEEF_DEAD_BEEF;
       msg_info_heap[`MSG_INFO_TEST1]   = 64'H1234_5678_9abc_def0;
       msg_info_heap[`MSG_INFO_ID_00]   = 64'H0000_FFFF_FFFF_FFFF;
       msg_info_heap[`MSG_INFO_ID_01]   = 64'H0100_FFFF_FFFF_FFFF;
       msg_info_heap[`MSG_INFO_TEST_11] = 64'H1122_3344_5566_7788;
       msg_info_heap[`MSG_INFO_TEST_22] = 64'H2233_4455_6677_8899;
       msg_info_heap[`MSG_INFO_TEST_33] = 64'H3344_5566_7788_99aa;
       msg_info_heap[`MSG_INFO_TEST_44] = 64'H4455_6677_8899_aabb;
       msg_info_heap[`MSG_INFO_TEST_55] = 64'H5566_7788_99aa_bbcc;
       msg_info_heap[`MSG_INFO_TEST_66] = 64'H6677_8899_aabb_ccdd;
       msg_info_heap[`MSG_INFO_TEST_77] = 64'H7788_99aa_bbcc_ddee;
       msg_info_heap[`MSG_INFO_TEST_88] = 64'H8899_aabb_ccdd_eeff;
       msg_info_heap[`MSG_INFO_TEST_99] = 64'H99aa_bbcc_ddee_ff00;
       msg_info_heap[`MSG_INFO_TEST_AA] = 64'Haabb_ccdd_eeff_0011;

       msg_data_heap[`MSG_DATA_NULL]  = 128'HDEAD_BEEF_DEAD_BEEF_DEAD_BEEF_DEAD_BEEF;
       msg_data_heap[`MSG_DATA_TEST1] = 128'H1122_3344_5566_7788_99aa_bbcc_ddee_ff00;
       msg_data_heap[`MSG_DATA_TEST2] = 128'H0102_1314_2526_3738_494a_5b5c_6d6e_7f70;
       msg_data_heap[`MSG_DATA_TEST3] = 128'H000f_0e0d_0c0b_0a09_0807_0605_0403_0201;
       msg_data_heap[`MSG_DATA_1DW_A] = 128'HFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_8765_4321;
       msg_data_heap[`MSG_DATA_1DW_B] = 128'HFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_0123_4567;
       msg_data_heap[`MSG_DATA_2DW_A] = 128'HFFFF_FFFF_FFFF_FFFF_8877_6655_4433_2211;
       msg_data_heap[`MSG_DATA_2DW_B] = 128'HFFFF_FFFF_FFFF_FFFF_00ff_eedd_ccbb_aa99;
       msg_data_heap[`MSG_DATA_3DW_A] = 128'HFFFF_FFFF_cccb_cac9_c8c7_c6c5_c4c3_c2c1;
       msg_data_heap[`MSG_DATA_3DW_B] = 128'HFFFF_FFFF_dddc_dbda_d9d8_d7d6_d5d4_d3d2;

       // create some random message info entries
       for (index = `MSG_INFO_TEST_AA + 1; index <= `NO_OF_MSG_INFO ; index = index + 1)
          msg_info_heap[index] = { $random(random_seed) , $random(random_seed) };

       // choose a vendor id value
       rsvd_vendor_id = $random(random_seed);

       // insert vendor id value into select message info values
       for (index = `MSG_INFO_TEST_AA + 1; index <= `NO_OF_MSG_INFO ; index = index + 2)
       begin
           tmp_info             = msg_info_heap[index];
           tmp_info[47:32]      = rsvd_vendor_id[15:0];
           msg_info_heap[index] = tmp_info;
       end

       // create some random message data entries
       for (index = `MSG_DATA_3DW_B + 1; index <= `NO_OF_MSG_DATA ; index = index + 1)
          msg_data_heap[index] = { $random(random_seed) , $random(random_seed) , $random(random_seed) , $random(random_seed) };

       msg_heap[1]  = { `MSG_NO_DATA, 2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_0,  `MSG_INFO_ID_00,   `MSG_DATA_TEST1 };
       msg_heap[2]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_0,  `MSG_INFO_TEST1,   `MSG_DATA_TEST1 };
       msg_heap[3]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_11, `MSG_DATA_TEST2 };
       msg_heap[4]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_22, `MSG_DATA_TEST3 };
       msg_heap[5]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_33, `MSG_DATA_TEST2 };
       msg_heap[6]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_44, `MSG_DATA_TEST3 };
       msg_heap[7]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_55, `MSG_DATA_TEST2 };
       msg_heap[8]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_66, `MSG_DATA_TEST3 };
       msg_heap[9]  = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_77, `MSG_DATA_TEST2 };
       msg_heap[10] = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_88, `MSG_DATA_TEST3 };
       msg_heap[11] = { `MSG_DATA,    2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_99, `MSG_DATA_TEST2 };
       msg_heap[12] = { `MSG_NO_DATA, 2'b00, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_11, `MSG_DATA_NULL  };
       msg_heap[13] = { `MSG_DATA,    2'b11, `MSG_ROUTE_LOCAL,   `MSG_CODE_VENDOR_DEF_1,  `MSG_INFO_TEST_22, `MSG_DATA_3DW_A };

       // create remaining standard messages
       for (index = 14 ; index <= `NO_OF_STD_MSGS ; index = index + 1)

       begin : creating_std_ep_msgs

           integer      msg_type;
           reg          data_ndata;
           reg    [1:0] data_cnt;
           reg    [2:0] route;
           reg    [7:0] opcode;
           reg    [7:0] info_index;
           reg    [7:0] data_index;

           msg_type = random_range(0, 4);

           case (msg_type)
               0 : begin
                       // vendor opcodes - no data
                       opcode[7:1] = 7'H3F;
                       opcode[0]    = $random(random_seed);
                       route       = `MSG_ROUTE_IMP_FROM_RC;
                       data_ndata  = 0;
                       data_cnt    = $random(random_seed);
                       info_index  = random_range(1, `NO_OF_MSG_INFO);
                       data_index  = `MSG_DATA_NULL;
                   end
               1 : begin
                       // vendor opcodes - data
                       opcode[7:1] = 7'H3F;
                       opcode[0]    = $random(random_seed);
                       route       = `MSG_ROUTE_IMP_FROM_RC;
                       data_ndata  = 1;
                       data_cnt    = 0;
                       info_index  = random_range(1, `NO_OF_MSG_INFO);
                       data_index  = random_range(1, `NO_OF_MSG_DATA);
                   end
               2 : begin
                       // power management
                       opcode      = 8'H14;
                       route       = `MSG_ROUTE_LOCAL;
                       data_ndata  = 0;
                       data_cnt    = $random(random_seed);
                       info_index  = random_range(1, `NO_OF_MSG_INFO);
                       data_index  = `MSG_DATA_NULL;
                   end
               3 : begin
                       // unlock
                       opcode      = 8'h00;
                       route       = `MSG_ROUTE_IMP_FROM_RC;
                       data_ndata  = 0;
                       data_cnt    = $random(random_seed);
                       info_index  = random_range(1, `NO_OF_MSG_INFO);
                       data_index  = `MSG_DATA_NULL;
                   end
               4 : begin
                       // set slot power limit
                       opcode      = 8'H50;
                       route       = `MSG_ROUTE_LOCAL;
                       data_ndata  = 1;
                       data_cnt    = 0;
                       info_index  = random_range(1, `NO_OF_MSG_INFO);
                       data_index  = random_range(1, `NO_OF_MSG_DATA);
                   end
           endcase

           msg_heap[index] = { data_ndata, data_cnt, route, opcode, info_index, data_index };
       end
   end


// -----------
// -- Tasks --
// -----------

// -------------------------------
// Initialize Simulation Variables

assign  check_status = 1'b0;

initial
begin : initalization_block

    // Initialize configuration system variables
    init_configure_pci;

    // BFM MSI-X Interrupt Controller; base address, number of vectors, and array containing interrupt vector hits
    `BFM_INT_MSIX_ADDR            = {64{1'b1}};
    `BFM_INT_MSIX_NUM_VECTORS     = MAX_MSIX_VECTORS;

    // BFM MSI Interrupt Controller; base address, base data value, number of vectors, and array containing interrupt vector hits
    `BFM_INT_MSI_ADDR             = {64{1'b1}};
    `BFM_INT_MSI_DATA             = {16{1'b1}};
    `BFM_INT_MSI_NUM_VECTORS      = MAX_MSI_VECTORS;

    // Disable all BFM Root Port memory and I/O windows until the PCIe hierarchy is configured
//    `BFM_CFG_IO_BASE      = 20'hFFFFF;       // Disable window
//    `BFM_CFG_IO_LIMIT     = 20'h00000;       //   ..
//    `BFM_CFG_MEM_BASE     = 12'hFFF;         // Disable window
//    `BFM_CFG_MEM_LIMIT    = 12'h000;         //   ..
//    `BFM_CFG_PF_MEM_BASE  = 44'hFFFFFFFFFFF; // Disable window
//    `BFM_CFG_PF_MEM_LIMIT = 44'h00000000000; //   ..
//    `BFM_CFG_BAR0         = rp_bar0;
//    `BFM_CFG_BAR1         = rp_bar1;
//    `BFM_CFG_EXP_ROM      = rp_exp_rom;

    // Pass some time, so over-riding BFM's time 0 initialization
    #1;

    // Map BFM BARs into memory map
    rp_bar0         = BFM_BASE_ADDR_RP_BAR0;    // Root Port BAR0
    rp_bar1         = BFM_BASE_ADDR_RP_BAR1;    // Root Port BAR1
    rp_exp_rom      = BFM_BASE_ADDR_RP_EXP_ROM; // Root Port Expansion ROM; enabled

    bfm_bar0          = BFM_BASE_ADDR_BAR0;
    bfm_64addr[31: 0] = BFM_BASE_ADDR_BAR1_LO;  // 64-bit BFM Memory location ... BFM as root-port supports this address using negative decode.
    bfm_64addr[63:32] = BFM_BASE_ADDR_BAR1_HI;  // 64-bit BFM Memory location
    bfm_bar1[31: 0] = BFM_BASE_ADDR_BAR1_LO;    // 64-bit BFM Memory location
    bfm_bar1[63:32] = BFM_BASE_ADDR_BAR1_HI;    // 64-bit BFM Memory location
    bfm_bar2[31: 0] = BFM_BASE_ADDR_BAR2;       // 32-bit BFM I/O    location

    `BFM_INT_BASE_IO_ADDR32 = bfm_bar2;         // 32-bit BFM I/O location
    `BFM_INT_BASE_ADDR32    = bfm_bar0;         // 32-bit BFM Memory location
    `BFM_INT_BASE_ADDR64    = bfm_bar1[63:32];  // Upper 32-bits of 64-bit BFM Memory location
    `BFM_INT_LIMIT_ADDR64   = BFM_LIMIT_ADDR_BAR1_HI;  // Upper 32-bits of BAR1 limit (just past end of ac
   // cept range)
//Set up 32-bit access into the BFM.
    bar_addr_end[0][0][0][0] = bfm_bar0 + `RP0_PATH.bfm_mem_bsize  - 1;

end



// Required for direct/force mgmt access
EXPRESSO_BFM_APB_MASTER_REG_LOOKUP bfm_lookup();


// ---------------
// -- Equations --
// ---------------

assign debug = (DEBUG_PASS_FAIL == 1) ? 1'b1 : 1'b0;



// ------------------
// Main Test Sequence

initial
begin
    test_done = 0;

    // Wait until we come out of reset to start
    wait (rst_n == 1'b0);

    // -----------------------
    // Initial Startup Process

    // Wait for Physical Layer to come up
    @(posedge clk);
    while (pl_link_up == 1'b0)
        @(posedge clk);

    $display  ("%m : ######## PHYSICAL LAYER UP ########");

    // Wait for Data Link Layer to come up
    while (dl_link_up == 0)
        @(posedge clk);
    $display  ("%m : ######## DATA LINK LAYER UP ########");

    // Wait some time before starting the first TLP transmissions
    repeat (100) @(posedge clk);
    if (!$test$plusargs("pcie_traffic_msgs_off"))
    begin
        // Wait for L0 before printing header
        while (`RP0_PATH.mgmt_pcie_status[7:2] != 6'h3)
        begin
            @(posedge clk);
        end

        $display  ("Transaction Layer packet display log:");
        $display  ("  * D - Downstream traffic (Root Complex Tx to Endpoint Rx)");
        $display  ("  * U - Upstream   traffic (Endpoint Tx to Root Complex Rx)");
        $display  ("  * For best viewing results, use a fixed width font");
        $display  ("");
        `DISPLAY_HDR;
    end


    // ------------------------------------------------------------------
    // Setting Bridge Register Base Address

    // $display  ("%m : Setting bridge register base register...");

    // init_bridge_register_base ( 32'H5000_0000, 0);  // The init process needs to set this address to the appropriate value

    // temporary kludge to match the init done by the AXI master
    setup_regspec_lookups;



    // ---------------------------------------------------------------
    // CONFIGURE_DUT : REQUIRED : SETS UP BASE ADDRESS REGISTERS, ETC.

    configure_pci(`BFM_CFG0_BUS_NUM);



    // ------------------------------------------------------------------
    // CONFIGURE_DMA : REQUIRED : SETS UP DMA ENGINE SIMULATION VARIABLES

    configure_dma;


    // -------------------
    // RUN_REPORT_CFG_REGS

    // Tests config reads of first 128 32-bit PCIe Configuration Registers.

    if (RUN_REPORT_CFG_REGS)
    begin
        report_cfg_regs;
    end // RUN_REPORT_CFG_REGS

    // ----------------------
    // RUN_BAR0_REGISTER_TEST

    // Test BAR0 Register and Scratchpad functionality in the DUT Reference Design

    if (RUN_BAR0_REGISTER_TEST)
    begin
        bar0_register_test;
    end // RUN_BAR0_REGISTER_TEST



    // --------------------
    // RUN_BAR_MEMORY_TEST

    // Tests reads and writes to the BAR number specified by BAR_TO_TEST
    // Verifies uniqueness across all functions

    if (RUN_BAR_MEMORY_TEST)
    begin
        bar_memory_test;
    end // BAR Memory Test



    // ----------------------
    // RUN_BAR_MEMORY_TEST_TC

    // Tests reads and writes to the BAR number specified by BAR_TO_TEST
    // Verifies uniqueness across all functions.
    // Uses different Traffic Classes for reads and writes

    if (RUN_BAR_MEMORY_TEST_TC)
    begin
        bar_memory_test_tc;
    end // BAR Memory Test with non-zero Traffic Class



    // ------------------------
    // RUN_STANDARD_TARGET_TEST

    // Basic test of target accesses on DUT, various burst lengths

    if (RUN_STANDARD_TARGET_TEST)
    begin
        standard_target_test;
    end // Standard Target Test

    // ------------
    // RUN_DWORD_BE

    //   Test of DWORD transactions with disabled bytes
    //   1) Initialize target with pattern of target bytes at zero (44332200, 44330011, 44002211, 00332211)
    //   2) DWORD Write target with pattern filling target byte with pattern using byte enables (00000011, 00002200, 00330000, 44000000)
    //   3) DWORD Read verifying DWORDS
    if (RUN_DWORD_BE)
    begin
        dword_be;
    end //RUN_DWORD_BE


    // ------------
    // RUN_BURST_BE

    //   Test of BURST transactions with disabled bytes at beginning and end of a burst
    //   1) Initialize target with pattern of target bytes at zero for first DWORD of bursts (44332200, 44330011, 44002211, 00332211)
    //   2) Burst write target with pattern filling target byte with pattern using byte enables (00000011, 00002200, 00330000, 44000000)
    //   3) Burst read verifying expected pattern
    //   4) Repeat steps 2 and 3 at last DWORD of burst
    if (RUN_BURST_BE)
    begin
        burst_be;
    end //RUN_BURST_BE

    // ---------------------
    // RUN_EXP_ROM_READ_TEST

    // Data Initialized in BAR1
    // Expansion ROM Read Test 1024 back-to-back DWORD Memory Reads
    // Assumes Expansion ROM is mapped to BAR1 space for testing

    if (RUN_EXP_ROM_READ_TEST)
    begin
        exp_rom_read_test;
    end // RUN_EXP_ROM_READ_TEST
    // -----------------------
    // RUN_USER_INTERRUPT_TEST

    // Test the optional user interrupt in the DMA Back End

    if (RUN_USER_INTERRUPT_TEST)
    begin
        user_interrupt_test;
    end

    // ---------------------
    // Packet DMA Test Cases

    // --------------
    // RUN_DMA_REG_G3

    // DMA Register Access test for Packet DMA
    // Byte enables also tested

    if (RUN_DMA_REG_G3)
    begin
        dma_reg_g3;
    end // RUN_DMA_REG_G3



    // --------------------
    // RUN_DMA_SHORT_PKT_G3

    // A Quick test that checks for basic functionality of small packet sizes.
    //
    // Test Packet DMA using packet sizes above, equal, and below Descriptor size; choose Descriptor
    //   size to be below Streaming FIFO depth (typical minimum is 2-8KBytes) to test operation when
    //   packet quanitity rather than packet data throttle the availability of the Packet Streaming FIFOs.

    if (RUN_DMA_SHORT_PKT_G3)
    begin
        dma_short_pkt_g3;
    end // RUN_DMA_SHORT_PKT_G3



    // -------------------------
    // RUN_DMA_SHORT_PKT_LPBK_G3

    // A Quick test that checks for basic functionality of Packet DMA using
    //   built-in packet Loopback.

    if (RUN_DMA_SHORT_PKT_LPBK_G3)
    begin
        dma_short_pkt_lpbk_g3;
    end // RUN_DMA_SHORT_PKT_LPBK_G3



    // ------------------------------
    // RUN_DMA_SMALL_UNALIGNED_PKT_G3

    // A Quick test that checks small unaligned packets are handled correctly;
    //   Requires the Pattern Generator and Pattern Checker Loopback functionality
    //   from a pair of DMA Engines.

    if (RUN_DMA_SMALL_UNALIGNED_PKT_G3)
    begin
        dma_small_unaligned_pkt_g3;
    end // RUN_DMA_SMALL_UNALIGNED_PKT_G3



    // --------------------------
    // RUN_DMA_SHORT_ADR_PKT_TEST

    // Short Addressable Packet DMA Test
    // First Engine Pair Tested

    if (RUN_DMA_SHORT_ADR_PKT_TEST)
    begin
        dma_short_adr_pkt_test;
    end // DMA_SHORT_ADR_PKT_TEST



    // --------------------
    // RUN_DMA_ADR_PKT_TEST

    // Addressable Packet DMA Test.  All DMA Engine Pairs tested (in sequence)

    if (RUN_DMA_ADR_PKT_TEST)
    begin
        dma_adr_pkt_test;
    end


    // ----------------------------
    // RUN_DMA_MED_UNALIGNED_PKT_G3

    // A Quick test that checks small unaligned packets are handled correctly;
    //   Requires the Pattern Generator and Pattern Checker Loopback functionality
    //   from a pair of DMA Engines.

    if (RUN_DMA_MED_UNALIGNED_PKT_G3)
    begin
        dma_med_unaligned_pkt_g3;
    end // RUN_DMA_MED_UNALIGNED_PKT_G3



    // -------------------
    // RUN_DMA_LONG_PKT_G3

    // A Quick test that checks for basic functionality of large packet sizes.
    //
    // Test C2S Packet DMA using packet sizes above, equal, and below Descriptor size; choose Descriptor
    //   size to be above C2S Streaming FIFO depth (typical minimum is 2KBytes) to test operation when
    //   packet data rather than packet quantity throttle the availability of the C2S Packet Streaming FIFO.

    if (RUN_DMA_LONG_PKT_G3)
    begin
        dma_long_pkt_g3;
    end // RUN_DMA_LONG_PKT_G3



    // -------------------------
    // RUN_DMA_LONG_PKT_LPBK_G3

    // An extended test that test functionality of Packet DMA using
    //   built-in packet Loopback.

    if (RUN_DMA_LONG_PKT_LPBK_G3)
    begin
        dma_long_pkt_lpbk_g3;
    end // RUN_DMA_LONG_PKT_LPBK_G3



    // --------------------------
    // RUN_DMA_PKT_PAT_GEN_CHK_G3

    // Test for proper operation using the different options of the Packet Generator

    if (RUN_DMA_PKT_PAT_GEN_CHK_G3)
    begin
        dma_pkt_pat_gen_chk_g3;
    end // RUN_DMA_PKT_PAT_GEN_CHK_G3

    // ---------------------
    // RUN_SPEED_CHANGE_TEST

    // Performs multiple speed changes from Root Port BFM
    // Runs for SPEED_CHANGE_ITERATIONS iterations.


    // --------------
    // End Simulation

    // Let model activity shake out and then stop
    repeat (500)
        @(posedge clk);

    $display  ("%m : DUT used the following tags[255:0]: 0x%x", `DUT_REQ_TAGS_USED);
    $display  ("%m : ######## SIMULATION COMPLETE ########");
    `REPORT_STATUS;
    test_done = 1;
end

endmodule

