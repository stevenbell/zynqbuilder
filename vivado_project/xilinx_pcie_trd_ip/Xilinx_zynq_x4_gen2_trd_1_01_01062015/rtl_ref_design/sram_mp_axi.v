// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2007 by Northwest Logic, Inc.
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

module sram_mp_axi (

    s2c_areset_n,
    s2c_aclk,
    s2c_awvalid,
    s2c_awready,
    s2c_awaddr,
    s2c_awlen,
    s2c_wvalid,
    s2c_wready,
    s2c_wdata,
    s2c_wstrb,
    s2c_wlast,
    s2c_bvalid,
    s2c_bready,
    s2c_bresp,

    c2s_areset_n,
    c2s_aclk,
    c2s_arvalid,
    c2s_arready,
    c2s_araddr,
    c2s_arlen,
    c2s_rvalid,
    c2s_rready,
    c2s_rdata,
    c2s_rresp,
    c2s_rlast

);



// ----------------
// -- Parameters --
// ----------------

parameter   DMA_DEST_BADDR_WIDTH            = 15;   // Size of multi-ported SRAM that is destination of addressable DMA == 2^DMA_DEST_BADDR_WIDTH bytes

localparam  AXI_DATA_WIDTH                  = 64;
localparam  AXI_REMAIN_WIDTH                = 3;
localparam  AXI_BE_WIDTH                    = AXI_DATA_WIDTH / 8;
parameter   AXI_LEN_WIDTH                   = 4;    // Sets maximum AXI burst size; supported values 4 (AXI3/AXI4) or 8 (AXI4); For AXI_DATA_WIDTH==256 must be 4 so a 4 KB boundary is not crossed
parameter   AXI_ADDR_WIDTH                  = 36;   // Width of AXI DMA address ports

localparam  RFIFO_ADDR_WIDTH                = AXI_LEN_WIDTH + 1;    // Read data FIFO needs to hold 2 max AXI-size transactions

localparam  DMA_DEST_ADDR_WIDTH             = DMA_DEST_BADDR_WIDTH - AXI_REMAIN_WIDTH; // Size of multi-ported SRAM = 2^DMA_DEST_ADDR_WIDTH AXI words

// Maximum number of S2C & C2S DMA Engines supported; do not modify
localparam  NUM_S2C                         = 8;
localparam  NUM_C2S                         = 8;



// ----------------------
// -- Port Definitions --
// ----------------------

input                                       s2c_areset_n;
input                                       s2c_aclk;
input   [ NUM_S2C                    -1:0]  s2c_awvalid;
output  [ NUM_S2C                    -1:0]  s2c_awready;
input   [(NUM_S2C*AXI_ADDR_WIDTH)    -1:0]  s2c_awaddr;
input   [(NUM_S2C*AXI_LEN_WIDTH)     -1:0]  s2c_awlen;
input   [ NUM_S2C                    -1:0]  s2c_wvalid;
output  [ NUM_S2C                    -1:0]  s2c_wready;
input   [(NUM_S2C*AXI_DATA_WIDTH)    -1:0]  s2c_wdata;
input   [(NUM_S2C*AXI_BE_WIDTH)      -1:0]  s2c_wstrb;
input   [ NUM_S2C                    -1:0]  s2c_wlast;
output  [ NUM_S2C                    -1:0]  s2c_bvalid;
input   [ NUM_S2C                    -1:0]  s2c_bready;
output  [(NUM_S2C*2)                 -1:0]  s2c_bresp;

input                                       c2s_areset_n;
input                                       c2s_aclk;
input   [ NUM_C2S                    -1:0]  c2s_arvalid;
output  [ NUM_C2S                    -1:0]  c2s_arready;
input   [(NUM_C2S*AXI_ADDR_WIDTH)    -1:0]  c2s_araddr;
input   [(NUM_C2S*AXI_LEN_WIDTH)     -1:0]  c2s_arlen;
output  [ NUM_C2S                    -1:0]  c2s_rvalid;
input   [ NUM_C2S                    -1:0]  c2s_rready;
output  [(NUM_C2S*AXI_DATA_WIDTH)    -1:0]  c2s_rdata;
output  [(NUM_C2S*2)                 -1:0]  c2s_rresp;
output  [ NUM_C2S                    -1:0]  c2s_rlast;



// ----------------
// -- Port Types --
// ----------------

wire                                        s2c_areset_n;
wire                                        s2c_aclk;
wire    [ NUM_S2C                    -1:0]  s2c_awvalid;
wire    [ NUM_S2C                    -1:0]  s2c_awready;
wire    [(NUM_S2C*AXI_ADDR_WIDTH)    -1:0]  s2c_awaddr;
wire    [(NUM_S2C*AXI_LEN_WIDTH)     -1:0]  s2c_awlen;
wire    [ NUM_S2C                    -1:0]  s2c_wvalid;
wire    [ NUM_S2C                    -1:0]  s2c_wready;
wire    [(NUM_S2C*AXI_DATA_WIDTH)    -1:0]  s2c_wdata;
wire    [(NUM_S2C*AXI_BE_WIDTH)      -1:0]  s2c_wstrb;
wire    [ NUM_S2C                    -1:0]  s2c_wlast;
reg     [ NUM_S2C                    -1:0]  s2c_bvalid;
wire    [ NUM_S2C                    -1:0]  s2c_bready;
wire    [(NUM_S2C*2)                 -1:0]  s2c_bresp;

