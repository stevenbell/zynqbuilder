// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2009 by Northwest Logic, Inc.
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



// -----------------------
// -- Module Definition --
// -----------------------

module sdram_dma_ref_design_axi (

    pcie_rst_n,
    pcie_clk,
    testmode,

    // DMA System to Card Engine Interface
    s2c_areset_n,
    s2c_aclk,
    s2c_fifo_addr_n,
    s2c_awvalid,
    s2c_awready,
    s2c_awaddr,
    s2c_awlen,
    s2c_awusereop,
    s2c_awsize,
    s2c_wvalid,
    s2c_wready,
    s2c_wdata,
    s2c_wstrb,
    s2c_wlast,
    s2c_wusereop,
    s2c_wusercontrol,
    s2c_bvalid,
    s2c_bready,
    s2c_bresp,

    // DMA Card to System Engine Interface
    c2s_areset_n,
    c2s_aclk,
    c2s_fifo_addr_n,
    c2s_arvalid,
    c2s_arready,
    c2s_araddr,
    c2s_arlen,
    c2s_arsize,
    c2s_rvalid,
    c2s_rready,
    c2s_rdata,
    c2s_rresp,
    c2s_rlast,
    c2s_ruserstatus,
    c2s_ruserstrb,

    // AXI Target Interface
    t_areset_n,
    t_aclk,
    t_awvalid,
    t_awready,
    t_awregion,
    t_awaddr,
    t_awlen,
    t_awsize,
    t_wvalid,
    t_wready,
    t_wdata,
    t_wstrb,
    t_wlast,
    t_bvalid,
    t_bready,
    t_bresp,
    t_arvalid,
    t_arready,
    t_arregion,
    t_araddr,
    t_arlen,
    t_arsize,
    t_rvalid,
    t_rready,
    t_rdata,
    t_rresp,
    t_rlast,

    ram_s2c_awvalid,
    ram_s2c_awready,
    ram_s2c_awaddr,
    ram_s2c_awlen,
    ram_s2c_wvalid,
    ram_s2c_wready,
    ram_s2c_wdata,
    ram_s2c_wstrb,
    ram_s2c_wlast,
    ram_s2c_bvalid,
    ram_s2c_bready,
    ram_s2c_bresp,

    ram_c2s_arvalid,
    ram_c2s_arready,
    ram_c2s_araddr,
    ram_c2s_arlen,
    ram_c2s_rvalid,
    ram_c2s_rready,
    ram_c2s_rdata,
    ram_c2s_rresp,
    ram_c2s_rlast,

    mgmt_core_ph,
    mgmt_core_pd,
    mgmt_core_nh,
    mgmt_core_nd,
    mgmt_core_ch,
    mgmt_core_cd,

    mgmt_chipset_ph,
    mgmt_chipset_pd,
    mgmt_chipset_nh,
    mgmt_chipset_nd,
    mgmt_chipset_ch,
    mgmt_chipset_cd,

    mgmt_user_version,
    mgmt_msi_en,
    mgmt_msix_en,
    mgmt_interrupt

);



// ----------------
// -- Parameters --
// ----------------

parameter   USER_VERSION                    = 32'h00_02_00_00;

parameter   REG_ADDR_WIDTH                  = 13;   // 64 KB expected for NWL Reference Design
parameter   SRAM_ADDR_WIDTH                 = 10;   //  8 KB expected for NWL Reference Design

localparam  AXI_DATA_WIDTH                  = 64;
localparam  AXI_REMAIN_WIDTH                = 3;
localparam  AXI_BE_WIDTH                    = AXI_DATA_WIDTH / 8;

localparam  AXI_LEN_WIDTH                   = 4;    // Sets maximum AXI burst size; supported values 4 (AXI3/AXI4) or 8 (AXI4); For AXI_DATA_WIDTH==256 must be 4 so a 4 KB boundary is not crossed
localparam  AXI_ADDR_WIDTH                  = 36;   // Width of AXI DMA address ports
localparam  T_AXI_ADDR_WIDTH                = 32;   // Width of AXI Target address ports
localparam  AXI_NUM_BYTES                   = 32768;  // Number of bytes in AXI memspace

parameter   NUM_S2C                         = 2;

parameter   NUM_C2S                         = 2;

// MAX_S2C & MAX_C2S must be set to the same value; maximum number of engines supported; do not modify
localparam  MAX_S2C                         = 8;
localparam  MAX_C2S                         = 8;

// USER_CONTROL_WIDTH & USER_STATUS_WIDTH must be set to the same value between 1 and 64; must be set the same as the rest of the design
parameter   USER_CONTROL_WIDTH              = 64;
parameter   USER_STATUS_WIDTH               = 64;

// If implemented, packet generators are located at BAR0 offset of DMA Engine registers + 16'hA000 bytes
localparam  PKT_GEN_REG_BASE_ADDR_C2S       = 32'h400 + 32'h1400;
localparam  PKT_GEN_REG_BASE_ADDR_C2S_INC   = 32'h20;

// If implemented, packet checkers are located at BAR0 offset of DMA Engine registers + 16'hA000 bytes
localparam  PKT_CHK_REG_BASE_ADDR_S2C       = 32'h000 + 32'h1400;
localparam  PKT_CHK_REG_BASE_ADDR_S2C_INC   = 32'h20;

localparam  ADDR_FIFO_ADDR_WIDTH            = 8;


// ----------------------
// -- Port Definitions --
// ----------------------

input                                       pcie_rst_n;
input                                       pcie_clk;
input                                       testmode;

