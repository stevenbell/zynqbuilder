// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2010 by Northwest Logic, Inc.
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
//  Single clock domain FIFO using RAM with a read latency of 1 clock
//
//  Notes on FMax:
//    There are optional FIFO features:
//      flush (to disable, tie to 0)
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

module ref_sc_fifo_shallow_ram (

    rst_n,
    clk, 

    flush,    

    wr_en,
    wr_data,
    wr_level,
    wr_full,

    rd_ack,
    rd_data,
    rd_level,
    rd_empty

);  



// ----------------
// -- Parameters --
// ----------------

parameter   ADDR_WIDTH          = 4;            // Set to desired number of RAM address bits
parameter   DATA_WIDTH          = 72;           // Set to desired total RAM data width
parameter   EN_LOOK_AHEAD       = 0;            // Set to compute look ahead read address to reduce FIFO latency from 1 to 0; NOTE! Setting affects FMax performance

parameter   WR_FULL_THRESH      = 1 << ADDR_WIDTH;



// -----------------------
// -- Port Declarations --
// -----------------------

input                           rst_n;          // Active low asynchronous reset
input                           clk;            // Positive edge-triggered clock

input                           flush;          // Set to flush the FIFO of all data

input                           wr_en;          // FIFO write enable
input   [DATA_WIDTH-1:0]        wr_data;        // FIFO write data
output  [ADDR_WIDTH:0]          wr_level;       // FIFO write level
output                          wr_full;        // FIFO write full flag

input                           rd_ack;         // FIFO read acknowledge 
output  [DATA_WIDTH-1:0]        rd_data;        // FIFO read data
output  [ADDR_WIDTH:0]          rd_level;       // FIFO read level
output                          rd_empty;       // FIFO read empty flag
                                                    


// ----------------
// -- Port Types --
// ----------------

wire                            rst_n;
wire                            clk;

wire                            flush;

wire                            wr_en;
wire    [DATA_WIDTH-1:0]        wr_data;
reg     [ADDR_WIDTH:0]          wr_level;       
reg                             wr_full;

wire                            rd_ack;
wire    [DATA_WIDTH-1:0]        rd_data;
reg     [ADDR_WIDTH:0]          rd_level;       
reg                             rd_empty;



// ---------------------
// -- Local Variables --
// ---------------------

// RAM address
wire    [ADDR_WIDTH-1:0]        ram_rd_addr;

reg     [ADDR_WIDTH-1:0]        wr_addr;

wire    [ADDR_WIDTH-1:0]        c_rd_addr;
reg     [ADDR_WIDTH-1:0]        rd_addr;

reg                             r_wr_en;

wire    [ADDR_WIDTH:0]          const_wr_full_thresh;
wire    [ADDR_WIDTH:0]          const_wr_full_thresh_minus1;



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

    .wr_clk             (clk                ),
    .wr_addr            (wr_addr            ),
    .wr_en              (wr_en              ),
    .wr_data            (wr_data            ),

    .rd_clk             (clk                ),
    .rd_addr            (ram_rd_addr        ),
    .rd_data            (rd_data            )

);

assign ram_rd_addr = EN_LOOK_AHEAD ? c_rd_addr : rd_addr;



// --------------------
//  Write side of FIFO

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        wr_addr <= {ADDR_WIDTH{1'b0}};
    else
    begin
        if (flush)
            wr_addr <= {ADDR_WIDTH{1'b0}};
        else
// bluepearl disable 30 // Mismatching bit ranges for assignment to 'Y' ('X' bits) with right hand side expression ('X+1' bits)
            wr_addr <= wr_addr + {{(ADDR_WIDTH-1){1'b0}}, wr_en};
// bluepearl enable 30
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        wr_level <= {(ADDR_WIDTH+1){1'b0}};
    else
    begin
        if (flush)
            wr_level <= {(ADDR_WIDTH+1){1'b0}};
        else
        begin
            case ({wr_en, rd_ack})
                2'b01   : wr_level <= wr_level - {{ADDR_WIDTH{1'b0}}, 1'b1};
                2'b10   : wr_level <= wr_level + {{ADDR_WIDTH{1'b0}}, 1'b1};
                default : wr_level <= wr_level;
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        wr_full <= 1'b0;
    else
    begin
        if (flush)
            wr_full <= 1'b0;
        else
        begin
            case ({wr_en, rd_ack})
                2'b01   : wr_full <= 1'b0;
                2'b10   : wr_full <= (wr_level == const_wr_full_thresh_minus1);
                default : wr_full <= (wr_level == const_wr_full_thresh);
            endcase
        end
    end
end

// bluepearl disable 442 // ('X' ('N'-bits) is assigned a constant value 'M' but, although the bit widths mismatch, there is no loss of data)
assign const_wr_full_thresh        = WR_FULL_THRESH;
assign const_wr_full_thresh_minus1 = WR_FULL_THRESH - 1;
// bluepearl enable 442



// -------------------
//  Read side of FIFO

assign c_rd_addr = flush ? {ADDR_WIDTH{1'b0}} : (rd_addr + {{(ADDR_WIDTH-1){1'b0}}, rd_ack});

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        rd_addr <= {ADDR_WIDTH{1'b0}};
    else
        rd_addr <= c_rd_addr;
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        r_wr_en  <= 1'b0;
        rd_level <= {(ADDR_WIDTH+1){1'b0}};
    end
    else
    begin
        // Delay wr_en until data can be read from latency 1 FIFO
        if (flush)
            r_wr_en <= 1'b0;
        else
            r_wr_en <= wr_en;

        if (flush)
            rd_level <= {(ADDR_WIDTH+1){1'b0}};
        else
        begin
            case ({r_wr_en, rd_ack})
                2'b01   : rd_level <= rd_level - {{ADDR_WIDTH{1'b0}}, 1'b1};
                2'b10   : rd_level <= rd_level + {{ADDR_WIDTH{1'b0}}, 1'b1};
                default : rd_level <= rd_level;
            endcase
        end
    end
end

// Compute rd_empty
always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        rd_empty <= 1'b1;
    else
    begin
        if (flush)
            rd_empty <= 1'b1;
        else
        begin
            case ({r_wr_en, rd_ack})
                2'b01   : rd_empty <= (rd_level == {{ADDR_WIDTH{1'b0}}, 1'b1});
                2'b10   : rd_empty <= 1'b0;
                default : rd_empty <= (rd_level == {(ADDR_WIDTH+1){1'b0}});
            endcase
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
always @(posedge clk)
begin
    if (wr_en & wr_full)
    begin
        $display ("%m : ** ERROR ** : Overflow : wr_en asserted when wr_full was asserted at time %t", $time);
    end    
end

// Check for FIFO underflow 
always @(posedge clk)
begin
    if (rd_ack & rd_empty)
    begin
        $display ("%m : ** ERROR ** : Underflow : rd_ack asserted when rd_empty was asserted at time %t", $time);
    end    
end



`endif
endmodule
