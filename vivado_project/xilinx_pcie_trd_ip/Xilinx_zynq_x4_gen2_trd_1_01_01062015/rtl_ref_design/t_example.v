// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
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

`timescale 1ps / 1ps



// -----------------------
// -- Module Definition --
// -----------------------

module t_example (

    rst_n,
    clk,

    // Target Write Interface
    awvalid,
    awready,
    awregion,
    awaddr,
    awlen,
    awsize,

    wvalid,
    wready,
    wdata,
    wstrb,
    wlast,

    bvalid,
    bready,
    bresp,

    arvalid,
    arready,
    arregion,
    araddr,
    arlen,
    arsize,

    rvalid,
    rready,
    rdata,
    rresp,
    rlast,

    reg_wr_addr,
    reg_wr_en,
    reg_wr_be,
    reg_wr_data,
    reg_rd_addr,
    reg_rd_data,

    sram_wr_addr,
    sram_wr_en,
    sram_wr_be,
    sram_wr_data,
    sram_rd_addr,
    sram_rd_data

);



// ----------------
// -- Parameters --
// ----------------

parameter   AXI_ADDR_WIDTH          = 32;   // AXI Address Width; Minimum value is the greater of (SRAM_ADDR_WIDTH, REG_ADDR_WIDTH)
parameter   AXI_LEN_WIDTH           = 8;    // AXI Len Width

parameter   AXI_DATA_WIDTH          = 64;

parameter   REG_ADDR_WIDTH          = 13;   // 64 KB expected for NWL Reference Design
parameter   SRAM_ADDR_WIDTH         = 10;   //  8 KB expected for NWL Reference Design

localparam  AXI_REMAIN_WIDTH        =  (AXI_DATA_WIDTH <=  32) ? 2 :
                                      ((AXI_DATA_WIDTH <=  64) ? 3 :
                                      ((AXI_DATA_WIDTH <= 128) ? 4 : 5));

localparam  AXI_BE_WIDTH            = AXI_DATA_WIDTH / 8;

localparam  FIFO_ADDR_WIDTH         = 3;    // Depth of read data FIFO; min value == 3



// ----------------------
// -- Port Definitions --
// ----------------------

input                               rst_n;
input                               clk;

input                               awvalid;
output                              awready;
input   [2:0]                       awregion;
input   [AXI_ADDR_WIDTH-1:0]        awaddr;
input   [AXI_LEN_WIDTH-1:0]         awlen;
input   [2:0]                       awsize;

input                               wvalid;
output                              wready;
input   [AXI_DATA_WIDTH-1:0]        wdata;
input   [AXI_BE_WIDTH-1:0]          wstrb;
input                               wlast;

output                              bvalid;
input                               bready;
output  [1:0]                       bresp;

input                               arvalid;
output                              arready;
input   [2:0]                       arregion;
input   [AXI_ADDR_WIDTH-1:0]        araddr;
input   [AXI_LEN_WIDTH-1:0]         arlen;
input   [2:0]                       arsize;

output                              rvalid;
input                               rready;
output  [AXI_DATA_WIDTH-1:0]        rdata;
output  [1:0]                       rresp;
output                              rlast;

output  [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
output                              reg_wr_en;
output  [AXI_BE_WIDTH-1:0]          reg_wr_be;
output  [AXI_DATA_WIDTH-1:0]        reg_wr_data;
output  [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
input   [AXI_DATA_WIDTH-1:0]        reg_rd_data;

output  [SRAM_ADDR_WIDTH-1:0]       sram_wr_addr;
output                              sram_wr_en;
output  [AXI_BE_WIDTH-1:0]          sram_wr_be;
output  [AXI_DATA_WIDTH-1:0]        sram_wr_data;
output  [SRAM_ADDR_WIDTH-1:0]       sram_rd_addr;
input   [AXI_DATA_WIDTH-1:0]        sram_rd_data;



// ----------------
// -- Port Types --
// ----------------

wire                                rst_n;
wire                                clk;

wire                                awvalid;
reg                                 awready;
wire    [2:0]                       awregion;
wire    [AXI_ADDR_WIDTH-1:0]        awaddr;
wire    [AXI_LEN_WIDTH-1:0]         awlen;
wire    [2:0]                       awsize;

wire                                wvalid;
reg                                 wready;
wire    [AXI_DATA_WIDTH-1:0]        wdata;
wire    [AXI_BE_WIDTH-1:0]          wstrb;
wire                                wlast;

reg                                 bvalid;
wire                                bready;
wire    [1:0]                       bresp;

wire                                arvalid;
reg                                 arready;
wire    [2:0]                       arregion;
wire    [AXI_ADDR_WIDTH-1:0]        araddr;
wire    [AXI_LEN_WIDTH-1:0]         arlen;
wire    [2:0]                       arsize;

wire                                rvalid;
wire                                rready;
wire    [AXI_DATA_WIDTH-1:0]        rdata;
wire    [1:0]                       rresp;
wire                                rlast;

reg     [REG_ADDR_WIDTH-1:0]        reg_wr_addr;
reg                                 reg_wr_en;
wire    [AXI_BE_WIDTH-1:0]          reg_wr_be;
wire    [AXI_DATA_WIDTH-1:0]        reg_wr_data;
reg     [REG_ADDR_WIDTH-1:0]        reg_rd_addr;
wire    [AXI_DATA_WIDTH-1:0]        reg_rd_data;

reg     [SRAM_ADDR_WIDTH-1:0]       sram_wr_addr;
reg                                 sram_wr_en;
wire    [AXI_BE_WIDTH-1:0]          sram_wr_be;
wire    [AXI_DATA_WIDTH-1:0]        sram_wr_data;
reg     [SRAM_ADDR_WIDTH-1:0]       sram_rd_addr;
wire    [AXI_DATA_WIDTH-1:0]        sram_rd_data;



// -------------------
// -- Local Signals --
// -------------------

// Target Reads
wire                                ar_sel_sram_reg_n;
wire                                rd_cmd_en;
wire                                rd_en;

reg                                 rd_sel_sram_reg_n;
reg     [AXI_LEN_WIDTH:0]           rd_ctr;
reg                                 rd_pend;
reg                                 rd_fifo_afull;
reg                                 r1_rd_en;
reg                                 r2_rd_en;
reg                                 r1_rd_last;
reg                                 r2_rd_last;
reg                                 r1_sel_sram_reg_n;
reg                                 r2_sel_sram_reg_n;
reg     [AXI_DATA_WIDTH-1:0]        r2_sram_rd_data;
reg     [AXI_DATA_WIDTH-1:0]        r2_reg_rd_data;

wire                                rd_fifo_wr_en;
wire                                rd_fifo_wr_last;
wire    [AXI_DATA_WIDTH-1:0]        rd_fifo_wr_data;
wire    [FIFO_ADDR_WIDTH:0]         rd_fifo_wr_level;
wire                                rd_fifo_wr_full_unused;

wire                                rd_fifo_rd_en;
wire                                rd_fifo_rd_last;
wire    [AXI_DATA_WIDTH-1:0]        rd_fifo_rd_data;
wire    [FIFO_ADDR_WIDTH:0]         rd_fifo_rd_level_unused;
wire                                rd_fifo_rd_empty;

wire                                i_tiny_valid;
wire                                i_tiny_ready;

// Target Writes
wire                                aw_sel_sram_reg_n;
wire                                wr_cmd_en;
wire                                wr_en;

reg                                 wr_sel_sram_reg_n;
reg     [SRAM_ADDR_WIDTH-1:0]       d_sram_wr_addr;
reg     [REG_ADDR_WIDTH-1:0]        d_reg_wr_addr;
reg     [AXI_LEN_WIDTH:0]           wr_ctr;
reg     [AXI_DATA_WIDTH-1:0]        wr_data;
reg     [AXI_BE_WIDTH-1:0]          wr_be;



// ---------------
// -- Equations --
// ---------------

// ------------
// Target Reads

assign ar_sel_sram_reg_n = (arregion != 3'h0); // arregion == 0 (Registers) else (SRAM)

assign rd_cmd_en = arvalid & arready;

assign rd_en = rd_pend & ~rd_fifo_afull;

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 0)
    begin
        arready             <= 1'b1;
        rd_sel_sram_reg_n   <= 1'b0;
        sram_rd_addr        <= {SRAM_ADDR_WIDTH{1'b0}};
        reg_rd_addr         <= {REG_ADDR_WIDTH{1'b0}};
        rd_ctr              <= {(AXI_LEN_WIDTH+1){1'b0}};
        rd_pend             <= 1'b0;
        rd_fifo_afull       <= 1'b0;
        r1_rd_en            <= 1'b0;
        r2_rd_en            <= 1'b0;
        r1_rd_last          <= 1'b0;
        r2_rd_last          <= 1'b0;
        r1_sel_sram_reg_n   <= 1'b0;
        r2_sel_sram_reg_n   <= 1'b0;
        r2_sram_rd_data     <= {AXI_DATA_WIDTH{1'b0}};
        r2_reg_rd_data      <= {AXI_DATA_WIDTH{1'b0}};
    end
    else
    begin
        // Only work on one read command at a time
        if (rd_cmd_en)
            arready <= 1'b0;
        else if (rd_en & (rd_ctr == {{AXI_LEN_WIDTH{1'b0}}, 1'b1}))
            arready <= 1'b1;

        if (rd_cmd_en)
            rd_sel_sram_reg_n <= ar_sel_sram_reg_n;

        if (rd_cmd_en & ar_sel_sram_reg_n)
            sram_rd_addr <= araddr[SRAM_ADDR_WIDTH+AXI_REMAIN_WIDTH-1:AXI_REMAIN_WIDTH];
        else if (rd_en & rd_sel_sram_reg_n)
            sram_rd_addr <= sram_rd_addr + {{(SRAM_ADDR_WIDTH-1){1'b0}}, 1'b1};

        if (rd_cmd_en & ~ar_sel_sram_reg_n)
            reg_rd_addr <= araddr[REG_ADDR_WIDTH+AXI_REMAIN_WIDTH-1:AXI_REMAIN_WIDTH];
        else if (rd_en & ~rd_sel_sram_reg_n)
            reg_rd_addr <= reg_rd_addr + {{(REG_ADDR_WIDTH-1){1'b0}}, 1'b1};

        if (rd_cmd_en)
            rd_ctr <= {1'b0, arlen} + {{AXI_LEN_WIDTH{1'b0}}, 1'b1};
        else if (rd_en)
            rd_ctr <= rd_ctr - {{AXI_LEN_WIDTH{1'b0}}, 1'b1};

        if (rd_cmd_en)
            rd_pend <= 1'b1;
        else if (rd_en & (rd_ctr == {{AXI_LEN_WIDTH{1'b0}}, 1'b1}))
            rd_pend <= 1'b0;

        rd_fifo_afull <= (rd_fifo_wr_level >= ((1 << FIFO_ADDR_WIDTH) - 4));

        // Delay enable to be valid with data; external latency == 1, plus register read data for total latency 2
        r1_rd_en          <=    rd_en;
        r2_rd_en          <= r1_rd_en;

        r1_rd_last        <= rd_en & (rd_ctr == {{AXI_LEN_WIDTH{1'b0}}, 1'b1});
        r2_rd_last        <= r1_rd_last;

        r1_sel_sram_reg_n <= rd_sel_sram_reg_n;
        r2_sel_sram_reg_n <= r1_sel_sram_reg_n;

        r2_sram_rd_data   <= sram_rd_data;
        r2_reg_rd_data    <= reg_rd_data;
    end
end

assign rd_fifo_wr_en   = r2_rd_en;
assign rd_fifo_wr_last = r2_rd_last;
assign rd_fifo_wr_data = r2_sel_sram_reg_n ? r2_sram_rd_data : r2_reg_rd_data;

ref_sc_fifo_shallow_ram #(

    .ADDR_WIDTH     (FIFO_ADDR_WIDTH                    ),
    .DATA_WIDTH     (1 + AXI_DATA_WIDTH                 ),
    .EN_LOOK_AHEAD  (1                                  )

) rd_fifo (

    .rst_n          (rst_n                              ),
    .clk            (clk                                ),

    .flush          (1'b0                               ),

    .wr_en          (rd_fifo_wr_en                      ),
    .wr_data        ({rd_fifo_wr_last, rd_fifo_wr_data} ),
    .wr_level       (rd_fifo_wr_level                   ),
    .wr_full        (rd_fifo_wr_full_unused             ),

    .rd_ack         (rd_fifo_rd_en                      ),
    .rd_data        ({rd_fifo_rd_last, rd_fifo_rd_data} ),
    .rd_level       (rd_fifo_rd_level_unused            ),
    .rd_empty       (rd_fifo_rd_empty                   )

);

assign i_tiny_valid  = ~rd_fifo_rd_empty;
assign rd_fifo_rd_en = i_tiny_valid & i_tiny_ready;

ref_tiny_fifo #(

    .DATA_WIDTH     (1 + AXI_DATA_WIDTH                 )

) rd_tiny_fifo(

    .rst_n          (rst_n                              ),
    .clk            (clk                                ),

    .in_src_rdy     (i_tiny_valid                       ),
    .in_dst_rdy     (i_tiny_ready                       ),
    .in_data        ({rd_fifo_rd_last, rd_fifo_rd_data} ),

    .out_src_rdy    (rvalid                             ),
    .out_dst_rdy    (rready                             ),
    .out_data       ({rlast, rdata}                     )

);

// Reads are always successful
assign rresp = 2'b00; // Okay



// -------------
// Target Writes

assign aw_sel_sram_reg_n = (awregion != 3'h0); // awregion == 0 (Registers) else (SRAM)

assign wr_cmd_en = awvalid & awready;

assign wr_en = wvalid & wready;

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 0)
    begin
        awready             <= 1'b1;
        wr_sel_sram_reg_n   <= 1'b0;
        d_sram_wr_addr      <= {SRAM_ADDR_WIDTH{1'b0}};
        d_reg_wr_addr       <= {REG_ADDR_WIDTH{1'b0}};
        sram_wr_addr        <= {SRAM_ADDR_WIDTH{1'b0}};
        reg_wr_addr         <= {REG_ADDR_WIDTH{1'b0}};
        wr_ctr              <= {(AXI_LEN_WIDTH+1){1'b0}};
        wready              <= 1'b0;
        sram_wr_en          <= 1'b0;
        reg_wr_en           <= 1'b0;
        wr_data             <= {AXI_DATA_WIDTH{1'b0}};
        wr_be               <= {AXI_BE_WIDTH{1'b0}};
        bvalid              <= 1'b0;
    end
    else
    begin
        // Only work on one write command at a time
        if (wr_cmd_en)
            awready <= 1'b0;
        else if (bvalid & bready)
            awready <= 1'b1;

        if (wr_cmd_en)
            wr_sel_sram_reg_n <= aw_sel_sram_reg_n;

        if (wr_cmd_en)
            d_sram_wr_addr <= awaddr[SRAM_ADDR_WIDTH+AXI_REMAIN_WIDTH-1:AXI_REMAIN_WIDTH];
        else if (wr_en)
            d_sram_wr_addr <= d_sram_wr_addr + {{(SRAM_ADDR_WIDTH-1){1'b0}}, 1'b1};

        if (wr_cmd_en)
            d_reg_wr_addr <= awaddr[REG_ADDR_WIDTH+AXI_REMAIN_WIDTH-1:AXI_REMAIN_WIDTH];
        else if (wr_en)
            d_reg_wr_addr <= d_reg_wr_addr + {{(REG_ADDR_WIDTH-1){1'b0}}, 1'b1};

        sram_wr_addr <= d_sram_wr_addr;
        reg_wr_addr  <= d_reg_wr_addr;

        if (wr_cmd_en)
            wr_ctr <= {1'b0, awlen} + {{AXI_LEN_WIDTH{1'b0}}, 1'b1};
        else if (wr_en)
            wr_ctr <= wr_ctr - {{AXI_LEN_WIDTH{1'b0}}, 1'b1};

        if (wr_cmd_en)
            wready <= 1'b1;
        else if (wr_en & (wr_ctr == {{AXI_LEN_WIDTH{1'b0}}, 1'b1}))
            wready <= 1'b0;

        sram_wr_en <= wr_en &  wr_sel_sram_reg_n;
        reg_wr_en  <= wr_en & ~wr_sel_sram_reg_n;

        wr_data <= wdata;
        wr_be   <= wstrb;

        if (wr_en & (wr_ctr == {{AXI_LEN_WIDTH{1'b0}}, 1'b1}))
            bvalid <= 1'b1;
        else if (bready)
            bvalid <= 1'b0;
    end
end

assign sram_wr_be   = wr_be;
assign sram_wr_data = wr_data;

assign reg_wr_be    = wr_be;
assign reg_wr_data  = wr_data;

// Writes always successful
assign bresp = 2'h0; // Okay


endmodule
