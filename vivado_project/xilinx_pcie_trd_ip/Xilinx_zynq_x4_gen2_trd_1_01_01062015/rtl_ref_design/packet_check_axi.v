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

module packet_check_axi (

    rst_n,                  // Asynchronous active low reset
    clk,                    // Posedge Clock

    check_control,          // Enable check of user_control value

    reg_base_addr,          // Register Base Address

    reg_wr_addr,            // Register Interface
    reg_wr_en,              //
    reg_wr_be,              //
    reg_wr_data,            //
    reg_rd_addr,            //
    reg_rd_data,            //

    lpbk_user_status,       // Loopback Output
    lpbk_sop,               //
    lpbk_eop,               //
    lpbk_data,              //
    lpbk_valid,             //
    lpbk_src_rdy,           //
    lpbk_dst_rdy,           //

    s2c_wvalid,             // System to Card DMA AXI Interface
    s2c_wready,             //
    s2c_wdata,              //
    s2c_wstrb,              //
    s2c_wusereop,           //
    s2c_wusercontrol,       //
    s2c_bvalid,             //
    s2c_bready,             //
    s2c_bresp,              //

    s2c_fifo_addr_n         // FIFO/Addressable Packet DMA Selector

);



// ----------------
// -- Parameters --
// ----------------

localparam  AXI_DATA_WIDTH          = 64;
localparam  AXI_BE_WIDTH            = 8;
localparam  AXI_REMAIN_WIDTH        = 3;

parameter   REG_ADDR_WIDTH          = 13;

localparam  USER_CONTROL_WIDTH      = 64;
localparam  USER_STATUS_WIDTH       = 64;

localparam  REG_REMAIN              = 5;

// 64-bit (Two DWORD) address locations
localparam  ADDR_CTL                = 5'h0;
localparam  ADDR_PKT                = 5'h0;
localparam  ADDR_DSD                = 5'h1;
localparam  ADDR_USD                = 5'h1;
localparam  ADDR_ERR                = 5'h2;
localparam  ADDR_LT0                = 5'h4;
localparam  ADDR_LT1                = 5'h4;
localparam  ADDR_LT2                = 5'h5;
localparam  ADDR_LT3                = 5'h5;

// Pattern Types
localparam  PAT_CONSTANT            = 3'h0; // next = curr
localparam  PAT_INC_BYTE            = 3'h1; // for each byte:  next = curr + (AXI_DATA_WIDTH/8)
localparam  PAT_LFSR                = 3'h2; // for each dword: next = LFSR(curr)
localparam  PAT_INC_DWORD           = 3'h3; // for each dword: next = curr + (AXI_DATA_WIDTH/32)

// Define LFSR to use for PAT_LFSR patterns; psuedo-random 32-bit pattern
localparam  LFSR_BITS               = 32;
localparam  LFSR_XNOR_MASK          = 32'b1000_0000_0010_0000_0000_0100_0000_0011; // bits 31, 21, 10, 1, and 0 (LFSR bits: 31:0)

// State Machine Status
localparam  IDLE                    = 4'b0001;
localparam  PREP                    = 4'b0010;
localparam  XFER                    = 4'b0100;
localparam  LPBK                    = 4'b1000;



// ----------------------
// -- Port Definitions --
// ----------------------

input                               rst_n;
input                               clk;

input                               check_control;

input   [REG_ADDR_WIDTH-1:0]        reg_base_addr;

