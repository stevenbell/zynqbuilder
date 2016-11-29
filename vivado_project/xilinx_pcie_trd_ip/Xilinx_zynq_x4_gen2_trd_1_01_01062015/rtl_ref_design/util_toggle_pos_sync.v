// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2014 by Northwest Logic, Inc.
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
//  FUNCTIONAL DESCRIPTION:
//
//  This circuit implements a synchronizer circuit for synchronizing events
//  on signal d in the d_clk domain to output signal q in the q_clk clock
//  domain.  The syncronizer circuit sets q high for one q_clk for every
//  d_clk that d is high.
//
//  PARAMETERS:
//
//  SINGLE_CLK - Set to bypass the synchronizer circuit; this is included 
//    to save logic resources and latency if the synchronizer is not needed
//  REG_Q - Set to register the synchronizer output or clear to
//    produce a combinatorial output including a single 2-input XOR.
//    REG_Q can be cleared to save one clock of latency.
//
//  LIMITATIONS:
//
//    The period of the path between the synchronizing register and
//    its destination must be a few ns faster (see comments in code
//    below) than the period of the synchroizing clock to enable
//  metastable events the necessary time to settle.
//
//    The minimum period of an input signal that can be safely
//  synchronized is equal to the period of the synchronizing q_clk
//  + 2 * (the sum of the worst case setup and hold times for the device).
//  This allows for a transition that generates a metastable event that
//  stabilizes in the wrong state to be meet valid setup and hold times
//  for the next rising clock edge, and thus be registered by the circuit
//  correctly.  A good rule of thumb is that the period of d signal
//  assertions should be approximately 2 or more times greater than
//  the q_clk period.
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module util_toggle_pos_sync (
    d_clk_rst_n,
    d_clk,
    d,

    q_clk_rst_n,
    q_clk,
    q
);



// ----------------
// -- Parameters --
// ----------------

parameter REG_Q      = 1'b1;    // Set to register Q output, clear to leave combinatorial
parameter SINGLE_CLK = 1'b0;    // Set to bypass the synchronizer; clear for normal operation



// ----------------------
// -- Port Definitions --
// ----------------------

input                               d_clk_rst_n;
input                               d_clk;
input                               d;

input                               q_clk_rst_n;
input                               q_clk;
output                              q;


// ----------------
// -- Port Types --
// ----------------

wire                                d_clk_rst_n;
wire                                d_clk;
wire                                d;

wire                                q_clk_rst_n;
wire                                q_clk;
wire                                q;



// -------------------
// -- Local Signals --
// -------------------

reg                                half;
wire                               int_q_clk;
wire                               int_q_clk_rst_n;
wire                               int_q_sync_rst_n;
wire                               s2;
reg                                s3;
wire                               c_q;
// bluepearl disable 534
reg                                r_q;
// bluepearl enable 534

reg                                logic_d_clk_rst_n;
reg                                logic_q_clk_rst_n;
wire                               d_sync_rst_n;
wire                               q_sync_rst_n;

// ---------------
// -- Equations --
// ---------------

// ------
// Resets - needs to cross polinate to avoid accidental output pulse after reset under certain conditions

// Avoid using rd_rst_n/wr_rst_n as logic inputs since they should only be used as resets
always @(posedge d_clk or negedge d_clk_rst_n) if (d_clk_rst_n == 1'b0) logic_d_clk_rst_n <= 1'b0; else logic_d_clk_rst_n <= 1'b1;
always @(posedge q_clk or negedge q_clk_rst_n) if (q_clk_rst_n == 1'b0) logic_q_clk_rst_n <= 1'b0; else logic_q_clk_rst_n <= 1'b1;
// Need to synchronize the opposite clock domain reset into the local clock domain
//   and use to synchronously reset the logic when the opposite side is in reset
util_sync_flops util_sync_flops0 (.clk (d_clk), .rst_n (d_clk_rst_n), .d (logic_q_clk_rst_n), .q (d_sync_rst_n));
util_sync_flops util_sync_flops1 (.clk (q_clk), .rst_n (q_clk_rst_n), .d (logic_d_clk_rst_n), .q (q_sync_rst_n));

// --------------
//  d_clk domain

// Toggle register half on each assertion of the input signal;
//   this has the advantage of halving the number of edges that must
//   be synchronized, smooths the duty cycle of the synchronized
//   signal, and allows for synchronizing d events with closer
//   periods to the q_clk period
always @(posedge d_clk or negedge d_clk_rst_n)
begin
    if (d_clk_rst_n == 1'b0)
        half <= 1'b0;
    else if (d_sync_rst_n == 1'b0)
        half <= 1'b0;
    else
    begin
        if (d)
            half <= ~half;
    end
end



// --------------
//  q_clk domain

assign int_q_clk         = (SINGLE_CLK != 0) ? d_clk        : q_clk;
assign int_q_clk_rst_n   = (SINGLE_CLK != 0) ? d_clk_rst_n  : q_clk_rst_n;
assign int_q_sync_rst_n  = (SINGLE_CLK != 0) ? d_sync_rst_n : q_sync_rst_n;

// This register's setup time is violated.  The path between this register
//     and the next register must run at a few ns (the exact number depends
//   upon the specs of the device being used) greater than the desired system
//     clock frequency to allow metastability events to settle before being
//     propogated to the next register; see your device vendor for the metastability
//   settling time for your device
util_sync_flops util_sync_flops (.clk (int_q_clk), .rst_n (int_q_clk_rst_n), .d (half), .q (s2)); 

// This register is a pipeline register used to aid in edge detection
always @(posedge int_q_clk or negedge int_q_clk_rst_n)
begin
    if (int_q_clk_rst_n == 1'b0)
        s3 <= 1'b0;
    else if (int_q_sync_rst_n == 1'b0)
        s3 <= 1'b0;
    else
        s3 <= s2;
end

// Output of synchronizer is high for 1 clock whenever the two final,
//     consectutive registers in the pipeline have a different value.
//   If SINGLE_CLK is set, skip synchronizer
assign c_q = (SINGLE_CLK != 0) ? d : (s2 ^ s3);

always @(posedge int_q_clk or negedge int_q_clk_rst_n)
begin
    if (int_q_clk_rst_n == 1'b0)
        r_q <= 1'b0;
    else if (int_q_sync_rst_n == 1'b0)
        r_q <= 1'b0;
    else
        r_q <= c_q;
end

// Implement optional registered output
assign q = (REG_Q != 0) ? r_q : c_q;


endmodule