// DMA System to Card Engine Interface
input   [ NUM_S2C                    -1:0]  s2c_areset_n;
input                                       s2c_aclk;
output  [ NUM_S2C                    -1:0]  s2c_fifo_addr_n;
input   [ NUM_S2C                    -1:0]  s2c_awvalid;
output  [ NUM_S2C                    -1:0]  s2c_awready;
input   [(NUM_S2C*AXI_ADDR_WIDTH)    -1:0]  s2c_awaddr;
input   [(NUM_S2C*AXI_LEN_WIDTH)     -1:0]  s2c_awlen;
input   [ NUM_S2C                    -1:0]  s2c_awusereop;
input   [(NUM_S2C*3)                 -1:0]  s2c_awsize;
input   [ NUM_S2C                    -1:0]  s2c_wvalid;
output  [ NUM_S2C                    -1:0]  s2c_wready;
input   [(NUM_S2C*AXI_DATA_WIDTH)    -1:0]  s2c_wdata;
input   [(NUM_S2C*AXI_BE_WIDTH)      -1:0]  s2c_wstrb;
input   [ NUM_S2C                    -1:0]  s2c_wlast;
input   [ NUM_S2C                    -1:0]  s2c_wusereop;
input   [(NUM_S2C*USER_CONTROL_WIDTH)-1:0]  s2c_wusercontrol;
output  [ NUM_S2C                    -1:0]  s2c_bvalid;
input   [ NUM_S2C                    -1:0]  s2c_bready;
output  [(NUM_S2C*2)                 -1:0]  s2c_bresp;

// DMA Card to System Engine Interface
input   [ NUM_C2S                    -1:0]  c2s_areset_n;
input                                       c2s_aclk;
output  [ NUM_C2S                    -1:0]  c2s_fifo_addr_n;
input   [ NUM_C2S                    -1:0]  c2s_arvalid;
output  [ NUM_C2S                    -1:0]  c2s_arready;
input   [(NUM_C2S*AXI_ADDR_WIDTH)    -1:0]  c2s_araddr;
input   [(NUM_C2S*AXI_LEN_WIDTH)     -1:0]  c2s_arlen;
input   [(NUM_C2S*3)                 -1:0]  c2s_arsize;
output  [ NUM_C2S                    -1:0]  c2s_rvalid;
input   [ NUM_C2S                    -1:0]  c2s_rready;
output  [(NUM_C2S*AXI_DATA_WIDTH)    -1:0]  c2s_rdata;
output  [(NUM_C2S*2)                 -1:0]  c2s_rresp;
output  [ NUM_C2S                    -1:0]  c2s_rlast;
output  [(NUM_C2S*USER_STATUS_WIDTH) -1:0]  c2s_ruserstatus;
output  [(NUM_C2S*AXI_BE_WIDTH)      -1:0]  c2s_ruserstrb;


// AXI Target Interface
input                                       t_areset_n;
input                                       t_aclk;
input                                       t_awvalid;
output                                      t_awready;
input   [2:0]                               t_awregion;
input   [T_AXI_ADDR_WIDTH-1:0]              t_awaddr;
input   [AXI_LEN_WIDTH-1:0]                 t_awlen;
input   [2:0]                               t_awsize;
input                                       t_wvalid;
output                                      t_wready;
input   [AXI_DATA_WIDTH-1:0]                t_wdata;
input   [AXI_BE_WIDTH-1:0]                  t_wstrb;
input                                       t_wlast;
output                                      t_bvalid;
input                                       t_bready;
output  [1:0]                               t_bresp;
input                                       t_arvalid;
output                                      t_arready;
input   [2:0]                               t_arregion;
input   [T_AXI_ADDR_WIDTH-1:0]              t_araddr;
input   [AXI_LEN_WIDTH-1:0]                 t_arlen;
input   [2:0]                               t_arsize;
output                                      t_rvalid;
input                                       t_rready;
output  [AXI_DATA_WIDTH-1:0]                t_rdata;
output  [1:0]                               t_rresp;
output                                      t_rlast;

output  [ MAX_S2C                    -1:0]  ram_s2c_awvalid;
input   [ MAX_S2C                    -1:0]  ram_s2c_awready;
output  [(MAX_S2C*AXI_ADDR_WIDTH)    -1:0]  ram_s2c_awaddr;
output  [(MAX_S2C*AXI_LEN_WIDTH)     -1:0]  ram_s2c_awlen;
output  [ MAX_S2C                    -1:0]  ram_s2c_wvalid;
input   [ MAX_S2C                    -1:0]  ram_s2c_wready;
output  [(MAX_S2C*AXI_DATA_WIDTH)    -1:0]  ram_s2c_wdata;
output  [(MAX_S2C*AXI_BE_WIDTH)      -1:0]  ram_s2c_wstrb;
output  [ MAX_S2C                    -1:0]  ram_s2c_wlast;
input   [ MAX_S2C                    -1:0]  ram_s2c_bvalid;
output  [ MAX_S2C                    -1:0]  ram_s2c_bready;
input   [(MAX_S2C*2)                 -1:0]  ram_s2c_bresp;

output  [ MAX_C2S                    -1:0]  ram_c2s_arvalid;
input   [ MAX_C2S                    -1:0]  ram_c2s_arready;
output  [(MAX_C2S*AXI_ADDR_WIDTH)    -1:0]  ram_c2s_araddr;
output  [(MAX_C2S*AXI_LEN_WIDTH)     -1:0]  ram_c2s_arlen;
input   [ MAX_C2S                    -1:0]  ram_c2s_rvalid;
output  [ MAX_C2S                    -1:0]  ram_c2s_rready;
input   [(MAX_C2S*AXI_DATA_WIDTH)    -1:0]  ram_c2s_rdata;
input   [(MAX_C2S*2)                 -1:0]  ram_c2s_rresp;
input   [ MAX_C2S                    -1:0]  ram_c2s_rlast;

