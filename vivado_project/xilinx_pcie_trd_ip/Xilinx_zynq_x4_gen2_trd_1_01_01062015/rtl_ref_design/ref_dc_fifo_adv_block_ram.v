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
//  Dual clock domain FIFO using block RAM with a read latency of 1 clock;
//    Contains two read ports:
//      1) Regular read port
//      2) Read port which tracks level in response to rd_adv_en, rd_adv_inc;
//         this port is useful when data must be committed before it is 
//         transferred as in most overlapping command/data phase cases
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
//  To accomodate possible write to read memory latency, the rd_clk domain's 
//    knowledge of a write to the Data FIFO can be delayed by one wr_clk
//    in order to ensure that the data can be read on the read port when
//    its level and empty ports indicate that data is present; this 
//    behavior is enabled by setting DLY_WR_FOR_RD_LVL == 1
//
//  This module includes assertion warnings to check for overflow/underflow
//    usage errors during simulations
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module ref_dc_fifo_adv_block_ram (

    wr_rst_n,
    wr_clk, 
    wr_en,
    wr_data,
    wr_level,
    wr_full,

    rd_rst_n,
    rd_clk, 
    rd_en,
    rd_data,
    rd_level,
    rd_empty,
    rd_adv_en,
    rd_adv_inc,
    rd_adv_level

);  



// ----------------
// -- Parameters --
// ----------------

parameter   ADDR_WIDTH          = 7;            // Set to desired number of RAM address bits
parameter   DATA_WIDTH          = 72;           // Set to desired number of RAM data bits
parameter   INC_WIDTH           = ADDR_WIDTH-1; // Set to maximum increment width; must be < ADDR_WIDTH
parameter   EN_LOOK_AHEAD       = 0;            // Set to compute look ahead read address to reduce FIFO latency from 1 to 0; NOTE! Setting affects FMax performance
parameter   DLY_WR_FOR_RD_LVL   = 1;            // Set to delay the rd_clk domain's knowledge of writes by 1 wr_clk



// -----------------------
// -- Port Declarations --
// -----------------------

input                           wr_rst_n;       // Active low asynchronous reset for write clock domain
input                           wr_clk;         // Positive edge-triggered clock
input                           wr_en;          // FIFO write enable
input   [DATA_WIDTH-1:0]        wr_data;        // FIFO write data
output  [ADDR_WIDTH:0]          wr_level;       // FIFO write level
output                          wr_full;        // FIFO write full flag

input                           rd_rst_n;       // Active low asynchronous reset for read clock domain
input                           rd_clk;         // Positive edge-triggered clock
input                           rd_en;          // FIFO read acknowledge 
output  [DATA_WIDTH-1:0]        rd_data;        // FIFO read data
output  [ADDR_WIDTH:0]          rd_level;       // FIFO read level
output                          rd_empty;       // FIFO read empty flag
input                           rd_adv_en;      // FIFO read advance enable
input   [INC_WIDTH-1:0]         rd_adv_inc;     // FIFO read advance increment
output  [ADDR_WIDTH:0]          rd_adv_level;   // FIFO read advance level
                                                    


// ----------------
// -- Port Types --
// ----------------

wire                            wr_rst_n;
wire                            wr_clk;
wire                            wr_en;
wire    [DATA_WIDTH-1:0]        wr_data;
reg     [ADDR_WIDTH:0]          wr_level;       
reg                             wr_full;

wire                            rd_rst_n;
wire                            rd_clk;
wire                            rd_en;
wire    [DATA_WIDTH-1:0]        rd_data;
reg     [ADDR_WIDTH:0]          rd_level;       
reg                             rd_empty;
wire                            rd_adv_en;
wire    [INC_WIDTH-1:0]         rd_adv_inc;
reg     [ADDR_WIDTH:0]          rd_adv_level;       



// ---------------------
// -- Local Variables --
// ---------------------

// RAM address
wire    [ADDR_WIDTH-1:0]    ram_wr_addr;
wire    [ADDR_WIDTH-1:0]    ram_rd_addr;

//  Write Clock Domain
//   FIFO write address pointers carry an extra address bit
//   to differentiate full from empty when pointers are equal
wire    [ADDR_WIDTH:0]      wr_addr_plus1;
wire    [ADDR_WIDTH:0]      c_wr_addr;

reg     [ADDR_WIDTH:0]      wr_addr;
reg     [ADDR_WIDTH:0]      r_wr_addr;
wire    [ADDR_WIDTH:0]      rd_wr_addr;

wire    [ADDR_WIDTH:0]      wr_side_rd_addr;

wire                        wr_diff_half;
wire    [ADDR_WIDTH:0]      c_wr_level;

//  Read Clock Domain
//   FIFO read address pointers carry an extra address bit
//   to differentiate full from empty when pointers are equal
wire    [ADDR_WIDTH:0]      rd_addr_plus1;
wire    [ADDR_WIDTH:0]      c_rd_addr;

wire    [ADDR_WIDTH:0]      rd_adv_addr_plus_inc;
wire    [ADDR_WIDTH:0]      c_rd_adv_addr;       

reg     [ADDR_WIDTH:0]      rd_addr;
reg     [ADDR_WIDTH:0]      rd_adv_addr;

wire    [ADDR_WIDTH:0]      rd_side_wr_addr;

wire                        rd_en_diff_half;
wire    [ADDR_WIDTH:0]      c_rd_en_level;

