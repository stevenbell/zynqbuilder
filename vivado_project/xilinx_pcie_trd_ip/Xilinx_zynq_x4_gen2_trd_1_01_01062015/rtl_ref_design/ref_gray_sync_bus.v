// --------------------------------------------------------------------------
//
//  PROJECT:             PCI Core
//  COMPANY:             Northwest Logic, Inc.
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

// -------------------------------------------------------------------------
//
//  FUNCTIONAL DESCRIPTION
//
//  Synchronizes an entire bus using Gray Codes
//    Latency is 1 d_clk and 3-4 q_clks depending upon whether
//    the current or last state of d was caught by the synchronizing
//    operation
//
//  For proper operation, the input bus, d, must only increment,
//    decrement, or stay the same on any given clock cycle.  This is
//    because Gray coding ensures that exactly one bit will change in
//    any increment or decrement, but makes no guarantee about other
//    add or subtract conditions.
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module ref_gray_sync_bus (
    d_rst_n,
    d_clk,
    d_clr,
    d,

    q_rst_n,
    q_clk,
    q_clr,
    q
);



// ----------------
// -- Parameters --
// ----------------

parameter   WIDTH           = 7; // Valid range: 1 to 16
parameter   REGISTER_OUTPUT = 1; // Set for registered output, clear for combinatorial output



// -----------------------
// -- Port Declarations --
// -----------------------

input                       d_rst_n;
input                       d_clk;
input                       d_clr;
input   [WIDTH-1:0]         d;

input                       q_rst_n;
input                       q_clk;
input                       q_clr;
output  [WIDTH-1:0]         q;



// ----------------
// -- Port Types --
// ----------------

wire                        d_rst_n;
wire                        d_clk;
wire                        d_clr;
wire    [WIDTH-1:0]         d;

wire                        q_rst_n;
wire                        q_clk;
wire                        q_clr;
wire    [WIDTH-1:0]         q;



// ---------------------
// -- Local Variables --
// ---------------------

wire    [WIDTH-1:0]         d_c_gray;
reg     [WIDTH-1:0]         d_r_gray;
reg     [WIDTH-1:0]         q_s1_gray;
reg     [WIDTH-1:0]         q_s2_gray;
wire    [WIDTH-1:0]         q_ungray;
reg     [WIDTH-1:0]         r_q_ungray;        



// ---------------
// -- Equations --
// ---------------

// Convert d to gray code
ref_bin_to_gray #(WIDTH) bin_to_gray_component (
    .d      (d          ),
    .q      (d_c_gray   )
);

// Register gray coded version of d in d_clk domain
always @(posedge d_clk or negedge d_rst_n)
begin
    if (d_rst_n == 1'b0)
        d_r_gray <= {WIDTH{1'b0}};
    else
        d_r_gray <= d_clr ? {WIDTH{1'b0}} : d_c_gray;
end

// Transfer gray coded d into q_clk domain
//   Double register to reduce metastable propogation
always @(posedge q_clk or negedge q_rst_n)
begin
    if (q_rst_n == 1'b0)
    begin
        q_s1_gray <= {WIDTH{1'b0}};
        q_s2_gray <= {WIDTH{1'b0}};
    end
    else
    begin
        q_s1_gray <= q_clr ? {WIDTH{1'b0}} : d_r_gray;
        q_s2_gray <= q_clr ? {WIDTH{1'b0}} : q_s1_gray;
    end
end

// Un-Gray code to generate q
ref_gray_to_bin #(WIDTH) gray_to_bin_component (
    .d      (q_s2_gray  ),
    .q      (q_ungray   )
);

always @(posedge q_clk or negedge q_rst_n)
begin
    if (q_rst_n == 1'b0)
        r_q_ungray <= {WIDTH{1'b0}};
    else
        r_q_ungray <= q_clr ? {WIDTH{1'b0}} : q_ungray;
end

assign q = REGISTER_OUTPUT ? r_q_ungray : q_ungray;



endmodule