wire                                        c2s_areset_n;
wire                                        c2s_aclk;
wire    [ NUM_C2S                    -1:0]  c2s_arvalid;
wire    [ NUM_C2S                    -1:0]  c2s_arready;
wire    [(NUM_C2S*AXI_ADDR_WIDTH)    -1:0]  c2s_araddr;
wire    [(NUM_C2S*AXI_LEN_WIDTH)     -1:0]  c2s_arlen;
wire    [ NUM_C2S                    -1:0]  c2s_rvalid;
wire    [ NUM_C2S                    -1:0]  c2s_rready;
wire    [(NUM_C2S*AXI_DATA_WIDTH)    -1:0]  c2s_rdata;
wire    [(NUM_C2S*2)                 -1:0]  c2s_rresp;
wire    [ NUM_C2S                    -1:0]  c2s_rlast;



// -------------------
// -- Local Signals --
// -------------------

// AXI Writes
reg     [2:0]                       c_wgnt_sel;
reg     [7:0]                       c_wgnt;
wire                                c_wchg_gnt;
wire                                c_wnew_gnt;

reg     [2:0]                       wgnt_sel;
reg     [2:0]                       wgnt_sel2;
reg     [2:0]                       wgnt_sel3;
reg     [2:0]                       wgnt_sel4;
reg     [2:0]                       wgnt_sel5;
reg     [2:0]                       wgnt_sel6;
reg     [2:0]                       wgnt_sel7;
reg     [7:0]                       wgnt;
reg                                 wbusy;
reg     [DMA_DEST_ADDR_WIDTH-1:0]   waddr;
`ifdef SIMULATION
reg     [AXI_LEN_WIDTH-1:0]         wlen;
`endif

reg                                 awvalid;
reg     [AXI_ADDR_WIDTH-1:0]        awaddr;
`ifdef SIMULATION
reg     [AXI_LEN_WIDTH-1:0]         awlen;
`endif
reg                                 wvalid;
reg     [AXI_DATA_WIDTH-1:0]        wdata;
reg     [AXI_BE_WIDTH-1:0]          wstrb;
reg                                 wlast;

reg     [AXI_BE_WIDTH-1:0]          sram_wr_en;
reg     [DMA_DEST_ADDR_WIDTH-1:0]   sram_wr_addr;
reg     [AXI_DATA_WIDTH-1:0]        sram_wr_data;

// AXI Reads
reg     [2:0]                       c_rgnt_sel;
reg     [7:0]                       c_rgnt;
wire                                c_rchg_gnt;
wire                                c_rnew_gnt;

reg     [2:0]                       rgnt_sel;
reg     [2:0]                       rgnt_sel2;
reg     [2:0]                       rgnt_sel3;
reg     [2:0]                       rgnt_sel4;
reg     [2:0]                       rgnt_sel5;
reg     [7:0]                       rgnt;
reg     [1:0]                       rlevel;
reg                                 rfull;
reg                                 rbusy;
reg     [DMA_DEST_ADDR_WIDTH-1:0]   raddr;
reg     [AXI_LEN_WIDTH-1:0]         rlen;

wire                                rlast;
wire                                rcmdready;

reg                                 arvalid;
reg     [AXI_ADDR_WIDTH-1:0]        araddr;
reg     [AXI_LEN_WIDTH-1:0]         arlen;

reg                                 sram_rd_en;
reg     [2:0]                       sram_rd_gnt_sel;
reg                                 sram_rd_last;

reg                                 rfifo_wr_en;     
reg     [2:0]                       rfifo_wr_gnt_sel;
reg                                 rfifo_wr_last;
reg     [AXI_DATA_WIDTH-1:0]        rfifo_wr_data;
wire    [RFIFO_ADDR_WIDTH:0]        rfifo_wr_level_unused;
wire                                rfifo_wr_full_unused;

wire                                rfifo_rd_en;     
wire    [2:0]                       rfifo_rd_gnt_sel;
wire                                rfifo_rd_last;
wire    [AXI_DATA_WIDTH-1:0]        rfifo_rd_data;    
wire    [RFIFO_ADDR_WIDTH:0]        rfifo_rd_level_unused;
wire                                rfifo_rd_empty;

wire                                i_tiny_valid;
wire                                i_tiny_ready;

wire                                o_tiny_valid;
wire    [2:0]                       o_tiny_gnt_sel;
wire                                o_tiny_last;
wire    [AXI_DATA_WIDTH-1:0]        o_tiny_data;    

reg                                 rready;

// Instantiate DMA Destination Memory
genvar                              i;
wire    [AXI_DATA_WIDTH-1:0]        sram_rd_data;



// ---------------
// -- Equations --
// ---------------

// ----------
// AXI Writes

