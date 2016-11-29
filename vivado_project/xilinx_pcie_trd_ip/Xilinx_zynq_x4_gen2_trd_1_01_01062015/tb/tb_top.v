// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2014 by Northwest Logic, Inc.
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

module tb_top;

// ----------------
// -- Parameters --
// ----------------

// NOTE: Only values defined using parameter are expected to be changed by the user;
//       Do not alter values defined using localparam

parameter   FINISH_STOP_N           = 0;    // On errors and simulation completion, $stop if FINISH_STOP_N==0 else $finish
parameter   STOP_ON_ERR             = 1;    // Set to 1 to $stop simulation on errors (for tests with optional $stop code);
                                            //   Note: During NWL command line regressions, $stop is automatically elevated to $finish
                                            //         by the regression flow for those simulators for which this is necessary

parameter   ACTIVITY_WDT_TIMEOUT    = 50_000;   // Simulation will halt after this many 100 MHz clocks with no high level transaction activity (default 0.5 mS) (0=disable)
parameter   ABSOLUTE_WDT_TIMEOUT    = 80_000;   // Simulation will halt after this many microseconds (default 40 ms) (0=disable)

// NUM_LANES indicates the number of PCI Express lanes supported by the core
localparam  NUM_LANES               = 4;

// BFM_NUM_LANES indicates the number of PCI Express lanes on the BFM
//  if not specified, assume it is equal to NUM_LANES
localparam  BFM_NUM_LANES           = NUM_LANES;

localparam  BFM_RCB_BYTES           = 128;

localparam  MAX_NUM_LANES           = (BFM_NUM_LANES > NUM_LANES) ? BFM_NUM_LANES : NUM_LANES;

// The following parameter controls the lanes that will be modelled as
//   detecting/not detecting receivers; to cause a lane not to detect
//   a receiver, set (1) the corresponding bit in PIPE_PHY_LANE_MASK;
//     For example: PHY_LANE_MASK == 16'h800C : Lanes[15, 3:2] will
//       emulate being disconnected
//   Note: The serial transmit lines of lanes that are modelled as
//   disconnected will output High-Z
parameter   BFM_PHY_LANE_MASK       = 16'h0000;

// The following parameters when == 1 emulate the inability for PHY to properly detect the active condition at 5G and 8G data rates; the active condition is only detected when an EIE low frequency pattern is on the serial lines
parameter   RX_IDLE_ACTIVE_8G_ONLY_EIE  = 0; // Set to 1 to cause rx_elec_idle to be 0 at 8G speed only when EIEOS == {8{8'h00, 8'ff}} is received;                                            0 == Use emulated analog comparator
parameter   RX_IDLE_ACTIVE_5G_ONLY_EIE  = 0; // Set to 1 to cause rx_elec_idle to be 0 at 5G speed only when EIE == symbols are received back-back; alternating pattern of 5 zeros and 5 ones; 0 == Use emulated analog comparator

// Message levels
parameter   MSGS_STD_OUT_ON         = 1;    // Set to enable logging TLP information to standard output
parameter   MSGS_FILE_ON            = 1;    // Set to enable logging TLP information to file output
parameter   VCD_DUMP                = 0;
parameter   VCD_DEPTH               = 0;
parameter   VCD_ON_TIME             = 0;
parameter   VCD_OFF_TIME            = 0;


// parameters for board delay simulation
parameter   TPD_CLK_CTRLR_MEM       = 1900;               // total delay of clock from controller clock net to SDRAM
parameter   TPD_CMD_CTRLR_MEM       = 1900;               // total delay of address/command signals from controller clock net to SDRAM
parameter   TPD_DATA_CTRLR_MEM      = 1900;               // total delay of dq/dqs from Controller to SDRAM devices

parameter   TPD_DATA_MEM_CTRLR      = TPD_DATA_CTRLR_MEM; // total delay of dq/dqs from SDRAM devices to Controller
parameter   TPD_RD_EN_LOOPBACK      = TPD_DATA_CTRLR_MEM + TPD_DATA_MEM_CTRLR;

