// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2011 by Northwest Logic, Inc.
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

module ref_dc_fifo (
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
    rd_data,
    rd_level,
    rd_empty
);



// ----------------
// -- Parameters --
// ----------------

parameter   ADDR_WIDTH          = 7;     // Set to desired number of RAM address bits
parameter   DATA_WIDTH          = 72;   // Set to desired number of RAM data bits
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
output  [DATA_WIDTH-1:0]        rd_data;        // FIFO read data
output  [ADDR_WIDTH:0]          rd_level;       // FIFO read level
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
reg     [DATA_WIDTH-1:0]        rd_data;
wire    [ADDR_WIDTH:0]          rd_level;
wire                            rd_empty;



// ---------------------
// -- Local Variables --
// ---------------------

wire                            rst_n;

reg                             d1_wr_rst_n;
reg                             d2_wr_rst_n;

reg                             d1_rd_rst_n;
reg                             d2_rd_rst_n;

// Memory to Register signals
wire    [DATA_WIDTH-1:0]        rdf_data;
wire                            rdf_ack;
reg                             rdf_empty;
reg     [ADDR_WIDTH:0]          rdf_level;
reg                             rdr_empty;

// RAM address
wire    [ADDR_WIDTH-1:0]        ram_wr_addr;
wire    [ADDR_WIDTH-1:0]        ram_rd_addr;

// FIFO write address pointers; carry an extra address bit
//   to differentiate full from empty when pointers are equal
reg     [ADDR_WIDTH:0]          c_wr_addr;
reg     [ADDR_WIDTH:0]          wr_addr;
reg     [ADDR_WIDTH:0]          r_wr_addr;
wire    [ADDR_WIDTH:0]          rd_wr_addr;
wire    [ADDR_WIDTH:0]          wr_side_rd_addr;

wire                            wr_diff_half;
wire    [ADDR_WIDTH:0]          c_wr_level;

// FIFO read address pointers; carry an extra address bit
//   to differentiate full from empty when pointers are equal
wire    [ADDR_WIDTH:0]          c_rd_addr;
reg     [ADDR_WIDTH:0]          rd_addr;
wire    [ADDR_WIDTH:0]          c_wr_rd_addr;
wire    [ADDR_WIDTH:0]          rd_side_wr_addr;

wire                            rd_ack_diff_half;
wire    [ADDR_WIDTH:0]          c_rd_ack_level;



// ---------------
// -- Equations --
// ---------------

assign  rst_n = rd_rst_n & wr_rst_n;