input   [7:0]                               mgmt_core_ph;
input   [11:0]                              mgmt_core_pd;
input   [7:0]                               mgmt_core_nh;
input   [11:0]                              mgmt_core_nd;
input   [7:0]                               mgmt_core_ch;
input   [11:0]                              mgmt_core_cd;

input   [7:0]                               mgmt_chipset_ph;
input   [11:0]                              mgmt_chipset_pd;
input   [7:0]                               mgmt_chipset_nh;
input   [11:0]                              mgmt_chipset_nd;
input   [7:0]                               mgmt_chipset_ch;
input   [11:0]                              mgmt_chipset_cd;

output  [31:0]                              mgmt_user_version;
input                                       mgmt_msi_en;
input                                       mgmt_msix_en;
output  [31:0]                              mgmt_interrupt;



// ----------------
// -- Port Types --
// ----------------

wire                                        pcie_rst_n;
wire                                        pcie_clk;
wire                                        testmode;

// DMA System to Card Engine Interface
wire    [ NUM_S2C                    -1:0]  s2c_areset_n;
wire                                        s2c_aclk;
wire    [ NUM_S2C                    -1:0]  s2c_fifo_addr_n;
wire    [ NUM_S2C                    -1:0]  s2c_awvalid;
wire    [ NUM_S2C                    -1:0]  s2c_awready;
wire    [(NUM_S2C*AXI_ADDR_WIDTH)    -1:0]  s2c_awaddr;
wire    [(NUM_S2C*AXI_LEN_WIDTH)     -1:0]  s2c_awlen;
wire    [ NUM_S2C                    -1:0]  s2c_awusereop;
wire    [(NUM_S2C*3)                 -1:0]  s2c_awsize;
wire    [ NUM_S2C                    -1:0]  s2c_wvalid;
wire    [ NUM_S2C                    -1:0]  s2c_wready;
wire    [(NUM_S2C*AXI_DATA_WIDTH)    -1:0]  s2c_wdata;
wire    [(NUM_S2C*AXI_BE_WIDTH)      -1:0]  s2c_wstrb;
wire    [ NUM_S2C                    -1:0]  s2c_wlast;
wire    [ NUM_S2C                    -1:0]  s2c_wusereop;
wire    [(NUM_S2C*USER_CONTROL_WIDTH)-1:0]  s2c_wusercontrol;
wire    [ NUM_S2C                    -1:0]  s2c_bvalid;
wire    [ NUM_S2C                    -1:0]  s2c_bready;
wire    [(NUM_S2C*2)                 -1:0]  s2c_bresp;

// DMA Card to System Engine Interface
wire    [ NUM_C2S                    -1:0]  c2s_areset_n;
wire                                        c2s_aclk;
wire    [ NUM_C2S                    -1:0]  c2s_fifo_addr_n;
wire    [ NUM_C2S                    -1:0]  c2s_arvalid;
wire    [ NUM_C2S                    -1:0]  c2s_arready;
wire    [(NUM_C2S*AXI_ADDR_WIDTH)    -1:0]  c2s_araddr;
wire    [(NUM_C2S*AXI_LEN_WIDTH)     -1:0]  c2s_arlen;
wire    [(NUM_C2S*3)                 -1:0]  c2s_arsize;
wire    [ NUM_C2S                    -1:0]  c2s_rvalid;
wire    [ NUM_C2S                    -1:0]  c2s_rready;
wire    [(NUM_C2S*AXI_DATA_WIDTH)    -1:0]  c2s_rdata;
wire    [(NUM_C2S*2)                 -1:0]  c2s_rresp;
wire    [ NUM_C2S                    -1:0]  c2s_rlast;
wire    [(NUM_C2S*USER_STATUS_WIDTH) -1:0]  c2s_ruserstatus;
wire    [(NUM_C2S*AXI_BE_WIDTH)      -1:0]  c2s_ruserstrb;

// AXI Target Interface
wire                                        t_areset_n;
wire                                        t_aclk;
wire                                        t_awvalid;
wire                                        t_awready;
wire    [2:0]                               t_awregion;
wire    [T_AXI_ADDR_WIDTH-1:0]              t_awaddr;
wire    [AXI_LEN_WIDTH-1:0]                 t_awlen;
wire    [2:0]                               t_awsize;
wire                                        t_wvalid;
wire                                        t_wready;
wire    [AXI_DATA_WIDTH-1:0]                t_wdata;
wire    [AXI_BE_WIDTH-1:0]                  t_wstrb;
wire                                        t_wlast;
wire                                        t_bvalid;
wire                                        t_bready;
wire    [1:0]                               t_bresp;
wire                                        t_arvalid;
wire                                        t_arready;
wire    [2:0]                               t_arregion;
wire    [T_AXI_ADDR_WIDTH-1:0]              t_araddr;
wire    [AXI_LEN_WIDTH-1:0]                 t_arlen;
wire    [2:0]                               t_arsize;
wire                                        t_rvalid;
wire                                        t_rready;
wire    [AXI_DATA_WIDTH-1:0]                t_rdata;
wire    [1:0]                               t_rresp;
wire                                        t_rlast;