parameter   RESET_INACTIVE_TIME       = 1;
parameter   RESET_ACTIVE_TIME       = 900000;

parameter   SIM_EL_IDLE_TYPE        = 2'b10; // Electrical Idle Emulation: 11 == 1'b1 : Common Mode 1
                                             //                            10 == 1'b0 : Common Mode 0
                                             //                            01 == 1'bx : Undefined
                                             //                            00 == 1'bz : Tristate

parameter   DUT_LANE_REVERSE        = 0;    // Default to DUT not reversed; Non-zero to reverse DUT Lanes
parameter   BFM_LANE_REVERSE        = 0;    // Default to BFM not reversed; Non-zero to reverse BFM Lanes
//parameter   DUT_LANE_SHIFT          = 0;
parameter   BFM_EMULATE_WIDTH       = 0;
parameter   DUT_TX_INVERT           = 0;
parameter   BFM_TX_INVERT           = 0;

// Per PCIe Spec, the max skew that can be received accross the lanes at receiver is 8nS @ 5G
//   and 20 nS @ 2.5G; this includes differences in length of SKP Ordered sets; select skew to
//   apply accross lanes; skew is evenly distributed with Lane 0 having no skew and highest lane
//   having MAX_LANE_SKEW
parameter   MAX_LANE_SKEW           = 4000;  // To DUT
parameter   MAX_LANE_SKEW_TO_BFM    = 4000;  // To BFM (8-bit per lane BFM has max 31 nS of range)
parameter   BFM_SKEW_EN             = 0;
parameter   DUT_SKEW_EN             = 0;
parameter   BFM_SKEW_TYPE           = 0;
parameter   DUT_SKEW_TYPE           = 0;

parameter   CLK200_PERIOD           = 5000;

parameter   DUT_LANE_SHIFT          = 0;