// Arbitrate access to SRAM
always @*
begin
    case (wgnt_sel)
        3'h0    : c_wgnt_sel = s2c_awvalid[1] ? 3'h1 : (s2c_awvalid[2] ? 3'h2 : (s2c_awvalid[3] ? 3'h3 : (s2c_awvalid[4] ? 3'h4 : (s2c_awvalid[5] ? 3'h5 : (s2c_awvalid[6] ? 3'h6 : (s2c_awvalid[7] ? 3'h7 : 3'h0))))));
        3'h1    : c_wgnt_sel = s2c_awvalid[2] ? 3'h2 : (s2c_awvalid[3] ? 3'h3 : (s2c_awvalid[4] ? 3'h4 : (s2c_awvalid[5] ? 3'h5 : (s2c_awvalid[6] ? 3'h6 : (s2c_awvalid[7] ? 3'h7 : (s2c_awvalid[0] ? 3'h0 : 3'h1))))));
        3'h2    : c_wgnt_sel = s2c_awvalid[3] ? 3'h3 : (s2c_awvalid[4] ? 3'h4 : (s2c_awvalid[5] ? 3'h5 : (s2c_awvalid[6] ? 3'h6 : (s2c_awvalid[7] ? 3'h7 : (s2c_awvalid[0] ? 3'h0 : (s2c_awvalid[1] ? 3'h1 : 3'h2))))));
        3'h3    : c_wgnt_sel = s2c_awvalid[4] ? 3'h4 : (s2c_awvalid[5] ? 3'h5 : (s2c_awvalid[6] ? 3'h6 : (s2c_awvalid[7] ? 3'h7 : (s2c_awvalid[0] ? 3'h0 : (s2c_awvalid[1] ? 3'h1 : (s2c_awvalid[2] ? 3'h2 : 3'h3))))));
        3'h4    : c_wgnt_sel = s2c_awvalid[5] ? 3'h5 : (s2c_awvalid[6] ? 3'h6 : (s2c_awvalid[7] ? 3'h7 : (s2c_awvalid[0] ? 3'h0 : (s2c_awvalid[1] ? 3'h1 : (s2c_awvalid[2] ? 3'h2 : (s2c_awvalid[3] ? 3'h3 : 3'h4))))));
        3'h5    : c_wgnt_sel = s2c_awvalid[6] ? 3'h6 : (s2c_awvalid[7] ? 3'h7 : (s2c_awvalid[0] ? 3'h0 : (s2c_awvalid[1] ? 3'h1 : (s2c_awvalid[2] ? 3'h2 : (s2c_awvalid[3] ? 3'h3 : (s2c_awvalid[4] ? 3'h4 : 3'h5))))));
        3'h6    : c_wgnt_sel = s2c_awvalid[7] ? 3'h7 : (s2c_awvalid[0] ? 3'h0 : (s2c_awvalid[1] ? 3'h1 : (s2c_awvalid[2] ? 3'h2 : (s2c_awvalid[3] ? 3'h3 : (s2c_awvalid[4] ? 3'h4 : (s2c_awvalid[5] ? 3'h5 : 3'h6))))));
        default : c_wgnt_sel = s2c_awvalid[0] ? 3'h0 : (s2c_awvalid[1] ? 3'h1 : (s2c_awvalid[2] ? 3'h2 : (s2c_awvalid[3] ? 3'h3 : (s2c_awvalid[4] ? 3'h4 : (s2c_awvalid[5] ? 3'h5 : (s2c_awvalid[6] ? 3'h6 : 3'h7))))));
    endcase
end

// 8 bit decoder - Convert Binary Grant Value to One-Hot
always @*
begin
    case (c_wgnt_sel)
        3'h0    : c_wgnt = 8'b00000001;
        3'h1    : c_wgnt = 8'b00000010;
        3'h2    : c_wgnt = 8'b00000100;
        3'h3    : c_wgnt = 8'b00001000;
        3'h4    : c_wgnt = 8'b00010000;
        3'h5    : c_wgnt = 8'b00100000;
        3'h6    : c_wgnt = 8'b01000000;
        default : c_wgnt = 8'b10000000;
    endcase
end

// Change the granted device when at least one device which
//   is not currently granted is requesting a transfer
assign c_wchg_gnt = (s2c_awvalid[0] & ~wgnt[0]) |
                    (s2c_awvalid[1] & ~wgnt[1]) |
                    (s2c_awvalid[2] & ~wgnt[2]) |
                    (s2c_awvalid[3] & ~wgnt[3]) |
                    (s2c_awvalid[4] & ~wgnt[4]) |
                    (s2c_awvalid[5] & ~wgnt[5]) |
                    (s2c_awvalid[6] & ~wgnt[6]) | 
                    (s2c_awvalid[7] & ~wgnt[7]);

// Condition to change the granted port:
//   ((End of transfer for the currently granted port) | (currently granted device is not starting a new transfer this clock)) & 
//   (request on one or more non-granted ports is active)
assign c_wnew_gnt = ((wbusy & wvalid & wlast) | (~wbusy & ~awvalid)) & c_wchg_gnt;                                

always @(posedge s2c_aclk or negedge s2c_areset_n)
begin
    if (s2c_areset_n == 1'b0)
    begin
        wgnt_sel  <= 3'h0;  // Default grant is Port 0
        wgnt_sel2 <= 3'h0;  // 
        wgnt_sel3 <= 3'h0;  // 
        wgnt_sel4 <= 3'h0;  // 
        wgnt_sel5 <= 3'h0;  // 
        wgnt_sel6 <= 3'h0;  // 
        wgnt_sel7 <= 3'h0;  // 

        wgnt      <= 8'h1;  // Default grant is Port 0

        wbusy     <= 1'b0;
        waddr     <= {DMA_DEST_ADDR_WIDTH{1'b0}};
`ifdef SIMULATION
        wlen      <= {AXI_LEN_WIDTH{1'b1}};
`endif
    end
    else
    begin
        // Select the next grant that will be made
        if (c_wnew_gnt)
        begin
            wgnt_sel  <= c_wgnt_sel;                        
            wgnt_sel2 <= c_wgnt_sel;                        
            wgnt_sel3 <= c_wgnt_sel;                        
            wgnt_sel4 <= c_wgnt_sel;                        
            wgnt_sel5 <= c_wgnt_sel;                        
            wgnt_sel6 <= c_wgnt_sel;                        
            wgnt_sel7 <= c_wgnt_sel;                        

            wgnt      <= c_wgnt;
        end

        // wbusy is asserted whenever a transfer is in progress
        if (awvalid & ~wbusy)
            wbusy <= 1'b1;
        else if (wvalid & wlast)
            wbusy <= 1'b0;

        if (awvalid & ~wbusy)
            waddr <= awaddr[(DMA_DEST_ADDR_WIDTH+AXI_REMAIN_WIDTH)-1:AXI_REMAIN_WIDTH];
        else if (wbusy & wvalid)
            waddr <= waddr + {{(DMA_DEST_ADDR_WIDTH-1){1'b0}}, 1'b1};
`ifdef SIMULATION

        if (awvalid & ~wbusy)
            wlen <= awlen;
        else if (wbusy & wvalid)
            wlen <= wlen - {{(AXI_LEN_WIDTH-1){1'b0}}, 1'b1};

        if (wbusy & wvalid & wlast & (wlen != {AXI_LEN_WIDTH{1'b0}}))
            $display ("%m : ERROR : awlen did not match the assertion of wlast (time %t)", $time);
`endif
    end
end

assign s2c_awready[0] = wgnt[0] & ~wbusy;
assign s2c_awready[1] = wgnt[1] & ~wbusy;
assign s2c_awready[2] = wgnt[2] & ~wbusy;
assign s2c_awready[3] = wgnt[3] & ~wbusy;
assign s2c_awready[4] = wgnt[4] & ~wbusy;
assign s2c_awready[5] = wgnt[5] & ~wbusy;
assign s2c_awready[6] = wgnt[6] & ~wbusy;
assign s2c_awready[7] = wgnt[7] & ~wbusy;

always @*
begin
    case (wgnt_sel2)
      3'h0    : awvalid = s2c_awvalid[0];
      3'h1    : awvalid = s2c_awvalid[1]; 
      3'h2    : awvalid = s2c_awvalid[2]; 
      3'h3    : awvalid = s2c_awvalid[3]; 
      3'h4    : awvalid = s2c_awvalid[4]; 
      3'h5    : awvalid = s2c_awvalid[5]; 
      3'h6    : awvalid = s2c_awvalid[6]; 
      default : awvalid = s2c_awvalid[7]; 
    endcase
end

always @*
begin
    case (wgnt_sel3)
        3'h0    : awaddr = s2c_awaddr[((0+1)*AXI_ADDR_WIDTH)-1:(0*AXI_ADDR_WIDTH)];
        3'h1    : awaddr = s2c_awaddr[((1+1)*AXI_ADDR_WIDTH)-1:(1*AXI_ADDR_WIDTH)];
        3'h2    : awaddr = s2c_awaddr[((2+1)*AXI_ADDR_WIDTH)-1:(2*AXI_ADDR_WIDTH)];
        3'h3    : awaddr = s2c_awaddr[((3+1)*AXI_ADDR_WIDTH)-1:(3*AXI_ADDR_WIDTH)];
        3'h4    : awaddr = s2c_awaddr[((4+1)*AXI_ADDR_WIDTH)-1:(4*AXI_ADDR_WIDTH)];
        3'h5    : awaddr = s2c_awaddr[((5+1)*AXI_ADDR_WIDTH)-1:(5*AXI_ADDR_WIDTH)];
        3'h6    : awaddr = s2c_awaddr[((6+1)*AXI_ADDR_WIDTH)-1:(6*AXI_ADDR_WIDTH)];
        default : awaddr = s2c_awaddr[((7+1)*AXI_ADDR_WIDTH)-1:(7*AXI_ADDR_WIDTH)];
    endcase
end
`ifdef SIMULATION

// For simulation verify that awlen matches # of words indicated by wlast
always @*
begin
    case (wgnt_sel3)
        3'h0    : awlen = s2c_awlen[((0+1)*AXI_LEN_WIDTH)-1:(0*AXI_LEN_WIDTH)];
        3'h1    : awlen = s2c_awlen[((1+1)*AXI_LEN_WIDTH)-1:(1*AXI_LEN_WIDTH)];
        3'h2    : awlen = s2c_awlen[((2+1)*AXI_LEN_WIDTH)-1:(2*AXI_LEN_WIDTH)];
        3'h3    : awlen = s2c_awlen[((3+1)*AXI_LEN_WIDTH)-1:(3*AXI_LEN_WIDTH)];
        3'h4    : awlen = s2c_awlen[((4+1)*AXI_LEN_WIDTH)-1:(4*AXI_LEN_WIDTH)];
        3'h5    : awlen = s2c_awlen[((5+1)*AXI_LEN_WIDTH)-1:(5*AXI_LEN_WIDTH)];
        3'h6    : awlen = s2c_awlen[((6+1)*AXI_LEN_WIDTH)-1:(6*AXI_LEN_WIDTH)];
        default : awlen = s2c_awlen[((7+1)*AXI_LEN_WIDTH)-1:(7*AXI_LEN_WIDTH)];
    endcase
end
`endif

always @*
begin
    case (wgnt_sel4)
      3'h0    : wvalid = s2c_wvalid[0];
      3'h1    : wvalid = s2c_wvalid[1]; 
      3'h2    : wvalid = s2c_wvalid[2]; 
      3'h3    : wvalid = s2c_wvalid[3]; 
      3'h4    : wvalid = s2c_wvalid[4]; 
      3'h5    : wvalid = s2c_wvalid[5]; 
      3'h6    : wvalid = s2c_wvalid[6]; 
      default : wvalid = s2c_wvalid[7]; 
    endcase
end

assign s2c_wready[0] = wgnt[0] & wbusy;
assign s2c_wready[1] = wgnt[1] & wbusy;
assign s2c_wready[2] = wgnt[2] & wbusy;
assign s2c_wready[3] = wgnt[3] & wbusy;
assign s2c_wready[4] = wgnt[4] & wbusy;
assign s2c_wready[5] = wgnt[5] & wbusy;
assign s2c_wready[6] = wgnt[6] & wbusy;
assign s2c_wready[7] = wgnt[7] & wbusy;

always @*
begin
    case (wgnt_sel5)
        3'h0    : wdata = s2c_wdata[((0+1)*AXI_DATA_WIDTH)-1:(0*AXI_DATA_WIDTH)];
        3'h1    : wdata = s2c_wdata[((1+1)*AXI_DATA_WIDTH)-1:(1*AXI_DATA_WIDTH)];
        3'h2    : wdata = s2c_wdata[((2+1)*AXI_DATA_WIDTH)-1:(2*AXI_DATA_WIDTH)];
        3'h3    : wdata = s2c_wdata[((3+1)*AXI_DATA_WIDTH)-1:(3*AXI_DATA_WIDTH)];
        3'h4    : wdata = s2c_wdata[((4+1)*AXI_DATA_WIDTH)-1:(4*AXI_DATA_WIDTH)];
        3'h5    : wdata = s2c_wdata[((5+1)*AXI_DATA_WIDTH)-1:(5*AXI_DATA_WIDTH)];
        3'h6    : wdata = s2c_wdata[((6+1)*AXI_DATA_WIDTH)-1:(6*AXI_DATA_WIDTH)];
        default : wdata = s2c_wdata[((7+1)*AXI_DATA_WIDTH)-1:(7*AXI_DATA_WIDTH)];
    endcase
end

always @*
begin
    case (wgnt_sel6)
        3'h0    : wstrb = s2c_wstrb[((0+1)*AXI_BE_WIDTH)-1:(0*AXI_BE_WIDTH)];
        3'h1    : wstrb = s2c_wstrb[((1+1)*AXI_BE_WIDTH)-1:(1*AXI_BE_WIDTH)];
        3'h2    : wstrb = s2c_wstrb[((2+1)*AXI_BE_WIDTH)-1:(2*AXI_BE_WIDTH)];
        3'h3    : wstrb = s2c_wstrb[((3+1)*AXI_BE_WIDTH)-1:(3*AXI_BE_WIDTH)];
        3'h4    : wstrb = s2c_wstrb[((4+1)*AXI_BE_WIDTH)-1:(4*AXI_BE_WIDTH)];
        3'h5    : wstrb = s2c_wstrb[((5+1)*AXI_BE_WIDTH)-1:(5*AXI_BE_WIDTH)];
        3'h6    : wstrb = s2c_wstrb[((6+1)*AXI_BE_WIDTH)-1:(6*AXI_BE_WIDTH)];
        default : wstrb = s2c_wstrb[((7+1)*AXI_BE_WIDTH)-1:(7*AXI_BE_WIDTH)];
    endcase
end

always @*
begin
    case (wgnt_sel7)
      3'h0    : wlast = s2c_wlast[0];
      3'h1    : wlast = s2c_wlast[1]; 
      3'h2    : wlast = s2c_wlast[2]; 
      3'h3    : wlast = s2c_wlast[3]; 
      3'h4    : wlast = s2c_wlast[4]; 
      3'h5    : wlast = s2c_wlast[5]; 
      3'h6    : wlast = s2c_wlast[6]; 
      default : wlast = s2c_wlast[7]; 
    endcase
end

always @(posedge s2c_aclk or negedge s2c_areset_n)
begin
    if (s2c_areset_n == 1'b0)
    begin
        s2c_bvalid <= {NUM_S2C{1'b0}};
    end
    else
    begin
        if (s2c_wvalid[0] & s2c_wready[0] & s2c_wlast[0]) s2c_bvalid[0] <= 1'b1; else if (s2c_bready[0]) s2c_bvalid[0] <= 1'b0; 
        if (s2c_wvalid[1] & s2c_wready[1] & s2c_wlast[1]) s2c_bvalid[1] <= 1'b1; else if (s2c_bready[1]) s2c_bvalid[1] <= 1'b0; 
        if (s2c_wvalid[2] & s2c_wready[2] & s2c_wlast[2]) s2c_bvalid[2] <= 1'b1; else if (s2c_bready[2]) s2c_bvalid[2] <= 1'b0; 
        if (s2c_wvalid[3] & s2c_wready[3] & s2c_wlast[3]) s2c_bvalid[3] <= 1'b1; else if (s2c_bready[3]) s2c_bvalid[3] <= 1'b0; 
        if (s2c_wvalid[4] & s2c_wready[4] & s2c_wlast[4]) s2c_bvalid[4] <= 1'b1; else if (s2c_bready[4]) s2c_bvalid[4] <= 1'b0; 
        if (s2c_wvalid[5] & s2c_wready[5] & s2c_wlast[5]) s2c_bvalid[5] <= 1'b1; else if (s2c_bready[5]) s2c_bvalid[5] <= 1'b0; 
        if (s2c_wvalid[6] & s2c_wready[6] & s2c_wlast[6]) s2c_bvalid[6] <= 1'b1; else if (s2c_bready[6]) s2c_bvalid[6] <= 1'b0; 
        if (s2c_wvalid[7] & s2c_wready[7] & s2c_wlast[7]) s2c_bvalid[7] <= 1'b1; else if (s2c_bready[7]) s2c_bvalid[7] <= 1'b0; 
    end
end

// Write response is always Okay
assign s2c_bresp = {NUM_S2C{2'b00}}; 

// SRAM Writes
always @(posedge s2c_aclk or negedge s2c_areset_n)
begin
    if (s2c_areset_n == 1'b0)
    begin
        sram_wr_en   <= {AXI_BE_WIDTH{1'b0}};
        sram_wr_addr <= {DMA_DEST_ADDR_WIDTH{1'b0}};
        sram_wr_data <= {AXI_DATA_WIDTH{1'b0}};
    end
    else
    begin
        sram_wr_en   <= {AXI_BE_WIDTH{wbusy}} & {AXI_BE_WIDTH{wvalid}} & wstrb;
        sram_wr_addr <= waddr;
        sram_wr_data <= wdata;
    end
end



// ---------
// AXI Reads

// Arbitrate access to SRAM
always @*
begin
    case (rgnt_sel)
        3'h0    : c_rgnt_sel = c2s_arvalid[1] ? 3'h1 : (c2s_arvalid[2] ? 3'h2 : (c2s_arvalid[3] ? 3'h3 : (c2s_arvalid[4] ? 3'h4 : (c2s_arvalid[5] ? 3'h5 : (c2s_arvalid[6] ? 3'h6 : (c2s_arvalid[7] ? 3'h7 : 3'h0))))));
        3'h1    : c_rgnt_sel = c2s_arvalid[2] ? 3'h2 : (c2s_arvalid[3] ? 3'h3 : (c2s_arvalid[4] ? 3'h4 : (c2s_arvalid[5] ? 3'h5 : (c2s_arvalid[6] ? 3'h6 : (c2s_arvalid[7] ? 3'h7 : (c2s_arvalid[0] ? 3'h0 : 3'h1))))));
        3'h2    : c_rgnt_sel = c2s_arvalid[3] ? 3'h3 : (c2s_arvalid[4] ? 3'h4 : (c2s_arvalid[5] ? 3'h5 : (c2s_arvalid[6] ? 3'h6 : (c2s_arvalid[7] ? 3'h7 : (c2s_arvalid[0] ? 3'h0 : (c2s_arvalid[1] ? 3'h1 : 3'h2))))));
        3'h3    : c_rgnt_sel = c2s_arvalid[4] ? 3'h4 : (c2s_arvalid[5] ? 3'h5 : (c2s_arvalid[6] ? 3'h6 : (c2s_arvalid[7] ? 3'h7 : (c2s_arvalid[0] ? 3'h0 : (c2s_arvalid[1] ? 3'h1 : (c2s_arvalid[2] ? 3'h2 : 3'h3))))));
        3'h4    : c_rgnt_sel = c2s_arvalid[5] ? 3'h5 : (c2s_arvalid[6] ? 3'h6 : (c2s_arvalid[7] ? 3'h7 : (c2s_arvalid[0] ? 3'h0 : (c2s_arvalid[1] ? 3'h1 : (c2s_arvalid[2] ? 3'h2 : (c2s_arvalid[3] ? 3'h3 : 3'h4))))));
        3'h5    : c_rgnt_sel = c2s_arvalid[6] ? 3'h6 : (c2s_arvalid[7] ? 3'h7 : (c2s_arvalid[0] ? 3'h0 : (c2s_arvalid[1] ? 3'h1 : (c2s_arvalid[2] ? 3'h2 : (c2s_arvalid[3] ? 3'h3 : (c2s_arvalid[4] ? 3'h4 : 3'h5))))));
        3'h6    : c_rgnt_sel = c2s_arvalid[7] ? 3'h7 : (c2s_arvalid[0] ? 3'h0 : (c2s_arvalid[1] ? 3'h1 : (c2s_arvalid[2] ? 3'h2 : (c2s_arvalid[3] ? 3'h3 : (c2s_arvalid[4] ? 3'h4 : (c2s_arvalid[5] ? 3'h5 : 3'h6))))));
        default : c_rgnt_sel = c2s_arvalid[0] ? 3'h0 : (c2s_arvalid[1] ? 3'h1 : (c2s_arvalid[2] ? 3'h2 : (c2s_arvalid[3] ? 3'h3 : (c2s_arvalid[4] ? 3'h4 : (c2s_arvalid[5] ? 3'h5 : (c2s_arvalid[6] ? 3'h6 : 3'h7))))));
    endcase
end

// 8 bit decoder - Convert Binary Grant Value to One-Hot
always @*
begin
    case (c_rgnt_sel)
        3'h0    : c_rgnt = 8'b00000001;
        3'h1    : c_rgnt = 8'b00000010;
        3'h2    : c_rgnt = 8'b00000100;
        3'h3    : c_rgnt = 8'b00001000;
        3'h4    : c_rgnt = 8'b00010000;
        3'h5    : c_rgnt = 8'b00100000;
        3'h6    : c_rgnt = 8'b01000000;
        default : c_rgnt = 8'b10000000;
    endcase
end

// Change the granted device when at least one device which
//   is not currently granted is requesting a transfer
assign c_rchg_gnt = (c2s_arvalid[0] & ~rgnt[0]) |
                    (c2s_arvalid[1] & ~rgnt[1]) |
                    (c2s_arvalid[2] & ~rgnt[2]) |
                    (c2s_arvalid[3] & ~rgnt[3]) |
                    (c2s_arvalid[4] & ~rgnt[4]) |
                    (c2s_arvalid[5] & ~rgnt[5]) |
                    (c2s_arvalid[6] & ~rgnt[6]) | 
                    (c2s_arvalid[7] & ~rgnt[7]);

// Condition to change the granted port:
//   ((End of transfer for the currently granted port) | (currently granted device is not starting a new transfer this clock)) & 
//   (request on one or more non-granted ports is active)
assign c_rnew_gnt = ((rbusy & rlast) | (~(rcmdready & arvalid))) & c_rchg_gnt;                                

always @(posedge c2s_aclk or negedge c2s_areset_n)
begin
    if (c2s_areset_n == 1'b0)
    begin
        rgnt_sel  <= 3'h0;  // Default grant is Port 0
        rgnt_sel2 <= 3'h0;  // 
        rgnt_sel3 <= 3'h0;  // 
        rgnt_sel4 <= 3'h0;  // 
        rgnt_sel5 <= 3'h0;  // 

        rgnt      <= 8'h1;  // Default grant is Port 0

        rlevel    <= 2'h0;
        rfull     <= 1'b0;

        rbusy     <= 1'b0;
        raddr     <= {DMA_DEST_ADDR_WIDTH{1'b0}};
        rlen      <= {AXI_LEN_WIDTH{1'b1}};
    end
    else
    begin
        // Select the next grant that will be made
        if (c_rnew_gnt)
        begin
            rgnt_sel  <= c_rgnt_sel;                        
            rgnt_sel2 <= c_rgnt_sel;                        
            rgnt_sel3 <= c_rgnt_sel;                        
            rgnt_sel4 <= c_rgnt_sel;                        
            rgnt_sel5 <= c_rgnt_sel;                        

            rgnt      <= c_rgnt;
        end

        // Only allow 2 AXI reads to be active at a time (rfull when 2 elements are stored);
        //   Read Data FIFO is sized to hold only 2 max size AXI transactions
        case ({(rcmdready & arvalid), (o_tiny_valid & rready & o_tiny_last)}) // {Transaction Accepted, Transaction Completed}
            2'b01   : begin rlevel <= rlevel - 2'h1; rfull <= (rlevel == 2'h3); end // -1
            2'b10   : begin rlevel <= rlevel + 2'h1; rfull <= (rlevel >= 2'h1); end // +1
            default : begin rlevel <= rlevel;        rfull <= (rlevel >= 2'h2); end // No change
        endcase            

        // rbusy is asserted whenever a transfer is in progress
        if (rcmdready & arvalid)
            rbusy <= 1'b1;
        else if (rlast)
            rbusy <= 1'b0;

        if (rcmdready & arvalid)
            raddr <= araddr[(DMA_DEST_ADDR_WIDTH+AXI_REMAIN_WIDTH)-1:AXI_REMAIN_WIDTH];
        else if (rbusy)
            raddr <= raddr + {{(DMA_DEST_ADDR_WIDTH-1){1'b0}}, 1'b1};

        if (rcmdready & arvalid)
            rlen <= arlen;
        else if (rbusy)
            rlen <= rlen - {{(AXI_LEN_WIDTH-1){1'b0}}, 1'b1};
    end
end

assign rlast = (rlen == {AXI_LEN_WIDTH{1'b0}});

// Ready to accept a new AXI transaction when not busy (currently processing a transaction)
//   and not full (already accepted maximum number of outstanding transactions)
assign rcmdready = ~rbusy & ~rfull;

assign c2s_arready[0] = rgnt[0] & rcmdready;
assign c2s_arready[1] = rgnt[1] & rcmdready;
assign c2s_arready[2] = rgnt[2] & rcmdready;
assign c2s_arready[3] = rgnt[3] & rcmdready;
assign c2s_arready[4] = rgnt[4] & rcmdready;
assign c2s_arready[5] = rgnt[5] & rcmdready;
assign c2s_arready[6] = rgnt[6] & rcmdready;
assign c2s_arready[7] = rgnt[7] & rcmdready;

always @*
begin
    case (rgnt_sel2)
      3'h0    : arvalid = c2s_arvalid[0];
      3'h1    : arvalid = c2s_arvalid[1]; 
      3'h2    : arvalid = c2s_arvalid[2]; 
      3'h3    : arvalid = c2s_arvalid[3]; 
      3'h4    : arvalid = c2s_arvalid[4]; 
      3'h5    : arvalid = c2s_arvalid[5]; 
      3'h6    : arvalid = c2s_arvalid[6]; 
      default : arvalid = c2s_arvalid[7]; 
    endcase
end

always @*
begin
    case (rgnt_sel3)
        3'h0    : araddr = c2s_araddr[((0+1)*AXI_ADDR_WIDTH)-1:(0*AXI_ADDR_WIDTH)];
        3'h1    : araddr = c2s_araddr[((1+1)*AXI_ADDR_WIDTH)-1:(1*AXI_ADDR_WIDTH)];
        3'h2    : araddr = c2s_araddr[((2+1)*AXI_ADDR_WIDTH)-1:(2*AXI_ADDR_WIDTH)];
        3'h3    : araddr = c2s_araddr[((3+1)*AXI_ADDR_WIDTH)-1:(3*AXI_ADDR_WIDTH)];
        3'h4    : araddr = c2s_araddr[((4+1)*AXI_ADDR_WIDTH)-1:(4*AXI_ADDR_WIDTH)];
        3'h5    : araddr = c2s_araddr[((5+1)*AXI_ADDR_WIDTH)-1:(5*AXI_ADDR_WIDTH)];
        3'h6    : araddr = c2s_araddr[((6+1)*AXI_ADDR_WIDTH)-1:(6*AXI_ADDR_WIDTH)];
        default : araddr = c2s_araddr[((7+1)*AXI_ADDR_WIDTH)-1:(7*AXI_ADDR_WIDTH)];
    endcase
end

// For simulation verify that awlen matches # of words indicated by rlast
always @*
begin
    case (rgnt_sel4)
        3'h0    : arlen = c2s_arlen[((0+1)*AXI_LEN_WIDTH)-1:(0*AXI_LEN_WIDTH)];
        3'h1    : arlen = c2s_arlen[((1+1)*AXI_LEN_WIDTH)-1:(1*AXI_LEN_WIDTH)];
        3'h2    : arlen = c2s_arlen[((2+1)*AXI_LEN_WIDTH)-1:(2*AXI_LEN_WIDTH)];
        3'h3    : arlen = c2s_arlen[((3+1)*AXI_LEN_WIDTH)-1:(3*AXI_LEN_WIDTH)];
        3'h4    : arlen = c2s_arlen[((4+1)*AXI_LEN_WIDTH)-1:(4*AXI_LEN_WIDTH)];
        3'h5    : arlen = c2s_arlen[((5+1)*AXI_LEN_WIDTH)-1:(5*AXI_LEN_WIDTH)];
        3'h6    : arlen = c2s_arlen[((6+1)*AXI_LEN_WIDTH)-1:(6*AXI_LEN_WIDTH)];
        default : arlen = c2s_arlen[((7+1)*AXI_LEN_WIDTH)-1:(7*AXI_LEN_WIDTH)];
    endcase
end

// Delay strobes to same latency as data
always @(posedge c2s_aclk or negedge c2s_areset_n)
begin
    if (c2s_areset_n == 1'b0)
    begin
        sram_rd_en       <= 1'b0;
        sram_rd_gnt_sel  <= 3'h0; // Default grant is Port 0
        sram_rd_last     <= 1'b0;

        rfifo_wr_en      <= 1'b0;
        rfifo_wr_gnt_sel <= 3'h0; // Default grant is Port 0
        rfifo_wr_last    <= 1'b0;
        rfifo_wr_data    <= {AXI_DATA_WIDTH{1'b0}};
    end
    else
    begin
        // Delay to same latency as sram_rd_data 
        sram_rd_en       <= rbusy;
        sram_rd_gnt_sel  <= rgnt_sel5;
        sram_rd_last     <= rbusy & (rlen == {AXI_LEN_WIDTH{1'b0}});

        // Register to break timing path between RAMs
        rfifo_wr_en      <= sram_rd_en;    
        rfifo_wr_gnt_sel <= sram_rd_gnt_sel;
        rfifo_wr_last    <= sram_rd_last;  
        rfifo_wr_data    <= sram_rd_data;
    end
end

// SRAM Read FIFO
ref_sc_fifo_shallow_ram #(

    .ADDR_WIDTH     (RFIFO_ADDR_WIDTH                                   ),
    .DATA_WIDTH     (3 + 1 + AXI_DATA_WIDTH                             ),
    .EN_LOOK_AHEAD  (1                                                  )

) rd_fifo (

    .rst_n          (c2s_areset_n                                       ),
    .clk            (c2s_aclk                                           ),

    .flush          (1'b0                                               ),

    .wr_en          (rfifo_wr_en                                        ),
    .wr_data        ({rfifo_wr_gnt_sel, rfifo_wr_last, rfifo_wr_data}   ),
    .wr_level       (rfifo_wr_level_unused                              ),
    .wr_full        (rfifo_wr_full_unused                               ),

    .rd_ack         (rfifo_rd_en                                        ),
    .rd_data        ({rfifo_rd_gnt_sel, rfifo_rd_last, rfifo_rd_data}   ),
    .rd_level       (rfifo_rd_level_unused                              ),
    .rd_empty       (rfifo_rd_empty                                     )

);  

assign i_tiny_valid = ~rfifo_rd_empty;
assign rfifo_rd_en  = i_tiny_valid & i_tiny_ready;

ref_tiny_fifo #(

    .DATA_WIDTH     (3 + 1 + AXI_DATA_WIDTH                             )

) rd_tiny_fifo(

    .rst_n          (c2s_areset_n                                       ),
    .clk            (c2s_aclk                                           ),

    .in_src_rdy     (i_tiny_valid                                       ),
    .in_dst_rdy     (i_tiny_ready                                       ),
    .in_data        ({rfifo_rd_gnt_sel, rfifo_rd_last, rfifo_rd_data}   ),

    .out_src_rdy    (o_tiny_valid                                       ),
    .out_dst_rdy    (rready                                             ),
    .out_data       ({o_tiny_gnt_sel,   o_tiny_last,   o_tiny_data}     )

);

assign c2s_rvalid[0] = o_tiny_valid & (o_tiny_gnt_sel == 3'h0);
assign c2s_rvalid[1] = o_tiny_valid & (o_tiny_gnt_sel == 3'h1);
assign c2s_rvalid[2] = o_tiny_valid & (o_tiny_gnt_sel == 3'h2);
assign c2s_rvalid[3] = o_tiny_valid & (o_tiny_gnt_sel == 3'h3);
assign c2s_rvalid[4] = o_tiny_valid & (o_tiny_gnt_sel == 3'h4);
assign c2s_rvalid[5] = o_tiny_valid & (o_tiny_gnt_sel == 3'h5);
assign c2s_rvalid[6] = o_tiny_valid & (o_tiny_gnt_sel == 3'h6);
assign c2s_rvalid[7] = o_tiny_valid & (o_tiny_gnt_sel == 3'h7);

assign c2s_rdata = {NUM_C2S{o_tiny_data}};
assign c2s_rlast = {NUM_C2S{o_tiny_last}};

// Read response is always Okay
assign c2s_rresp = {NUM_C2S{2'b00}}; 

always @*
begin
    case (o_tiny_gnt_sel)
      3'h0    : rready = c2s_rready[0];
      3'h1    : rready = c2s_rready[1]; 
      3'h2    : rready = c2s_rready[2]; 
      3'h3    : rready = c2s_rready[3]; 
      3'h4    : rready = c2s_rready[4]; 
      3'h5    : rready = c2s_rready[5]; 
      3'h6    : rready = c2s_rready[6]; 
      default : rready = c2s_rready[7]; 
    endcase
end



// ----------------------------------
// Instantiate DMA Destination Memory

// Assign each byte its own RAM instance
generate for (i=0; i<AXI_BE_WIDTH; i=i+1)
    begin : gen_dma_sram

        ref_inferred_block_ram #(

            .ADDR_WIDTH         (DMA_DEST_ADDR_WIDTH                ),
            .DATA_WIDTH         (8                                  )

        ) dma_sram (

            .wr_clk             (s2c_aclk                           ),
            .wr_addr            (sram_wr_addr                       ),
            .wr_en              (sram_wr_en[i]                      ),
            .wr_data            (sram_wr_data[((i+1)*8)-1:(i*8)]    ),

            .rd_clk             (c2s_aclk                           ),
            .rd_addr            (raddr                              ),
            .rd_data            (sram_rd_data[((i+1)*8)-1:(i*8)]    )

        );
    end
endgenerate



endmodule