wire    [ MAX_S2C                    -1:0]  ram_s2c_awvalid;
wire    [ MAX_S2C                    -1:0]  ram_s2c_awready;
wire    [(MAX_S2C*AXI_ADDR_WIDTH)    -1:0]  ram_s2c_awaddr;
wire    [(MAX_S2C*AXI_LEN_WIDTH)     -1:0]  ram_s2c_awlen;
wire    [ MAX_S2C                    -1:0]  ram_s2c_wvalid;
wire    [ MAX_S2C                    -1:0]  ram_s2c_wready;
wire    [(MAX_S2C*AXI_DATA_WIDTH)    -1:0]  ram_s2c_wdata;
wire    [(MAX_S2C*AXI_BE_WIDTH)      -1:0]  ram_s2c_wstrb;
wire    [ MAX_S2C                    -1:0]  ram_s2c_wlast;
wire    [ MAX_S2C                    -1:0]  ram_s2c_bvalid;
wire    [ MAX_S2C                    -1:0]  ram_s2c_bready;
wire    [(MAX_S2C*2)                 -1:0]  ram_s2c_bresp;

wire    [ MAX_C2S                    -1:0]  ram_c2s_arvalid;
wire    [ MAX_C2S                    -1:0]  ram_c2s_arready;
wire    [(MAX_C2S*AXI_ADDR_WIDTH)    -1:0]  ram_c2s_araddr;
wire    [(MAX_C2S*AXI_LEN_WIDTH)     -1:0]  ram_c2s_arlen;
wire    [ MAX_C2S                    -1:0]  ram_c2s_rvalid;
wire    [ MAX_C2S                    -1:0]  ram_c2s_rready;
wire    [(MAX_C2S*AXI_DATA_WIDTH)    -1:0]  ram_c2s_rdata;
wire    [(MAX_C2S*2)                 -1:0]  ram_c2s_rresp;
wire    [ MAX_C2S                    -1:0]  ram_c2s_rlast;

wire    [7:0]                               mgmt_core_ph;
wire    [11:0]                              mgmt_core_pd;
wire    [7:0]                               mgmt_core_nh;
wire    [11:0]                              mgmt_core_nd;
wire    [7:0]                               mgmt_core_ch;
wire    [11:0]                              mgmt_core_cd;

wire    [7:0]                               mgmt_chipset_ph;
wire    [11:0]                              mgmt_chipset_pd;
wire    [7:0]                               mgmt_chipset_nh;
wire    [11:0]                              mgmt_chipset_nd;
wire    [7:0]                               mgmt_chipset_ch;
wire    [11:0]                              mgmt_chipset_cd;

wire    [31:0]                              mgmt_user_version;
wire                                        mgmt_msi_en;
wire                                        mgmt_msix_en;
wire    [31:0]                              mgmt_interrupt;



// -------------------
// -- Local Signals --
// -------------------

// Master Interface

// Target Interface
wire    [REG_ADDR_WIDTH-1:0]                reg_wr_addr;
wire                                        reg_wr_en;
wire    [AXI_BE_WIDTH-1:0]                  reg_wr_be;
wire    [AXI_DATA_WIDTH-1:0]                reg_wr_data;
wire    [REG_ADDR_WIDTH-1:0]                reg_rd_addr;
wire    [AXI_DATA_WIDTH-1:0]                reg_rd_data;

wire    [SRAM_ADDR_WIDTH-1:0]               sram_wr_addr;
wire                                        sram_wr_en;
wire    [AXI_BE_WIDTH-1:0]                  sram_wr_be;
wire    [AXI_DATA_WIDTH-1:0]                sram_wr_data;
wire    [SRAM_ADDR_WIDTH-1:0]               sram_rd_addr;
wire    [AXI_DATA_WIDTH-1:0]                sram_rd_data;

wire    [AXI_DATA_WIDTH-1:0]                example_reg_rd_data;

genvar                                      i;

// System to Card DMA
genvar                                      s;
genvar                                      t;

wire    [(MAX_S2C*AXI_DATA_WIDTH)-1:0]      s2c_reg_rd_data_array;

wire    [NUM_S2C-1:0]                       fif_s2c_awready;
wire    [NUM_S2C-1:0]                       fif_s2c_wready;
wire    [NUM_S2C-1:0]                       fif_s2c_bvalid;
wire    [(NUM_S2C*2)-1:0]                   fif_s2c_bresp;

wire    [(MAX_S2C*USER_CONTROL_WIDTH)-1:0]  lpbk_user_st_ctl;
wire    [MAX_S2C-1:0]                       lpbk_sop;
wire    [MAX_S2C-1:0]                       lpbk_eop;
wire    [(MAX_S2C*AXI_DATA_WIDTH)-1:0]      lpbk_data;
wire    [(MAX_S2C*AXI_REMAIN_WIDTH)-1:0]    lpbk_valid;
wire    [MAX_S2C-1:0]                       lpbk_src_rdy;
wire    [MAX_S2C-1:0]                       lpbk_dst_rdy;

wire    [AXI_DATA_WIDTH-1:0]                s2c_reg_rd_data;

// Card to System DMA
genvar                                      c;
genvar                                      d;

wire    [(MAX_C2S*AXI_DATA_WIDTH)-1:0]      c2s_reg_rd_data_array;

wire    [NUM_C2S-1:0]                       fif_c2s_arready;
wire    [(NUM_C2S*2)-1:0]                   fif_c2s_rresp;
wire    [NUM_C2S-1:0]                       fif_c2s_rvalid;
wire    [(NUM_C2S*AXI_DATA_WIDTH)-1:0]      fif_c2s_rdata;
wire    [NUM_C2S-1:0]                       fif_c2s_rlast;

wire    [AXI_DATA_WIDTH-1:0]                c2s_reg_rd_data;


// Instantiate Multi-Ported SRAM as Addressable DMA Destination
genvar                                      u;
genvar                                      v;
genvar                                      j;
genvar                                      e;
genvar                                      f;
genvar                                      k;

// ---------------
// -- Equations --
// ---------------

// -------------
// User Revision

assign mgmt_user_version = USER_VERSION;
// ----------------
// Target Interface

