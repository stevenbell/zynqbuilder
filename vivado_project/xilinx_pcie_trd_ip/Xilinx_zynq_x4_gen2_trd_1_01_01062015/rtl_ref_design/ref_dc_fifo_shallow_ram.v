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

// -------------------------------------------------------------------------
//
//  FUNCTIONAL DESCRIPTION
//
//  Dual clock domain, speculatively readable FIFO
//     using block RAM with a read latency of 1 clock
//
//  This module implements a dual clock FIFO that uses Gray Code
//    conversion to handle FIFO level synchronization between the
//    two clock domains.  This design can accomodate any frequency
//    relationship between the 2 clocks.
//
//  FIFO full/empty status is determined from subtracting the
//    synchornized FIFO address counters from both the read 
//    and write interfaces
//
//  Read FIFO logic permits data to be speculatively read from the FIFO:
//    flush is used to synchronously reset the FIFO effectively removing
//      all data from the FIFO; if unused it must be set to 0.
//    rd_ack is used to read data from the FIFO and advances the FIFO
//      rd_addr pointer and updates the FIFO read level and read flags
//    rd_xfer indicates that one data read from the FIFO transfered and 
//      thus can be removed from the FIFO; rd_xfer advances the rd_xfer_addr
//      pointer and is used to update the FIFO write level and flags
//    rd_sync indicates that the rd_addr pointer should be set back to the
//      value of the rd_xfer_addr pointer; rd_sync is strobed when it is known
//      that speculatively read data will not be transfered (usually this is known
//      at the end of a transaction); rd_sync effectively puts back the read
//      data that did not transfer so that it can be transfered at a later time
//    If speculative read prefetching via rd_ack, rd_xfer, and rd_sync is not
//      desired then this logic can be disabled by setting parameter 
//      EN_SPECULATIVE_RD = 0.  In this case, rd_xfer and rd_sync must
//      bet hardcoded to 0.
//
//  When this FIFO is used as a Data FIFO with a parallel Command FIFO,
//    it is necessary to delay the rd_clk domain's knowledge of a write
//    to the Data FIFO by one wr_clk in order to ensure that when a Command
//    and Data word are input into the two parallel FIFOs on the same wr_clk
//    clock cycle, that the Command word will always be seen on the rd_clk
//    side of the FIFO at or before the Data word; this behavior is enabled 
//    by setting parameter DLY_WR_FOR_RD_LVL == 1; for standard FIFO use
//    without a parallel FIFO dependency, set DLY_WR_FOR_RD_LVL == 0
//
//  Notes on FMax:
//    There are several optional FIFO features that when used, reduce FMax:
//      rd_flush (to disable, tie to 0)
//      rd_sync (to disable, tie to 0 and set parameter EN_SPECULATIVE_RD=0)
//      Read look ahead (to disable, set parameter EN_LOOK_AHEAD=0)
//
//  This module includes assertion warnings to check for overflow/underflow
//    usage errors during simulations
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module ref_dc_fifo_shallow_ram (
    wr_rst_n,
    wr_clk, 
    wr_clr,
    wr_en,
    wr_data,
    wr_level,
    wr_full,

    rd_rst_n,
    rd_clk, 
    rd_clr,
    rd_flush,    
    rd_ack,
    rd_xfer,
    rd_sync,
    rd_data,
    rd_level,
    rd_xfer_level,
    rd_empty
);  



// ----------------
// -- Parameters --
// ----------------

parameter   ADDR_WIDTH          = 7;    // Set to desired number of RAM address bits
parameter   DATA_WIDTH          = 72;   // Set to desired number of RAM data bits
parameter   EN_SPECULATIVE_RD   = 0;    // Set to enable speculative read logic, clear to disable
parameter   EN_LOOK_AHEAD       = 0;    // Set to compute look ahead read address to reduce FIFO latency from 1 to 0; NOTE! Setting affects FMax performance
parameter   DLY_WR_FOR_RD_LVL   = 0;    // Set to delay the rd_clk domain's knowledge of writes by 1 wr_clk to ensure data ordering when used with a parallel FIFO



