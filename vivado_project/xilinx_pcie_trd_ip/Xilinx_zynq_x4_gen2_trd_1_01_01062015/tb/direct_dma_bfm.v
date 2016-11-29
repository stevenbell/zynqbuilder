// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express
//  COMPANY: Northwest Logic, Inc.
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

`timescale 1ps / 1ps

// -----------------------
// -- Module Definition --
// -----------------------

module direct_dma_bfm (
    clk,
    rst_n
);



// -------------
// -- Defines --
// -------------

`define BFM_PATH                    tb_top.pcie_bfm
`define DUT_PATH                    tb_top.dut
`define INC_ERRORS                  `BFM_PATH.inc_errors
`define DMA_BYTES                   `BFM_PATH.DMA_BYTES
`define DMA_REMAIN                  `BFM_PATH.DMA_REMAIN



// ----------------
// -- Parameters --
// ----------------

parameter ENGINE       = 0;         // Engine 0 == S2C0, Engine 1 == C2S0


// ----------------------
// -- Port Definitions --
// ----------------------

input                               clk;
input                               rst_n;



// ----------------
// -- Port Types --
// ----------------

wire                                clk;
wire                                rst_n;



// -------------------
// -- Local Signals --
// -------------------

reg                                 desc_req;
wire                                desc_ready;
reg     [31:0]                      desc_ptr;
reg     [255:0]                     desc_data;
reg                                 desc_abort;
wire                                desc_abort_ack;
wire                                desc_done;
wire    [7:0]                       desc_done_channel;
wire    [159:0]                     desc_done_status;
reg                                 desc_rst_n;

integer                             xfer_keys = 1;
reg     [31:0]                      next_prior = 32'b0;
reg     [31:0]                      curr_prior = 32'b0;



// ---------------
// -- Equations --
// ---------------

generate
    if (ENGINE == 0)
    begin : s2c_gen
        assign `DUT_PATH.s2c0_desc_req   = desc_req;
        assign `DUT_PATH.s2c0_desc_ptr   = desc_ptr;
        assign `DUT_PATH.s2c0_desc_data  = desc_data;
        assign `DUT_PATH.s2c0_desc_abort = desc_abort;
        assign `DUT_PATH.s2c0_desc_rst_n = desc_rst_n;
        assign desc_ready                = `DUT_PATH.s2c0_desc_ready;
        assign desc_abort_ack            = `DUT_PATH.s2c0_desc_abort_ack;
        assign desc_done                 = `DUT_PATH.s2c0_desc_done;
        assign desc_done_channel         = `DUT_PATH.s2c0_desc_done_channel;
        assign desc_done_status          = `DUT_PATH.s2c0_desc_done_status;
    end
    else if (ENGINE == 1)
    begin : c2s_gen
        assign `DUT_PATH.c2s0_desc_req   = desc_req;
        assign `DUT_PATH.c2s0_desc_ptr   = desc_ptr;
        assign `DUT_PATH.c2s0_desc_data  = desc_data;
        assign `DUT_PATH.c2s0_desc_abort = desc_abort;
        assign `DUT_PATH.c2s0_desc_rst_n = desc_rst_n;
        assign desc_ready                = `DUT_PATH.c2s0_desc_ready;
        assign desc_abort_ack            = `DUT_PATH.c2s0_desc_abort_ack;
        assign desc_done                 = `DUT_PATH.c2s0_desc_done;
        assign desc_done_channel         = `DUT_PATH.c2s0_desc_done_channel;
        assign desc_done_status          = `DUT_PATH.c2s0_desc_done_status;
    end
endgenerate

// Initialize to idle state
initial
begin
    desc_req   = 1'b0;
    desc_ptr   = 32'b0;
    desc_data  = 256'b0;
    desc_abort = 1'b0;
    desc_rst_n = 1'b1;
end


// Semaphore task used to ensure that only 1 xfer task call can
//   use the core transmit interface at one time; get_xfer_key may
//   only be called by task xfer
task automatic get_xfer_key;
begin
    wait (xfer_keys > 0)
        xfer_keys = xfer_keys - 1;
end
endtask

// Semaphore task used to ensure that only 1 xfer task call can
//   use the core transmit interface at one time; put_xfer_key may
//   only be called by task xfer
task automatic put_xfer_key;
begin
    xfer_keys = xfer_keys + 1;
end
endtask

task automatic xfer;
    input           first_chain;
    input           last_chain;
    input   [63:0]  sys_addr;
    input   [63:0]  card_addr;
    input   [31:0]  bcount;

    reg     [31:0]  my_prior;

    begin
        get_xfer_key;
        my_prior = next_prior;
        next_prior = next_prior + 1;
        #1;
        put_xfer_key;
        while (my_prior != curr_prior)
            @(posedge clk);
        xfer_action (first_chain,last_chain,sys_addr,card_addr,bcount);
    end
endtask

task automatic xfer_action;
    input           first_chain;
    input           last_chain;
    input   [63:0]  sys_addr;
    input   [63:0]  card_addr;
    input   [31:0]  bcount;

    begin
        // wait for ready to be asserted (last operation complete)
        while (desc_ready == 1'b1) begin
            @(posedge clk);
            #1;
        end

        // Issue request
        desc_ptr  = 32'b0;
        if (ENGINE == 0) begin
                desc_data = { 64'b0, card_addr, sys_addr, bcount, 20'b0, last_chain, first_chain, 9'b0, last_chain};    // Block Mode Descriptor
        end
        else begin
                desc_data = { 64'b0, card_addr, sys_addr, bcount, 20'b0, last_chain, first_chain, 9'b0, last_chain};    // Block Mode Descriptor
        end
        desc_req  = 1'b1;
        // wait for command to be accepted
        while (desc_ready == 1'b0) begin
            @(posedge clk);
            #1;
        end
        // stop request
        @(posedge clk);
        #1;
        desc_req = 1'b0;

        // Advance to next operation
        curr_prior = curr_prior + 1;

    end
endtask

task automatic reset;
    begin
        @(posedge clk);
        #1;
        desc_rst_n <= 1'b0;
        repeat (10) @(posedge clk);
        #1;
        desc_rst_n <= 1'b1;
        @(posedge clk);
        #1;
    end
endtask

task automatic abort;
    begin
        @(posedge clk);
        #1;
        desc_abort <= 1'b1;
        @(posedge clk);
        #1;
        while (desc_abort_ack == 1'b0) begin
            @(posedge clk);
            #1;
        end
        desc_abort <= 1'b0;
        @(posedge clk);
        #1;
    end
endtask

task do_multi_dma;
    input   [63:0]  sys_addr;
    input   [63:0]  card_addr;
    input   [31:0]  bcount;
    input           done_wait;
    output  [159:0] status;

    reg     [63:0]  curr_sys_addr;
    reg     [63:0]  curr_card_addr;
    reg     [31:0]  curr_bcount;
    reg     [31:0]  max_bcount;
    reg     [31:0]  xfer_bcount;
    reg     [31:0]  num_desc;
    reg     [31:0]  num_done;
    reg     [31:0]  done_bcount;
    reg     [159:0] curr_status;

    reg             first;
    reg             last;

    if (bcount == 32'b0) begin
        $display ("%m : ERROR : Called wih invalid byte count (time %t)", $time);
        `INC_ERRORS;
    end
    else begin
        $display ("%m : INFO : Starting direct DMA (time %t)", $time);
        curr_bcount    = bcount;
        curr_sys_addr  = sys_addr;
        curr_card_addr = card_addr;
        num_desc       = 32'h0;
        num_done       = 32'h0;
        done_bcount    = 32'h0;

        fork
            // Break large DMAs at DMA_BYTES boundaries
            while (curr_bcount != 32'b0) begin
                max_bcount = `DMA_BYTES -  curr_sys_addr % (1<<`DMA_REMAIN);
                xfer_bcount = (curr_bcount > max_bcount) ? max_bcount : curr_bcount;
                if (num_desc == 32'h0)
                    first = 1;
                else
                    first = 0;

                if (xfer_bcount == curr_bcount)
                    last = 1;
                else
                    last = 0;

                xfer (first, last, curr_sys_addr, curr_card_addr, xfer_bcount);

                curr_sys_addr  = curr_sys_addr  + xfer_bcount;
                curr_card_addr = curr_card_addr + xfer_bcount;
                curr_bcount    = curr_bcount    - xfer_bcount;
                num_desc       = num_desc       + 32'h1;
            end

            // Record results as descriptors are completed
            if (done_wait) begin
                while (num_done < num_desc || last == 1'b0) begin
                    while (desc_done == 1'b0) begin                     // Wait for done
                        @(posedge clk);
                        #1;
                    end
                    done_bcount = done_bcount + desc_done_status[63:32];
                    curr_status = desc_done_status;
                    num_done = num_done + 1;
                    while (desc_done == 1'b1) begin                     // Wait for done to deassert
                        @(posedge clk);
                        #1;
                    end
                    @(posedge clk);
                    #1;
                end
            end
        join

        if (done_wait)
            status = {curr_status[159:64], done_bcount, curr_status[31:0]};
        else
            status = 160'b0;
    end
endtask



endmodule

