/*******************************************************************************
** © Copyright 2012 - 2013 Xilinx, Inc. All rights reserved.
** This file contains confidential and proprietary information of Xilinx, Inc. and 
** is protected under U.S. and international copyright and other intellectual property laws.
*******************************************************************************
**   ____  ____ 
**  /   /\/   / 
** /___/  \  /   Vendor: Xilinx 
** \   \   \/    
**  \   \        
**  /   /          
** /___/   /\     
** \   \  /  \   Zynq-7 PCIe Targeted Reference Design
**  \___\/\___\ 
** 
**  Device: zc7z045
**  Reference: UG 
*******************************************************************************
**
**  Disclaimer: 
**
**    This disclaimer is not a license and does not grant any rights to the materials 
**    distributed herewith. Except as otherwise provided in a valid license issued to you 
**    by Xilinx, and to the maximum extent permitted by applicable law: 
**    (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, 
**    AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
**    INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR 
**    FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether in contract 
**    or tort, including negligence, or under any other theory of liability) for any loss or damage 
**    of any kind or nature related to, arising under or in connection with these materials, 
**    including for any direct, or any indirect, special, incidental, or consequential loss 
**    or damage (including loss of data, profits, goodwill, or any type of loss or damage suffered 
**    as a result of any action brought by a third party) even if such damage or loss was 
**    reasonably foreseeable or Xilinx had been advised of the possibility of the same.


**  Critical Applications:
**
**    Xilinx products are not designed or intended to be fail-safe, or for use in any application 
**    requiring fail-safe performance, such as life-support or safety devices or systems, 
**    Class III medical devices, nuclear facilities, applications related to the deployment of airbags,
**    or any other applications that could lead to death, personal injury, or severe property or 
**    environmental damage (individually and collectively, "Critical Applications"). Customer assumes 
**    the sole risk and liability of any use of Xilinx products in Critical Applications, subject only 
**    to applicable laws and regulations governing limitations on product liability.

**  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.

*******************************************************************************/

//-----------------------------------------------------------------------------