// Assertion paths
`define DUT_CORE_CLK                        dut.core_clk



// -------------------
// -- Local Signals --
// -------------------

reg                                 pcie_clk_p_x2;
wire                                pcie_clk_n_x2;
reg                                 pcie_clk_p;
wire                                pcie_clk_n;
reg                                 pcie_clk_p_div2;
reg                                 clk200;
reg                                 clk400;
reg                                 clk100;
reg                                 clk50;
reg                                 clk33;
reg                                 c_rst_n;
reg                                 rst_n;
wire                                activity_observed_i;
reg                                 activity_observed;
tri1                                clkreq_n;

// Lane Masking - NWL Use Only
wire    [MAX_NUM_LANES-1:0]         lane_fail;
reg     [MAX_NUM_LANES-1:0]         lane_mask;

// Lane Skew Control - NWL Use Only
reg     [MAX_NUM_LANES-1:0]         bfm_skew_mask = (BFM_SKEW_TYPE == 1) ? {MAX_NUM_LANES{1'b1}} : {MAX_NUM_LANES{1'b0}};
reg     [MAX_NUM_LANES-1:0]         dut_skew_mask = (DUT_SKEW_TYPE == 1) ? {MAX_NUM_LANES{1'b1}} : {MAX_NUM_LANES{1'b0}};
reg                                 bfm_skew_en   = (BFM_SKEW_EN == 1) ? 1'b1 : 1'b0;
reg                                 dut_skew_en   = (DUT_SKEW_EN == 1) ? 1'b1 : 1'b0;

// Lane p, n Inversion - NWL Use Only
reg     [MAX_NUM_LANES-1:0]         bfm_invert_tx = DUT_TX_INVERT[MAX_NUM_LANES-1:0];
reg     [MAX_NUM_LANES-1:0]         dut_invert_tx = BFM_TX_INVERT[MAX_NUM_LANES-1:0];

// Lane reversal Control - NWL Use Only
reg                                 dut_reverse;
reg                                 bfm_reverse;
reg     [4:0]                       lane_shift;
reg     [4:0]                       bfm_em_width;

wire                                el_idle;

genvar                              g;

// Serial lines connected to DUT/Model
wire    [MAX_NUM_LANES-1:0]         dut_to_model_p;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n;

wire    [MAX_NUM_LANES-1:0]         temp_model_to_dut_p;
wire    [MAX_NUM_LANES-1:0]         temp_model_to_dut_n;

wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_swiz;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_swiz;
reg     [MAX_NUM_LANES-1:0]         dut_to_model_p_swiz;
reg     [MAX_NUM_LANES-1:0]         dut_to_model_n_swiz;

wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_shft;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_shft;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_shft;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_shft;

// Intermediary serial lines after optional actions
wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_drev;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_drev;

wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_mask;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_mask;

reg     [MAX_NUM_LANES-1:0]         dut_to_model_p_mask_skew_inc;
reg     [MAX_NUM_LANES-1:0]         dut_to_model_n_mask_skew_inc;
reg     [MAX_NUM_LANES-1:0]         dut_to_model_p_mask_skew_dec;
reg     [MAX_NUM_LANES-1:0]         dut_to_model_n_mask_skew_dec;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_mask_skew_sel;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_mask_skew_sel;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_mask_skew;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_mask_skew;

wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_mask_skew_swap;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_mask_skew_swap;

wire    [MAX_NUM_LANES-1:0]         dut_to_model_p_brev;
wire    [MAX_NUM_LANES-1:0]         dut_to_model_n_brev;

wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_brev;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_brev;

wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_mask;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_mask;

reg     [MAX_NUM_LANES-1:0]         model_to_dut_p_mask_skew_inc;
reg     [MAX_NUM_LANES-1:0]         model_to_dut_n_mask_skew_inc;
reg     [MAX_NUM_LANES-1:0]         model_to_dut_p_mask_skew_dec;
reg     [MAX_NUM_LANES-1:0]         model_to_dut_n_mask_skew_dec;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_mask_skew_sel;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_mask_skew_sel;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_mask_skew;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_mask_skew;

wire    [MAX_NUM_LANES-1:0]         model_to_dut_p_mask_skew_swap;
wire    [MAX_NUM_LANES-1:0]         model_to_dut_n_mask_skew_swap;

reg     [MAX_NUM_LANES-1:0]         model_to_dut_p;
reg     [MAX_NUM_LANES-1:0]         model_to_dut_n;

// PCIe Bus Functional Model
wire                                core_rst_n;
wire                                core_clk;
wire                                pl_link_up;
wire                                dl_link_up;
wire    [1535:0]                    mgmt_pcie_status;
wire                                test_done;


wire                                i2c_reset_n;
wire                                proc_wr_en;
wire                                proc_rd_en;
wire [15:0]                         proc_addr;
wire [31:0]                         proc_wr_data;
wire [31:0]                         proc_rd_data;
wire                                proc_rd_data_valid;

assign activity_observed_i =
                           pcie_bfm.model_tx_en |
                           pcie_bfm.rx_en ;                 // PCIe bus activity

always @(posedge activity_observed_i or posedge clk100)
begin
    if (activity_observed_i == 1'b1)
        activity_observed <= 1'b1;
    else
        activity_observed <= 1'b0;
end



// ---------------
// -- Equations --
// ---------------

initial
    if (VCD_DUMP)
    begin: vcd_dump_block
        $dumpfile ("vcd_dump.vcd");

        $dumpvars (VCD_DEPTH, tb_top.dut);
        $dumpoff;
        #(VCD_ON_TIME);
        $display("%m: Starting VCD dump at time %t",$time);
        $dumpon;
        if (VCD_OFF_TIME > VCD_ON_TIME)
        begin
            #(VCD_OFF_TIME-VCD_ON_TIME);
            $display("%m: Stopping VCD dump at time %t",$time);
            $dumpoff;
            $stop;
        end
    end

// ---------------
// Clock and Reset

// Generate rising edge aligned clocks;
//   Note: Not all clocks used in all configurations

// Generate 250 MHz PCI Express reference clock
initial
begin
    pcie_clk_p_x2 = 0;
    #6000;
    forever
    begin
        #2000; // 4 ns Period
        pcie_clk_p_x2 = ~pcie_clk_p_x2;
    end
end
assign pcie_clk_n_x2 = ~pcie_clk_p_x2;

// Generate 125 MHz PCI Express reference clock
initial
begin
    pcie_clk_p = 0;
    #4000;
    forever
    begin
        #4000; // 8 ns Period
        pcie_clk_p = ~pcie_clk_p;
    end
end
assign pcie_clk_n = ~pcie_clk_p;

// Generate 125 MHz PCI Express reference clock / 2 (phase aligned to pcie_clk_p)
initial
begin
    pcie_clk_p_div2 = 0;
    forever
    begin
        #8000; // 16 ns Period
        pcie_clk_p_div2 = ~pcie_clk_p_div2;
    end
end

// Generate 400 MHz clock
initial
begin
    clk400 = 0;
    forever
    begin
        #1250; // 2.5 ns Period
        clk400 = ~clk400;
    end
end

// Generate 200 MHz clock
initial
begin
    clk200 = 0;
    forever
    begin
        #(CLK200_PERIOD/2); // 5 ns Period
        clk200 = ~clk200;
    end
end

// Generate 100 MHz clock
initial
begin
    clk100 = 0;
    forever
    begin
        #5000; // 10 ns Period
        clk100 = ~clk100;
    end
end

// Generate 50 MHz clock
initial
begin
    clk50 = 0;
    forever
    begin
        #10000; // 20 ns Period
        clk50 = ~clk50;
    end
end

// Generate 33.333333 MHz clock
initial
begin
    clk33 = 0;
    forever
    begin
        #15050; // 30 ns Period
        clk33 = ~clk33;
    end
end

// Generate reset
initial
begin
    c_rst_n = 1;
    #RESET_INACTIVE_TIME;
    c_rst_n = 0;
    #RESET_ACTIVE_TIME;
    c_rst_n = 1;
end


always @* rst_n = c_rst_n;



// ----------------------------
// Lane Mask, Skew, & Inversion

// Use requested electrical idle symbol
assign el_idle =  (SIM_EL_IDLE_TYPE == 2'b11) ? 1'b1 :
                 ((SIM_EL_IDLE_TYPE == 2'b10) ? 1'b0 :
                 ((SIM_EL_IDLE_TYPE == 2'b01) ? 1'bx : 1'bz));

// Set bits cause associated Lane to bad data so it will be dropped from the link during training
assign lane_fail =  0
                    ;

initial begin
    @(posedge core_clk);
    lane_mask = ~lane_fail;
    dut_reverse = DUT_LANE_REVERSE;
    bfm_reverse = BFM_LANE_REVERSE;
    lane_shift  = DUT_LANE_SHIFT;
    bfm_em_width = (BFM_EMULATE_WIDTH == 0) ? BFM_NUM_LANES : BFM_EMULATE_WIDTH;
end


always @* model_to_dut_p = model_to_dut_p_swiz;
always @* model_to_dut_n = model_to_dut_n_swiz;

always @* dut_to_model_p_swiz = dut_to_model_p;
always @* dut_to_model_n_swiz = dut_to_model_n;

// Apply optional operations to serial lines to enable testing
//   of down-training, skew correction, and lane inversion
//     NOTE: The following registers are forced to control these functions
//       lane_mask    [MAX_NUM_LANES-1:0] : clear corresponding bits to force lanes to output constant diff data
//       skew_mask    [MAX_NUM_LANES-1:0] : set/clear corresponding bits to select skew for lanes
//       dut_invert_tx[MAX_NUM_LANES-1:0] : set   corresponding bits to force DUT TX to invert tx_p & tx_n
//       bfm_invert_tx[MAX_NUM_LANES-1:0] : set   corresponding bits to force BFM TX to invert tx_p & tx_n
generate
    for (g = 0; g < MAX_NUM_LANES; g = g + 1)
    begin: gen_lane_mask
        // ------------
        // DUT to Model

        // Mask selected lanes : Force down-training
        assign dut_to_model_p_mask[g] = lane_mask[g] ? dut_to_model_p_swiz[g] : 1'b0;
        assign dut_to_model_n_mask[g] = lane_mask[g] ? dut_to_model_n_swiz[g] : 1'b1;

        // DUT Lane Shift
        assign dut_to_model_p_shft[g] = (g < NUM_LANES) ? ((g+lane_shift < NUM_LANES) ? dut_to_model_p_mask[(g+lane_shift)] : dut_to_model_p_mask[g+lane_shift-NUM_LANES]) : 1'bz;
        assign dut_to_model_n_shft[g] = (g < NUM_LANES) ? ((g+lane_shift < NUM_LANES) ? dut_to_model_n_mask[(g+lane_shift)] : dut_to_model_n_mask[g+lane_shift-NUM_LANES]) : 1'bz;

        // DUT Lane Reversal
        assign dut_to_model_p_drev[g] = (g < NUM_LANES) ? ((dut_reverse != 0) ? dut_to_model_p_shft[(NUM_LANES-1)-g] : dut_to_model_p_shft[g]) : 1'bz;
        assign dut_to_model_n_drev[g] = (g < NUM_LANES) ? ((dut_reverse != 0) ? dut_to_model_n_shft[(NUM_LANES-1)-g] : dut_to_model_n_shft[g]) : 1'bz;

        // Introduce lane skew : Exercise skew correction
        //   Skew increases as lane numbers increase
        always @* dut_to_model_p_mask_skew_inc[g] <= #(                ((MAX_LANE_SKEW_TO_BFM/(MAX_NUM_LANES-1))*g)) dut_to_model_p_drev[g];
        always @* dut_to_model_n_mask_skew_inc[g] <= #(                ((MAX_LANE_SKEW_TO_BFM/(MAX_NUM_LANES-1))*g)) dut_to_model_n_drev[g];
        //   Skew decreases as lane numbers increase
        always @* dut_to_model_p_mask_skew_dec[g] <= #(MAX_LANE_SKEW_TO_BFM - ((MAX_LANE_SKEW_TO_BFM/(MAX_NUM_LANES-1))*g)) dut_to_model_p_drev[g];
        always @* dut_to_model_n_mask_skew_dec[g] <= #(MAX_LANE_SKEW_TO_BFM - ((MAX_LANE_SKEW_TO_BFM/(MAX_NUM_LANES-1))*g)) dut_to_model_n_drev[g];
        //   Choose which skew to use
        assign dut_to_model_p_mask_skew_sel[g] = dut_skew_mask[g] ? dut_to_model_p_mask_skew_inc[g] : dut_to_model_p_mask_skew_dec[g];
        assign dut_to_model_n_mask_skew_sel[g] = dut_skew_mask[g] ? dut_to_model_n_mask_skew_inc[g] : dut_to_model_n_mask_skew_dec[g];
        //   Final skew selection
        assign dut_to_model_p_mask_skew[g] = dut_skew_en ? dut_to_model_p_mask_skew_sel[g] : dut_to_model_p_drev[g];
        assign dut_to_model_n_mask_skew[g] = dut_skew_en ? dut_to_model_n_mask_skew_sel[g] : dut_to_model_n_drev[g];

        // Reverse tx_p, tx_n for selected lanes : Exercise lane inversion correction
        assign dut_to_model_p_mask_skew_swap[g] = dut_invert_tx[g] ? dut_to_model_n_mask_skew[g] : dut_to_model_p_mask_skew[g];
        assign dut_to_model_n_mask_skew_swap[g] = dut_invert_tx[g] ? dut_to_model_p_mask_skew[g] : dut_to_model_n_mask_skew[g];

        // Model Lane Reversal
        assign dut_to_model_p_brev[g] = (g < bfm_em_width) ? ((bfm_reverse != 0) ? dut_to_model_p_mask_skew_swap[(bfm_em_width-1)-g] : dut_to_model_p_mask_skew_swap[g]) : 1'bz;
        assign dut_to_model_n_brev[g] = (g < bfm_em_width) ? ((bfm_reverse != 0) ? dut_to_model_n_mask_skew_swap[(bfm_em_width-1)-g] : dut_to_model_n_mask_skew_swap[g]) : 1'bz;

        // ------------
        // Model to DUT

        // Model Lane Reversal
        assign model_to_dut_p_brev[g] = (g < bfm_em_width) ? ((bfm_reverse != 0) ? temp_model_to_dut_p[(bfm_em_width-1)-g] : temp_model_to_dut_p[g]) : 1'bz;
        assign model_to_dut_n_brev[g] = (g < bfm_em_width) ? ((bfm_reverse != 0) ? temp_model_to_dut_n[(bfm_em_width-1)-g] : temp_model_to_dut_n[g]) : 1'bz;

        // Introduce lane skew : Exercise skew correction
        //   Skew increases as lane numbers increase
        always @* model_to_dut_p_mask_skew_inc[g] <= #(                ((MAX_LANE_SKEW/(MAX_NUM_LANES-1))*g)) model_to_dut_p_brev[g];
        always @* model_to_dut_n_mask_skew_inc[g] <= #(                ((MAX_LANE_SKEW/(MAX_NUM_LANES-1))*g)) model_to_dut_n_brev[g];
        //   Skew decreases as lane numbers increase
        always @* model_to_dut_p_mask_skew_dec[g] <= #(MAX_LANE_SKEW - ((MAX_LANE_SKEW/(MAX_NUM_LANES-1))*g)) model_to_dut_p_brev[g];
        always @* model_to_dut_n_mask_skew_dec[g] <= #(MAX_LANE_SKEW - ((MAX_LANE_SKEW/(MAX_NUM_LANES-1))*g)) model_to_dut_n_brev[g];
        //   Choose which skew to use
        assign model_to_dut_p_mask_skew_sel[g] = bfm_skew_mask[g] ? model_to_dut_p_mask_skew_inc[g] : model_to_dut_p_mask_skew_dec[g];
        assign model_to_dut_n_mask_skew_sel[g] = bfm_skew_mask[g] ? model_to_dut_n_mask_skew_inc[g] : model_to_dut_n_mask_skew_dec[g];
        //   Final skew selection
        assign model_to_dut_p_mask_skew[g] = bfm_skew_en ? model_to_dut_p_mask_skew_sel[g] : model_to_dut_p_brev[g];
        assign model_to_dut_n_mask_skew[g] = bfm_skew_en ? model_to_dut_n_mask_skew_sel[g] : model_to_dut_n_brev[g];

        // Reverse tx_p, tx_n for selected lanes : Exercise lane inversion correction
        assign model_to_dut_p_mask_skew_swap[g] = bfm_invert_tx[g] ? model_to_dut_n_mask_skew[g] : model_to_dut_p_mask_skew[g];
        assign model_to_dut_n_mask_skew_swap[g] = bfm_invert_tx[g] ? model_to_dut_p_mask_skew[g] : model_to_dut_n_mask_skew[g];

        // BFM Lane Reversal
        assign model_to_dut_p_shft[g] = (g < NUM_LANES) ? ((dut_reverse != 0) ? model_to_dut_p_mask_skew_swap[(NUM_LANES-1)-g] : model_to_dut_p_mask_skew_swap[g]) : 1'bz;
        assign model_to_dut_n_shft[g] = (g < NUM_LANES) ? ((dut_reverse != 0) ? model_to_dut_n_mask_skew_swap[(NUM_LANES-1)-g] : model_to_dut_n_mask_skew_swap[g]) : 1'bz;

        // DUT Lane Reverse
        assign model_to_dut_p_mask[g] = (g < NUM_LANES) ? ((g >= lane_shift) ? model_to_dut_p_shft[(g-lane_shift)] : model_to_dut_p_shft[NUM_LANES+g-lane_shift]) : 1'bz;
        assign model_to_dut_n_mask[g] = (g < NUM_LANES) ? ((g >= lane_shift) ? model_to_dut_n_shft[(g-lane_shift)] : model_to_dut_n_shft[NUM_LANES+g-lane_shift]) : 1'bz;

        // Mask selected lanes : Force down-training
        assign model_to_dut_p_swiz[g] = lane_mask[g] ? model_to_dut_p_mask[g] : 1'b0;
        assign model_to_dut_n_swiz[g] = lane_mask[g] ? model_to_dut_n_mask[g] : 1'b1;

    end
endgenerate

// -----------------------------
// Instantiate Device Under Test

// Signals used to inject errors into serial pcie data
wire [NUM_LANES-1:0] dut_to_model_noerr_p;
wire [NUM_LANES-1:0] dut_to_model_noerr_n;
reg  [NUM_LANES-1:0] dut_to_model_err_inject;   // Used by loopback_test.v
wire [NUM_LANES-1:0] model_to_dut_err_p;
wire [NUM_LANES-1:0] model_to_dut_err_n;
reg  [NUM_LANES-1:0] model_to_dut_err_inject;   // Used by loopback_test.v

initial begin
    dut_to_model_err_inject = 0;
    model_to_dut_err_inject = 0;
end

dma_ref_design
dut (


    .perst_n                (rst_n                              ), // Core fundamental reset

    .pcie_clk_p             (clk100                             ), // 100 MHz
    .pcie_clk_n             (~clk100                            ), // 100 MHz
//    .tx_p                   (dut_to_model_p[NUM_LANES-1:0]      ),
    .tx_p                   (dut_to_model_noerr_p[NUM_LANES-1:0]      ),
//    .tx_n                   (dut_to_model_n[NUM_LANES-1:0]      ),
    .tx_n                   (dut_to_model_noerr_n[NUM_LANES-1:0]      ),

    .rx_p                   (model_to_dut_err_p[NUM_LANES-1:0]      ),
    .rx_n                   (model_to_dut_err_n[NUM_LANES-1:0]      ),
    .led                    (                                   )
);

    assign dut_to_model_p[NUM_LANES-1:0]     = dut_to_model_noerr_p[NUM_LANES-1:0] ^ dut_to_model_err_inject;
    assign model_to_dut_err_p[NUM_LANES-1:0] = model_to_dut_p[NUM_LANES-1:0]       ^ model_to_dut_err_inject;

    assign dut_to_model_n[NUM_LANES-1:0]     = dut_to_model_noerr_n[NUM_LANES-1:0] ^ dut_to_model_err_inject;
    assign model_to_dut_err_n[NUM_LANES-1:0] = model_to_dut_n[NUM_LANES-1:0]       ^ model_to_dut_err_inject;

 `ifdef SIMULATION
 `endif // ifdef SIMULATION

// -------------------------
// PCIe Bus Functional Model

// Emulates a Root Complex Device and includes tasks called by test_sequences

reg     bfm_rst_n = 1'b1;

always @(rst_n)
begin
    if (rst_n === 1'b0)
    begin
        bfm_rst_n = 1'b0;
    end
    else if (bfm_rst_n == 1'b0 & rst_n == 1'b1)
    begin
        bfm_rst_n = 1'b1;
    end
end

pcie_bfm_rp # (
    .RCB_BYTES                      (BFM_RCB_BYTES              ),

    .SIM_EL_IDLE_TYPE               (SIM_EL_IDLE_TYPE           ),
    .BFM_PHY_LANE_MASK              (BFM_PHY_LANE_MASK          ),
    .RX_IDLE_ACTIVE_8G_ONLY_EIE     (RX_IDLE_ACTIVE_8G_ONLY_EIE ),
    .RX_IDLE_ACTIVE_5G_ONLY_EIE     (RX_IDLE_ACTIVE_5G_ONLY_EIE )

) pcie_bfm (

    .rst_n              (bfm_rst_n                              ),

    .core_rst_n         (core_rst_n                             ),
    .core_clk           (core_clk                               ),

    .clkreq_n           (clkreq_n                               ),
    .tx_p               (temp_model_to_dut_p[BFM_NUM_LANES-1:0] ),
    .tx_n               (temp_model_to_dut_n[BFM_NUM_LANES-1:0] ),

    .rx_p               (dut_to_model_p_brev[BFM_NUM_LANES-1:0] ),
    .rx_n               (dut_to_model_n_brev[BFM_NUM_LANES-1:0] ),
    .pl_link_up         (pl_link_up                             ),
    .dl_link_up         (dl_link_up                             ),

    .mgmt_training_mode (1'b1                                   ), // When DUT is not the RC, then set the BFM to be the RC
    .mgmt_pcie_status   (mgmt_pcie_status                       )  // Status port - very useful for system debug; See PCIe Core Datasheet
);

// Tie unused lanes inactive
genvar i;
generate
    if (BFM_NUM_LANES < NUM_LANES) begin
        for (i=BFM_NUM_LANES; i<NUM_LANES; i=i+1) begin
            assign temp_model_to_dut_p[i] = 1'bz;
            assign temp_model_to_dut_n[i] = 1'bz;
        end
    end
endgenerate

genvar j;
generate
    if (NUM_LANES < BFM_NUM_LANES) begin
        for (j=NUM_LANES; j<BFM_NUM_LANES; j=j+1) begin
            assign dut_to_model_p[j] = 1'bz;
            assign dut_to_model_n[j] = 1'bz;
        end
    end
endgenerate
 `ifdef BFM_ASSERTIONS
