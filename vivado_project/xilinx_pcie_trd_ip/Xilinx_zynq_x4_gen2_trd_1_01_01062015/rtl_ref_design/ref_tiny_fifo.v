// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
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
// This module implements a small two word FIFO to break the enable path
//   between the input and output ports.  This module improves the ability
//   of a design to meet timing at the expense of using additional registers
//   and adding 1 clock of latency.
//
// out_data is a combinatorial 2:1 mux for better timing; if out_data was
//   registered then out_en = out_src_rdy & out_dst_rdy would have to fanout
//   to each out_data bit; this tradeoff was made because generally the
//   enable terms are more heavily loaded and have higher fanout than
//   the data bits, and thus, from a meeting timing perspective, the data
//   bits are generally more tolerant to the extra mux than the enable terms
//   are be to the additional fanout
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module ref_tiny_fifo (

    rst_n,
    clk,

    in_src_rdy,
    in_dst_rdy,
    in_data,

    out_src_rdy,
    out_dst_rdy,
    out_data

);



// ----------------
// -- Parameters --
// ----------------

// FIFO Data Width
parameter   DATA_WIDTH      = 32;



// ----------------------
// -- Port Definitions --
// ----------------------

input                       rst_n;
input                       clk;

input                       in_src_rdy;
output                      in_dst_rdy;
input   [DATA_WIDTH-1:0]    in_data;

output                      out_src_rdy;
input                       out_dst_rdy;
output  [DATA_WIDTH-1:0]    out_data;



// ----------------
// -- Port Types --
// ----------------

wire                        rst_n;
wire                        clk;

wire                        in_src_rdy;
reg                         in_dst_rdy;
wire    [DATA_WIDTH-1:0]    in_data;

reg                         out_src_rdy;
wire                        out_dst_rdy;
wire    [DATA_WIDTH-1:0]    out_data;



// -------------------
// -- Local Signals --
// -------------------

// Use Shallow FIFO to Buffer Packets
reg     [DATA_WIDTH-1:0]    da_dat;
reg     [DATA_WIDTH-1:0]    db_dat;

// FIFO Writes
wire                        in_en;
reg                         in_addr;

// FIFO Reads
wire                        out_en;
reg                         out_addr;

// FIFO Level
reg     [1:0]               level;
reg                         int_in_dst_rdy;
reg                         int_out_src_rdy;



// ---------------
// -- Equations --
// ---------------

// ----------------------------------
// Use Shallow FIFO to Buffer Packets

  `ifdef SIMULATION
initial
begin
    da_dat = $random;
    db_dat = $random;
end
  `endif

always @(posedge clk)
begin
        // Timing optimization: Use in_dst_rdy ready only; it is not
        //    necessary to include in_src_rdy since if in_dst_rdy is
        //    asserted the location is empty so there is no harm in
        //    filling it with unused data; leaving out in_src_rdy
        //    reduces the enable term and fanout on in_src_rdy
        //    which improves the ability to meet timing
        if (int_in_dst_rdy & (in_addr == 1'b0))
            da_dat <= in_data;

        if (int_in_dst_rdy & (in_addr == 1'b1))
            db_dat <= in_data;
end



// -----------
// FIFO Writes

assign in_en = in_src_rdy & int_in_dst_rdy;

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        in_addr <= 1'b0;
    else if (in_en)
        in_addr <= ~in_addr;
end



// ----------
// FIFO Reads

assign out_en = int_out_src_rdy & out_dst_rdy;

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
        out_addr <= 1'b0;
    else if (out_en)
        out_addr <= ~out_addr;
end

// Note reads are left with a combinatorial output mux to
//   reduce the fanout on the incoming out_en signal; with a
//   combinatorial output, out_en does not need to enable data
assign out_data = out_addr ? db_dat : da_dat;



// ----------
// FIFO Level

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        level           <= 2'b00;

        in_dst_rdy      <= 1'b0;
        int_in_dst_rdy  <= 1'b0;

        out_src_rdy     <= 1'b0;
        int_out_src_rdy <= 1'b0;
    end
    else
    begin
        case ({in_en, out_en})
            2'b01   : level <= level - 2'b01; // -1
            2'b10   : level <= level + 2'b01; // +1
            default : level <= level;         // No change
        endcase

        // Duplicates: in_dst_rdy used outside this module; int_in_dst_rdy used inside this module
        case ({in_en, out_en})
            2'b01   : begin in_dst_rdy <= 1'b1;              int_in_dst_rdy <= 1'b1;              end // -1
            2'b10   : begin in_dst_rdy <= (level == 2'b00);  int_in_dst_rdy <= (level == 2'b00);  end // +1
            default : begin in_dst_rdy <= (level <= 2'b01);  int_in_dst_rdy <= (level <= 2'b01);  end // No change
        endcase

        // Duplicates: out_src_rdy used outside this module; int_out_src_rdy used inside this module
        case ({in_en, out_en})
            2'b01   : begin out_src_rdy <= (level >  2'b01); int_out_src_rdy <= (level >  2'b01); end // -1
            2'b10   : begin out_src_rdy <= 1'b1;             int_out_src_rdy <= 1'b1;             end // +1
            default : begin out_src_rdy <= (level != 2'b00); int_out_src_rdy <= (level != 2'b00); end // No change
        endcase
    end
end



endmodule
