// --------------------------------------------------------------------------
//
//  PROJECT:             PCI Core
//  COMPANY:             Northwest Logic, Inc.
//
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
//  Synchronizes an entire bus by passing a bus update token between 
//    clock domains to identify when the bus can be safely sampled
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module util_sync_bus (

    i_rst_n,
    i_clk,
    i_data,

    o_rst_n,
    o_clk,
    o_data

);



// ----------------
// -- Parameters --
// ----------------

parameter   WIDTH            = 8;
parameter   SYNC_RESET_VALUE = {WIDTH{1'b0}};



// -----------------------
// -- Port Declarations --
// -----------------------

input                       i_rst_n;
input                       i_clk;
input   [WIDTH-1:0]         i_data;

input                       o_rst_n;
input                       o_clk;
output  [WIDTH-1:0]         o_data;



// ----------------
// -- Port Types --
// ----------------

wire                        i_rst_n;
wire                        i_clk;
wire    [WIDTH-1:0]         i_data;

wire                        o_rst_n;
wire                        o_clk;
reg     [WIDTH-1:0]         o_data;



// ---------------------
// -- Local Variables --
// ---------------------

reg     [3:0]               i_rst_ctr;
reg                         i_ready;

reg     [3:0]               o_rst_ctr;
reg                         o_ready;

wire                        sync2_o_ready;

reg                         en_bus_sync;
reg                         r_en_bus_sync;
reg     [WIDTH-1:0]         hold_i_data;
reg     [7:0]               i_pulse_ctr;
reg                         i_pulse_timeout;

wire                        i_pulse;
wire                        o_pulse;
wire                        i_pulse_return;


// ---------------
// -- Equations --
// ---------------

// Wait 16 clocks after reset deassertion to begin
always @(posedge i_clk or negedge i_rst_n)
begin
    if (i_rst_n == 1'b0)
    begin
        i_rst_ctr <= 4'h0;
        i_ready   <= 1'b0;
    end
    else
    begin
        if (i_rst_ctr != 4'hf)
            i_rst_ctr <= i_rst_ctr + 4'h1;

        i_ready <= (i_rst_ctr == 4'hf);
    end
end

// Wait 16 clocks after reset deassertion to begin
always @(posedge o_clk or negedge o_rst_n)
begin
    if (o_rst_n == 1'b0)
    begin
        o_rst_ctr <= 4'h0;
        o_ready   <= 1'b0;
    end
    else
    begin
        if (o_rst_ctr != 4'hf)
            o_rst_ctr <= o_rst_ctr + 4'h1;

        o_ready <= (o_rst_ctr == 4'hf);
    end
end

util_sync_flops util_sync_flops0 (.clk (i_clk), .rst_n (i_rst_n), .d (o_ready), .q (sync2_o_ready));

// Wait until both clock domains are ready before beginning bus synchronization
always @(posedge i_clk or negedge i_rst_n)
begin
    if (i_rst_n == 1'b0)
    begin
        en_bus_sync     <= 1'b0;
        r_en_bus_sync   <= 1'b0;

        hold_i_data     <= SYNC_RESET_VALUE; //{WIDTH{1'b0}};

        i_pulse_ctr     <= 8'h0;
        i_pulse_timeout <= 1'b0;
    end
    else
    begin
        en_bus_sync   <= i_ready & sync2_o_ready;
        r_en_bus_sync <= en_bus_sync;

        // Hold i_data so it can be synchronized safely when 
        //   o_clk domain receives i_pulse
        if (i_pulse)
            hold_i_data <= i_data;

        // Implement 256 clock timeout to restart synchronization pulse if it should get lost for some reason
        if (i_pulse | (~en_bus_sync))
            i_pulse_ctr <= 8'h0;
        else                         
            i_pulse_ctr <= i_pulse_ctr + 8'h1;

        i_pulse_timeout <= (i_pulse_ctr == 8'hff);
    end
end

// Initiate pulse on en_bus_sync rising edge or timeout or return of i_pulse from o_clk domain
assign i_pulse = (en_bus_sync & ~r_en_bus_sync) | i_pulse_timeout | i_pulse_return;

// Bounce synchronization pulse between clock domains
util_toggle_pos_sync #(

    .REG_Q          (0                  ),
    .SINGLE_CLK     (0                  )

) util_toggle_pos_sync_i_to_o (

    .d_clk_rst_n    (i_rst_n            ),
    .d_clk          (i_clk              ),
    .d              (i_pulse            ),

    .q_clk_rst_n    (o_rst_n            ),
    .q_clk          (o_clk              ),
    .q              (o_pulse            )

);

util_toggle_pos_sync #(

    .REG_Q          (0                  ),
    .SINGLE_CLK     (0                  )

) util_toggle_pos_sync_o_to_i (

    .d_clk_rst_n    (o_rst_n            ),
    .d_clk          (o_clk              ),
    .d              (o_pulse            ),

    .q_clk_rst_n    (i_rst_n            ),
    .q_clk          (i_clk              ),
    .q              (i_pulse_return     )

);

// Store i_data in o_clk domain when o_pulse == 1 indicating i_data is being held constant
always @(posedge o_clk or negedge o_rst_n)
begin
    if (o_rst_n == 1'b0)
        o_data <= SYNC_RESET_VALUE; //{WIDTH{1'b0}};
    else if (o_pulse)
        o_data <= hold_i_data;
end    



endmodule
