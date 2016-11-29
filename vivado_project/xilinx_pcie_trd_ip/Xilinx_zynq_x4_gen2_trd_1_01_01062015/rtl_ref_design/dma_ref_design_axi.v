// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2013 by Northwest Logic, Inc.
//
//  All rights reserved.  No part of this source code may be reproduced or
//  transmitted in any form or by any means, electronic or mechanical,
//  including photocopying, recording, or any information storage and
//  retrieval system, without permission in writing from Northwest Logic, Inc.
//
//  Further, no use of this source code is permitted in any form or means
//  without a valid, written license agreement with Northwest Logic, Inc.
//
//  $Date: 2015-01-06 09:02:03 -0800 (Tue, 06 Jan 2015) $
//  $Revision: 53103 $
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

// -------------------------------------------------------------------------
//
// This module is a top level reference design file containing:
//   * PCI Express Core
//   * DMA Back-End Core
//   * Reference Design
//
// This reference design is intended both for simulation to illustrate
//   use of the above cores as well as implemenation in hardware to
//   illustrate core capabilities.
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module dma_ref_design (

    perst_n,            // PCI Express slot PERST# reset signal

    pcie_clk_p,         // PCIe Reference Clock Input
    pcie_clk_n,         // PCIe Reference Clock Input


    tx_p,               // PCIe differential transmit output
    tx_n,               // PCIe differential transmit output

    rx_p,               // PCIe differential receive output
    rx_n,               // PCIe differential receive output

    led                 // Diagnostic LEDs

);



// ----------------
// -- Parameters --
// ----------------

`ifdef SIMULATION
parameter   HALF_PERIOD_AXI             = 2000; // 250 MHz
`endif
parameter   TS_FOR_1NS              = 1000;  //`timescale 1ps/1ps

localparam  NUM_LANES                   = 4;

localparam  CORE_DATA_WIDTH             = 64;
localparam  CORE_BE_WIDTH               = 8;
localparam  CORE_REMAIN_WIDTH           = 3;
localparam  REG_ADDR_WIDTH              = 13; // Register BAR is 64KBytes
localparam  CORE_STS_WIDTH              = (CORE_BE_WIDTH * 3);

localparam  USER_CONTROL_WIDTH          = 64;
localparam  USER_STATUS_WIDTH           = 64;

// AXI Parameters
localparam  AXI_LEN_WIDTH               = 4;    // Sets maximum AXI burst size; supported values 4 (AXI3/AXI4) or 8 (AXI4); For AXI_DATA_WIDTH==256 must be 4 so a 4 KB boundary is not crossed
localparam  AXI_MAX_SIMUL_WIDTH         = 4;    // Maximum number of simultaneously pending AXI transactions == 2^AXI_MAX_SIMUL_WIDTH
localparam  AXI_ADDR_WIDTH              = 36;   // Width of AXI DMA address ports
localparam  T_AXI_ADDR_WIDTH            = 32;   // Width of AXI Target address ports
localparam  AXI_DATA_WIDTH              = 64;   // AXI Data Width
localparam  AXI_BE_WIDTH                = AXI_DATA_WIDTH / 8;


localparam  FDBK_BITS                   = 8;   // Number of bits provided by PHY when reporting equalization quality

localparam  NUM_S2C                     = 2;

localparam  NUM_C2S                     = 2;

// MAX_S2C & MAX_C2S must be set to the same value; maximum number of engines supported; do not modify
localparam  MAX_S2C                     = 8;
localparam  MAX_C2S                     = 8;

// AXI Master implements 1 interrupt vector per DMA Engine plus one for User Interrupt
localparam  M_INT_VECTORS               = NUM_S2C + NUM_C2S + 1;

localparam  INTERRUPT_VECTOR_BITS       = 5;  // Valid values are 5 (32 vectors) to 11 (2048 vectors)

localparam  DESC_STATUS_WIDTH           = 160;  // Packet DMA Engine Descriptor Status port width

localparam  DESC_WIDTH                  = 256;


localparam  DMA_DEST_BADDR_WIDTH        = 15; // Size of multi-ported SRAM that is destination of addressable DMA == 2^DMA_DEST_BADDR_WIDTH bytes


localparam  LED_CTR_WIDTH               = 26;  // Sets period of LED flashing (~twice per Second @ 8nS clock rate, ~once per Second @ 16nS clock period)

// Configure size and indexes of led[LED_HI:LED_LO] port
localparam  LED_HI                      = 2;    // LED port high bit
localparam  LED_LO                      = 0;    // LED port low bit


// ----------------------
// -- Port Definitions --
// ----------------------

input                               perst_n;

input                               pcie_clk_p;
input                               pcie_clk_n;


output  [NUM_LANES-1:0]             tx_p;
output  [NUM_LANES-1:0]             tx_n;

input   [NUM_LANES-1:0]             rx_p;
input   [NUM_LANES-1:0]             rx_n;

output  [LED_HI:LED_LO]             led;



// ----------------
// -- Port Types --
// ----------------