// -----------------------
// -- Port Declarations --
// -----------------------

input                           wr_rst_n;       // Active low asynchronous reset for write clock domain
input                           wr_clk;         // Positive edge-triggered clock
input                           wr_clr;         // Synchronous reset
input                           wr_en;          // FIFO write enable
input   [DATA_WIDTH-1:0]        wr_data;        // FIFO write data
output  [ADDR_WIDTH:0]          wr_level;       // FIFO write level
output                          wr_full;        // FIFO write full flag

input                           rd_rst_n;       // Active low asynchronous reset for read clock domain
input                           rd_clk;         // Positive edge-triggered clock
input                           rd_clr;         // Synchronous reset
input                           rd_flush;       // Set to flush the FIFO of all data that is known to the read side of FIFO at the time (adds rd_level to rd_addr)
input                           rd_ack;         // FIFO read acknowledge 
input                           rd_xfer;        // FIFO read transfer acknowledge (only used when EN_SPECULATIVE_RD == 1; see header)
input                           rd_sync;        // FIFO read synchronization (only used when EN_SPECULATIVE_RD == 1; see header)
output  [DATA_WIDTH-1:0]        rd_data;        // FIFO read data
output  [ADDR_WIDTH:0]          rd_level;       // FIFO read level
output  [ADDR_WIDTH:0]          rd_xfer_level;  // FIFO xfer read level
output                          rd_empty;       // FIFO read empty flag
                                                    


// ----------------
// -- Port Types --
// ----------------

wire                            wr_rst_n;
wire                            wr_clk;
wire                            wr_clr;
wire                            wr_en;
wire    [DATA_WIDTH-1:0]        wr_data;
reg     [ADDR_WIDTH:0]          wr_level;       
reg                             wr_full;

wire                            rd_rst_n;
wire                            rd_clk;
wire                            rd_clr;
wire                            rd_flush;
wire                            rd_ack;
wire                            rd_xfer;
wire                            rd_sync;
wire    [DATA_WIDTH-1:0]        rd_data;
reg     [ADDR_WIDTH:0]          rd_level;       
reg     [ADDR_WIDTH:0]          rd_xfer_level;       
reg                             rd_empty;



// ---------------------
// -- Local Variables --
// ---------------------

// RAM address
wire    [ADDR_WIDTH-1:0]    ram_wr_addr;
wire    [ADDR_WIDTH-1:0]    ram_rd_addr;

// FIFO write address pointers; carry an extra address bit
//   to differentiate full from empty when pointers are equal
wire    [ADDR_WIDTH:0]      c_wr_addr;
reg     [ADDR_WIDTH:0]      wr_addr;
reg     [ADDR_WIDTH:0]      r_wr_addr;
wire    [ADDR_WIDTH:0]      rd_wr_addr;
wire    [ADDR_WIDTH:0]      wr_side_rd_addr;

wire                        wr_diff_half;
wire    [ADDR_WIDTH:0]      c_wr_level;

// FIFO read address pointers; carry an extra address bit
//   to differentiate full from empty when pointers are equal
wire    [ADDR_WIDTH:0]      c_rd_addr;
reg     [ADDR_WIDTH:0]      rd_addr;
wire    [ADDR_WIDTH:0]      c_xfer_rd_addr;
reg     [ADDR_WIDTH:0]      xfer_rd_addr;
wire    [ADDR_WIDTH:0]      c_wr_rd_addr;
wire    [ADDR_WIDTH:0]      rd_side_wr_addr;

wire                        rd_ack_diff_half;
wire    [ADDR_WIDTH:0]      c_rd_ack_level;

wire                        rd_xfer_diff_half;
wire    [ADDR_WIDTH:0]      c_rd_xfer_level;  



// ---------------
// -- Equations --
// ---------------

// Instantiate dual port RAM for FIFO;
//   read enable is always asserted, so the rd_data
//   output depends exclusively on rd_addr;
ref_inferred_shallow_ram #(

    .ADDR_WIDTH         (ADDR_WIDTH         ),                  
    .DATA_WIDTH         (DATA_WIDTH         )

) fifo_ram (

    .wr_clk             (wr_clk             ),
    .wr_addr            (ram_wr_addr        ),
    .wr_en              (wr_en              ),
    .wr_data            (wr_data            ),

    .rd_clk             (rd_clk             ),
    .rd_addr            (ram_rd_addr        ),
    .rd_data            (rd_data            )

);