// synchronize combined reset to read and write clock domains
always @(posedge rd_clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        d1_rd_rst_n <= 1'b0;
        d2_rd_rst_n <= 1'b0;
    end
    else
    begin
        d1_rd_rst_n <= 1'b1;
        d2_rd_rst_n <= d1_rd_rst_n;
    end
end

always @(posedge wr_clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        d1_wr_rst_n <= 1'b0;
        d2_wr_rst_n <= 1'b0;
    end
    else
    begin
        d1_wr_rst_n <= 1'b1;
        d2_wr_rst_n <= d1_wr_rst_n;
    end
end


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
    .rd_data            (rdf_data           )

);

// An extra address bit is carried in the write and
//   read address pointers to determine the empty/full
//   condition when the remaining write and read addresses are
//   the same; drop this bit when accessing the RAM
assign ram_wr_addr = wr_addr[ADDR_WIDTH-1:0];
// assign ram_rd_addr = EN_LOOK_AHEAD ? c_rd_addr[ADDR_WIDTH-1:0] : rd_addr[ADDR_WIDTH-1:0];
assign  ram_rd_addr = c_rd_addr[ADDR_WIDTH-1:0];



// --------------------
//  Write side of FIFO

// Generate next wr_addr
always @*
begin
    if (wr_en == 1'b1)
        c_wr_addr = wr_addr + {{ADDR_WIDTH{1'b0}},1'b1};
    else
        c_wr_addr = wr_addr;
end

always @(posedge wr_clk or negedge d2_wr_rst_n)
begin
    if (d2_wr_rst_n == 1'b0)
        wr_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        wr_addr <= wr_clr ? {(ADDR_WIDTH+1){1'b0}} : c_wr_addr;
end

always @(posedge wr_clk or negedge d2_wr_rst_n)
begin
    if (d2_wr_rst_n == 1'b0)
        r_wr_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        r_wr_addr <= wr_clr ? {(ADDR_WIDTH+1){1'b0}} : wr_addr;
end

// Delay wr_addr to read FIFO level logic if parameter DLY_WR_FOR_RD_LVL is set
assign rd_wr_addr = DLY_WR_FOR_RD_LVL ? r_wr_addr : wr_addr;

// Synchronize c_wr_rd_addr into wr_clk domain
ref_gray_sync_bus #((ADDR_WIDTH+1), 1) sync_c_wr_rd_addr (

    .d_rst_n    (d2_rd_rst_n        ),
    .d_clk      (rd_clk             ),
    .d_clr      (rd_clr             ),
    .d          (c_wr_rd_addr       ),

    .q_rst_n    (d2_wr_rst_n        ),
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

always @(posedge wr_clk or negedge d2_wr_rst_n)
begin
    if (d2_wr_rst_n == 1'b0)
        wr_level <= {(ADDR_WIDTH+1){1'b0}};
    else
        wr_level <= wr_clr ? {(ADDR_WIDTH+1){1'b0}} : c_wr_level;
end

// Compute wr_full
always @(posedge wr_clk or negedge d2_wr_rst_n)
begin
    if (d2_wr_rst_n == 1'b0)
        wr_full <= 1'b0;
    else
        // c_wr_level[ADDR_WIDTH] can only be set on the full condition
        wr_full <= wr_clr ? 1'b0 : c_wr_level[ADDR_WIDTH];
end


// -------------------
//  Read side of FIFO

// Generate next rd_addr
assign c_rd_addr = rd_flush ? (rd_addr + rd_level) : (rd_addr + {{ADDR_WIDTH{1'b0}}, rdf_ack});

always @(posedge rd_clk or negedge d2_rd_rst_n)
begin
    if (d2_rd_rst_n == 1'b0)
        rd_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        rd_addr <= rd_clr ? {(ADDR_WIDTH+1){1'b0}} : c_rd_addr;
end

assign c_wr_rd_addr = rd_addr;

// Synchronize wr_addr into rd_clk domain
ref_gray_sync_bus #((ADDR_WIDTH+1), 1) sync_wr_addr (

    .d_rst_n    (d2_wr_rst_n        ),
    .d_clk      (wr_clk             ),
    .d_clr      (wr_clr             ),
    .d          (rd_wr_addr         ),

    .q_rst_n    (d2_rd_rst_n        ),
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

// Compute rd_level
always @(posedge rd_clk or negedge d2_rd_rst_n)
begin
    if (d2_rd_rst_n == 1'b0)
        rdf_level <= {(ADDR_WIDTH+1){1'b0}};
    else
    begin
        if (rd_flush | rd_clr)
            rdf_level <= {(ADDR_WIDTH+1){1'b0}};
        else
            rdf_level <= rdf_ack  ? (c_rd_ack_level  - {{ADDR_WIDTH{1'b0}}, 1'b1}) : c_rd_ack_level;
    end
end

// Compute rd_empty
always @(posedge rd_clk or negedge d2_rd_rst_n)
begin
    if (d2_rd_rst_n == 1'b0)
        rdf_empty <= 1'b1;
    else
    begin
        if (rd_flush | rd_clr)
            rdf_empty <= 1'b1;
        else
            rdf_empty <= ((c_rd_ack_level  == {{ADDR_WIDTH{1'b0}}, 1'b1}) & rdf_ack)  | (c_rd_ack_level  == {(ADDR_WIDTH+1){1'b0}});
    end
end

assign  rdf_ack  = EN_LOOK_AHEAD ? (rdr_empty | rd_ack) & ~rdf_empty : rd_ack & ~rdf_empty;
assign  rd_level = EN_LOOK_AHEAD ? ((rdr_empty) ? {(ADDR_WIDTH+1){1'b0}} : rdf_level + {{ADDR_WIDTH{1'b0}},1'b1}) :
                                    rdf_level;
assign  rd_empty = EN_LOOK_AHEAD ? rdr_empty : rdf_empty;

always @(posedge rd_clk or negedge d2_rd_rst_n) begin
    if (d2_rd_rst_n == 1'b0) begin
        rdr_empty <= 1'b1;
        rd_data <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if (rd_flush | rd_clr) begin
            rdr_empty <= 1'b1;
            rd_data  <= {DATA_WIDTH{1'b0}};
        end
        else if (rdf_ack) begin
            rdr_empty <= 1'b0;
            rd_data  <= rdf_data;
        end
        else if (rd_ack) begin
            rdr_empty <= 1'b1;
            rd_data  <= {DATA_WIDTH{1'b0}};
        end
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
    if (rdf_ack & rdf_empty)
    begin
        $display ("%m : ** ERROR ** : Underflow : rd_ack asserted when rd_empty was asserted at time %t", $time);
    end
end



`endif
endmodule