t_example #(

    .AXI_ADDR_WIDTH     (T_AXI_ADDR_WIDTH       ),
    .AXI_LEN_WIDTH      (AXI_LEN_WIDTH          ),
    .AXI_DATA_WIDTH     (AXI_DATA_WIDTH         ),
    .REG_ADDR_WIDTH     (REG_ADDR_WIDTH         ),
    .SRAM_ADDR_WIDTH    (SRAM_ADDR_WIDTH        )

) t_example (

    .rst_n              (t_areset_n             ),
    .clk                (t_aclk                 ),

    .awvalid            (t_awvalid              ),
    .awready            (t_awready              ),
    .awregion           (t_awregion             ),
    .awaddr             (t_awaddr               ),
    .awlen              (t_awlen                ),
    .awsize             (t_awsize               ),

    .wvalid             (t_wvalid               ),
    .wready             (t_wready               ),
    .wdata              (t_wdata                ),
    .wstrb              (t_wstrb                ),
    .wlast              (t_wlast                ),

    .bvalid             (t_bvalid               ),
    .bready             (t_bready               ),
    .bresp              (t_bresp                ),

    .arvalid            (t_arvalid              ),
    .arready            (t_arready              ),
    .arregion           (t_arregion             ),
    .araddr             (t_araddr               ),
    .arlen              (t_arlen                ),
    .arsize             (t_arsize               ),

    .rvalid             (t_rvalid               ),
    .rready             (t_rready               ),
    .rdata              (t_rdata                ),
    .rresp              (t_rresp                ),
    .rlast              (t_rlast                ),

    .reg_wr_addr        (reg_wr_addr            ),
    .reg_wr_en          (reg_wr_en              ),
    .reg_wr_be          (reg_wr_be              ),
    .reg_wr_data        (reg_wr_data            ),
    .reg_rd_addr        (reg_rd_addr            ),
    .reg_rd_data        (reg_rd_data            ),

    .sram_wr_addr       (sram_wr_addr           ),
    .sram_wr_en         (sram_wr_en             ),
    .sram_wr_be         (sram_wr_be             ),
    .sram_wr_data       (sram_wr_data           ),
    .sram_rd_addr       (sram_rd_addr           ),
    .sram_rd_data       (sram_rd_data           )

);

// Combine regsiter read data from various sources
assign reg_rd_data = example_reg_rd_data |
                     c2s_reg_rd_data     |
                     s2c_reg_rd_data;

// Implements example user registers  (Targeted by PCIe BAR0 accesses >= 0x8000 (byte address))
register_example_axi #(

    .REG_ADDR_WIDTH     (REG_ADDR_WIDTH         )

) register_example_axi (

    .rst_n              (pcie_rst_n             ),
    .clk                (pcie_clk               ),

    .mgmt_core_ph       (mgmt_core_ph           ),
    .mgmt_core_pd       (mgmt_core_pd           ),
    .mgmt_core_nh       (mgmt_core_nh           ),
    .mgmt_core_nd       (mgmt_core_nd           ),
    .mgmt_core_ch       (mgmt_core_ch           ),
    .mgmt_core_cd       (mgmt_core_cd           ),

    .mgmt_chipset_ph    (mgmt_chipset_ph        ),
    .mgmt_chipset_pd    (mgmt_chipset_pd        ),
    .mgmt_chipset_nh    (mgmt_chipset_nh        ),
    .mgmt_chipset_nd    (mgmt_chipset_nd        ),
    .mgmt_chipset_ch    (mgmt_chipset_ch        ),
    .mgmt_chipset_cd    (mgmt_chipset_cd        ),
    .mgmt_msi_en        (mgmt_msi_en            ),
    .mgmt_msix_en       (mgmt_msix_en           ),
    .mgmt_interrupt     (mgmt_interrupt         ),

    .reg_rst_n          (t_areset_n             ),
    .reg_clk            (t_aclk                 ),
    .reg_wr_addr        (reg_wr_addr            ),
    .reg_wr_en          (reg_wr_en              ),
    .reg_wr_be          (reg_wr_be              ),
    .reg_wr_data        (reg_wr_data            ),
    .reg_rd_addr        (reg_rd_addr            ),
    .reg_rd_data        (example_reg_rd_data    )

);

// Implements example internal SRAM (Targeted by PCIe BAR1 & BAR2 accesses)
generate for (i=0; i<AXI_BE_WIDTH; i=i+1)
    begin : gen_sram

        ref_inferred_block_ram #(

            .ADDR_WIDTH (SRAM_ADDR_WIDTH                    ),
            .DATA_WIDTH (8                                  )

        ) sram (

            .wr_clk     (t_aclk                             ),
            .wr_addr    (sram_wr_addr                       ),
            .wr_en      (sram_wr_en & sram_wr_be[i]         ),
            .wr_data    (sram_wr_data[((i+1)*8)-1:(i*8)]    ),

            .rd_clk     (t_aclk                             ),
            .rd_addr    (sram_rd_addr                       ),
            .rd_data    (sram_rd_data[((i+1)*8)-1:(i*8)]    )

        );

    end
endgenerate



// ------------------
// System to Card DMA