wire                                perst_n;

wire                                pcie_clk_p;
wire                                pcie_clk_n;


wire    [NUM_LANES-1:0]             tx_p;
wire    [NUM_LANES-1:0]             tx_n;

wire    [NUM_LANES-1:0]             rx_p;
wire    [NUM_LANES-1:0]             rx_n;

wire    [LED_HI:LED_LO]             led;



// -------------------
// -- Local Signals --
// -------------------

// Reference Design Clock
wire                                user_clk;
wire                                user_rst_n;

wire                                ref_clk;


// PCI Express PHY Instantiation
wire                                mgmt_dl_link_up_i;
wire                                mgmt_mst_en;
wire                                link_up_i;

// Instantiate PCIe Complete Core
wire                                core_rst_n;
wire                                core_clk;
wire    [5:0]                       core_clk_period_in_ns;
wire                                testmode;
wire                                pf_flr;

wire                                phy_rx_clkreq_n;
wire                                phy_tx_clkreq_n;
wire                                phy_tx_cm_disable;
wire                                phy_rx_ei_disable;
wire                                phy_tx_swing;
wire    [2:0]                       phy_tx_margin;
wire    [NUM_LANES-1:0]             phy_tx_deemph;

wire    [NUM_LANES-1:0]             phy_tx_detect_rx_loopback;
wire    [(NUM_LANES*2)-1:0]         phy_power_down;
wire    [NUM_LANES-1:0]             phy_rate;
wire    [NUM_LANES-1:0]             phy_phy_status;
wire    [NUM_LANES-1:0]             phy_rx_polarity;

wire    [CORE_DATA_WIDTH-1:0]       phy_tx_data;
wire    [CORE_BE_WIDTH-1:0]         phy_tx_is_k;
wire    [CORE_BE_WIDTH-1:0]         phy_tx_fneg;
wire    [NUM_LANES-1:0]             phy_tx_elec_idle;

