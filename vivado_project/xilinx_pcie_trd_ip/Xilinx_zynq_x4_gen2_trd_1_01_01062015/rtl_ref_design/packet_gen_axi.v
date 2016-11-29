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

module packet_gen_axi (

    rst_n,                  // Asynchronous active low reset
    clk,                    // Posedge Clock

    reg_base_addr,          // Register Base Address

    reg_wr_addr,            // Register Interface
    reg_wr_en,              //
    reg_wr_be,              //
    reg_wr_data,            //
    reg_rd_addr,            //
    reg_rd_data,            //

    lpbk_user_status,       // Loopback Input
    lpbk_sop,               //
    lpbk_eop,               //
    lpbk_data,              //
    lpbk_valid,             //
    lpbk_src_rdy,           //
    lpbk_dst_rdy,           //

    c2s_rvalid,             // Card to System AXI Interface
    c2s_rready,             //
    c2s_rdata,              //
    c2s_rresp,              //
    c2s_rlast,              //
    c2s_ruserstatus,        //
    c2s_ruserstrb,          //

    c2s_fifo_addr_n         //

);



// ----------------
// -- Parameters --
// ----------------

localparam  AXI_DATA_WIDTH          = 64;
localparam  AXI_BE_WIDTH            = 8;
localparam  AXI_REMAIN_WIDTH        = 3;

parameter   REG_ADDR_WIDTH          = 13;

localparam  USER_STATUS_WIDTH       = 64;

localparam  REG_REMAIN              = 5;

// 64-bit (Two DWORD) address locations
localparam  ADDR_CTL                = 5'h0;
localparam  ADDR_PKT                = 5'h0;
localparam  ADDR_DSD                = 5'h1;
localparam  ADDR_USD                = 5'h1;
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

input   [REG_ADDR_WIDTH-1:0]        reg_base_addr;