// ------------------------------------------------------
// Report PCIe BFM Assertions:
//   Requries Northwest Logic Root Complex PCIe BFM Model

report_assertions root_assert (

    .core_rst_n         (rst_n                          ),
    .core_clk           (core_clk                       ),

    .mgmt_pcie_status   (mgmt_pcie_status               )
);
 `endif

// ---------------------------------------------------------------------
// PCIe Test Sequences: Series of task calls exercising PCIe port of DUT

ref_design_ts ref_design_ts (

    .rst_n              (rst_n                          ),
    .clk                (core_clk                       ),

    .pl_link_up         (pl_link_up                     ),
    .dl_link_up         (dl_link_up                     ),

    .test_done          (test_done                      )
);

assign proc_wr_en   = 1'b0;
assign proc_rd_en   = 1'b0;
assign proc_addr    = 16'b0;
assign proc_wr_data = 32'b0;
assign i2c_reset_n  = 1'b0;
// --------------------------------------------------------------
// Watchdog timer. Stop simulation if no activity for a long time

integer wdt;

always @(posedge clk100)
begin
    if (pl_link_up === 1'b0)
        wdt <= 0;
    else if (activity_observed === 1'b1)
        wdt <= 0;
    else
        wdt <= wdt + 1;
end

always @(test_done)
begin
    if (test_done == 1'b1)
    begin
        if (FINISH_STOP_N) $finish; else $stop;
    end
end

always @(posedge clk100)
begin
    if (ACTIVITY_WDT_TIMEOUT != 0 && wdt === ACTIVITY_WDT_TIMEOUT)
    begin
        $display ("%m : ERROR : Activity Watchdog Timer expired. No activity noticed for %0d uS. Exiting at time %0t", (ACTIVITY_WDT_TIMEOUT/100), $time);
        pcie_bfm.inc_errors;
        pcie_bfm.report_status;
        //if (STOP_ON_ERR) if (FINISH_STOP_N) $finish; else $stop;
        // This fatal error should always end the sim., even if STOP_ON_ERR==0 to log other failures.
        if (FINISH_STOP_N) $finish; else $stop;
    end
end


// Halt test if the simulation time reaches absolute limit
always @(posedge clk100)
begin
    if (ABSOLUTE_WDT_TIMEOUT != 0 && $time > (ABSOLUTE_WDT_TIMEOUT * 1000000))
    begin
        $display ("%m : ERROR : Watchdog timer expired. Reached maximum time %0t", $time);
        pcie_bfm.inc_errors;
        pcie_bfm.report_status;
        // This fatal error should always end the sim., even if STOP_ON_ERR==0 to log other failures.
        //if (STOP_ON_ERR)
        if (FINISH_STOP_N) $finish; else $stop;
    end
end


endmodule