wire    [CORE_DATA_WIDTH-1:0]       phy_rx_data;
wire    [CORE_BE_WIDTH-1:0]         phy_rx_is_k;
wire    [NUM_LANES-1:0]             phy_rx_data_valid;
wire    [NUM_LANES-1:0]             phy_rx_valid;
wire    [CORE_STS_WIDTH-1:0]        phy_rx_status;
wire    [NUM_LANES-1:0]             phy_rx_elec_idle;
`ifdef SIMULATION
reg     [NUM_LANES-1:0]             phy_rx_elec_idle_override;
`else
wire    [NUM_LANES-1:0]             phy_rx_elec_idle_override = {NUM_LANES{1'b0}};
`endif
// DMA System to Card Engine Interface
wire    [ NUM_S2C                    -1:0]  s2c_areset_n;
reg                                         s2c_aclk;

// DMA Card to System Engine Interface
wire    [ NUM_C2S                    -1:0]  c2s_areset_n;
reg                                         c2s_aclk;

// RAM interface
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

wire    [31:0]                      mgmt_user_version;
wire    [15:0]                      mgmt_cfg_id;

wire                                mgmt_msix_en;
wire                                mgmt_msi_en;
wire    [31:0]                      mgmt_interrupt;

`ifdef SIMULATION
reg                                 user_interrupt;
`else
wire                                user_interrupt;
`endif
// LEDs
reg     [LED_CTR_WIDTH-1:0]         led_ctr;



// ---------------
// -- Equations --
// ---------------

// ---------------
// Clock and Reset
// Reference Design Clock
assign                  user_clk     = core_clk;
assign                  user_rst_n   = link_up_i;

// Generate s2c_aclk
  `ifdef SIMULATION
initial                 s2c_aclk     = 1'b0;
always #HALF_PERIOD_AXI s2c_aclk     = ~s2c_aclk;
  `else
always @*               s2c_aclk     = core_clk;
  `endif

// Generate c2s_aclk
  `ifdef SIMULATION
initial                 c2s_aclk     = 1'b0;
always #HALF_PERIOD_AXI c2s_aclk     = ~c2s_aclk;
  `else
always @*               c2s_aclk     = core_clk;
  `endif


// -----------------------------
// PCI Express PHY Instantiation

assign link_up_i = mgmt_dl_link_up_i;

// ------------------------------
// Instantiate PCIe Complete Core

`ifdef SIMULATION
initial user_interrupt = 1'b0;
`else
assign user_interrupt = 1'b0;
`endif


IBUFDS_GTE2 refclk_ibuf (.O(ref_clk), .ODIV2(), .I(pcie_clk_p), .CEB(1'b0), .IB(pcie_clk_n));

xil_pcie_wrapper_ipi  xil_pcie_wrapper (

    .perst_n                        (perst_n                        ),

    .pcie_clk                       (ref_clk                        ),

    .tx_p                           (tx_p                           ),
    .tx_n                           (tx_n                           ),

    .rx_p                           (rx_p                           ),
    .rx_n                           (rx_n                           ),

    .user_clk                       (core_clk                       ),
    .user_rst_n                     (mgmt_dl_link_up_i              ),

    .mgmt_mst_en                    (mgmt_mst_en                    ),

    .s2c_areset_n                   (s2c_areset_n                   ),
    .c2s_areset_n                   (c2s_areset_n                   ),

    .ram_s2c_awvalid                (ram_s2c_awvalid                ),
    .ram_s2c_awready                (ram_s2c_awready                ),
    .ram_s2c_awaddr                 (ram_s2c_awaddr                 ),
    .ram_s2c_awlen                  (ram_s2c_awlen                  ),
    .ram_s2c_wvalid                 (ram_s2c_wvalid                 ),
    .ram_s2c_wready                 (ram_s2c_wready                 ),
    .ram_s2c_wdata                  (ram_s2c_wdata                  ),
    .ram_s2c_wstrb                  (ram_s2c_wstrb                  ),
    .ram_s2c_wlast                  (ram_s2c_wlast                  ),
    .ram_s2c_bvalid                 (ram_s2c_bvalid                 ),
    .ram_s2c_bready                 (ram_s2c_bready                 ),
    .ram_s2c_bresp                  (ram_s2c_bresp                  ),

    .ram_c2s_arvalid                (ram_c2s_arvalid                ),
    .ram_c2s_arready                (ram_c2s_arready                ),
    .ram_c2s_araddr                 (ram_c2s_araddr                 ),
    .ram_c2s_arlen                  (ram_c2s_arlen                  ),
    .ram_c2s_rvalid                 (ram_c2s_rvalid                 ),
    .ram_c2s_rready                 (ram_c2s_rready                 ),
    .ram_c2s_rdata                  (ram_c2s_rdata                  ),
    .ram_c2s_rresp                  (ram_c2s_rresp                  ),
    .ram_c2s_rlast                  (ram_c2s_rlast                  )
);


// --------------
// AXI Master BFM

// Master Interface is unused
assign m_awvalid = 1'b0;
assign m_awaddr  = 16'h0;
assign m_wvalid  = 1'b0;
assign m_wdata   = 32'h0;
assign m_wstrb   = 4'h0;
assign m_bready  = 1'b0;
assign m_arvalid = 1'b0;
assign m_araddr  = 16'h0;
assign m_rready  = 1'b0;


sram_mp_axi #(

    .DMA_DEST_BADDR_WIDTH   (DMA_DEST_BADDR_WIDTH   ),
    .AXI_LEN_WIDTH          (AXI_LEN_WIDTH          ),
    .AXI_ADDR_WIDTH         (AXI_ADDR_WIDTH         )

) sram_mp_axi (

    .s2c_areset_n           (&s2c_areset_n          ), // Reset on any engine being reset
    .s2c_aclk               (s2c_aclk               ),
    .s2c_awvalid            (ram_s2c_awvalid        ),
    .s2c_awready            (ram_s2c_awready        ),
    .s2c_awaddr             (ram_s2c_awaddr         ),
    .s2c_awlen              (ram_s2c_awlen          ),
    .s2c_wvalid             (ram_s2c_wvalid         ),
    .s2c_wready             (ram_s2c_wready         ),
    .s2c_wdata              (ram_s2c_wdata          ),
    .s2c_wstrb              (ram_s2c_wstrb          ),
    .s2c_wlast              (ram_s2c_wlast          ),
    .s2c_bvalid             (ram_s2c_bvalid         ),
    .s2c_bready             (ram_s2c_bready         ),
    .s2c_bresp              (ram_s2c_bresp          ),

    .c2s_areset_n           (&c2s_areset_n          ), // Reset on any engine being reset
    .c2s_aclk               (c2s_aclk               ),
    .c2s_arvalid            (ram_c2s_arvalid        ),
    .c2s_arready            (ram_c2s_arready        ),
    .c2s_araddr             (ram_c2s_araddr         ),
    .c2s_arlen              (ram_c2s_arlen          ),
    .c2s_rvalid             (ram_c2s_rvalid         ),
    .c2s_rready             (ram_c2s_rready         ),
    .c2s_rdata              (ram_c2s_rdata          ),
    .c2s_rresp              (ram_c2s_rresp          ),
    .c2s_rlast              (ram_c2s_rlast          )

);


// ----
// LEDs

// Heart beat LED; flashes when primary PCIe core clock is present;
//   don't want to use reset so we can see when clock is present even
//   when reset is not working properly
always @(posedge user_clk)
begin
    led_ctr <= led_ctr + {{(LED_CTR_WIDTH-1){1'b0}}, 1'b1};
end
`ifdef SIMULATION

// Initialize for simulation
initial
begin
    led_ctr = {LED_CTR_WIDTH{1'b0}};
end
`endif

assign led[LED_LO  ] = link_up_i;                 // dl_link_up
assign led[LED_LO+1] = led_ctr[LED_CTR_WIDTH-1];  // Heart beat LED indicating primary PCIe Core clock is present
assign led[LED_LO+2] = mgmt_mst_en;               // Data Link Layer Up
endmodule