input   [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
input                               reg_wr_en;
input   [AXI_BE_WIDTH-1:0]          reg_wr_be;
input   [AXI_DATA_WIDTH-1:0]        reg_wr_data;
input   [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
output  [AXI_DATA_WIDTH-1:0]        reg_rd_data;

input   [USER_STATUS_WIDTH-1:0]     lpbk_user_status;
input                               lpbk_sop;
input                               lpbk_eop;
input   [AXI_DATA_WIDTH-1:0]        lpbk_data;
input   [AXI_REMAIN_WIDTH-1:0]      lpbk_valid;
input                               lpbk_src_rdy;
output                              lpbk_dst_rdy;

output                              c2s_rvalid;
input                               c2s_rready;
output  [AXI_DATA_WIDTH-1:0]        c2s_rdata;
output  [1:0]                       c2s_rresp;
output                              c2s_rlast;
output  [USER_STATUS_WIDTH-1:0]     c2s_ruserstatus;
output  [AXI_BE_WIDTH-1:0]          c2s_ruserstrb;

output                              c2s_fifo_addr_n;



// ----------------
// -- Port Types --
// ----------------

wire                                rst_n;
wire                                clk;

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

wire                                c2s_rvalid;
wire                                c2s_rready;
wire    [AXI_DATA_WIDTH-1:0]        c2s_rdata;
wire    [1:0]                       c2s_rresp;
wire                                c2s_rlast;
wire    [USER_STATUS_WIDTH-1:0]     c2s_ruserstatus;
wire    [AXI_BE_WIDTH-1:0]          c2s_ruserstrb;

reg                                 c2s_fifo_addr_n /* synthesis syn_maxfan = 32 */;



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

// Register Decodes
reg     [AXI_DATA_WIDTH-1:0]        r_reg_wr_data;

wire                                reg_wr_hit;
wire                                reg_rd_hit;

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

reg     [31:0]                      user_status_seed;
wire    [31:0]                      usd_rd_data;

reg     [19:0]                      pkt_length0;
reg     [19:0]                      pkt_length1;
reg     [19:0]                      pkt_length2;
reg     [19:0]                      pkt_length3;

wire    [31:0]                      lt0_rd_data;
wire    [31:0]                      lt1_rd_data;
wire    [31:0]                      lt2_rd_data;
wire    [31:0]                      lt3_rd_data;

// Generate Packets
wire                                seed_en;

reg     [3:0]                       state;

wire                                c_state_prep;
reg     [9:0]                       state_prep;
reg     [1:0]                       state_lpbk;
reg                                 state_lpbk_n;

reg                                 lpbk_in_pkt;

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

wire    [AXI_REMAIN_WIDTH:0]        c_load_pkt_remain;
wire    [AXI_REMAIN_WIDTH:0]        c_ctr_pkt_remain;

reg                                 seed_start_en;
reg                                 seed_sop;
reg                                 seed_eop;
reg     [AXI_REMAIN_WIDTH-1:0]      seed_remain;
reg     [31:0]                      next_data_seed;
reg     [31:0]                      next_user_status_seed;

// Compute Next Data Value
wire    [LFSR_BITS-1:0]             next_data_lfsr2;
wire    [LFSR_BITS-1:0]             next_data_lfsr1;

reg     [31:0]                      next2;
reg     [31:0]                      next1;
reg     [AXI_DATA_WIDTH-1:0]        i_gen_data;

reg                                 i_gen_eop;
reg                                 i_gen_src_rdy;
reg     [AXI_REMAIN_WIDTH-1:0]      i_gen_valid;
reg                                 full;

wire    [AXI_REMAIN_WIDTH:0]        seed_valid;

// Compute Next User Status Value
wire    [LFSR_BITS-1:0]             next_user_status_lfsr2;
wire    [LFSR_BITS-1:0]             next_user_status_lfsr1;

reg     [31:0]                      unext2;
reg     [31:0]                      unext1;
reg     [USER_STATUS_WIDTH-1:0]     i_gen_user_status;



reg     [7:0]                       hi_ctr;
reg     [7:0]                       lo_ctr;
reg                                 seed_src_rdy;

// Cut Timing Between Packet Generation and Merging Output with Loopback
wire                                i_gen_en;
wire                                i_gen_dst_rdy;

wire                                gen_src_rdy;
wire                                gen_dst_rdy;
wire    [AXI_REMAIN_WIDTH-1:0]      gen_valid;
wire    [USER_STATUS_WIDTH-1:0]     gen_user_status;
wire                                gen_eop;
wire    [AXI_DATA_WIDTH-1:0]        gen_data;

// Loopback
reg                                 i_c2s_rvalid;
wire                                i_c2s_rready;
reg     [AXI_DATA_WIDTH-1:0]        i_c2s_rdata;
reg                                 i_c2s_rlast;
reg     [USER_STATUS_WIDTH-1:0]     i_c2s_ruserstatus;
reg     [AXI_BE_WIDTH-1:0]          i_c2s_ruserstrb;

reg                                 out_empty;

wire                                en;

wire                                gen_en;
wire                                lpbk_en;



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

wire abort = 1'b0;
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
assign reg_rd_hit = (reg_rd_addr[REG_ADDR_WIDTH-1:5] == reg_base_addr[REG_ADDR_WIDTH-1:5]);

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

// User Status Seed
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
        c2s_fifo_addr_n     <= 1'b1;
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
        else if ((state == XFER) & (seed_en & seed_eop) & (pkt_enable_clear | num_packets_ctr_eq1))
            pkt_enable <= 1'b0;

        if ((ctl_wr_en0 & ~ctl_wr_data0[0]) | abort) // Clear pkt_enable at next oportunity when software wants to abort
            pkt_enable_clear <= 1'b1;
        else if (state == IDLE)
            pkt_enable_clear <= 1'b0;

        if (ctl_wr_en0)
            pkt_loopback <= ctl_wr_data0[1] & ~abort; // Don't set if currently aborting DMA

        if (ctl_wr_en0)
            pkt_sel_ram_pkt_n_i <= ctl_wr_data0[2];

        c2s_fifo_addr_n <= ~pkt_sel_ram_pkt_n_i;

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
                      2'h0, pkt_table_entries[1:0], 1'b0, pkt_sel_ram_pkt_n_i, pkt_loopback, pkt_enable};

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

// User Status Seed
always @(posedge clk or negedge r8_6_dma_rst_n)
begin
    if (r8_6_dma_rst_n == 1'b0)
    begin
        user_status_seed <= 32'h0;
    end
    else
    begin
        // Byte 0

        if (usd_wr_en0)
            user_status_seed[ 7: 0] <= usd_wr_data0[7:0];

        // Byte 1

        if (usd_wr_en1)
            user_status_seed[15: 8] <= usd_wr_data1[7:0];

        // Byte 2

        if (usd_wr_en2)
            user_status_seed[23:16] <= usd_wr_data2[7:0];

        // Byte 3

        if (usd_wr_en3)
            user_status_seed[31:24] <= usd_wr_data3[7:0];
    end
end

assign usd_rd_data = user_status_seed[31:0];

// Packet Length Table
always @(posedge clk or negedge r8_7_dma_rst_n)
begin
    if (r8_7_dma_rst_n == 1'b0)
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



// ----------------
// Generate Packets

assign seed_en = seed_start_en | (seed_src_rdy & (~full | i_gen_en)); // Enable when packet data is taken from this module; preload first value when starting up

always @(posedge clk or negedge r8_8_dma_rst_n)
begin
    if (r8_8_dma_rst_n == 1'b0)
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

            XFER    :   if ((seed_en & seed_eop) & (pkt_enable_clear | num_packets_ctr_eq1))
                            state <= IDLE;

            // Leave loopback mode when loopback is disabled and ending a packet or idle and not starting a new packet
            LPBK    :   if (~pkt_loopback & ( (                (lpbk_eop & lpbk_en)) |
                                              (~lpbk_in_pkt & ~(lpbk_sop & lpbk_en)) ) )
                            state <= IDLE;

            default :       state <= IDLE;

        endcase
    end
end

assign c_state_prep = (state == IDLE) & (pkt_enable & ~abort);

always @(posedge clk or negedge r8_8_dma_rst_n)
begin
    if (r8_8_dma_rst_n == 1'b0)
    begin
        state_prep   <= {10{1'b0}};
        state_lpbk   <= { 2{1'b0}};
        state_lpbk_n <=     1'b1;
    end
    else
    begin
        state_prep <= {10{c_state_prep}};

        if ((state == IDLE) & ~(pkt_enable & ~abort) & (pkt_loopback & ~abort))
        begin
            state_lpbk   <= {2{1'b1}};
            state_lpbk_n <=    1'b0;
        end
        else if ((state == LPBK) & (~pkt_loopback & ( (                (lpbk_eop & lpbk_en)) |
                                                      (~lpbk_in_pkt & ~(lpbk_sop & lpbk_en)) ) ))
        begin
            state_lpbk   <= {2{1'b0}};
            state_lpbk_n <=    1'b1;
        end
    end
end

// Keep track of when we are busy receiving a packet
always @(posedge clk or negedge r8_8_dma_rst_n)
begin
    if (r8_8_dma_rst_n == 1'b0)
    begin
        lpbk_in_pkt <= 1'b0;
    end
    else
    begin
        if (lpbk_sop & ~lpbk_eop & lpbk_en)
            lpbk_in_pkt <= 1'b1;
        else if (lpbk_eop & lpbk_en)
            lpbk_in_pkt <= 1'b0;
    end
end

// Hold register values for entire operation
always @(posedge clk or negedge r8_9_dma_rst_n)
begin
    if (r8_9_dma_rst_n == 1'b0)
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
        else if (seed_en & seed_eop & (num_packets_ctr != 32'h0)) // Decrement on end of packet transfer when not in infinite mode
            num_packets_ctr <= num_packets_ctr - 32'h1;

        // Pre-decode num_packets_ctr == 1 for timing speed
        if (state_prep[0]) // num_packets_ctr_eq1 is not used until state == XFER
            num_packets_ctr_eq1 <= (num_packets_ctr == 32'h1); // Loaded with 1
        else if (seed_en & seed_eop)
            num_packets_ctr_eq1 <= (num_packets_ctr == 32'h2); // Decrementing from 2 to 1

        if (state == IDLE)
            curr_pkt_table_entry <= 2'h0;
        else if ((state_prep[1]) | (seed_en & seed_eop)) // Increment to next value as soon as curr_pkt_table_entry is used
            curr_pkt_table_entry <= (curr_pkt_table_entry == hold_pkt_table_entries) ? 2'h0 : (curr_pkt_table_entry + 2'h1);

        if (state == IDLE)
            pkt_length <= pkt_length0;
        else if ((state_prep[2]) | (seed_en & seed_eop)) // Increment to next value as soon as curr_pkt_table_entry is used
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

        if ((state_prep[3]) | (seed_en & seed_eop))
            pkt_length_ctr <= pkt_length;
        else if (seed_en)
            pkt_length_ctr <= (pkt_length_ctr <= AXI_BE_WIDTH) ? 20'h0 : (pkt_length_ctr - AXI_BE_WIDTH);
    end
end

// Conditions for which a new packet will be started
assign c_start_new_pkt = (state_prep[4]) | ((seed_en & seed_eop) & ~(pkt_enable_clear | num_packets_ctr_eq1));

// Asserts when pkt_length_ctr has 2 words remaining
assign c_pkt_length_ctr_is_2_words = (pkt_length_ctr <= (2*AXI_BE_WIDTH)) & (pkt_length_ctr > AXI_BE_WIDTH);

assign c_load_pkt_remain = {1'b1, {AXI_REMAIN_WIDTH{1'b0}}} - {1'b0,     pkt_length[AXI_REMAIN_WIDTH-1:0]};
assign c_ctr_pkt_remain  = {1'b1, {AXI_REMAIN_WIDTH{1'b0}}} - {1'b0, pkt_length_ctr[AXI_REMAIN_WIDTH-1:0]};

// Packet Output
always @(posedge clk or negedge r8_10_dma_rst_n)
begin
    if (r8_10_dma_rst_n == 1'b0)
    begin
        seed_start_en         <= 1'b0;
        seed_sop              <= 1'b0;
        seed_eop              <= 1'b0;
        seed_remain           <= {AXI_REMAIN_WIDTH{1'b0}};
        next_data_seed        <= 32'h0;
        next_user_status_seed <= 32'h0;
    end
    else
    begin
        seed_start_en <= (state_prep[5]);

        if (c_start_new_pkt) // Beginning a new packet
            seed_sop <= 1'b1;
        else if (seed_en)
            seed_sop <= 1'b0;

        if (c_start_new_pkt & (pkt_length <= AXI_BE_WIDTH)) // Beginning a new 1 word packet
            seed_eop <= 1'b1;
        else if (seed_en)
        begin
            if (c_pkt_length_ctr_is_2_words) // Going from 2 to 1 words
                seed_eop <= 1'b1;
            else
                seed_eop <= 1'b0;
        end

        // Save number of bytes that will be invalid in final packet word; only non-zero when seed_eop is asserted
        if (c_start_new_pkt & (pkt_length <= AXI_BE_WIDTH)) // Beginning of new 1 word packet
            seed_remain <= c_load_pkt_remain[AXI_REMAIN_WIDTH-1:0];
        else if (seed_en)
        begin
            if (c_pkt_length_ctr_is_2_words) // Going from 2 to 1 words
                seed_remain <= c_ctr_pkt_remain[AXI_REMAIN_WIDTH-1:0];
            else
                seed_remain <= {AXI_REMAIN_WIDTH{1'b0}};
        end

        if ((state_prep[6]) | (seed_en & seed_eop & ~hold_pkt_data_continue)) // Advance see for start of new packet
        begin
            next_data_seed <= data_seed;
        end
        else if (seed_en)
        begin
            case (seed_remain[2])
                  1'h0 : next_data_seed <= next2; // All used
                  1'h1 : next_data_seed <= next1; // 1 DWORD unused
            endcase
        end

        if ((state_prep[7]) | (seed_en & seed_eop & ~hold_pkt_user_continue)) // Advance see for start of new packet
            next_user_status_seed <= user_status_seed;
        else if (seed_en & seed_eop)
            next_user_status_seed <= unext2;
    end
end



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

always @(posedge clk or negedge r8_11_dma_rst_n)
begin
    if (r8_11_dma_rst_n == 1'b0)
    begin
        i_gen_data <= {AXI_DATA_WIDTH{1'b0}};
    end
    else
    begin
        if (seed_en)
            i_gen_data <= {next1, next_data_seed};
    end
end
always @(posedge clk or negedge r8_12_dma_rst_n)
begin
    if (r8_12_dma_rst_n == 1'b0)
    begin
        i_gen_eop     <= 1'b0;
        i_gen_src_rdy <= 1'b0;
        i_gen_valid   <= {AXI_REMAIN_WIDTH{1'b0}};
        full          <= 1'b0;
    end
    else
    begin
        if (seed_en)
            i_gen_eop <= seed_eop;
        else if (i_gen_en)
            i_gen_eop <= 1'b0;

        if (seed_en)
            i_gen_src_rdy <= 1'b1;
        else if (i_gen_en)
            i_gen_src_rdy <= 1'b0;

        if (seed_en)
            i_gen_valid <= seed_eop ? seed_valid[AXI_REMAIN_WIDTH-1:0] : {AXI_REMAIN_WIDTH{1'b0}};


        case ({seed_en, i_gen_en})
            2'b01   : full <= 1'b0;
            2'b10   : full <= 1'b1;
            default : full <= full;
        endcase
    end
end

// Change remain to valid for output; valid is more useful
assign seed_valid = {1'b1, {AXI_REMAIN_WIDTH{1'b0}}} - {1'b0, seed_remain};



// ------------------------------
// Compute Next User Status Value

// Expand LFSR to AXI_DATA_WIDTH
assign next_user_status_lfsr2 = {next_user_status_lfsr1[LFSR_BITS-2:0], ~(^(next_user_status_lfsr1 & sized_lfsr_xnor_mask))};
assign next_user_status_lfsr1 = { next_user_status_seed[LFSR_BITS-2:0], ~(^( next_user_status_seed & sized_lfsr_xnor_mask))};

always @*
begin
    // Expand seed to AXI_DATA_WIDTH
    case (hold_pkt_user_pattern)

        PAT_CONSTANT    :
            begin
                unext2 = next_user_status_seed;
                unext1 = next_user_status_seed;
            end

        PAT_INC_BYTE    :
            begin
                unext2[31:24] = next_user_status_seed[31:24] + 8'd8;
                unext2[23:16] = next_user_status_seed[23:16] + 8'd8;
                unext2[15: 8] = next_user_status_seed[15: 8] + 8'd8;
                unext2[ 7: 0] = next_user_status_seed[ 7: 0] + 8'd8;

                unext1[31:24] = next_user_status_seed[31:24] + 8'd4;
                unext1[23:16] = next_user_status_seed[23:16] + 8'd4;
                unext1[15: 8] = next_user_status_seed[15: 8] + 8'd4;
                unext1[ 7: 0] = next_user_status_seed[ 7: 0] + 8'd4;
            end

        PAT_LFSR      :
            begin
                unext2 = next_user_status_lfsr2;
                unext1 = next_user_status_lfsr1;
            end

        PAT_INC_DWORD   :
            begin
                unext2 = next_user_status_seed + 32'd2;
                unext1 = next_user_status_seed + 32'd1;
            end

        default         :
            begin
                unext2 = next_user_status_seed;
                unext1 = next_user_status_seed;
            end

    endcase
end

always @(posedge clk or negedge r8_13_dma_rst_n)
begin
    if (r8_13_dma_rst_n == 1'b0)
    begin
        i_gen_user_status <= {USER_STATUS_WIDTH{1'b0}};
    end
    else
    begin
        if (seed_en & seed_eop)
            i_gen_user_status <= {unext1, next_user_status_seed};
        else if (i_gen_en)
            i_gen_user_status <= {USER_STATUS_WIDTH{1'b0}};
    end
end

// Packet rate control
always @(posedge clk or negedge r8_14_dma_rst_n)
begin
    if (r8_14_dma_rst_n == 1'b0)
    begin
        hi_ctr       <= 8'h0;
        lo_ctr       <= 8'h0;
        seed_src_rdy <= 1'b0;
    end
    else
    begin
        if ((seed_en & seed_eop) & (pkt_enable_clear | num_packets_ctr_eq1))      // End of packet sequence
            hi_ctr <= 8'h0;
        else if ( (state_prep[8]                                    ) | // if (Start of packet generation |
                  ((hi_ctr == 8'h1) & (hold_inactive_clocks == 8'h0)) | //     No inactive period         |
                  ((hi_ctr == 8'h0) & (lo_ctr == 8'h1)              ) ) //     End of inactive period     )
            hi_ctr <= hold_active_clocks;                               // then load Ctr
        else if (hi_ctr != 8'h0)
            hi_ctr <= hi_ctr - 8'h1;

        if ((seed_en & seed_eop) & (pkt_enable_clear | num_packets_ctr_eq1))      // End of packet sequence
            lo_ctr <= 8'h0;
        else if (hi_ctr == 8'h1)
            lo_ctr <= hold_inactive_clocks;
        else if (lo_ctr != 8'h0)
            lo_ctr <= lo_ctr - 8'h1;

        if ((seed_en & seed_eop) & (pkt_enable_clear | num_packets_ctr_eq1))      // End of packet sequence
            seed_src_rdy <= 1'b0;
        else if ( (state_prep[9]                                    ) | // if (Start of packet generation |
                  ((hi_ctr == 8'h1) & (hold_inactive_clocks == 8'h0)) | //     No inactive period         |
                  ((hi_ctr == 8'h0) & (lo_ctr == 8'h1)              ) ) //     End of inactive period     )
            seed_src_rdy <= (hold_active_clocks != 8'h0);               // then set if loading non-zero value
        else if (hi_ctr == 8'h1)
            seed_src_rdy <= 1'b0;
    end
end



// ---------------------------------------------------------------------
// Cut Timing Between Packet Generation and Merging Output with Loopback

assign i_gen_en = i_gen_src_rdy & i_gen_dst_rdy;

ref_tiny_fifo #(

    .DATA_WIDTH     (AXI_REMAIN_WIDTH + USER_STATUS_WIDTH + 1 +        AXI_DATA_WIDTH   )

) gen_ref_tiny_fifo (

    .rst_n          (r8_15_dma_rst_n                                                    ),
    .clk            (clk                                                                ),

    .in_src_rdy     (i_gen_src_rdy                                                      ),
    .in_dst_rdy     (i_gen_dst_rdy                                                      ),
    .in_data        ({i_gen_valid,      i_gen_user_status,  i_gen_eop, i_gen_data}      ),

    .out_src_rdy    (gen_src_rdy                                                        ),
    .out_dst_rdy    (gen_dst_rdy                                                        ),
    .out_data       ({gen_valid,        gen_user_status,    gen_eop,   gen_data}        )

);



// --------
// Loopback

always @(posedge clk or negedge r8_15_dma_rst_n)
begin
    if (r8_15_dma_rst_n == 1'b0)
    begin
        i_c2s_ruserstatus <= {USER_STATUS_WIDTH{1'b0}};
        i_c2s_rlast       <= 1'b0;
        i_c2s_rdata       <= {AXI_DATA_WIDTH{1'b0}};
        i_c2s_ruserstrb   <= {AXI_BE_WIDTH{1'b0}};
        i_c2s_rvalid      <= 1'b0;
        out_empty         <= 1'b1;
    end
    else
    begin
        if (gen_en & gen_eop)
            i_c2s_ruserstatus <= gen_user_status;
        else if (lpbk_en & lpbk_eop)
            i_c2s_ruserstatus <= lpbk_user_status;
        else if (en)
            i_c2s_ruserstatus <= {USER_STATUS_WIDTH{1'b0}};

        if (gen_en)
            i_c2s_rlast <= gen_eop;
        else if (lpbk_en)
            i_c2s_rlast <= lpbk_eop;
        else if (en)
            i_c2s_rlast <= 1'b0;

        if (gen_en)
            i_c2s_rdata <= gen_data;
        else if (lpbk_en)
            i_c2s_rdata <= lpbk_data;

        if (gen_en)
        begin
            case (gen_valid)
                3'h7    : i_c2s_ruserstrb <= 8'b01111111;
                3'h6    : i_c2s_ruserstrb <= 8'b00111111;
                3'h5    : i_c2s_ruserstrb <= 8'b00011111;
                3'h4    : i_c2s_ruserstrb <= 8'b00001111;
                3'h3    : i_c2s_ruserstrb <= 8'b00000111;
                3'h2    : i_c2s_ruserstrb <= 8'b00000011;
                3'h1    : i_c2s_ruserstrb <= 8'b00000001;
                default : i_c2s_ruserstrb <= 8'b11111111;
            endcase
        end
        else if (lpbk_en)
            case (lpbk_valid)
                3'h7    : i_c2s_ruserstrb <= 8'b01111111;
                3'h6    : i_c2s_ruserstrb <= 8'b00111111;
                3'h5    : i_c2s_ruserstrb <= 8'b00011111;
                3'h4    : i_c2s_ruserstrb <= 8'b00001111;
                3'h3    : i_c2s_ruserstrb <= 8'b00000111;
                3'h2    : i_c2s_ruserstrb <= 8'b00000011;
                3'h1    : i_c2s_ruserstrb <= 8'b00000001;
                default : i_c2s_ruserstrb <= 8'b11111111;
            endcase
        else if (en)
            i_c2s_ruserstrb <= {AXI_BE_WIDTH{1'b0}};

        if (gen_en | lpbk_en)
            i_c2s_rvalid <= 1'b1;
        else if (en)
            i_c2s_rvalid <= 1'b0;

        if (gen_en | lpbk_en)
            out_empty <= 1'b0;
        else if (en)
            out_empty <= 1'b1;
    end
end

assign en = i_c2s_rvalid & i_c2s_rready; // Enable when packet data is taken from this module

assign gen_dst_rdy  = state_lpbk_n  & (en | out_empty);
assign gen_en       = gen_dst_rdy & gen_src_rdy;
assign lpbk_en      = state_lpbk[0] & (en | out_empty) & lpbk_src_rdy;
assign lpbk_dst_rdy = state_lpbk[1] & (en | out_empty);

// Use a small FIFO to cut AXI timing path between Packet Generator and AXI destination
ref_tiny_fifo #(

    .DATA_WIDTH     (AXI_BE_WIDTH +    USER_STATUS_WIDTH + 1 +          AXI_DATA_WIDTH  )

) c2s_ref_tiny_fifo (

    .rst_n          (r8_15_dma_rst_n                                                    ),
    .clk            (clk                                                                ),

    .in_src_rdy     (i_c2s_rvalid                                                       ),
    .in_dst_rdy     (i_c2s_rready                                                       ),
    .in_data        ({i_c2s_ruserstrb, i_c2s_ruserstatus,  i_c2s_rlast, i_c2s_rdata}    ),

    .out_src_rdy    (c2s_rvalid                                                         ),
    .out_dst_rdy    (c2s_rready                                                         ),
    .out_data       ({c2s_ruserstrb,   c2s_ruserstatus,    c2s_rlast,   c2s_rdata}      )

);

// Always indicate status == OKAY
assign c2s_rresp = 2'b00;



endmodule