generate for (s=0; s<NUM_S2C; s=s+1)
    begin : gen_packet_check

        wire    [REG_ADDR_WIDTH-1:0]    reg_base_addr;
        assign                          reg_base_addr = PKT_CHK_REG_BASE_ADDR_S2C + (s*PKT_CHK_REG_BASE_ADDR_S2C_INC);
        integer                         i;

        // Generate test packet source
        packet_check_axi #(

            .REG_ADDR_WIDTH         (REG_ADDR_WIDTH                                                                                     )

        ) s2c_packet_check_axi (

            .rst_n                  (s2c_areset_n[s]                                                                                    ),
            .clk                    (s2c_aclk                                                                                           ),

            .check_control          (1'b1                                                                                               ),

            .reg_base_addr          (reg_base_addr                                                                                      ),

            .reg_wr_addr            (reg_wr_addr                                                                                        ),
            .reg_wr_en              (reg_wr_en                                                                                          ),
            .reg_wr_be              (reg_wr_be                                                                                          ),
            .reg_wr_data            (reg_wr_data                                                                                        ),
            .reg_rd_addr            (reg_rd_addr                                                                                        ),
            .reg_rd_data            (s2c_reg_rd_data_array  [((s+1)*AXI_DATA_WIDTH    )-1:(s*AXI_DATA_WIDTH    )]                       ),

            .lpbk_user_status       (lpbk_user_st_ctl       [((s+1)*USER_CONTROL_WIDTH)-1:(s*USER_CONTROL_WIDTH)]                       ),
            .lpbk_sop               (lpbk_sop               [  s                                                ]                       ),
            .lpbk_eop               (lpbk_eop               [  s                                                ]                       ),
            .lpbk_data              (lpbk_data              [((s+1)*AXI_DATA_WIDTH    )-1:(s*AXI_DATA_WIDTH    )]                       ),
            .lpbk_valid             (lpbk_valid             [((s+1)*AXI_REMAIN_WIDTH  )-1:(s*AXI_REMAIN_WIDTH  )]                       ),
            .lpbk_src_rdy           (lpbk_src_rdy           [  s                                                ]                       ),
            .lpbk_dst_rdy           (lpbk_dst_rdy           [  s                                                ]                       ),

            .s2c_wvalid             (s2c_wvalid             [  s                                                ] & s2c_fifo_addr_n[s]  ),
            .s2c_wready             (fif_s2c_wready         [  s                                                ]                       ),
            .s2c_wdata              (s2c_wdata              [((s+1)*AXI_DATA_WIDTH    )-1:(s*AXI_DATA_WIDTH    )]                       ),
            .s2c_wstrb              (s2c_wstrb              [((s+1)*AXI_BE_WIDTH      )-1:(s*AXI_BE_WIDTH      )]                       ),
            .s2c_wusereop           (s2c_wusereop           [  s                                                ]                       ),
            .s2c_wusercontrol       (s2c_wusercontrol       [((s+1)*USER_CONTROL_WIDTH)-1:(s*USER_CONTROL_WIDTH)]                       ),
            .s2c_bvalid             (fif_s2c_bvalid         [  s                                                ]                       ),
            .s2c_bready             (s2c_bready             [  s                                                ] & s2c_fifo_addr_n[s]  ),
            .s2c_bresp              (fif_s2c_bresp          [((s+1)*2                 )-1:(s*2                 )]                       ),

            .s2c_fifo_addr_n        (s2c_fifo_addr_n        [  s                                                ]                       )

        );

        // Address bus unused for FIFO applications
        assign fif_s2c_awready[s] = 1'b1;

        // Mux between FIFO and Addressable DMA Applications
        assign s2c_awready[  s              ] = s2c_fifo_addr_n[s] ? fif_s2c_awready[  s              ] : ram_s2c_awready[  s              ];

        assign s2c_wready [  s              ] = s2c_fifo_addr_n[s] ? fif_s2c_wready [  s              ] : ram_s2c_wready [  s              ];
        assign s2c_bvalid [  s              ] = s2c_fifo_addr_n[s] ? fif_s2c_bvalid [  s              ] : ram_s2c_bvalid [  s              ];
        assign s2c_bresp  [((s+1)*2)-1:(s*2)] = s2c_fifo_addr_n[s] ? fif_s2c_bresp  [((s+1)*2)-1:(s*2)] : ram_s2c_bresp  [((s+1)*2)-1:(s*2)];

    end
endgenerate

// Tie off DMA Engine output ports for non-implemented engines
generate for (t=NUM_S2C; t<MAX_S2C; t=t+1)
    begin : gen_s2c_dma_axi_not_present

        assign s2c_reg_rd_data_array[((t+1)*AXI_DATA_WIDTH    )-1:(t*AXI_DATA_WIDTH    )] = {AXI_DATA_WIDTH{1'b0}};

        assign lpbk_user_st_ctl     [((t+1)*USER_CONTROL_WIDTH)-1:(t*USER_CONTROL_WIDTH)] = {USER_CONTROL_WIDTH{1'b0}};
        assign lpbk_sop             [  t                                                ] = 1'b0;
        assign lpbk_eop             [  t                                                ] = 1'b0;
        assign lpbk_data            [((t+1)*AXI_DATA_WIDTH    )-1:(t*AXI_DATA_WIDTH    )] = {AXI_DATA_WIDTH{1'b0}};
        assign lpbk_valid           [((t+1)*AXI_REMAIN_WIDTH  )-1:(t*AXI_REMAIN_WIDTH  )] = {AXI_REMAIN_WIDTH{1'b0}};
        assign lpbk_src_rdy         [  t                                                ] = 1'b0;

    end
endgenerate

assign s2c_reg_rd_data = s2c_reg_rd_data_array[((0+1)*AXI_DATA_WIDTH)-1:(0*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((1+1)*AXI_DATA_WIDTH)-1:(1*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((2+1)*AXI_DATA_WIDTH)-1:(2*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((3+1)*AXI_DATA_WIDTH)-1:(3*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((4+1)*AXI_DATA_WIDTH)-1:(4*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((5+1)*AXI_DATA_WIDTH)-1:(5*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((6+1)*AXI_DATA_WIDTH)-1:(6*AXI_DATA_WIDTH)] |
                         s2c_reg_rd_data_array[((7+1)*AXI_DATA_WIDTH)-1:(7*AXI_DATA_WIDTH)];



// ------------------
// Card to System DMA

generate for (c=0; c<NUM_C2S; c=c+1)
    begin : gen_packet_gen

        wire    [REG_ADDR_WIDTH-1:0]    reg_base_addr;
        assign                          reg_base_addr = PKT_GEN_REG_BASE_ADDR_C2S + (c*PKT_GEN_REG_BASE_ADDR_C2S_INC);
        integer                         i;

        // Generate test packet source
        packet_gen_axi #(

            .REG_ADDR_WIDTH         (REG_ADDR_WIDTH                                                                                     )

        ) c2s_packet_gen_axi (

            .rst_n                  (c2s_areset_n[c]                                                                                    ),
            .clk                    (c2s_aclk                                                                                           ),

            .reg_base_addr          (reg_base_addr                                                                                      ),

            .reg_wr_addr            (reg_wr_addr                                                                                        ),
            .reg_wr_en              (reg_wr_en                                                                                          ),
            .reg_wr_be              (reg_wr_be                                                                                          ),
            .reg_wr_data            (reg_wr_data                                                                                        ),
            .reg_rd_addr            (reg_rd_addr                                                                                        ),
            .reg_rd_data            (c2s_reg_rd_data_array  [((c+1)*AXI_DATA_WIDTH    )-1:(c*AXI_DATA_WIDTH    )]                       ),

            .lpbk_user_status       (lpbk_user_st_ctl       [((c+1)*USER_STATUS_WIDTH )-1:(c*USER_STATUS_WIDTH )]                       ),
            .lpbk_sop               (lpbk_sop               [  c                                                ]                       ),
            .lpbk_eop               (lpbk_eop               [  c                                                ]                       ),
            .lpbk_data              (lpbk_data              [((c+1)*AXI_DATA_WIDTH    )-1:(c*AXI_DATA_WIDTH    )]                       ),
            .lpbk_valid             (lpbk_valid             [((c+1)*AXI_REMAIN_WIDTH  )-1:(c*AXI_REMAIN_WIDTH  )]                       ),
            .lpbk_src_rdy           (lpbk_src_rdy           [  c                                                ]                       ),
            .lpbk_dst_rdy           (lpbk_dst_rdy           [  c                                                ]                       ),

            .c2s_rvalid             (fif_c2s_rvalid         [  c                                                ]                       ),
            .c2s_rready             (c2s_rready             [  c                                                ] & c2s_fifo_addr_n[c]  ),
            .c2s_rdata              (fif_c2s_rdata          [((c+1)*AXI_DATA_WIDTH    )-1:(c*AXI_DATA_WIDTH    )]                       ),
            .c2s_rresp              (fif_c2s_rresp          [((c+1)*2                 )-1:(c*2                 )]                       ),
            .c2s_rlast              (fif_c2s_rlast          [  c                                                ]                       ),
            .c2s_ruserstatus        (c2s_ruserstatus        [((c+1)*USER_STATUS_WIDTH )-1:(c*USER_STATUS_WIDTH )]                       ),
            .c2s_ruserstrb          (c2s_ruserstrb          [((c+1)*AXI_BE_WIDTH      )-1:(c*AXI_BE_WIDTH      )]                       ),

            .c2s_fifo_addr_n        (c2s_fifo_addr_n        [  c                                                ]                       )

        );

        // Address bus unused for FIFO applications
        assign fif_c2s_arready[c] = 1'b1;

        // Mux between FIFO and Addressable DMA Applications
        assign c2s_arready[  c                                        ] = c2s_fifo_addr_n[c] ? fif_c2s_arready[  c                                        ] : ram_c2s_arready[  c                                        ];

        assign c2s_rvalid [  c                                        ] = c2s_fifo_addr_n[c] ? fif_c2s_rvalid [  c                                        ] : ram_c2s_rvalid [  c                                        ];
        assign c2s_rdata  [((c+1)*AXI_DATA_WIDTH)-1:(c*AXI_DATA_WIDTH)] = c2s_fifo_addr_n[c] ? fif_c2s_rdata  [((c+1)*AXI_DATA_WIDTH)-1:(c*AXI_DATA_WIDTH)] : ram_c2s_rdata  [((c+1)*AXI_DATA_WIDTH)-1:(c*AXI_DATA_WIDTH)];
        assign c2s_rresp  [((c+1)*2             )-1:(c*2             )] = c2s_fifo_addr_n[c] ? fif_c2s_rresp  [((c+1)*2             )-1:(c*2             )] : ram_c2s_rresp  [((c+1)*2             )-1:(c*2             )];
        assign c2s_rlast  [  c                                        ] = c2s_fifo_addr_n[c] ? fif_c2s_rlast  [  c                                        ] : ram_c2s_rlast  [  c                                        ];

    end
endgenerate

// Tie off DMA Engine output ports for non-implemented engines
generate for (d=NUM_C2S; d<MAX_C2S; d=d+1)
    begin : gen_c2s_dma_axi_not_present

        assign c2s_reg_rd_data_array[((d+1)*AXI_DATA_WIDTH    )-1:(d*AXI_DATA_WIDTH   )] = {AXI_DATA_WIDTH{1'b0}};

        assign lpbk_dst_rdy         [  d                                               ] = 1'b0;

    end
endgenerate

assign c2s_reg_rd_data = c2s_reg_rd_data_array[((0+1)*AXI_DATA_WIDTH)-1:(0*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((1+1)*AXI_DATA_WIDTH)-1:(1*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((2+1)*AXI_DATA_WIDTH)-1:(2*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((3+1)*AXI_DATA_WIDTH)-1:(3*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((4+1)*AXI_DATA_WIDTH)-1:(4*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((5+1)*AXI_DATA_WIDTH)-1:(5*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((6+1)*AXI_DATA_WIDTH)-1:(6*AXI_DATA_WIDTH)] |
                         c2s_reg_rd_data_array[((7+1)*AXI_DATA_WIDTH)-1:(7*AXI_DATA_WIDTH)];



// Present S2C DMA Engines
generate for (u=0; u<NUM_S2C; u=u+1)
    begin : gen_s2c_sram_mp_axi_present

        assign ram_s2c_awvalid[  u                                        ] = s2c_awvalid[  u                                        ] & ~s2c_fifo_addr_n[u];
        assign ram_s2c_awaddr [((u+1)*AXI_ADDR_WIDTH)-1:(u*AXI_ADDR_WIDTH)] = s2c_awaddr [((u+1)*AXI_ADDR_WIDTH)-1:(u*AXI_ADDR_WIDTH)];
        assign ram_s2c_awlen  [((u+1)*AXI_LEN_WIDTH )-1:(u*AXI_LEN_WIDTH )] = s2c_awlen  [((u+1)*AXI_LEN_WIDTH )-1:(u*AXI_LEN_WIDTH )];

        assign ram_s2c_wvalid [  u                                        ] = s2c_wvalid [  u                                        ] & ~s2c_fifo_addr_n[u];
        assign ram_s2c_wdata  [((u+1)*AXI_DATA_WIDTH)-1:(u*AXI_DATA_WIDTH)] = s2c_wdata  [((u+1)*AXI_DATA_WIDTH)-1:(u*AXI_DATA_WIDTH)];
        assign ram_s2c_wstrb  [((u+1)*AXI_BE_WIDTH  )-1:(u*AXI_BE_WIDTH  )] = s2c_wstrb  [((u+1)*AXI_BE_WIDTH  )-1:(u*AXI_BE_WIDTH  )];
        assign ram_s2c_wlast  [  u                                        ] = s2c_wlast  [  u                                        ];

        assign ram_s2c_bready [  u                                        ] = s2c_bready [  u                                        ] & ~s2c_fifo_addr_n[u];

    end
endgenerate

// Not Present S2C DMA Engines
generate for (v=NUM_S2C; v<MAX_S2C; v=v+1)
    begin : gen_s2c_sram_mp_axi_not_present

        assign ram_s2c_awvalid[  v                                        ] = 1'b0;
        assign ram_s2c_awaddr [((v+1)*AXI_ADDR_WIDTH)-1:(v*AXI_ADDR_WIDTH)] = {AXI_ADDR_WIDTH{1'b0}};
        assign ram_s2c_awlen  [((v+1)*AXI_LEN_WIDTH )-1:(v*AXI_LEN_WIDTH )] = {AXI_LEN_WIDTH{1'b0}};

        assign ram_s2c_wvalid [  v                                        ] = 1'b0;
        assign ram_s2c_wdata  [((v+1)*AXI_DATA_WIDTH)-1:(v*AXI_DATA_WIDTH)] = {AXI_DATA_WIDTH{1'b0}};
        assign ram_s2c_wstrb  [((v+1)*AXI_BE_WIDTH  )-1:(v*AXI_BE_WIDTH  )] = {AXI_BE_WIDTH{1'b0}};
        assign ram_s2c_wlast  [  v                                        ] = 1'b0;

        assign ram_s2c_bready [  v                                        ] = 1'b0;

        assign ram_s2c_awvalid[  v                                        ] = 1'b0;
        assign ram_s2c_wvalid [  v                                        ] = 1'b0;
        assign ram_s2c_bready [  v                                        ] = 1'b0;
    end
endgenerate

// Present C2S DMA Engines
generate for (e=0; e<NUM_C2S; e=e+1)
    begin : gen_c2s_sram_mp_axi_present

        assign ram_c2s_arvalid[  e                                        ] = c2s_arvalid[  e                                        ] & ~c2s_fifo_addr_n[e];
        assign ram_c2s_araddr [((e+1)*AXI_ADDR_WIDTH)-1:(e*AXI_ADDR_WIDTH)] = c2s_araddr [((e+1)*AXI_ADDR_WIDTH)-1:(e*AXI_ADDR_WIDTH)];
        assign ram_c2s_arlen  [((e+1)*AXI_LEN_WIDTH )-1:(e*AXI_LEN_WIDTH )] = c2s_arlen  [((e+1)*AXI_LEN_WIDTH )-1:(e*AXI_LEN_WIDTH )];

        assign ram_c2s_rready [  e                                        ] = c2s_rready [  e                                        ] & ~c2s_fifo_addr_n[e];

    end
endgenerate

// Not Present C2S DMA Engines
generate for (f=NUM_C2S; f<MAX_C2S; f=f+1)
    begin : gen_c2s_sram_mp_axi_not_present

        assign ram_c2s_arvalid[  f                                        ] = 1'b0;
        assign ram_c2s_araddr [((f+1)*AXI_ADDR_WIDTH)-1:(f*AXI_ADDR_WIDTH)] = {AXI_ADDR_WIDTH{1'b0}};
        assign ram_c2s_arlen  [((f+1)*AXI_LEN_WIDTH )-1:(f*AXI_LEN_WIDTH )] = {AXI_LEN_WIDTH{1'b0}};

        assign ram_c2s_rready [  f                                        ] = 1'b0;

        assign ram_c2s_arvalid[  f                                        ] = 1'b0;
        assign ram_c2s_rready [  f                                        ] = 1'b0;
    end
endgenerate


endmodule