input   [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
input                               reg_wr_en;
input   [AXI_BE_WIDTH-1:0]          reg_wr_be;
input   [AXI_DATA_WIDTH-1:0]        reg_wr_data;
input   [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
output  [AXI_DATA_WIDTH-1:0]        reg_rd_data;

output  [USER_STATUS_WIDTH-1:0]     lpbk_user_status;
output                              lpbk_sop;
output                              lpbk_eop;
output  [AXI_DATA_WIDTH-1:0]        lpbk_data;
output  [AXI_REMAIN_WIDTH-1:0]      lpbk_valid;
output                              lpbk_src_rdy;
input                               lpbk_dst_rdy;

input                               s2c_wvalid;
output                              s2c_wready;
input   [AXI_DATA_WIDTH-1:0]        s2c_wdata;
input   [AXI_BE_WIDTH-1:0]          s2c_wstrb;
input                               s2c_wusereop;
input   [USER_CONTROL_WIDTH-1:0]    s2c_wusercontrol;
output                              s2c_bvalid;
input                               s2c_bready;
output  [1:0]                       s2c_bresp;

output                              s2c_fifo_addr_n;



// ----------------
// -- Port Types --
// ----------------

wire                                rst_n;
wire                                clk;

wire                                check_control;

wire    [REG_ADDR_WIDTH-1:0]        reg_base_addr;

wire    [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
wire                                reg_wr_en;
wire    [AXI_BE_WIDTH-1:0]          reg_wr_be;
wire    [AXI_DATA_WIDTH-1:0]        reg_wr_data;
wire    [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
reg     [AXI_DATA_WIDTH-1:0]        reg_rd_data;

wire    [USER_STATUS_WIDTH-1:0]     lpbk_user_status;
wire                                lpbk_sop;
wire                                lpbk_eop;
wire    [AXI_DATA_WIDTH-1:0]        lpbk_data;
wire    [AXI_REMAIN_WIDTH-1:0]      lpbk_valid;
wire                                lpbk_src_rdy;
wire                                lpbk_dst_rdy;

wire                                s2c_wvalid;
wire                                s2c_wready;
wire    [AXI_DATA_WIDTH-1:0]        s2c_wdata;
wire    [AXI_BE_WIDTH-1:0]          s2c_wstrb;
wire                                s2c_wusereop;
wire    [USER_CONTROL_WIDTH-1:0]    s2c_wusercontrol;
reg                                 s2c_bvalid;
wire                                s2c_bready;
wire    [1:0]                       s2c_bresp;

reg                                 s2c_fifo_addr_n /* synthesis syn_maxfan = 32 */;



// -------------------
// -- Local Signals --
// -------------------

wire    [LFSR_BITS-1:0]             sized_lfsr_xnor_mask;

// Pipeline Reset
reg                                 r7_dma_rst_n;

reg                                 r8_0_dma_rst_n;
reg                                 r8_1_dma_rst_n;
reg                                 r8_2_dma_rst_n;
reg                                 r8_3_dma_rst_n;
reg                                 r8_4_dma_rst_n;
reg                                 r8_5_dma_rst_n;
reg                                 r8_6_dma_rst_n;
reg                                 r8_7_dma_rst_n;
reg                                 r8_8_dma_rst_n;
reg                                 r8_9_dma_rst_n;
reg                                 r8_10_dma_rst_n;
reg                                 r8_11_dma_rst_n;
reg                                 r8_12_dma_rst_n;
reg                                 r8_13_dma_rst_n;
reg                                 r8_14_dma_rst_n;
reg                                 r8_15_dma_rst_n;

// Register Read-Back
wire                                reg_rd_hit;

// Register Decodes
reg     [AXI_DATA_WIDTH-1:0]        r_reg_wr_data;

wire                                reg_wr_hit;

reg                                 ctl_wr_en0;
reg                                 ctl_wr_en1;
reg                                 ctl_wr_en2;
reg                                 ctl_wr_en3;

wire    [7:0]                       ctl_wr_data0;
wire    [7:0]                       ctl_wr_data1;
wire    [7:0]                       ctl_wr_data2;
wire    [7:0]                       ctl_wr_data3;

reg                                 pkt_wr_en0;
reg                                 pkt_wr_en1;
reg                                 pkt_wr_en2;
reg                                 pkt_wr_en3;

wire    [7:0]                       pkt_wr_data0;
wire    [7:0]                       pkt_wr_data1;
wire    [7:0]                       pkt_wr_data2;
wire    [7:0]                       pkt_wr_data3;

reg                                 dsd_wr_en0;
reg                                 dsd_wr_en1;
reg                                 dsd_wr_en2;
reg                                 dsd_wr_en3;

wire    [7:0]                       dsd_wr_data0;
wire    [7:0]                       dsd_wr_data1;
wire    [7:0]                       dsd_wr_data2;
wire    [7:0]                       dsd_wr_data3;

reg                                 usd_wr_en0;
reg                                 usd_wr_en1;
reg                                 usd_wr_en2;
reg                                 usd_wr_en3;

wire    [7:0]                       usd_wr_data0;
wire    [7:0]                       usd_wr_data1;
wire    [7:0]                       usd_wr_data2;
wire    [7:0]                       usd_wr_data3;

reg                                 err_wr_en0;
//reg                                 err_wr_en1;
//reg                                 err_wr_en2;
//reg                                 err_wr_en3;

wire    [7:0]                       err_wr_data0;
//wire    [7:0]                       err_wr_data1;
//wire    [7:0]                       err_wr_data2;
//wire    [7:0]                       err_wr_data3;

reg                                 lt0_wr_en0;
reg                                 lt0_wr_en1;
reg                                 lt0_wr_en2;

reg                                 lt1_wr_en0;
reg                                 lt1_wr_en1;
reg                                 lt1_wr_en2;

reg                                 lt2_wr_en0;
reg                                 lt2_wr_en1;
reg                                 lt2_wr_en2;

reg                                 lt3_wr_en0;
reg                                 lt3_wr_en1;
reg                                 lt3_wr_en2;

wire    [7:0]                       lt0_wr_data0;
wire    [7:0]                       lt0_wr_data1;
wire    [3:0]                       lt0_wr_data2;

wire    [7:0]                       lt1_wr_data0;
wire    [7:0]                       lt1_wr_data1;
wire    [3:0]                       lt1_wr_data2;

wire    [7:0]                       lt2_wr_data0;
wire    [7:0]                       lt2_wr_data1;
wire    [3:0]                       lt2_wr_data2;

wire    [7:0]                       lt3_wr_data0;
wire    [7:0]                       lt3_wr_data1;
wire    [3:0]                       lt3_wr_data2;

// Register Implementation
reg                                 pkt_enable;
reg                                 pkt_enable_clear;
reg                                 pkt_loopback;
reg                                 pkt_sel_ram_pkt_n_i;
reg     [1:0]                       pkt_table_entries;
reg     [2:0]                       pkt_data_pattern;
reg                                 pkt_data_continue;
reg     [2:0]                       pkt_user_pattern;
reg                                 pkt_user_continue;
reg     [7:0]                       active_clocks;
reg     [7:0]                       inactive_clocks;
wire    [31:0]                      ctl_rd_data;

reg     [31:0]                      num_packets;
wire    [31:0]                      pkt_rd_data;

reg     [31:0]                      data_seed;
wire    [31:0]                      dsd_rd_data;

reg     [31:0]                      user_control_seed;
wire    [31:0]                      usd_rd_data;

reg                                 err_sop;
reg                                 err_eop;
reg                                 err_cpl;
reg                                 err_data;
reg                                 err_data_valid;
reg                                 err_user_control;
reg                                 err_clear;
reg     [23:0]                      err_ctr;

wire    [31:0]                      err_rd_data;

reg     [19:0]                      pkt_length0;
reg     [19:0]                      pkt_length1;
reg     [19:0]                      pkt_length2;
reg     [19:0]                      pkt_length3;

wire    [31:0]                      lt0_rd_data;
wire    [31:0]                      lt1_rd_data;
wire    [31:0]                      lt2_rd_data;
wire    [31:0]                      lt3_rd_data;

// Generate Packet Pattern
wire                                en;

reg     [3:0]                       state;

wire                                c_state_prep;
reg     [8:0]                       state_prep;
reg     [1:0]                       state_lpbk;
reg                                 state_lpbk_n;

reg                                 in_pkt;

reg     [1:0]                       hold_pkt_table_entries;
reg     [2:0]                       hold_pkt_data_pattern;
reg                                 hold_pkt_data_continue;
reg     [2:0]                       hold_pkt_user_pattern;
reg                                 hold_pkt_user_continue;
reg     [7:0]                       hold_active_clocks;
reg     [7:0]                       hold_inactive_clocks;

reg     [31:0]                      num_packets_ctr;
reg                                 num_packets_ctr_eq1;

reg     [1:0]                       curr_pkt_table_entry;
reg     [19:0]                      pkt_length;

reg     [19:0]                      pkt_length_ctr;

wire                                c_start_new_pkt;
wire                                c_pkt_length_ctr_is_2_words;

wire    [AXI_REMAIN_WIDTH:0]        c_load_pkt_data_remain;
wire    [AXI_REMAIN_WIDTH:0]        c_ctr_pkt_data_remain;

reg                                 seed_sop;
reg                                 seed_eop;
reg     [AXI_REMAIN_WIDTH-1:0]      seed_data_remain;
reg     [31:0]                      next_data_seed;
reg     [31:0]                      next_user_control_seed;

// Check Packet
reg                                 check_en;

reg                                 check_sop;
reg                                 check_eop;
reg                                 check_err;
reg     [AXI_REMAIN_WIDTH-1:0]      check_data_valid;
reg     [AXI_DATA_WIDTH-1:0]        check_data;
reg     [USER_CONTROL_WIDTH-1:0]    check_user_control;
                                   
reg                                 expected_sop;
reg                                 expected_eop;
reg     [AXI_REMAIN_WIDTH-1:0]      expected_data_valid;
reg     [AXI_BE_WIDTH-1:0]          expected_check_bytes;
                                   
reg                                 d_det_err_sop;
reg                                 d_det_err_eop;
reg                                 d_det_err_cpl;
reg     [AXI_BE_WIDTH-1:0]          d_det_err_data;
reg                                 d_det_err_data_valid;
reg                                 d_det_err_user_control;

reg                                 det_err_sop;
reg                                 det_err_eop;
reg                                 det_err_cpl;
reg                                 det_err_data;
reg                                 det_err_data_valid;
reg                                 det_err_user_control;

reg                                 det_err;

// Compute Next Data Value
wire    [LFSR_BITS-1:0]             next_data_lfsr2;
wire    [LFSR_BITS-1:0]             next_data_lfsr1;

reg     [31:0]                      next2;
reg     [31:0]                      next1;

reg     [AXI_DATA_WIDTH-1:0]        expected_data;

wire    [AXI_REMAIN_WIDTH:0]        seed_data_valid;

// Compute Next User Control Value
wire    [LFSR_BITS-1:0]             next_user_control_lfsr2;
wire    [LFSR_BITS-1:0]             next_user_control_lfsr1;

reg     [31:0]                      unext2;
reg     [31:0]                      unext1;

reg     [USER_CONTROL_WIDTH-1:0]    expected_user_control;

reg     [7:0]                       hi_ctr;
reg     [7:0]                       lo_ctr;

reg                                 check_dst_rdy;

// Loopback
reg                                 lpbi_src_rdy;
reg                                 lpbi_empty;
reg                                 lpbi_sop;
reg                                 lpbi_eop;
reg     [AXI_REMAIN_WIDTH-1:0]      lpbi_valid;
reg     [AXI_DATA_WIDTH-1:0]        lpbi_data;

reg     [USER_CONTROL_WIDTH-1:0]    hold_user_control;

wire    [USER_STATUS_WIDTH-1:0]     lpbi_user_status;
wire                                lpbi_dst_rdy;

// AXI Interface
reg     [AXI_REMAIN_WIDTH-1:0]      valid;
wire                                src_rdy;
wire                                dst_rdy;
wire    [AXI_DATA_WIDTH-1:0]        data;
wire                                eop;
wire                                err;
wire    [USER_CONTROL_WIDTH-1:0]    user_control;
reg                                 sop;

wire                                i_s2c_wvalid;
wire                                i_s2c_wready;
wire    [AXI_DATA_WIDTH-1:0]        i_s2c_wdata;
wire    [AXI_BE_WIDTH-1:0]          i_s2c_wstrb;
wire                                i_s2c_wusereop;
wire    [USER_CONTROL_WIDTH-1:0]    i_s2c_wusercontrol;



// ---------------
// -- Equations --
// ---------------

// Size localpram LFSR_XNOR_MASK
assign sized_lfsr_xnor_mask = LFSR_XNOR_MASK;



// --------------
// Pipeline Reset

// rst_n input is delayed 6 of 8 clocks at input to this 
//   module; delay an additional 2 clocks to release at
//   the same 8 clock delay time as other logic using
//   this reset tree; take advantage of reset tree to
//   reduce reset fanout
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        r7_dma_rst_n    <= 1'b0;

        r8_0_dma_rst_n  <= 1'b0;
        r8_1_dma_rst_n  <= 1'b0;
        r8_2_dma_rst_n  <= 1'b0;
        r8_3_dma_rst_n  <= 1'b0;
        r8_4_dma_rst_n  <= 1'b0;
        r8_5_dma_rst_n  <= 1'b0;
        r8_6_dma_rst_n  <= 1'b0;
        r8_7_dma_rst_n  <= 1'b0;
        r8_8_dma_rst_n  <= 1'b0;
        r8_9_dma_rst_n  <= 1'b0;
        r8_10_dma_rst_n <= 1'b0;
        r8_11_dma_rst_n <= 1'b0;
        r8_12_dma_rst_n <= 1'b0;
        r8_13_dma_rst_n <= 1'b0;
        r8_14_dma_rst_n <= 1'b0;
        r8_15_dma_rst_n <= 1'b0;
    end
    else
    begin
        r7_dma_rst_n    <= 1'b1;

        r8_0_dma_rst_n  <= r7_dma_rst_n;
        r8_1_dma_rst_n  <= r7_dma_rst_n;
        r8_2_dma_rst_n  <= r7_dma_rst_n;
        r8_3_dma_rst_n  <= r7_dma_rst_n;
        r8_4_dma_rst_n  <= r7_dma_rst_n;
        r8_5_dma_rst_n  <= r7_dma_rst_n;
        r8_6_dma_rst_n  <= r7_dma_rst_n;
        r8_7_dma_rst_n  <= r7_dma_rst_n;
        r8_8_dma_rst_n  <= r7_dma_rst_n;
        r8_9_dma_rst_n  <= r7_dma_rst_n;
        r8_10_dma_rst_n <= r7_dma_rst_n;
        r8_11_dma_rst_n <= r7_dma_rst_n;
        r8_12_dma_rst_n <= r7_dma_rst_n;
        r8_13_dma_rst_n <= r7_dma_rst_n;
        r8_14_dma_rst_n <= r7_dma_rst_n;
        r8_15_dma_rst_n <= r7_dma_rst_n;
    end
end



// -----------------
// Abort Acknowledge

wire    abort = 1'b0;
/*
always @(posedge clk or negedge r8_0_dma_rst_n)
begin
    if (r8_0_dma_rst_n == 1'b0)
        abort_ack <= 1'b0;
    else
        // Acknowledge abort once we reach the IDLE state; 
        //   include ~abort_ack so we can register output
        //   and only generate only a 1 clock pulse
        abort_ack <= abort & (state == IDLE) & ~abort_ack;
end
*/



// ------------------
// Register Read-Back

assign reg_rd_hit = (reg_rd_addr[REG_ADDR_WIDTH-1:5] == reg_base_addr[REG_ADDR_WIDTH-1:5]);

always @(posedge clk or negedge r8_0_dma_rst_n)
begin
    if (r8_0_dma_rst_n == 1'b0)
        reg_rd_data <= {AXI_DATA_WIDTH{1'b0}};
    else
    begin
        if (reg_rd_hit)
        begin
            case (reg_rd_addr[4:0])

                ADDR_CTL    : reg_rd_data <= {pkt_rd_data,
                                              ctl_rd_data};

                ADDR_DSD    : reg_rd_data <= {usd_rd_data,
                                              dsd_rd_data};

                ADDR_ERR    : reg_rd_data <= {32'h0,
                                              err_rd_data};

                ADDR_LT0    : reg_rd_data <= {lt1_rd_data,
                                              lt0_rd_data};

                ADDR_LT2    : reg_rd_data <= {lt3_rd_data,
                                              lt2_rd_data};

                default     : reg_rd_data <= {AXI_DATA_WIDTH{1'b0}};

            endcase
        end
        else
        begin
            reg_rd_data <= {AXI_DATA_WIDTH{1'b0}};
        end
    end
end


// ----------------
// Register Decodes

// Pipeline writes for speed; input signals would otherwise have too high fanout
always @(posedge clk or negedge r8_1_dma_rst_n)
begin
    if (r8_1_dma_rst_n == 1'b0)
        r_reg_wr_data <= {AXI_DATA_WIDTH{1'b0}};
    else
        r_reg_wr_data <= reg_wr_data;
end

// Check for a base address hit; DMA Registers are a 256 byte block (32 64-bit Register Words)
assign reg_wr_hit = (reg_wr_addr[REG_ADDR_WIDTH-1:5] == reg_base_addr[REG_ADDR_WIDTH-1:5]);

// Control and Status
always @(posedge clk or negedge r8_2_dma_rst_n)
begin
    if (r8_2_dma_rst_n == 1'b0)
    begin
        ctl_wr_en0 <= 1'b0;
        ctl_wr_en1 <= 1'b0;
        ctl_wr_en2 <= 1'b0;
        ctl_wr_en3 <= 1'b0;
    end
    else
    begin
        ctl_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_CTL) & reg_wr_be[0];
        ctl_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_CTL) & reg_wr_be[1];
        ctl_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_CTL) & reg_wr_be[2];
        ctl_wr_en3 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_CTL) & reg_wr_be[3];
    end
end

assign ctl_wr_data0 = r_reg_wr_data[ 7: 0];
assign ctl_wr_data1 = r_reg_wr_data[15: 8];
assign ctl_wr_data2 = r_reg_wr_data[23:16];
assign ctl_wr_data3 = r_reg_wr_data[31:24];

// Num Packets
always @(posedge clk or negedge r8_2_dma_rst_n)
begin
    if (r8_2_dma_rst_n == 1'b0)
    begin
        pkt_wr_en0 <= 1'b0;
        pkt_wr_en1 <= 1'b0;
        pkt_wr_en2 <= 1'b0;
        pkt_wr_en3 <= 1'b0;
    end
    else
    begin
        pkt_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_PKT) & reg_wr_be[4];
        pkt_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_PKT) & reg_wr_be[5];
        pkt_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_PKT) & reg_wr_be[6];
        pkt_wr_en3 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_PKT) & reg_wr_be[7];
    end
end

assign pkt_wr_data0 = r_reg_wr_data[39:32];
assign pkt_wr_data1 = r_reg_wr_data[47:40];
assign pkt_wr_data2 = r_reg_wr_data[55:48];
assign pkt_wr_data3 = r_reg_wr_data[63:56];

// Data Seed
always @(posedge clk or negedge r8_2_dma_rst_n)
begin
    if (r8_2_dma_rst_n == 1'b0)
    begin
        dsd_wr_en0 <= 1'b0;
        dsd_wr_en1 <= 1'b0;
        dsd_wr_en2 <= 1'b0;
        dsd_wr_en3 <= 1'b0;
    end
    else
    begin
        dsd_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_DSD) & reg_wr_be[0];
        dsd_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_DSD) & reg_wr_be[1];
        dsd_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_DSD) & reg_wr_be[2];
        dsd_wr_en3 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_DSD) & reg_wr_be[3];
    end
end

assign dsd_wr_data0 = r_reg_wr_data[ 7: 0];
assign dsd_wr_data1 = r_reg_wr_data[15: 8];
assign dsd_wr_data2 = r_reg_wr_data[23:16];
assign dsd_wr_data3 = r_reg_wr_data[31:24];

// User Control Seed
always @(posedge clk or negedge r8_2_dma_rst_n)
begin
    if (r8_2_dma_rst_n == 1'b0)
    begin
        usd_wr_en0 <= 1'b0;
        usd_wr_en1 <= 1'b0;
        usd_wr_en2 <= 1'b0;
        usd_wr_en3 <= 1'b0;
    end
    else
    begin
        usd_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USD) & reg_wr_be[4];
        usd_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USD) & reg_wr_be[5];
        usd_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USD) & reg_wr_be[6];
        usd_wr_en3 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USD) & reg_wr_be[7];
    end
end

assign usd_wr_data0 = r_reg_wr_data[39:32];
assign usd_wr_data1 = r_reg_wr_data[47:40];
assign usd_wr_data2 = r_reg_wr_data[55:48];
assign usd_wr_data3 = r_reg_wr_data[63:56];

// Error Register
always @(posedge clk or negedge r8_2_dma_rst_n)
begin
    if (r8_2_dma_rst_n == 1'b0)
    begin
        err_wr_en0 <= 1'b0;
//        err_wr_en1 <= 1'b0;
//        err_wr_en2 <= 1'b0;
//        err_wr_en3 <= 1'b0;
    end
    else
    begin
        err_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_ERR) & reg_wr_be[0];
//        err_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_ERR) & reg_wr_be[1];
//        err_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_ERR) & reg_wr_be[2];
//        err_wr_en3 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_ERR) & reg_wr_be[3];
    end
end

assign err_wr_data0 = r_reg_wr_data[ 7: 0];
//assign err_wr_data1 = r_reg_wr_data[15: 8];
//assign err_wr_data2 = r_reg_wr_data[23:16];
//assign err_wr_data3 = r_reg_wr_data[31:24];

// Packet Length Table
always @(posedge clk or negedge r8_2_dma_rst_n)
begin
    if (r8_2_dma_rst_n == 1'b0)
    begin
        lt0_wr_en0 <= 1'b0;
        lt0_wr_en1 <= 1'b0;
        lt0_wr_en2 <= 1'b0;

        lt1_wr_en0 <= 1'b0;
        lt1_wr_en1 <= 1'b0;
        lt1_wr_en2 <= 1'b0;

        lt2_wr_en0 <= 1'b0;
        lt2_wr_en1 <= 1'b0;
        lt2_wr_en2 <= 1'b0;

        lt3_wr_en0 <= 1'b0;
        lt3_wr_en1 <= 1'b0;
        lt3_wr_en2 <= 1'b0;
    end
    else
    begin
        lt0_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT0) & reg_wr_be[0];
        lt0_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT0) & reg_wr_be[1];
        lt0_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT0) & reg_wr_be[2];

        lt1_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT1) & reg_wr_be[4];
        lt1_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT1) & reg_wr_be[5];
        lt1_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT1) & reg_wr_be[6];

        lt2_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT2) & reg_wr_be[0];
        lt2_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT2) & reg_wr_be[1];
        lt2_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT2) & reg_wr_be[2];

        lt3_wr_en0 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT3) & reg_wr_be[4];
        lt3_wr_en1 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT3) & reg_wr_be[5];
        lt3_wr_en2 <= reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_LT3) & reg_wr_be[6];
    end
