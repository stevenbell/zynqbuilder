// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2006 by Northwest Logic, Inc.
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

module register_example_axi (

    rst_n,
    clk,

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

    mgmt_msi_en,
    mgmt_msix_en,
    mgmt_interrupt,


    reg_rst_n,
    reg_clk,
    reg_wr_addr,
    reg_wr_en,
    reg_wr_be,
    reg_wr_data,
    reg_rd_addr,
    reg_rd_data

);



// ----------------
// -- Parameters --
// ----------------

localparam  AXI_DATA_WIDTH          = 64;
localparam  AXI_BE_WIDTH            = 8;
localparam  AXI_REMAIN_WIDTH        = 3;

// These localparameters must be set to the same sizes implemented in the PCIe Complete Core
parameter   REG_ADDR_WIDTH          = 12 + (4 - AXI_REMAIN_WIDTH);  // Register BAR address width

// AXI_DATA_WIDTH base address offset where this 256 byte register block is located (byte address == 0x8000)
localparam  BASE_ADDR_OFFSET        = 13'h1000;

// 64-bit (Two DWORD) address locations
localparam  ADDR_CORE_P_CREDITS     = 5'h2;
localparam  ADDR_CORE_N_CREDITS     = 5'h2;
localparam  ADDR_CORE_C_CREDITS     = 5'h3;

localparam  ADDR_REM_P_CREDITS      = 5'h4;
localparam  ADDR_REM_N_CREDITS      = 5'h4;
localparam  ADDR_REM_C_CREDITS      = 5'h5;

localparam  ADDR_USER_INT_SET       = 5'h8;
localparam  ADDR_USER_INT_STATUS    = 5'hA;

// scratch pad registers
localparam  ADDR_USER_SCRATCH0      = 5'h10;
localparam  ADDR_USER_SCRATCH1      = 5'h10;
localparam  ADDR_USER_SCRATCH2      = 5'h11;
localparam  ADDR_USER_SCRATCH3      = 5'h11;
// ----------------------
// -- Port Definitions --
// ----------------------

input                               rst_n;
input                               clk;

input   [7:0]                       mgmt_core_ph;
input   [11:0]                      mgmt_core_pd;
input   [7:0]                       mgmt_core_nh;
input   [11:0]                      mgmt_core_nd;
input   [7:0]                       mgmt_core_ch;
input   [11:0]                      mgmt_core_cd;

input   [7:0]                       mgmt_chipset_ph;
input   [11:0]                      mgmt_chipset_pd;
input   [7:0]                       mgmt_chipset_nh;
input   [11:0]                      mgmt_chipset_nd;
input   [7:0]                       mgmt_chipset_ch;
input   [11:0]                      mgmt_chipset_cd;

input                               mgmt_msi_en;
input                               mgmt_msix_en;
output  [31:0]                      mgmt_interrupt;