wire                        rd_adv_en_diff_half;
wire    [ADDR_WIDTH:0]      c_rd_adv_en_level;



// ---------------
// -- Equations --
// ---------------

// Instantiate dual port RAM for FIFO;
//   read enable is always asserted, so the rd_data
//   output depends exclusively on rd_addr;
ref_inferred_block_ram #(

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
//   condition when the remaining write and read addresses bits
//   are the same; drop this bit when accessing the RAM
assign ram_wr_addr = wr_addr[ADDR_WIDTH-1:0];
assign ram_rd_addr = EN_LOOK_AHEAD ? c_rd_addr[ADDR_WIDTH-1:0] : rd_addr[ADDR_WIDTH-1:0];



// -------------------
//  Write Clock Domain

// Generate next wr_addr
assign wr_addr_plus1 = wr_addr + {{ADDR_WIDTH{1'b0}}, 1'b1};
assign c_wr_addr     = wr_en ? wr_addr_plus1 : wr_addr;

always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        wr_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        wr_addr <= c_wr_addr;
end

always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        r_wr_addr <= {(ADDR_WIDTH+1){1'b0}};
    else
        r_wr_addr <= wr_addr;
end

// Delay wr_addr to read FIFO level logic if parameter DLY_WR_FOR_RD_LVL is set
assign rd_wr_addr = (DLY_WR_FOR_RD_LVL == 0) ? wr_addr : r_wr_addr;

// Synchronize rd_addr into wr_clk domain
ref_gray_sync_bus #((ADDR_WIDTH + 1), 1) sync_rd_addr (

    .d_rst_n    (rd_rst_n           ),
    .d_clk      (rd_clk             ),
    .d_clr      (1'b0               ),
    .d          (rd_addr            ),

    .q_rst_n    (wr_rst_n           ),
    .q_clk      (wr_clk             ),
    .q_clr      (1'b0               ),
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
        wr_level <= c_wr_level;
end

// Compute wr_full
always @(posedge wr_clk or negedge wr_rst_n)
begin
    if (wr_rst_n == 1'b0)
        wr_full <= 1'b0;
    else 
        // c_wr_level[ADDR_WIDTH] can only be set on the full condition
        wr_full <= c_wr_level[ADDR_WIDTH];  
end



// ------------------
//  Read Clock Domain

// Generate next rd_addr
assign rd_addr_plus1 = rd_addr + {{ADDR_WIDTH{1'b0}}, 1'b1};
assign c_rd_addr     = rd_en ? rd_addr_plus1 : rd_addr;

assign rd_adv_addr_plus_inc = rd_adv_addr + {{(ADDR_WIDTH-INC_WIDTH){1'b0}}, rd_adv_inc};
assign c_rd_adv_addr        = rd_adv_en ? rd_adv_addr_plus_inc : rd_adv_addr;

always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
    begin
        rd_addr     <= {(ADDR_WIDTH+1){1'b0}};
        rd_adv_addr <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
        rd_addr     <= c_rd_addr;
        rd_adv_addr <= c_rd_adv_addr;
    end
end

// Synchronize rd_wr_addr into rd_clk domain
ref_gray_sync_bus #((ADDR_WIDTH + 1), 1) sync_rd_wr_addr (

    .d_rst_n    (wr_rst_n           ),
    .d_clk      (wr_clk             ),
    .d_clr      (1'b0               ),
    .d          (rd_wr_addr         ),

    .q_rst_n    (rd_rst_n           ),
    .q_clk      (rd_clk             ),
    .q_clr      (1'b0               ),
    .q          (rd_side_wr_addr    )

);

// If the extra address bit being carried in each of the FIFO addresses have
//   different values, then the write address has wrapped relative to the read
//   address and 2^ADDR_WIDTH must be added to the write address in order to
//   determining the true level
assign rd_en_diff_half     = (rd_side_wr_addr[ADDR_WIDTH] != c_rd_addr[ADDR_WIDTH]);
assign c_rd_en_level       = {rd_en_diff_half, rd_side_wr_addr[ADDR_WIDTH-1:0]} - {1'b0, c_rd_addr[ADDR_WIDTH-1:0]};

assign rd_adv_en_diff_half = (rd_side_wr_addr[ADDR_WIDTH] != c_rd_adv_addr[ADDR_WIDTH]);
assign c_rd_adv_en_level   = {rd_adv_en_diff_half, rd_side_wr_addr[ADDR_WIDTH-1:0]} - {1'b0, c_rd_adv_addr[ADDR_WIDTH-1:0]};

// Compute rd_level
always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
    begin
        rd_level     <= {(ADDR_WIDTH+1){1'b0}};
        rd_adv_level <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
        rd_level     <= c_rd_en_level;
        rd_adv_level <= c_rd_adv_en_level;
    end
end

// Compute rd_empty
always @(posedge rd_clk or negedge rd_rst_n)
begin
    if (rd_rst_n == 1'b0)
        rd_empty <= 1'b1;
    else
        rd_empty <= (c_rd_en_level == {(ADDR_WIDTH+1){1'b0}});
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
    if (rd_en & rd_empty)
    begin
        $display ("%m : ** ERROR ** : Underflow : rd_en asserted when rd_empty was asserted at time %t", $time);
    end    
end

// Check for invalid parameters
initial
begin
    if (ADDR_WIDTH <= INC_WIDTH)
    begin
        $display ("%m : ** PARAMETER ERROR ** : ADDR_WIDTH must be > INC_WIDTH");
    end    
end

`endif

endmodule