module user_registers_slave #(
    parameter         C_S_AXI_ADDR_WIDTH  = 32,
    parameter         C_S_AXI_DATA_WIDTH  = 32,
    parameter [31:0]  C_BASE_ADDRESS      = 32'h0000_9000,
    parameter [31:0]  C_HIGH_ADDRESS      = 32'h0000_9FFF,
    parameter [31:0]  C_BASE_ADDRESS_PS   = 32'h4002_0000,
    parameter [31:0]  C_HIGH_ADDRESS_PS   = 32'h4002_FFFF,
    parameter         C_TOTAL_NUM_CE      = 1,
    parameter         C_NUM_ADDRESS_RANGES  = 1,
    parameter         C_S_AXI_MIN_SIZE    = 32'h0000_FFFF,
    parameter         C_S_AXI_MIN_SIZE_PS = 32'h4002_FFFF,
    parameter         C_DPHASE_TIMEOUT    = 32,
    parameter         C_FAMILY            = "zynq"
  ) (
    input                               s_axi_clk,
    input                               s_axi_areset_n,
    input [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr,
    input                               s_axi_awvalid,
    output                              s_axi_awready,
    input [C_S_AXI_DATA_WIDTH-1:0]      s_axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0]  s_axi_wstrb,
    input                               s_axi_wvalid,
    output                              s_axi_wready,
    output [1:0]                        s_axi_bresp,
    output                              s_axi_bvalid,
    input                               s_axi_bready,
    input [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_araddr,
    input                               s_axi_arvalid,
    output                              s_axi_arready,
    output [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata,
    output [1:0]                        s_axi_rresp,
    output                              s_axi_rvalid,
    input                               s_axi_rready,

    input                               s_axi_clk_ps,
    input                               s_axi_areset_n_ps,
    input [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr_ps,
    input                               s_axi_awvalid_ps,
    output                              s_axi_awready_ps,
    input [C_S_AXI_DATA_WIDTH-1:0]      s_axi_wdata_ps,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0]  s_axi_wstrb_ps,
    input                               s_axi_wvalid_ps,
    output                              s_axi_wready_ps,
    output [1:0]                        s_axi_bresp_ps,
    output                              s_axi_bvalid_ps,
    input                               s_axi_bready_ps,
    input [C_S_AXI_ADDR_WIDTH-1:0]      s_axi_araddr_ps,
    input                               s_axi_arvalid_ps,
    output                              s_axi_arready_ps,
    output [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata_ps,
    output [1:0]                        s_axi_rresp_ps,
    output                              s_axi_rvalid_ps,
    input                               s_axi_rready_ps,

    input [31:0]                        tx_pcie_byte_cnt,
    input [31:0]                        rx_pcie_byte_cnt,
    input [31:0]                        tx_pcie_payload_cnt,
    input [31:0]                        rx_pcie_payload_cnt,

    input [11:0]                        init_fc_cpld,
    input [7:0]                         init_fc_cplh,
    input [11:0]                        init_fc_npd,
    input [7:0]                         init_fc_nph,
    input [11:0]                        init_fc_pd,
    input [7:0]                         init_fc_ph,

    output                              enable_checker1 ,
    output                              enable_generator1 ,
    output                              enable_loopback1 ,
    output    [15:0]                    pkt_len1 ,
    input                               data_mismatch1
  
  );

  wire                                  Bus2IP_Clk;
  wire                                  Bus2IP_Resetn;
  wire [(C_S_AXI_ADDR_WIDTH-1):0]       Bus2IP_Addr;
  wire                                  Bus2IP_RNW;
  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]     Bus2IP_BE;
  wire [C_NUM_ADDRESS_RANGES-1:0]       Bus2IP_CS;
  wire [C_TOTAL_NUM_CE-1:0]             Bus2IP_RdCE;
  wire [C_TOTAL_NUM_CE-1:0]             Bus2IP_WrCE;
  wire [C_S_AXI_DATA_WIDTH-1:0]         Bus2IP_Data;
  wire [C_S_AXI_DATA_WIDTH-1:0]         IP2Bus_Data;
  wire                                  IP2Bus_WrAck;
  wire                                  IP2Bus_RdAck;
  wire                                  IP2Bus_Error;

  wire                                  Bus2IP_Clk_ps;
  wire                                  Bus2IP_Resetn_ps;
  wire [(C_S_AXI_ADDR_WIDTH-1):0]       Bus2IP_Addr_ps;
  wire                                  Bus2IP_RNW_ps;
  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]     Bus2IP_BE_ps;
  wire [C_NUM_ADDRESS_RANGES-1:0]       Bus2IP_CS_ps;
  wire [C_TOTAL_NUM_CE-1:0]             Bus2IP_RdCE_ps;
  wire [C_TOTAL_NUM_CE-1:0]             Bus2IP_WrCE_ps;
  wire [C_S_AXI_DATA_WIDTH-1:0]         Bus2IP_Data_ps;
  wire [C_S_AXI_DATA_WIDTH-1:0]         IP2Bus_Data_ps;
  wire                                  IP2Bus_WrAck_ps;
  wire                                  IP2Bus_RdAck_ps;
  wire                                  IP2Bus_Error_ps;

  /*
   *    Instantiation of AXI Lite IPIF Slave which converts the AXI Lite
   *    interface to IPIF
   */
  axi_lite_ipif #(
    .C_S_AXI_DATA_WIDTH     (C_S_AXI_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH     (C_S_AXI_ADDR_WIDTH ),
    .C_S_AXI_MIN_SIZE       (C_S_AXI_MIN_SIZE   ),
    .C_DPHASE_TIMEOUT       (C_DPHASE_TIMEOUT   ),
    .C_NUM_ADDRESS_RANGES   (C_NUM_ADDRESS_RANGES),
    .C_TOTAL_NUM_CE         (C_TOTAL_NUM_CE     ),
    .C_ARD_ADDR_RANGE_ARRAY ({C_BASE_ADDRESS,C_HIGH_ADDRESS}),
    .C_ARD_NUM_CE_ARRAY     ({8'd1}),
    .C_FAMILY               (C_FAMILY           )
  ) axi_lite_ipif_inst_0 (
    .S_AXI_ACLK             (s_axi_clk          ),
    .S_AXI_ARESETN          (s_axi_areset_n     ),
    .S_AXI_AWADDR           (s_axi_awaddr       ),
    .S_AXI_AWVALID          (s_axi_awvalid      ),
    .S_AXI_AWREADY          (s_axi_awready      ),
    .S_AXI_WDATA            (s_axi_wdata        ),
    .S_AXI_WSTRB            (s_axi_wstrb        ),
    .S_AXI_WVALID           (s_axi_wvalid       ),
    .S_AXI_WREADY           (s_axi_wready       ),
    .S_AXI_BRESP            (s_axi_bresp        ),
    .S_AXI_BVALID           (s_axi_bvalid       ),
    .S_AXI_BREADY           (s_axi_bready       ),
    .S_AXI_ARADDR           (s_axi_araddr       ),
    .S_AXI_ARVALID          (s_axi_arvalid      ),
    .S_AXI_ARREADY          (s_axi_arready      ),
    .S_AXI_RDATA            (s_axi_rdata        ),
    .S_AXI_RRESP            (s_axi_rresp        ),
    .S_AXI_RVALID           (s_axi_rvalid       ),
    .S_AXI_RREADY           (s_axi_rready       ),
    .Bus2IP_Clk             (Bus2IP_Clk         ),  
    .Bus2IP_Resetn          (Bus2IP_Resetn      ),  
    .Bus2IP_Addr            (Bus2IP_Addr        ),  
    .Bus2IP_RNW             (Bus2IP_RNW         ),  
    .Bus2IP_BE              (Bus2IP_BE          ),  
    .Bus2IP_CS              (Bus2IP_CS          ),  
    .Bus2IP_RdCE            (Bus2IP_RdCE        ),  
    .Bus2IP_WrCE            (Bus2IP_WrCE        ),  
    .Bus2IP_Data            (Bus2IP_Data        ),  
    .IP2Bus_Data            (IP2Bus_Data        ),  
    .IP2Bus_WrAck           (IP2Bus_WrAck       ),  
    .IP2Bus_RdAck           (IP2Bus_RdAck       ),  
    .IP2Bus_Error           (IP2Bus_Error       )   
  );

  axi_lite_ipif #(
    .C_S_AXI_DATA_WIDTH     (C_S_AXI_DATA_WIDTH ),
    .C_S_AXI_ADDR_WIDTH     (C_S_AXI_ADDR_WIDTH ),
    .C_S_AXI_MIN_SIZE       (C_S_AXI_MIN_SIZE_PS),
    .C_DPHASE_TIMEOUT       (C_DPHASE_TIMEOUT   ),
    .C_NUM_ADDRESS_RANGES   (C_NUM_ADDRESS_RANGES),
    .C_TOTAL_NUM_CE         (C_TOTAL_NUM_CE     ),
    .C_ARD_ADDR_RANGE_ARRAY ({C_BASE_ADDRESS_PS,C_HIGH_ADDRESS_PS}),
    .C_ARD_NUM_CE_ARRAY     ({8'd1}),
    .C_FAMILY               (C_FAMILY           )
  ) axi_lite_ipif_inst_1 (
    .S_AXI_ACLK             (s_axi_clk_ps          ),
    .S_AXI_ARESETN          (s_axi_areset_n_ps     ),
    .S_AXI_AWADDR           (s_axi_awaddr_ps       ),
    .S_AXI_AWVALID          (s_axi_awvalid_ps      ),
    .S_AXI_AWREADY          (s_axi_awready_ps      ),
    .S_AXI_WDATA            (s_axi_wdata_ps        ),
    .S_AXI_WSTRB            (4'hF                  ),
    .S_AXI_WVALID           (s_axi_wvalid_ps       ),
    .S_AXI_WREADY           (s_axi_wready_ps       ),
    .S_AXI_BRESP            (s_axi_bresp_ps        ),
    .S_AXI_BVALID           (s_axi_bvalid_ps       ),
    .S_AXI_BREADY           (s_axi_bready_ps       ),
    .S_AXI_ARADDR           (s_axi_araddr_ps       ),
    .S_AXI_ARVALID          (s_axi_arvalid_ps      ),
    .S_AXI_ARREADY          (s_axi_arready_ps      ),
    .S_AXI_RDATA            (s_axi_rdata_ps        ),
    .S_AXI_RRESP            (s_axi_rresp_ps        ),
    .S_AXI_RVALID           (s_axi_rvalid_ps       ),
    .S_AXI_RREADY           (s_axi_rready_ps       ),
    .Bus2IP_Clk             (Bus2IP_Clk_ps         ),  
    .Bus2IP_Resetn          (Bus2IP_Resetn_ps      ),  
    .Bus2IP_Addr            (Bus2IP_Addr_ps        ),  
    .Bus2IP_RNW             (Bus2IP_RNW_ps         ),  
    .Bus2IP_BE              (Bus2IP_BE_ps          ),  
    .Bus2IP_CS              (Bus2IP_CS_ps          ),  
    .Bus2IP_RdCE            (Bus2IP_RdCE_ps        ),  
    .Bus2IP_WrCE            (Bus2IP_WrCE_ps        ),  
    .Bus2IP_Data            (Bus2IP_Data_ps        ),  
    .IP2Bus_Data            (IP2Bus_Data_ps        ),  
    .IP2Bus_WrAck           (IP2Bus_WrAck_ps       ),  
    .IP2Bus_RdAck           (IP2Bus_RdAck_ps       ),  
    .IP2Bus_Error           (IP2Bus_Error_ps       )   
  );
    /*
     * Register Logic tied to the IPIC interface
     */

  registers registers_inst (
    .Bus2IP_Addr            (Bus2IP_Addr           ),
    .Bus2IP_RNW             (Bus2IP_RNW            ),
    .Bus2IP_CS              (Bus2IP_CS             ),
    .Bus2IP_Data            (Bus2IP_Data           ),
    .IP2Bus_Data            (IP2Bus_Data           ),  
    .IP2Bus_WrAck           (IP2Bus_WrAck          ),  
    .IP2Bus_RdAck           (IP2Bus_RdAck          ),  
    .IP2Bus_Error           (IP2Bus_Error          ),

    .Bus2IP_Addr_ps            (Bus2IP_Addr_ps        ),
    .Bus2IP_RNW_ps             (Bus2IP_RNW_ps         ),
    .Bus2IP_CS_ps              (Bus2IP_CS_ps          ),
    .Bus2IP_Data_ps            (Bus2IP_Data_ps        ),
    .IP2Bus_Data_ps            (IP2Bus_Data_ps        ),  
    .IP2Bus_WrAck_ps           (IP2Bus_WrAck_ps       ),  
    .IP2Bus_RdAck_ps           (IP2Bus_RdAck_ps       ),  
    .IP2Bus_Error_ps           (IP2Bus_Error_ps       ),

    .tx_pcie_byte_cnt       (tx_pcie_byte_cnt   ),
    .rx_pcie_byte_cnt       (rx_pcie_byte_cnt   ),
    .tx_pcie_payload_cnt    (tx_pcie_payload_cnt),
    .rx_pcie_payload_cnt    (rx_pcie_payload_cnt),

    .init_fc_cpld           (init_fc_cpld          ),
    .init_fc_cplh           (init_fc_cplh          ),
    .init_fc_npd            (init_fc_npd           ),
    .init_fc_nph            (init_fc_nph           ),
    .init_fc_pd             (init_fc_pd            ),
    .init_fc_ph             (init_fc_ph            ),  

    .enable_checker1        (enable_checker1       ),
    .enable_generator1      (enable_generator1     ),
    .enable_loopback1       (enable_loopback1      ),
    .pkt_len1               (pkt_len1              ),
    .data_mismatch1         (data_mismatch1        ),
    
    .Clk                    (Bus2IP_Clk            ),
    .Resetn                 (Bus2IP_Resetn         )
  );

endmodule
