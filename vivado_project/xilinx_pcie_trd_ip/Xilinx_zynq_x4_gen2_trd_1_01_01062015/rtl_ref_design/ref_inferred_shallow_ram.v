//  ------------------------- CONFIDENTIAL ----------------------------------
//
//                 (c) Copyright 2010 by Northwest Logic, Inc.
//
//  All rights reserved.  No part of this source code may be reproduced or
//  transmitted in any form or by any means, electronic or mechanical,
//  including photocopying, recording, or any information storage and
//  retrieval system, without permission in writing from Northwest Logic, Inc.
//
//  Further, no use of this source code is permitted in any form or means
//  without a valid, written license agreement with Northwest Logic, Inc.
//
// $Date: 2014-05-07 08:39:04 -0700 (Wed, 07 May 2014) $
// $Revision: 46484 $
//
//                         Northwest Logic, Inc.
//                  1100 NW Compton Drive, Suite 100
//                      Beaverton, OR 97006, USA
//
//                       Ph.  +1 503 533 5800
//                       Fax. +1 503 533 5900
//                          www.nwlogic.com
//
//  -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module ref_inferred_shallow_ram (

    wr_clk,
    wr_addr,
    wr_en,
    wr_data,

    rd_clk,
    rd_addr,
    rd_data

);



// ----------------
// -- Parameters --
// ----------------

parameter   ADDR_WIDTH          = 9;                // Set to desired number of address bits
parameter   DATA_WIDTH          = 8;                // Set to desired number of data bits
parameter   FAST_READ           = 0;                // If 1, allows simultaneous read and write

`ifdef SIMULATION
localparam  INITIAL_SIM_VALUE   = 1'b0;             // Set the initial value for all ram bits (used for simulation only)
`endif
localparam  NUM_WORDS           = 1 << ADDR_WIDTH;  // The number of words is 2^ADDR_WIDTH



// -----------------------
// -- Port Declarations --
// -----------------------

input                           wr_clk;
input   [ADDR_WIDTH-1:0]        wr_addr;
input                           wr_en;
input   [DATA_WIDTH-1:0]        wr_data;

input                           rd_clk;
input   [ADDR_WIDTH-1:0]        rd_addr;
output  [DATA_WIDTH-1:0]        rd_data;



// ----------------
// -- Port Types --
// ----------------

wire                            wr_clk;
wire    [ADDR_WIDTH-1:0]        wr_addr;
wire                            wr_en;
wire    [DATA_WIDTH-1:0]        wr_data;

wire                            rd_clk;
wire    [ADDR_WIDTH-1:0]        rd_addr;
wire    [DATA_WIDTH-1:0]        rd_data;



// ---------------------
// -- Local Variables --
// ---------------------

reg     [ADDR_WIDTH-1:0]        r_rd_addr;
(* ram_style = "distributed" *)
reg     [DATA_WIDTH-1:0]        mem [NUM_WORDS-1:0];



// ---------------
// -- Equations --
// ---------------


// Perform RAM write
always @(posedge wr_clk)
begin
    if (wr_en)
        mem[wr_addr] <= wr_data;
end

// Register read inputs
// bluepearl disable 24 // (Register 'X' has no asynchronous preset/clear)
// bluepearl disable 224 // Synchronization of data crossing clock domain boundary is attempted using a memory/register file
always @(posedge rd_clk)
begin
    r_rd_addr <= rd_addr;
end
// bluepearl enable 24 // (Register 'X' has no asynchronous preset/clear)
// bluepearl enable 224 // Synchronization of data crossing clock domain boundary is attempted using a memory/register file

`ifdef SIMULATION

reg [ADDR_WIDTH-1:0] r_wr_addr;
reg                  r_wr_en;
wire                 wr_rd_collision;

always @(posedge wr_clk)
begin
    r_wr_en <= wr_en;
    if (wr_en == 1'b1)
        r_wr_addr <= wr_addr;
end

assign wr_rd_collision = (FAST_READ == 1) ? 1'b0 : (r_wr_en & (r_wr_addr == r_rd_addr));

initial r_rd_addr = {ADDR_WIDTH{1'b0}};

assign rd_data = (wr_rd_collision == 1'b1) ? {DATA_WIDTH{1'bx}} : mem[r_rd_addr];

// Initialize the memory for simualtion
integer i;
initial
begin
    for (i=0; i<NUM_WORDS; i=i+1)
        mem[i] = {DATA_WIDTH{INITIAL_SIM_VALUE}};
end
 `else // SIMULATION

assign rd_data = mem[r_rd_addr];
 `endif // SIMULATION

`ifdef SIMULATION
initial $display("RAM Instance using ADDR_WIDTH=%d, DATA_WIDTH=%d, FAST_READ=%d : %m",ADDR_WIDTH,DATA_WIDTH,FAST_READ);
`endif

endmodule