input                               reg_rst_n;
input                               reg_clk;
input   [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
input                               reg_wr_en;
input   [AXI_BE_WIDTH-1:0]          reg_wr_be;
input   [AXI_DATA_WIDTH-1:0]        reg_wr_data;
input   [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
output  [AXI_DATA_WIDTH-1:0]        reg_rd_data;



// ----------------
// -- Port Types --
// ----------------

wire                                rst_n;
wire                                clk;

wire    [7:0]                       mgmt_core_ph;
wire    [11:0]                      mgmt_core_pd;
wire    [7:0]                       mgmt_core_nh;
wire    [11:0]                      mgmt_core_nd;
wire    [7:0]                       mgmt_core_ch;
wire    [11:0]                      mgmt_core_cd;

wire    [7:0]                       mgmt_chipset_ph;
wire    [11:0]                      mgmt_chipset_pd;
wire    [7:0]                       mgmt_chipset_nh;
wire    [11:0]                      mgmt_chipset_nd;
wire    [7:0]                       mgmt_chipset_ch;
wire    [11:0]                      mgmt_chipset_cd;

wire                                mgmt_msi_en;
wire                                mgmt_msix_en;
reg     [31:0]                      mgmt_interrupt;


wire                                reg_rst_n;
wire                                reg_clk;
wire    [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
wire                                reg_wr_en;
wire    [AXI_BE_WIDTH-1:0]          reg_wr_be;
wire    [AXI_DATA_WIDTH-1:0]        reg_wr_data;
wire    [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
reg     [AXI_DATA_WIDTH-1:0]        reg_rd_data;



// -------------------
// -- Local Signals --
// -------------------

// Correlate register interface to AXI_DATA_WIDTH
wire    [REG_ADDR_WIDTH-1:0]        reg_base_addr;

wire                                reg_rd_hit;
wire                                reg_wr_hit;

wire                                user_int_set_wr_en0;
wire                                user_int_set_wr_en1;
wire                                user_int_set_wr_en2;
wire                                user_int_set_wr_en3;

wire    [7:0]                       user_int_set_wr_data0;
wire    [7:0]                       user_int_set_wr_data1;
wire    [7:0]                       user_int_set_wr_data2;
wire    [7:0]                       user_int_set_wr_data3;

wire                                user_int_status_wr_en0;
wire                                user_int_status_wr_en1;
wire                                user_int_status_wr_en2;
wire                                user_int_status_wr_en3;

wire    [7:0]                       user_int_status_wr_data0;
wire    [7:0]                       user_int_status_wr_data1;
wire    [7:0]                       user_int_status_wr_data2;
wire    [7:0]                       user_int_status_wr_data3;

// Register Writes
reg     [31:0]                      mgmt_interrupt_status;
reg     [31:0]                      mgmt_interrupt_pulse;

reg     [31:0]                      d_sync_mgmt_interrupt_status;
reg     [31:0]                      sync_mgmt_interrupt_status;

genvar                              i;
wire    [31:0]                      sync_mgmt_interrupt_pulse;

reg                                 mgmt_msixmsi_legacy_n;

wire                                user_scratch0_wr_en0;
wire                                user_scratch0_wr_en1;
wire                                user_scratch0_wr_en2;
wire                                user_scratch0_wr_en3;
wire                                user_scratch1_wr_en0;
wire                                user_scratch1_wr_en1;
wire                                user_scratch1_wr_en2;
wire                                user_scratch1_wr_en3;
wire                                user_scratch2_wr_en0;
wire                                user_scratch2_wr_en1;
wire                                user_scratch2_wr_en2;
wire                                user_scratch2_wr_en3;
wire                                user_scratch3_wr_en0;
wire                                user_scratch3_wr_en1;
wire                                user_scratch3_wr_en2;
wire                                user_scratch3_wr_en3;

wire    [7:0]                       user_scratch0_wr_data0;
wire    [7:0]                       user_scratch0_wr_data1;
wire    [7:0]                       user_scratch0_wr_data2;
wire    [7:0]                       user_scratch0_wr_data3;
wire    [7:0]                       user_scratch1_wr_data0;
wire    [7:0]                       user_scratch1_wr_data1;
wire    [7:0]                       user_scratch1_wr_data2;
wire    [7:0]                       user_scratch1_wr_data3;
wire    [7:0]                       user_scratch2_wr_data0;
wire    [7:0]                       user_scratch2_wr_data1;
wire    [7:0]                       user_scratch2_wr_data2;
wire    [7:0]                       user_scratch2_wr_data3;
wire    [7:0]                       user_scratch3_wr_data0;
wire    [7:0]                       user_scratch3_wr_data1;
wire    [7:0]                       user_scratch3_wr_data2;
wire    [7:0]                       user_scratch3_wr_data3;

reg     [31:0]                      user_scratch0_reg;
reg     [31:0]                      user_scratch1_reg;
reg     [31:0]                      user_scratch2_reg;
reg     [31:0]                      user_scratch3_reg;

// Register Read-Back
reg     [7:0]                       reg_mgmt_core_ph;
reg     [11:0]                      reg_mgmt_core_pd;
reg     [7:0]                       reg_mgmt_core_nh;
reg     [11:0]                      reg_mgmt_core_nd;
reg     [7:0]                       reg_mgmt_core_ch;
reg     [11:0]                      reg_mgmt_core_cd;

reg     [7:0]                       reg_mgmt_chipset_ph;
reg     [11:0]                      reg_mgmt_chipset_pd;
reg     [7:0]                       reg_mgmt_chipset_nh;
reg     [11:0]                      reg_mgmt_chipset_nd;
reg     [7:0]                       reg_mgmt_chipset_ch;
reg     [11:0]                      reg_mgmt_chipset_cd;

reg     [AXI_DATA_WIDTH-1:0]        c_reg_rd_data;



// ---------------
// -- Equations --
// ---------------

// -----------------------------------------------
// Correlate register interface to AXI_DATA_WIDTH

// Convert byte address offset to AXI_DATA_WIDTH address offset
assign reg_base_addr = BASE_ADDR_OFFSET;

// Check for a base address hit; Registers are a 256 byte block (32 64-bit Register Words)
assign reg_rd_hit = (reg_rd_addr[REG_ADDR_WIDTH-1:5] == reg_base_addr[REG_ADDR_WIDTH-1:5]);
assign reg_wr_hit = (reg_wr_addr[REG_ADDR_WIDTH-1:5] == reg_base_addr[REG_ADDR_WIDTH-1:5]);

assign user_int_set_wr_en0      = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_SET) & reg_wr_be[0];
assign user_int_set_wr_en1      = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_SET) & reg_wr_be[1];
assign user_int_set_wr_en2      = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_SET) & reg_wr_be[2];
assign user_int_set_wr_en3      = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_SET) & reg_wr_be[3];