end

assign lt0_wr_data0 = r_reg_wr_data[ 7: 0];
assign lt0_wr_data1 = r_reg_wr_data[15: 8];
assign lt0_wr_data2 = r_reg_wr_data[19:16];

assign lt1_wr_data0 = r_reg_wr_data[39:32];
assign lt1_wr_data1 = r_reg_wr_data[47:40];
assign lt1_wr_data2 = r_reg_wr_data[51:48];

assign lt2_wr_data0 = r_reg_wr_data[ 7: 0];
assign lt2_wr_data1 = r_reg_wr_data[15: 8];
assign lt2_wr_data2 = r_reg_wr_data[19:16];

assign lt3_wr_data0 = r_reg_wr_data[39:32];
assign lt3_wr_data1 = r_reg_wr_data[47:40];
assign lt3_wr_data2 = r_reg_wr_data[51:48];
// -----------------------
// Register Implementation

// Control and Status
always @(posedge clk or negedge r8_3_dma_rst_n)
begin
    if (r8_3_dma_rst_n == 1'b0)
    begin
        pkt_enable          <= 1'b0;
        pkt_enable_clear    <= 1'b0;
        pkt_loopback        <= 1'b0;
        pkt_sel_ram_pkt_n_i <= 1'b0;
        s2c_fifo_addr_n     <= 1'b1;
        pkt_table_entries   <= 2'h0;

        pkt_data_pattern    <= 3'h0; 
        pkt_data_continue   <= 1'b0;
        pkt_user_pattern    <= 3'h0;
        pkt_user_continue   <= 1'b0;

        active_clocks       <= 8'h0;

        inactive_clocks     <= 8'h0;
    end
    else
    begin
        // Byte 0

        // pkt_enable is set by software to start packet generation;
        //   pkt_enable is cleared only at the end of a packet transfer
        if (ctl_wr_en0 & ctl_wr_data0[0] & ~abort) // Don't set if currently aborting DMA
            pkt_enable <= 1'b1;
        // Clear when last packet completes or on S/W request
        else if ((state == XFER) & (en & eop) & (pkt_enable_clear | num_packets_ctr_eq1)) 
            pkt_enable <= 1'b0;

        if ((ctl_wr_en0 & ~ctl_wr_data0[0]) | abort) // Clear pkt_enable at next oportunity when software wants to abort
            pkt_enable_clear <= 1'b1;
        else if (state == IDLE)
            pkt_enable_clear <= 1'b0;

        if (ctl_wr_en0)
            pkt_loopback <= ctl_wr_data0[1] & ~abort; // Don't set if currently aborting DMA

        if (ctl_wr_en0)
            pkt_sel_ram_pkt_n_i <= ctl_wr_data0[2];

        s2c_fifo_addr_n <= ~pkt_sel_ram_pkt_n_i;

        if (ctl_wr_en0)
            pkt_table_entries <= ctl_wr_data0[5:4];

        // Byte 1

        if (ctl_wr_en1)
        begin
            pkt_data_pattern  <= ctl_wr_data1[2:0]; 
            pkt_data_continue <= ctl_wr_data1[  3]; 
            pkt_user_pattern  <= ctl_wr_data1[6:4]; 
            pkt_user_continue <= ctl_wr_data1[  7]; 
        end

        // Byte 2

        if (ctl_wr_en2)
            active_clocks <= ctl_wr_data2[7:0]; 

        // Byte 3

        if (ctl_wr_en3)
            inactive_clocks <= ctl_wr_data3[7:0]; 
    end
end

assign ctl_rd_data = {inactive_clocks[7:0],
                      active_clocks[7:0],
                      pkt_user_continue, pkt_user_pattern[2:0], pkt_data_continue, pkt_data_pattern[2:0],
                      2'h0, pkt_table_entries[1:0], 1'h0, pkt_sel_ram_pkt_n_i, pkt_loopback, pkt_enable};

// Num Packets
always @(posedge clk or negedge r8_4_dma_rst_n)
begin
    if (r8_4_dma_rst_n == 1'b0)
    begin
        num_packets <= 32'h0;
    end
    else
    begin
        // Byte 0

        if (pkt_wr_en0)
            num_packets[ 7: 0] <= pkt_wr_data0[7:0];

        // Byte 1

        if (pkt_wr_en1)
            num_packets[15: 8] <= pkt_wr_data1[7:0];

        // Byte 2

        if (pkt_wr_en2)
            num_packets[23:16] <= pkt_wr_data2[7:0];

        // Byte 3

        if (pkt_wr_en3)
            num_packets[31:24] <= pkt_wr_data3[7:0];
    end
end

assign pkt_rd_data = num_packets[31:0];

// Data Seed
always @(posedge clk or negedge r8_5_dma_rst_n)
begin
    if (r8_5_dma_rst_n == 1'b0)
    begin
        data_seed <= 32'h0;
    end
    else
    begin
        // Byte 0

        if (dsd_wr_en0)
            data_seed[ 7: 0] <= dsd_wr_data0[7:0];

        // Byte 1

        if (dsd_wr_en1)
            data_seed[15: 8] <= dsd_wr_data1[7:0];

        // Byte 2

        if (dsd_wr_en2)
            data_seed[23:16] <= dsd_wr_data2[7:0];

        // Byte 3

        if (dsd_wr_en3)
            data_seed[31:24] <= dsd_wr_data3[7:0];
    end
end

assign dsd_rd_data = data_seed[31:0];

// User Control Seed
always @(posedge clk or negedge r8_6_dma_rst_n)
begin
    if (r8_6_dma_rst_n == 1'b0)
    begin
        user_control_seed <= 32'h0;
    end
    else
    begin
        // Byte 0

        if (usd_wr_en0)
            user_control_seed[ 7: 0] <= usd_wr_data0[7:0];

        // Byte 1

        if (usd_wr_en1)
            user_control_seed[15: 8] <= usd_wr_data1[7:0];

        // Byte 2

        if (usd_wr_en2)
            user_control_seed[23:16] <= usd_wr_data2[7:0];

        // Byte 3

        if (usd_wr_en3)
            user_control_seed[31:24] <= usd_wr_data3[7:0];
    end
end

assign usd_rd_data = user_control_seed[31:0];

// Error Register
always @(posedge clk or negedge r8_7_dma_rst_n)
begin
    if (r8_7_dma_rst_n == 1'b0)
    begin
        err_sop          <= 1'b0;
        err_eop          <= 1'b0;
        err_cpl          <= 1'b0;
        err_data         <= 1'b0;
        err_data_valid   <= 1'b0;
        err_user_control <= 1'b0;

        err_clear        <= 1'b0;

        err_ctr          <= 24'h0;
    end
    else
    begin
        // Byte 0

        if (det_err_sop)
            err_sop <= 1'b1;
        else if (err_clear)
            err_sop <= 1'b0;

        if (det_err_eop)
            err_eop <= 1'b1;
        else if (err_clear)
            err_eop <= 1'b0;

        if (det_err_cpl)
            err_cpl <= 1'b1;
        else if (err_clear)
            err_cpl <= 1'b0;

        if (det_err_data)
            err_data <= 1'b1;
        else if (err_clear)
            err_data <= 1'b0;

        if (det_err_data_valid)
            err_data_valid <= 1'b1;
        else if (err_clear)
            err_data_valid <= 1'b0;

        if (det_err_user_control)
            err_user_control <= 1'b1;
        else if (err_clear)
            err_user_control <= 1'b0;

        // Create one clock strobe to clear error
        //   information on software request
        if (err_wr_en0)
            err_clear <= err_wr_data0[7];
        else 
            err_clear <= 1'b0;

        // Bytes 3:1

        if (err_clear)
            err_ctr <= 24'h0;
        else if (det_err & (err_ctr != 24'hffffff)) // Saturate at max count
            err_ctr <= err_ctr + 24'h1;
    end
end

assign err_rd_data = {err_ctr[23:0], 2'h0, err_user_control, err_data_valid, err_data, err_cpl, err_eop, err_sop};  

// Packet Length Table
always @(posedge clk or negedge r8_8_dma_rst_n)
begin
    if (r8_8_dma_rst_n == 1'b0)
    begin
        pkt_length0 <= 20'h0;
        pkt_length1 <= 20'h0;
        pkt_length2 <= 20'h0;
        pkt_length3 <= 20'h0;
    end
    else
    begin
        // LT0

        // Byte 0
        if (lt0_wr_en0)
            pkt_length0[ 7: 0] <= lt0_wr_data0[7:0];

        // Byte 1
        if (lt0_wr_en1)
            pkt_length0[15: 8] <= lt0_wr_data1[7:0];

        // Byte 2
        if (lt0_wr_en2)
            pkt_length0[19:16] <= lt0_wr_data2[3:0];

        // LT1

        // Byte 0
        if (lt1_wr_en0)
            pkt_length1[ 7: 0] <= lt1_wr_data0[7:0];

        // Byte 1
        if (lt1_wr_en1)
            pkt_length1[15: 8] <= lt1_wr_data1[7:0];

        // Byte 2
        if (lt1_wr_en2)
            pkt_length1[19:16] <= lt1_wr_data2[3:0];

        // LT2

        // Byte 0
        if (lt2_wr_en0)
            pkt_length2[ 7: 0] <= lt2_wr_data0[7:0];

        // Byte 1
        if (lt2_wr_en1)
            pkt_length2[15: 8] <= lt2_wr_data1[7:0];

        // Byte 2
        if (lt2_wr_en2)
            pkt_length2[19:16] <= lt2_wr_data2[3:0];

        // LT3

        // Byte 0
        if (lt3_wr_en0)
            pkt_length3[ 7: 0] <= lt3_wr_data0[7:0];

        // Byte 1
        if (lt3_wr_en1)
            pkt_length3[15: 8] <= lt3_wr_data1[7:0];

        // Byte 2
        if (lt3_wr_en2)
            pkt_length3[19:16] <= lt3_wr_data2[3:0];
    end
end

assign lt0_rd_data = {12'h0, pkt_length0};
assign lt1_rd_data = {12'h0, pkt_length1};
assign lt2_rd_data = {12'h0, pkt_length2};
assign lt3_rd_data = {12'h0, pkt_length3};



// -----------------------
// Generate Packet Pattern

assign en = src_rdy & dst_rdy; // Enable when packet data is taken by this module

always @(posedge clk or negedge r8_9_dma_rst_n)
begin
    if (r8_9_dma_rst_n == 1'b0)
    begin
        state <= IDLE;
    end
    else
    begin
        case (state)

            IDLE    :   if (pkt_enable & ~abort)
                            state <= PREP;
                        else if (pkt_loopback & ~abort)
                            state <= LPBK;

            PREP    :   state <= XFER;

            XFER    :   if ((en & eop) & (pkt_enable_clear | num_packets_ctr_eq1))
                            state <= IDLE;

            // Leave loopback mode when loopback is disabled and ending a packet or idle and not starting a new packet
            LPBK    :   if (~pkt_loopback & ( (           (eop & src_rdy & dst_rdy)) |
                                              (~in_pkt & ~(sop & src_rdy & dst_rdy)) ) )
                            state <= IDLE;

           default  :   state <= IDLE;

        endcase
    end
end

// Create multiple copies of states to reduce fanout
assign c_state_prep = (state == IDLE) & (pkt_enable & ~abort);

always @(posedge clk or negedge r8_9_dma_rst_n)
begin
    if (r8_9_dma_rst_n == 1'b0)
    begin
        state_prep   <= {9{1'b0}};
        state_lpbk   <= {2{1'b0}};
        state_lpbk_n <=    1'b1;
    end
    else
    begin
        state_prep <= {9{c_state_prep}};

        if ((state == IDLE) & ~(pkt_enable & ~abort) & (pkt_loopback & ~abort))
        begin
            state_lpbk   <= {2{1'b1}};
            state_lpbk_n <=    1'b0;
        end
        else if ((state == LPBK) & (~pkt_loopback & ( (           (eop & src_rdy & dst_rdy)) |
                                                      (~in_pkt & ~(sop & src_rdy & dst_rdy)) ) ) )
        begin
            state_lpbk   <= {2{1'b0}};
            state_lpbk_n <=    1'b1;
        end
    end
end

// Keep track of when we are busy receiving a packet
always @(posedge clk or negedge r8_9_dma_rst_n)
begin
    if (r8_9_dma_rst_n == 1'b0)
    begin
        in_pkt <= 1'b0;
    end
    else
    begin
        if (sop & ~eop & src_rdy & dst_rdy)
            in_pkt <= 1'b1;
        else if (eop & src_rdy & dst_rdy)
            in_pkt <= 1'b0;
    end
end

// Hold register values for entire operation
always @(posedge clk or negedge r8_10_dma_rst_n)
begin
    if (r8_10_dma_rst_n == 1'b0)
    begin
        hold_pkt_table_entries <= 2'h0;
        hold_pkt_data_pattern  <= 3'h0;
        hold_pkt_data_continue <= 1'b0;
        hold_pkt_user_pattern  <= 3'h0;
        hold_pkt_user_continue <= 1'b0;
        hold_active_clocks     <= 8'h0;
        hold_inactive_clocks   <= 8'h0;

        num_packets_ctr        <= 32'h0;
        num_packets_ctr_eq1    <= 1'b0;

        curr_pkt_table_entry   <= 2'h0;
        pkt_length             <= 20'h0;

        pkt_length_ctr         <= 20'h0;
    end
    else
    begin
        if (state == IDLE)
        begin
            hold_pkt_table_entries <= pkt_table_entries;
            hold_pkt_data_pattern  <= pkt_data_pattern;
            hold_pkt_data_continue <= pkt_data_continue;
            hold_pkt_user_pattern  <= pkt_user_pattern;
            hold_pkt_user_continue <= pkt_user_continue;
            hold_active_clocks     <= active_clocks; 
            hold_inactive_clocks   <= inactive_clocks;
        end

        if (state == IDLE)
            num_packets_ctr <= num_packets;
        else if (en & eop & (num_packets_ctr != 32'h0)) // Decrement on end of packet transfer when not in infinite mode
            num_packets_ctr <= num_packets_ctr - 32'h1;

        // Pre-decode num_packets_ctr == 1 for timing speed
        if (state_prep[0]) // num_packets_ctr_eq1 is not used until state == XFER           
            num_packets_ctr_eq1 <= (num_packets_ctr == 32'h1); // Loaded with 1
        else if (en & eop)
            num_packets_ctr_eq1 <= (num_packets_ctr == 32'h2); // Decrementing from 2 to 1

        if (state == IDLE)
            curr_pkt_table_entry <= 2'h0;
        else if ((state_prep[1]) | (en & eop)) // Increment to next value as soon as curr_pkt_table_entry is used
            curr_pkt_table_entry <= (curr_pkt_table_entry == hold_pkt_table_entries) ? 2'h0 : (curr_pkt_table_entry + 2'h1);

        if (state == IDLE)
            pkt_length <= pkt_length0;
        else if ((state_prep[2]) | (en & eop)) // Increment to next value as soon as curr_pkt_table_entry is used
        begin
            if (curr_pkt_table_entry == hold_pkt_table_entries)
                pkt_length <= pkt_length0;
            else
            begin
                // Get next value based on current value of curr_pkt_table_entry[1:0]
                case (curr_pkt_table_entry[1:0])
                    2'h3 : pkt_length <= pkt_length0;
                    2'h0 : pkt_length <= pkt_length1;
                    2'h1 : pkt_length <= pkt_length2;
                    2'h2 : pkt_length <= pkt_length3;
                endcase
            end
        end

        if ((state_prep[3]) | (en & eop))
            pkt_length_ctr <= pkt_length;
        else if (en)
            pkt_length_ctr <= (pkt_length_ctr <= AXI_BE_WIDTH) ? 20'h0 : (pkt_length_ctr - AXI_BE_WIDTH);
    end
end

// Conditions for which a new packet will be started
assign c_start_new_pkt = (state_prep[4]) | ((en & eop) & ~(pkt_enable_clear | num_packets_ctr_eq1));

// Asserts when pkt_length_ctr has 2 words remaining
assign c_pkt_length_ctr_is_2_words = (pkt_length_ctr <= (2*AXI_BE_WIDTH)) & (pkt_length_ctr > AXI_BE_WIDTH);

assign c_load_pkt_data_remain = {1'b1, {AXI_REMAIN_WIDTH{1'b0}}} - {1'b0,     pkt_length[AXI_REMAIN_WIDTH-1:0]};
assign c_ctr_pkt_data_remain  = {1'b1, {AXI_REMAIN_WIDTH{1'b0}}} - {1'b0, pkt_length_ctr[AXI_REMAIN_WIDTH-1:0]};

// Packet Output
always @(posedge clk or negedge r8_11_dma_rst_n)
begin
    if (r8_11_dma_rst_n == 1'b0)
    begin
        seed_sop               <= 1'b0;
        seed_eop               <= 1'b0;
        seed_data_remain       <= {AXI_REMAIN_WIDTH{1'b0}};
        next_data_seed         <= 32'h0;
        next_user_control_seed <= 32'h0;
    end
    else
    begin
        if (c_start_new_pkt) // Beginning a new packet
            seed_sop <= 1'b1;
        else if (en)
            seed_sop <= 1'b0;

        if (c_start_new_pkt & (pkt_length <= AXI_BE_WIDTH)) // Beginning a new 1 word packet
            seed_eop <= 1'b1;
        else if (en & c_pkt_length_ctr_is_2_words) // Going from 2 to 1 words
            seed_eop <= 1'b1;
        else if (en)
            seed_eop <= 1'b0;

        // Save number of bytes that will be invalid in final packet word; only non-zero when eop is asserted
        if (c_start_new_pkt & (pkt_length <= AXI_BE_WIDTH)) // Beginning of new 1 word packet
            seed_data_remain <= c_load_pkt_data_remain[AXI_REMAIN_WIDTH-1:0];
        else if (en & c_pkt_length_ctr_is_2_words) // Going from 2 to 1 words
            seed_data_remain <= c_ctr_pkt_data_remain[AXI_REMAIN_WIDTH-1:0];
        else if (en)
            seed_data_remain <= {AXI_REMAIN_WIDTH{1'b0}};

        if ((state_prep[5]) | (en & eop & ~hold_pkt_data_continue)) // Advance seed for start of new packet
        begin
            next_data_seed <= data_seed;
        end
        else if (en)
        begin          
            case (seed_data_remain[2]) 
                  1'h0 : next_data_seed <= next2; // All used
                  1'h1 : next_data_seed <= next1; // 1 DWORD unused
            endcase
        end

        if ((state_prep[6]) | (en & eop & ~hold_pkt_user_continue)) // Advance seed for start of new packet
            next_user_control_seed <= user_control_seed;
        else if (en & sop)
            next_user_control_seed <= unext2;
    end
end



// ------------
// Check Packet

always @(posedge clk or negedge r8_12_dma_rst_n)
begin
    if (r8_12_dma_rst_n == 1'b0)
    begin
        check_en               <= 1'b0;

        check_sop              <= 1'b0;
        check_eop              <= 1'b0;
        check_err              <= 1'b0;
        check_data_valid       <= {AXI_REMAIN_WIDTH{1'b0}};
        check_data             <= {AXI_DATA_WIDTH{1'b0}};
        check_user_control     <= {USER_CONTROL_WIDTH{1'b0}};

        expected_sop           <= 1'b0;
        expected_eop           <= 1'b0;
        expected_data_valid    <= {AXI_REMAIN_WIDTH{1'b0}};
        expected_check_bytes   <= {AXI_BE_WIDTH{1'b0}};

        d_det_err_sop          <= 1'b0;
        d_det_err_eop          <= 1'b0;
        d_det_err_cpl          <= 1'b0;
        d_det_err_data         <= {AXI_BE_WIDTH{1'b0}};
        d_det_err_data_valid   <= 1'b0;
        d_det_err_user_control <= 1'b0;

        det_err_sop            <= 1'b0;
        det_err_eop            <= 1'b0;
        det_err_cpl            <= 1'b0;
        det_err_data           <= 1'b0;
        det_err_data_valid     <= 1'b0;
        det_err_user_control   <= 1'b0;

        det_err                <= 1'b0;
    end
    else
    begin
        // Delay en by 1 clock to be able to generate expected data pattern
        check_en               <= en;

        // Delay received packet interface ports by 1 clock to be able to generate expected data pattern
        check_sop              <= sop;
        check_eop              <= eop;
        check_err              <= err;
        check_data_valid       <= valid;
        check_data             <= data;
        check_user_control     <= user_control;

        // Delay expected values to check_en timing
        expected_sop           <= seed_sop;
        expected_eop           <= seed_eop;
        expected_data_valid    <= seed_data_valid[AXI_REMAIN_WIDTH-1:0];

        case (seed_data_remain[AXI_REMAIN_WIDTH-1:0])             
            3'h7 : expected_check_bytes <= 8'b00000001;              
            3'h6 : expected_check_bytes <= 8'b00000011;              
            3'h5 : expected_check_bytes <= 8'b00000111;              
            3'h4 : expected_check_bytes <= 8'b00001111;              
            3'h3 : expected_check_bytes <= 8'b00011111;
            3'h2 : expected_check_bytes <= 8'b00111111;              
            3'h1 : expected_check_bytes <= 8'b01111111;              
            3'h0 : expected_check_bytes <= 8'b11111111;              
        endcase                                                      

        if (check_en) // Only check values when check_en == 1
        begin
            d_det_err_sop          <= (expected_sop != check_sop);
            d_det_err_eop          <= (expected_eop != check_eop);
            d_det_err_cpl          <= check_err;
            d_det_err_data[ 0]     <= (expected_check_bytes[0] & (expected_data[ 7: 0] != check_data[ 7: 0]));
            d_det_err_data[ 1]     <= (expected_check_bytes[1] & (expected_data[15: 8] != check_data[15: 8]));
            d_det_err_data[ 2]     <= (expected_check_bytes[2] & (expected_data[23:16] != check_data[23:16]));
            d_det_err_data[ 3]     <= (expected_check_bytes[3] & (expected_data[31:24] != check_data[31:24]));
            d_det_err_data[ 4]     <= (expected_check_bytes[4] & (expected_data[39:32] != check_data[39:32]));
            d_det_err_data[ 5]     <= (expected_check_bytes[5] & (expected_data[47:40] != check_data[47:40]));
            d_det_err_data[ 6]     <= (expected_check_bytes[6] & (expected_data[55:48] != check_data[55:48]));
            d_det_err_data[ 7]     <= (expected_check_bytes[7] & (expected_data[63:56] != check_data[63:56]));
            d_det_err_data_valid   <= expected_eop & (expected_data_valid   != check_data_valid);
            d_det_err_user_control <= expected_sop & (expected_user_control != check_user_control) & check_control;
        end
        else
        begin
            d_det_err_sop          <= 1'b0;
            d_det_err_eop          <= 1'b0;
            d_det_err_data         <= {AXI_BE_WIDTH{1'b0}};
            d_det_err_data_valid   <= 1'b0;
            d_det_err_user_control <= 1'b0;
        end

        // Want the following error signals to have the same timing;
        //   don't record errors when in loopback mode since the packet
        //   checker is not setup in this mode; packet validity needs 
        //   checked by software since only software knows what it is
        //   transmitting
        det_err_sop            <= state_lpbk_n &   d_det_err_sop;         
        det_err_eop            <= state_lpbk_n &   d_det_err_eop;         
        det_err_cpl            <= state_lpbk_n &   d_det_err_cpl;         
        det_err_data           <= state_lpbk_n & (|d_det_err_data);        
        det_err_data_valid     <= state_lpbk_n &   d_det_err_data_valid;  
        det_err_user_control   <= state_lpbk_n &   d_det_err_user_control;

        det_err                <= state_lpbk_n & ( d_det_err_sop          |
                                                   d_det_err_eop          |
                                                   d_det_err_cpl          |
                                                 (|d_det_err_data)        |
                                                   d_det_err_data_valid   |
                                                   d_det_err_user_control );
    end
end    
`ifdef SIMULATION



// -----------------------------------
// Report Errors to the Simulation Log

wire                                error_sop;
wire                                error_eop;
wire                                error_data;
wire                                error_valid;
wire                                error_user_control;

reg     [AXI_DATA_WIDTH-1:0]        debug1_expected_data;
reg     [AXI_DATA_WIDTH-1:0]        debug1_check_data;

reg     [AXI_DATA_WIDTH-1:0]        debug2_expected_data;
reg     [AXI_DATA_WIDTH-1:0]        debug2_check_data;

assign error_sop          = det_err_sop;                
assign error_eop          = det_err_eop;         
assign error_data         = det_err_data;        
assign error_valid        = det_err_data_valid;  
assign error_user_control = det_err_user_control;

always @(posedge clk)
begin : debug_expected_check_bytes_expansion
    integer i;
    for (i=0; i<AXI_DATA_WIDTH; i=i+1)
    begin
        debug1_expected_data[i] <= expected_check_bytes[i/8] ? expected_data[i] : 1'bx;
        debug1_check_data[i]    <= expected_check_bytes[i/8] ?    check_data[i] : 1'bx;
    end
end

always @(posedge clk)
begin
    // Pipeline to same latency as error_data
    debug2_expected_data <= expected_data;       
    debug2_check_data    <= check_data;          

    if (error_sop)
        $display ("%m : ERROR : received_sop != expected_sop (time %t)", $time);

    if (error_eop)
        $display ("%m : ERROR : received_eop != expected_eop (time %t)", $time);

    if (error_data)
        $display ("%m : ERROR : packet data error; expected=0x%x, received=0x%x (time %t)", debug2_expected_data, debug2_check_data, $time);

    if (error_valid)
        $display ("%m : ERROR : packet valid error (time %t)", $time);

    if (error_user_control)
        $display ("%m : ERROR : packet user_control error (time %t)", $time);
end
`endif



// -----------------------
// Compute Next Data Value

// Expand LFSR to AXI_DATA_WIDTH
assign next_data_lfsr2 = {next_data_lfsr1[LFSR_BITS-2:0], ~(^(next_data_lfsr1 & sized_lfsr_xnor_mask))};
assign next_data_lfsr1 = { next_data_seed[LFSR_BITS-2:0], ~(^( next_data_seed & sized_lfsr_xnor_mask))};

always @*
begin
    // Expand seed to AXI_DATA_WIDTH
    case (hold_pkt_data_pattern)

        PAT_CONSTANT    :
            begin
                next2 = next_data_seed;
                next1 = next_data_seed;
            end

        PAT_INC_BYTE    :   
            begin
                next2[31:24] = next_data_seed[31:24] + 8'd8;
                next2[23:16] = next_data_seed[23:16] + 8'd8;
                next2[15: 8] = next_data_seed[15: 8] + 8'd8;
                next2[ 7: 0] = next_data_seed[ 7: 0] + 8'd8;

                next1[31:24] = next_data_seed[31:24] + 8'd4;
                next1[23:16] = next_data_seed[23:16] + 8'd4;
                next1[15: 8] = next_data_seed[15: 8] + 8'd4;
                next1[ 7: 0] = next_data_seed[ 7: 0] + 8'd4;    
            end

        PAT_LFSR      :  
            begin
                next2 = next_data_lfsr2;
                next1 = next_data_lfsr1;
            end

        PAT_INC_DWORD   :  
            begin
                next2 = next_data_seed + 32'd2;
                next1 = next_data_seed + 32'd1;
            end

        default         :
            begin
                next2 = next_data_seed;
                next1 = next_data_seed;
            end

    endcase
end

always @(posedge clk or negedge r8_13_dma_rst_n)
begin
    if (r8_13_dma_rst_n == 1'b0)
    begin
        expected_data <= {AXI_DATA_WIDTH{1'b0}};
    end
    else
    begin
        if (en)
            expected_data <= {next1, next_data_seed};
    end
end
// Change remain to valid for output; valid is more useful
assign seed_data_valid = {1'b1, {AXI_REMAIN_WIDTH{1'b0}}} - {1'b0, seed_data_remain};



// -------------------------------
// Compute Next User Control Value

// Expand LFSR to AXI_DATA_WIDTH
assign next_user_control_lfsr2 = {next_user_control_lfsr1[LFSR_BITS-2:0], ~(^(next_user_control_lfsr1 & sized_lfsr_xnor_mask))};
assign next_user_control_lfsr1 = { next_user_control_seed[LFSR_BITS-2:0], ~(^( next_user_control_seed & sized_lfsr_xnor_mask))};

always @*
begin
    // Expand seed to AXI_DATA_WIDTH
    case (hold_pkt_user_pattern)

        PAT_CONSTANT    :
            begin
                unext2 = next_user_control_seed;
                unext1 = next_user_control_seed;
            end

        PAT_INC_BYTE    :   
            begin
                unext2[31:24] = next_user_control_seed[31:24] + 8'd8;
                unext2[23:16] = next_user_control_seed[23:16] + 8'd8;
                unext2[15: 8] = next_user_control_seed[15: 8] + 8'd8;
                unext2[ 7: 0] = next_user_control_seed[ 7: 0] + 8'd8;

                unext1[31:24] = next_user_control_seed[31:24] + 8'd4;
                unext1[23:16] = next_user_control_seed[23:16] + 8'd4;
                unext1[15: 8] = next_user_control_seed[15: 8] + 8'd4;
                unext1[ 7: 0] = next_user_control_seed[ 7: 0] + 8'd4;    
            end

        PAT_LFSR      :  
            begin
                unext2 = next_user_control_lfsr2;
                unext1 = next_user_control_lfsr1;
            end

        PAT_INC_DWORD   :  
            begin
                unext2 = next_user_control_seed + 32'd2;
                unext1 = next_user_control_seed + 32'd1;
            end

        default         :
            begin
                unext2 = next_user_control_seed;
                unext1 = next_user_control_seed;
            end

    endcase
end

always @(posedge clk or negedge r8_14_dma_rst_n)
begin
    if (r8_14_dma_rst_n == 1'b0)
    begin
        expected_user_control <= {USER_CONTROL_WIDTH{1'b0}};
    end
    else
    begin
        if (en & sop)
            expected_user_control <= {unext1, next_user_control_seed};
    end
end

// Packet rate control
always @(posedge clk or negedge r8_15_dma_rst_n)
begin
    if (r8_15_dma_rst_n == 1'b0)
    begin
        hi_ctr        <= 8'h0;
        lo_ctr        <= 8'h0;
        check_dst_rdy <= 1'b0;
    end
    else
    begin
        if ((en & eop) & (pkt_enable_clear | num_packets_ctr_eq1))      // End of packet sequence
            hi_ctr <= 8'h0;
        else if ( (state_prep[7]                                    ) | // if (Start of packet checking |
                  ((hi_ctr == 8'h1) & (hold_inactive_clocks == 8'h0)) | //     No inactive period       |
                  ((hi_ctr == 8'h0) & (lo_ctr == 8'h1)              ) ) //     End of inactive period   )
            hi_ctr <= hold_active_clocks;                               // then load Ctr
        else if (hi_ctr != 8'h0)
            hi_ctr <= hi_ctr - 8'h1;
                             
        if ((en & eop) & (pkt_enable_clear | num_packets_ctr_eq1))      // End of packet sequence
            lo_ctr <= 8'h0;
        else if (hi_ctr == 8'h1)
            lo_ctr <= hold_inactive_clocks;
        else if (lo_ctr != 8'h0)
            lo_ctr <= lo_ctr - 8'h1;

        if ((en & eop) & (pkt_enable_clear | num_packets_ctr_eq1))      // End of packet sequence
            check_dst_rdy <= 1'b0;
        else if ( (state_prep[8]                                    ) | // if (Start of packet checking |
                  ((hi_ctr == 8'h1) & (hold_inactive_clocks == 8'h0)) | //     No inactive period       |
                  ((hi_ctr == 8'h0) & (lo_ctr == 8'h1)              ) ) //     End of inactive period   )
            check_dst_rdy <= (hold_active_clocks != 8'h0);                    // then set if loading non-zero value
        else if (hi_ctr == 8'h1)
            check_dst_rdy <= 1'b0;
    end
end



// --------
// Loopback

always @(posedge clk or negedge r8_15_dma_rst_n)
begin
    if (r8_15_dma_rst_n == 1'b0)
    begin
        lpbi_src_rdy      <= 1'b0;
        lpbi_empty        <= 1'b1;
        lpbi_sop          <= 1'b0;
        lpbi_eop          <= 1'b0;
        lpbi_valid        <= {AXI_REMAIN_WIDTH{1'b0}};
        lpbi_data         <= {AXI_DATA_WIDTH{1'b0}};

        hold_user_control <= {USER_CONTROL_WIDTH{1'b0}};
    end
    else
    begin
        if (state_lpbk[0] & src_rdy & dst_rdy)
            lpbi_src_rdy <= 1'b1;
        else if (lpbi_dst_rdy)
            lpbi_src_rdy <= 1'b0;

        // Same as lpbi_src_rdy but opposite polarity
        if (state_lpbk[0] & src_rdy & dst_rdy)
            lpbi_empty <= 1'b0;
        else if (lpbi_dst_rdy)
            lpbi_empty <= 1'b1;

        if (state_lpbk[0] & sop & src_rdy & dst_rdy)
            lpbi_sop <= 1'b1;
        else if (lpbi_dst_rdy)
            lpbi_sop <= 1'b0;

        if (state_lpbk[0] & eop & src_rdy & dst_rdy)
            lpbi_eop <= 1'b1;
        else if (lpbi_dst_rdy)
            lpbi_eop <= 1'b0;

        if (state_lpbk[0] & eop & src_rdy & dst_rdy)
            lpbi_valid <= valid;
        else if (lpbi_dst_rdy)
            lpbi_valid <= {AXI_REMAIN_WIDTH{1'b0}};

        if (src_rdy & dst_rdy) // Not a control signal; don't use state_lpbk[0] to reduce fanout
            lpbi_data <= data;

        if (sop & src_rdy & dst_rdy)
            hold_user_control <= user_control;
    end
end

assign lpbi_user_status = lpbi_eop ? hold_user_control : {USER_STATUS_WIDTH{1'b0}};

// Only allow one AXI transaction to be active at a time
assign dst_rdy = (state_lpbk[1] ? (lpbi_empty | (~lpbi_empty & lpbi_dst_rdy)) : check_dst_rdy) & ~s2c_bvalid;

// Use a small FIFO to cut Loopback timing path between Packet Generator and Checker
ref_tiny_fifo #(

    .DATA_WIDTH     (2+USER_STATUS_WIDTH+AXI_REMAIN_WIDTH+AXI_DATA_WIDTH            )

) ref_tiny_fifo (

    .rst_n          (r8_15_dma_rst_n                                                ),
    .clk            (clk                                                            ),

    .in_src_rdy     (lpbi_src_rdy                                                   ),
    .in_dst_rdy     (lpbi_dst_rdy                                                   ),
    .in_data        ({lpbi_sop, lpbi_eop, lpbi_user_status, lpbi_valid, lpbi_data}  ),

    .out_src_rdy    (lpbk_src_rdy                                                   ), 
    .out_dst_rdy    (lpbk_dst_rdy                                                   ),
    .out_data       ({lpbk_sop, lpbk_eop, lpbk_user_status, lpbk_valid, lpbk_data}  )

);



// -------------
// AXI Interface

// Always respond successful
assign s2c_bresp = 2'b00; // Okay

always @*
begin
    if      (i_s2c_wstrb[ 7])
        valid = 3'h0;
    else if (i_s2c_wstrb[ 6])
        valid = 3'h7;
    else if (i_s2c_wstrb[ 5])
        valid = 3'h6;
    else if (i_s2c_wstrb[ 4])
        valid = 3'h5;
    else if (i_s2c_wstrb[ 3])
        valid = 3'h4;
    else if (i_s2c_wstrb[ 2])
        valid = 3'h3;
    else if (i_s2c_wstrb[ 1])
        valid = 3'h2;
    else if (i_s2c_wstrb[ 0])
        valid = 3'h1;
    else
        valid = 3'h0;
end

assign src_rdy      = i_s2c_wvalid;
assign i_s2c_wready = dst_rdy;
assign data         = i_s2c_wdata;
assign eop          = i_s2c_wusereop;
assign err          = 1'b0;
assign user_control = i_s2c_wusercontrol;

always @(posedge clk or negedge r8_15_dma_rst_n)
begin
    if (r8_15_dma_rst_n == 1'b0)
    begin
        sop        <= 1'b1;
        s2c_bvalid <= 1'b0;
    end
    else
    begin
        if (en & eop)
            sop <= 1'b1;
        else if (en)
            sop <= 1'b0;

        if (en & eop)
            s2c_bvalid <= 1'b1;
        else if (s2c_bready)
            s2c_bvalid <= 1'b0;
    end
end

// Cut timing on S2C Interface
ref_tiny_fifo #(

    .DATA_WIDTH     (USER_CONTROL_WIDTH + 1 +             AXI_BE_WIDTH + AXI_DATA_WIDTH )

) s2c_ref_tiny_fifo (

    .rst_n          (r8_15_dma_rst_n                                                    ),
    .clk            (clk                                                                ),

    .in_src_rdy     (s2c_wvalid                                                         ),
    .in_dst_rdy     (s2c_wready                                                         ),
    .in_data        ({s2c_wusercontrol,   s2c_wusereop,   s2c_wstrb,     s2c_wdata}     ),

    .out_src_rdy    (i_s2c_wvalid                                                       ),
    .out_dst_rdy    (i_s2c_wready                                                       ),
    .out_data       ({i_s2c_wusercontrol, i_s2c_wusereop, i_s2c_wstrb,   i_s2c_wdata}   )

);



endmodule