// An extra address bit is carried in the write and
//   read address pointers to determine the empty/full
//   condition when the remaining write and read addresses are
//   the same; drop this bit when accessing the RAM
assign ram_wr_addr = wr_addr[ADDR_WIDTH-1:0];
assign ram_rd_addr = EN_LOOK_AHEAD ? c_rd_addr[ADDR_WIDTH-1:0] : rd_addr[ADDR_WIDTH-1:0];



// --------------------
//  Write side of FIFO

// Generate next wr_addr
assign c_wr_addr = wr_addr + {{ADDR_WIDTH{1'b0}}, wr_en};

always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        wr_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        wr_addr <= wr_clr ? {(ADDR_WIDTH+1){1'b0}} : c_wr_addr;
end

always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        r_wr_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        r_wr_addr <= wr_clr ? {(ADDR_WIDTH+1){1'b0}} : wr_addr;
end

// Delay wr_addr to read FIFO level logic if parameter DLY_WR_FOR_RD_LVL is set
assign rd_wr_addr = DLY_WR_FOR_RD_LVL ? r_wr_addr : wr_addr;

// Synchronize c_wr_rd_addr into wr_clk domain
ref_gray_sync_bus #((ADDR_WIDTH+1), 1) sync_c_wr_rd_addr (

    .d_rst_n    (rd_rst_n           ),
    .d_clk      (rd_clk             ),
    .d_clr      (rd_clr             ),
    .d          (c_wr_rd_addr       ),

    .q_rst_n    (wr_rst_n           ),
    .q_clk      (wr_clk             ),
    .q_clr      (wr_clr             ),
    .q          (wr_side_rd_addr    )

);

// If the extra address bit being carried in each of the FIFO addresses have
//   different values, then the write address has wrapped relative to the read
//   address and 2^ADDR_WIDTH must be added to the write address in order to
//   determining the true level
assign wr_diff_half = (c_wr_addr[ADDR_WIDTH] != wr_side_rd_addr[ADDR_WIDTH]);
assign c_wr_level   = {wr_diff_half, c_wr_addr[ADDR_WIDTH-1:0]} - {1'b0, wr_side_rd_addr[ADDR_WIDTH-1:0]};

always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        wr_level <= {(ADDR_WIDTH+1){1'b0}};
    else
        wr_level <= wr_clr ? {(ADDR_WIDTH+1){1'b0}} : c_wr_level;
end

// Compute wr_full
always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        wr_full <= 1'b0;
    else 
        // c_wr_level[ADDR_WIDTH] can only be set on the full condition
        wr_full <= wr_clr ? 1'b0 : c_wr_level[ADDR_WIDTH];
end



// -------------------
//  Read side of FIFO

// Generate next rd_addr
assign c_rd_addr = rd_flush ? (rd_addr + rd_level) : (rd_sync ? (xfer_rd_addr + {{ADDR_WIDTH{1'b0}}, rd_xfer}) : (rd_addr + {{ADDR_WIDTH{1'b0}}, rd_ack}));

always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
        rd_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        rd_addr <= rd_clr ? {(ADDR_WIDTH+1){1'b0}} : c_rd_addr;
end

// Generate xfer_rd_addr
assign c_xfer_rd_addr = rd_flush ? (rd_addr + rd_level) : (xfer_rd_addr + {{ADDR_WIDTH{1'b0}}, rd_xfer});

always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
        xfer_rd_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        xfer_rd_addr <= rd_clr ? {(ADDR_WIDTH+1){1'b0}} : c_xfer_rd_addr;
end

// Select which read address is used to determine the write level; 
//   when speculative reads are enabled use c_xfer_rd_addr so that
//   only data that is confirmed as transfered is removed from the FIFO;
//   when speculative reads are not enabled, then use c_rd_addr since
//   on rd_ack data is confirmed as transfered and can be removed from the FIFO
assign c_wr_rd_addr = EN_SPECULATIVE_RD ? xfer_rd_addr : rd_addr;

// Synchronize wr_addr into rd_clk domain
ref_gray_sync_bus #((ADDR_WIDTH+1), 1) sync_wr_addr (

    .d_rst_n    (wr_rst_n           ),
    .d_clk      (wr_clk             ),
    .d_clr      (wr_clr             ),
    .d          (rd_wr_addr         ),

    .q_rst_n    (rd_rst_n           ),
    .q_clk      (rd_clk             ),
    .q_clr      (rd_clr             ),
    .q          (rd_side_wr_addr    )

);

// If the extra address bit being carried in each of the FIFO addresses have
//   different values, then the write address has wrapped relative to the read
//   address and 2^ADDR_WIDTH must be added to the write address in order to
//   determining the true level

assign rd_ack_diff_half  = (rd_side_wr_addr[ADDR_WIDTH] != rd_addr[ADDR_WIDTH]);
assign c_rd_ack_level    = {rd_ack_diff_half, rd_side_wr_addr[ADDR_WIDTH-1:0]} - {1'b0, rd_addr[ADDR_WIDTH-1:0]};

assign rd_xfer_diff_half = (rd_side_wr_addr[ADDR_WIDTH] != xfer_rd_addr[ADDR_WIDTH]);
assign c_rd_xfer_level   = {rd_xfer_diff_half, rd_side_wr_addr[ADDR_WIDTH-1:0]} - {1'b0, xfer_rd_addr[ADDR_WIDTH-1:0]};

// Compute rd_level
always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
        rd_level <= {(ADDR_WIDTH+1){1'b0}};
    else
    begin
        if (rd_flush | rd_clr)
            rd_level <= {(ADDR_WIDTH+1){1'b0}};
        else if (rd_sync)
            rd_level <= rd_xfer ? (c_rd_xfer_level - {{ADDR_WIDTH{1'b0}}, 1'b1}) : c_rd_xfer_level;
        else
            rd_level <= rd_ack  ? (c_rd_ack_level  - {{ADDR_WIDTH{1'b0}}, 1'b1}) : c_rd_ack_level;
    end
end

always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
        rd_xfer_level <= {(ADDR_WIDTH+1){1'b0}};
    else
        rd_xfer_level <= rd_clr ? {(ADDR_WIDTH+1){1'b0}} : (rd_xfer ? (c_rd_xfer_level - {{ADDR_WIDTH{1'b0}}, 1'b1}) : c_rd_xfer_level);
end

// Compute rd_empty
always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
        rd_empty <= 1'b1;
    else
    begin
        if (rd_flush | rd_clr)
            rd_empty <= 1'b1;
        else if (rd_sync)
            rd_empty <= ((c_rd_xfer_level == {{ADDR_WIDTH{1'b0}}, 1'b1}) & rd_xfer) | (c_rd_xfer_level == {(ADDR_WIDTH+1){1'b0}});
        else
            rd_empty <= ((c_rd_ack_level == {{ADDR_WIDTH{1'b0}}, 1'b1}) & rd_ack) | (c_rd_ack_level == {(ADDR_WIDTH+1){1'b0}});
    end
end



`ifdef SIMULATION
// ----------------------
//  Assertion Monitoring

// The following lines generate assertion warnings when the FIFO interface
//   has been misused.  These statements are not synthesizable and should 
//   be automatically removed during synthesis.  If the synthesizer does
//   not automatically remove them then they can be deleted without affecting
//   the functionality of this module.

// Check for FIFO overflow 
always @(posedge wr_clk)
begin
    if (wr_en & wr_full)
    begin
        $display ("%m : ** ERROR ** : Overflow : wr_en asserted when wr_full was asserted at time %t", $time);
    end    
end

// Check for FIFO underflow 
always @(posedge rd_clk)
begin
    if (rd_ack & rd_empty)
    begin
        $display ("%m : ** ERROR ** : Underflow : rd_ack asserted when rd_empty was asserted at time %t", $time);
    end    
end



`endif
endmodule