assign user_int_set_wr_data0    = reg_wr_data[ 7: 0];
assign user_int_set_wr_data1    = reg_wr_data[15: 8];
assign user_int_set_wr_data2    = reg_wr_data[23:16];
assign user_int_set_wr_data3    = reg_wr_data[31:24];

assign user_int_status_wr_en0   = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_STATUS) & reg_wr_be[0];
assign user_int_status_wr_en1   = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_STATUS) & reg_wr_be[1];
assign user_int_status_wr_en2   = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_STATUS) & reg_wr_be[2];
assign user_int_status_wr_en3   = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_INT_STATUS) & reg_wr_be[3];

assign user_int_status_wr_data0 = reg_wr_data[ 7: 0];
assign user_int_status_wr_data1 = reg_wr_data[15: 8];
assign user_int_status_wr_data2 = reg_wr_data[23:16];
assign user_int_status_wr_data3 = reg_wr_data[31:24];
assign user_scratch0_wr_en0    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH0) & reg_wr_be[0];
assign user_scratch0_wr_en1    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH0) & reg_wr_be[1];
assign user_scratch0_wr_en2    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH0) & reg_wr_be[2];
assign user_scratch0_wr_en3    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH0) & reg_wr_be[3];
assign user_scratch1_wr_en0    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH1) & reg_wr_be[4];
assign user_scratch1_wr_en1    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH1) & reg_wr_be[5];
assign user_scratch1_wr_en2    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH1) & reg_wr_be[6];
assign user_scratch1_wr_en3    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH1) & reg_wr_be[7];
assign user_scratch2_wr_en0    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH2) & reg_wr_be[0];
assign user_scratch2_wr_en1    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH2) & reg_wr_be[1];
assign user_scratch2_wr_en2    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH2) & reg_wr_be[2];
assign user_scratch2_wr_en3    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH2) & reg_wr_be[3];
assign user_scratch3_wr_en0    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH3) & reg_wr_be[4];
assign user_scratch3_wr_en1    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH3) & reg_wr_be[5];
assign user_scratch3_wr_en2    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH3) & reg_wr_be[6];
assign user_scratch3_wr_en3    = reg_wr_hit & reg_wr_en & (reg_wr_addr[4:0] == ADDR_USER_SCRATCH3) & reg_wr_be[7];

