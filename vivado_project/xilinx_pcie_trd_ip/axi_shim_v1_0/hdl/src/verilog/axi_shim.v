//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information of Xilinx, Inc.
// and is protected under U.S. and international copyright and other
// intellectual property laws.
//
// DISCLAIMER
//
// This disclaimer is not a license and does not grant any rights to the
// materials distributed herewith. Except as otherwise provided in a valid
// license issued to you by Xilinx, and to the maximum extent permitted by
// applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
// FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
// IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
// MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
// and (2) Xilinx shall not be liable (whether in contract or tort, including
// negligence, or under any other theory of liability) for any loss or damage
// of any kind or nature related to, arising under or in connection with these
// materials, including for any direct, or any indirect, special, incidental,
// or consequential loss or damage (including loss of data, profits, goodwill,
// or any type of loss or damage suffered as a result of any action brought by
// a third party) even if such damage or loss was reasonably foreseeable or
// Xilinx had been advised of the possibility of the same.
//
// CRITICAL APPLICATIONS
//
// Xilinx products are not designed or intended to be fail-safe, or for use in
// any application requiring fail-safe performance, such as life-support or
// safety devices or systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any other
// applications that could lead to death, personal injury, or severe property
// or environmental damage (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and liability of any use of
// Xilinx products in Critical Applications, subject only to applicable laws
// and regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
// AT ALL TIMES.
//
//-----------------------------------------------------------------------------

module axi_shim 
(
   input            user_clk,
  // Input AXI4-Lite interface
   input            t_awvalid,
   input  [31:0]    t_awaddr,
   input  [3:0]     t_awlen,
   input  [2:0]     t_awregion,
   input  [2:0]     t_awsize,
   output           t_awready,
   input            t_wvalid,
   input  [63:0]    t_wdata,
   input  [7:0]     t_wstrb,
   input            t_wlast,
   output           t_wready,
   output           t_bvalid,
   input            t_bready,
   output [1:0]     t_bresp,
   input            t_arvalid,
   input  [31:0]    t_araddr,
   input  [3:0]     t_arlen,
   input  [2:0]     t_arregion,
   input  [2:0]     t_arsize,
   output           t_arready,
   output           t_rvalid,
   input            t_rready,
   output   [63:0]  t_rdata,
   output   [1:0]   t_rresp,
   output           t_rlast,
  // Output AXI4-Lite interface
   output           s_axi_awvalid,
   output  [31:0]   s_axi_awaddr,
   input            s_axi_awready,
   output           s_axi_wvalid,
   output  [31:0]   s_axi_wdata,
   output  [3:0]    s_axi_wstrb,
   input            s_axi_wready,
   input            s_axi_bvalid,
   output           s_axi_bready,
   input   [1:0]    s_axi_bresp,
   output           s_axi_arvalid,
   input            s_axi_arready,
   output  [31:0]   s_axi_araddr,
   input            s_axi_rvalid,
   output           s_axi_rready,
   input   [31:0]   s_axi_rdata,
   input   [1:0]    s_axi_rresp
);

  reg  [3:0]  rd_addr_nibble = 4'd0;
  wire t_rlast_i;
  
  /********* SHIM FOR TARGET AXI to AXI-LITE connection ***********/

    //- This shim enabless the 64-bit target AXI master to connect to
    //- 32-bit AXILITE interconnect
    //- All register operations issued by software are read-modify-write
    //- operations i.e. access to all bits of one entire register 

    /*
      In case of writes, it puts the appropriate 32-bit data slice based on
      value of wstrb. 
          wstrb         wdata bit locations
          ---------------------------------
          [0] = 1       [31:0]
          [4] = 1       [63:32]
          ---------------------------------
          
      In case of reads, it places the 32-bit read data value in the
      appropriate segment in the 64-bit read data bus based on the read
      address' lowest nibble value.
          araddr[3:0]     rdata segment
          -----------------------------
           4'b0000      [31:0]
           4'b0100      [63:32]
          -----------------------------     */

assign s_axi_awaddr = {16'd0,t_awaddr[15:0]};
assign t_awready    = s_axi_awready;
assign s_axi_awvalid= t_awvalid;

//- Extract out valid write data based on strobe
assign s_axi_wdata = t_wstrb[0] ? t_wdata[31:0] : t_wdata[63:32] ;
assign s_axi_wstrb  = 4'b1111;
assign s_axi_wvalid = t_wvalid;
assign t_wready     = s_axi_wready;

assign t_bvalid     = s_axi_bvalid;
assign s_axi_bready = t_bready;
assign t_bresp      = s_axi_bresp;

assign s_axi_arvalid= t_arvalid;
assign s_axi_araddr = {16'd0,t_araddr[15:0]};
assign t_arready    = s_axi_arready;

assign t_rvalid     = s_axi_rvalid;
assign s_axi_rready = t_rready;

//- Latch onto the read address lowest nibble
always @(posedge user_clk)
  if (t_arvalid & t_arready)
    rd_addr_nibble  <= t_araddr[3:0];
    
//- Place the read 32-bit data into the appropriate 64-bit rdata
//  location based on address nibble latched above
assign t_rdata = (rd_addr_nibble == 4'h4) ? {s_axi_rdata,32'd0} :
                 (rd_addr_nibble == 4'hC) ? {s_axi_rdata,32'd0} :
                 {32'd0,s_axi_rdata};

assign t_rresp = s_axi_rresp;                 
assign t_rlast = t_rlast_i;

endmodule