assign user_scratch0_wr_data0 = reg_wr_data[ 7: 0];
assign user_scratch0_wr_data1 = reg_wr_data[15: 8];
assign user_scratch0_wr_data2 = reg_wr_data[23:16];
assign user_scratch0_wr_data3 = reg_wr_data[31:24];
assign user_scratch1_wr_data0 = reg_wr_data[39:32];
assign user_scratch1_wr_data1 = reg_wr_data[47:40];
assign user_scratch1_wr_data2 = reg_wr_data[55:48];
assign user_scratch1_wr_data3 = reg_wr_data[63:56];
assign user_scratch2_wr_data0 = reg_wr_data[ 7: 0];
assign user_scratch2_wr_data1 = reg_wr_data[15: 8];
assign user_scratch2_wr_data2 = reg_wr_data[23:16];
assign user_scratch2_wr_data3 = reg_wr_data[31:24];
assign user_scratch3_wr_data0 = reg_wr_data[39:32];
assign user_scratch3_wr_data1 = reg_wr_data[47:40];
assign user_scratch3_wr_data2 = reg_wr_data[55:48];
assign user_scratch3_wr_data3 = reg_wr_data[63:56];


// ---------------
// Register Writes

// Interrupt Status Register
//   Set   interrupt status for each bit that is written to 1 to ADDR_USER_INT_SET
//   Clear interrupt status for each bit that is written to 1 to ADDR_USER_INT_STATUS
always @(posedge reg_clk or negedge reg_rst_n)
begin
    if (reg_rst_n == 1'b0)
    begin
        mgmt_interrupt_status <= 32'h0;
    end
    else
    begin
        if (user_int_set_wr_en0)
            mgmt_interrupt_status[ 7: 0] <= mgmt_interrupt_status[ 7: 0] | user_int_set_wr_data0;
        else if (user_int_status_wr_en0)
            mgmt_interrupt_status[ 7: 0] <= mgmt_interrupt_status[ 7: 0] & (~user_int_status_wr_data0);

        if (user_int_set_wr_en1)
            mgmt_interrupt_status[15: 8] <= mgmt_interrupt_status[15: 8] | user_int_set_wr_data1;
        else if (user_int_status_wr_en1)
            mgmt_interrupt_status[15: 8] <= mgmt_interrupt_status[15: 8] & (~user_int_status_wr_data1);

        if (user_int_set_wr_en2)
            mgmt_interrupt_status[23:16] <= mgmt_interrupt_status[23:16] | user_int_set_wr_data2;
        else if (user_int_status_wr_en2)
            mgmt_interrupt_status[23:16] <= mgmt_interrupt_status[23:16] & (~user_int_status_wr_data2);

        if (user_int_set_wr_en3)
            mgmt_interrupt_status[31:24] <= mgmt_interrupt_status[31:24] | user_int_set_wr_data3;
        else if (user_int_status_wr_en3)
            mgmt_interrupt_status[31:24] <= mgmt_interrupt_status[31:24] & (~user_int_status_wr_data3);
    end
end

// Interrupt Pulse Register
//   Pulse mgmt_interrupt_pulse for each bit that is written to 1 to ADDR_USER_INT_SET
always @(posedge reg_clk or negedge reg_rst_n)
begin
    if (reg_rst_n == 1'b0)
    begin
        mgmt_interrupt_pulse <= 32'h0;
    end
    else
    begin
        mgmt_interrupt_pulse[ 7: 0] <= {8{user_int_set_wr_en0}} & user_int_set_wr_data0;
        mgmt_interrupt_pulse[15: 8] <= {8{user_int_set_wr_en1}} & user_int_set_wr_data1;
        mgmt_interrupt_pulse[23:16] <= {8{user_int_set_wr_en2}} & user_int_set_wr_data2;
        mgmt_interrupt_pulse[31:24] <= {8{user_int_set_wr_en3}} & user_int_set_wr_data3;
    end
end

// Syncronize mgmt_interrupt_status to clk domain (32 separate interrupt lines used for Legacy Interrupt Mode)
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        d_sync_mgmt_interrupt_status <= 32'h0;
        sync_mgmt_interrupt_status   <= 32'h0;
    end
    else
    begin
        d_sync_mgmt_interrupt_status <=        mgmt_interrupt_status;
        sync_mgmt_interrupt_status   <= d_sync_mgmt_interrupt_status;
    end
end

generate for (i=0; i<32; i=i+1)
    begin : gen_sync_mgmt_interrupt_pulse

        util_toggle_pos_sync u_sync_mgmt_interrupt_pulse (

            .d_clk_rst_n    (reg_rst_n                      ),
            .d_clk          (reg_clk                        ),
            .d              (mgmt_interrupt_pulse[i]        ),

            .q_clk_rst_n    (rst_n                          ),
            .q_clk          (clk                            ),
            .q              (sync_mgmt_interrupt_pulse[i]   )

        );
    end
endgenerate

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        mgmt_msixmsi_legacy_n <= 1'b0;
        mgmt_interrupt        <= 32'h0;
    end
    else
    begin
        // Set when MSI-X or MSI interrupts are in use; clear when legacy interrupts are in use
        mgmt_msixmsi_legacy_n <= mgmt_msix_en | mgmt_msi_en;

        // Interrupt Output
        mgmt_interrupt <= mgmt_msixmsi_legacy_n ? sync_mgmt_interrupt_pulse[ 31:0] : // Event based interrupts
                                                  sync_mgmt_interrupt_status[31:0];  // Level based interrupts
    end
end

// scratch pad registers
always @(posedge reg_clk or negedge reg_rst_n)
begin
    if (reg_rst_n == 1'b0)
    begin
        user_scratch0_reg <= 32'h0000_0000;
        user_scratch1_reg <= 32'h1111_1111;
        user_scratch2_reg <= 32'h2222_2222;
        user_scratch3_reg <= 32'h3333_3333;
    end
    else
    begin
        if (user_scratch0_wr_en0 == 1'b1) user_scratch0_reg[ 7: 0] <= user_scratch0_wr_data0;
        if (user_scratch0_wr_en1 == 1'b1) user_scratch0_reg[15: 8] <= user_scratch0_wr_data1;
        if (user_scratch0_wr_en2 == 1'b1) user_scratch0_reg[23:16] <= user_scratch0_wr_data2;
        if (user_scratch0_wr_en3 == 1'b1) user_scratch0_reg[31:24] <= user_scratch0_wr_data3;

        if (user_scratch1_wr_en0 == 1'b1) user_scratch1_reg[ 7: 0] <= user_scratch1_wr_data0;
        if (user_scratch1_wr_en1 == 1'b1) user_scratch1_reg[15: 8] <= user_scratch1_wr_data1;
        if (user_scratch1_wr_en2 == 1'b1) user_scratch1_reg[23:16] <= user_scratch1_wr_data2;
        if (user_scratch1_wr_en3 == 1'b1) user_scratch1_reg[31:24] <= user_scratch1_wr_data3;

        if (user_scratch2_wr_en0 == 1'b1) user_scratch2_reg[ 7: 0] <= user_scratch2_wr_data0;
        if (user_scratch2_wr_en1 == 1'b1) user_scratch2_reg[15: 8] <= user_scratch2_wr_data1;
        if (user_scratch2_wr_en2 == 1'b1) user_scratch2_reg[23:16] <= user_scratch2_wr_data2;
        if (user_scratch2_wr_en3 == 1'b1) user_scratch2_reg[31:24] <= user_scratch2_wr_data3;

        if (user_scratch3_wr_en0 == 1'b1) user_scratch3_reg[ 7: 0] <= user_scratch3_wr_data0;
        if (user_scratch3_wr_en1 == 1'b1) user_scratch3_reg[15: 8] <= user_scratch3_wr_data1;
        if (user_scratch3_wr_en2 == 1'b1) user_scratch3_reg[23:16] <= user_scratch3_wr_data2;
        if (user_scratch3_wr_en3 == 1'b1) user_scratch3_reg[31:24] <= user_scratch3_wr_data3;
    end
end

// ------------------
// Register Read-Back

// Note: These signals come from the clk domain and are read-back in the reg_clk domain;
//       These signals are pseudo-static, so just register once in reg_clk domain instead
//       of a more complicated synchronizer
always @(posedge reg_clk or negedge reg_rst_n)
begin
    if (reg_rst_n == 1'b0)
    begin
        reg_mgmt_core_ph    <= 8'h0;
        reg_mgmt_core_pd    <= 12'h0;
        reg_mgmt_core_nh    <= 8'h0;
        reg_mgmt_core_nd    <= 12'h0;
        reg_mgmt_core_ch    <= 8'h0;
        reg_mgmt_core_cd    <= 12'h0;

        reg_mgmt_chipset_ph <= 8'h0;
        reg_mgmt_chipset_pd <= 12'h0;
        reg_mgmt_chipset_nh <= 8'h0;
        reg_mgmt_chipset_nd <= 12'h0;
        reg_mgmt_chipset_ch <= 8'h0;
        reg_mgmt_chipset_cd <= 12'h0;
    end
    else
    begin
        reg_mgmt_core_ph    <= mgmt_core_ph;
        reg_mgmt_core_pd    <= mgmt_core_pd;
        reg_mgmt_core_nh    <= mgmt_core_nh;
        reg_mgmt_core_nd    <= mgmt_core_nd;
        reg_mgmt_core_ch    <= mgmt_core_ch;
        reg_mgmt_core_cd    <= mgmt_core_cd;

        reg_mgmt_chipset_ph <= mgmt_chipset_ph;
        reg_mgmt_chipset_pd <= mgmt_chipset_pd;
        reg_mgmt_chipset_nh <= mgmt_chipset_nh;
        reg_mgmt_chipset_nd <= mgmt_chipset_nd;
        reg_mgmt_chipset_ch <= mgmt_chipset_ch;
        reg_mgmt_chipset_cd <= mgmt_chipset_cd;
    end
end

always @*
begin
    case (reg_rd_addr[4:0])
        ADDR_CORE_P_CREDITS  : c_reg_rd_data = {4'h0, reg_mgmt_core_nd,    8'h0, reg_mgmt_core_nh,
                                                4'h0, reg_mgmt_core_pd,    8'h0, reg_mgmt_core_ph};

        ADDR_CORE_C_CREDITS  : c_reg_rd_data = {32'h0,
                                                4'h0, reg_mgmt_core_cd,    8'h0, reg_mgmt_core_ch};

        ADDR_REM_P_CREDITS   : c_reg_rd_data = {4'h0, reg_mgmt_chipset_nd, 8'h0, reg_mgmt_chipset_nh,
                                                4'h0, reg_mgmt_chipset_pd, 8'h0, reg_mgmt_chipset_ph};

        ADDR_REM_C_CREDITS   : c_reg_rd_data = {32'h0,
                                                4'h0, reg_mgmt_chipset_cd, 8'h0, reg_mgmt_chipset_ch};

        ADDR_USER_INT_STATUS : c_reg_rd_data = {32'h0,
                                                mgmt_interrupt_status[31:0]};

        ADDR_USER_SCRATCH0   : c_reg_rd_data = {user_scratch1_reg,
                                                user_scratch0_reg};

        ADDR_USER_SCRATCH2   : c_reg_rd_data = {user_scratch3_reg,
                                                user_scratch2_reg};

        default              : c_reg_rd_data = {AXI_DATA_WIDTH{1'b0}};
    endcase
end
always @(posedge reg_clk or negedge reg_rst_n)
begin
    if (reg_rst_n == 1'b0)
        reg_rd_data <= {AXI_DATA_WIDTH{1'b0}};
    else
        reg_rd_data <= reg_rd_hit ? c_reg_rd_data : {AXI_DATA_WIDTH{1'b0}};
end



endmodule
