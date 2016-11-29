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

module registers #(
  parameter ADDR_WIDTH  = 32,
  parameter DATA_WIDTH  = 32
) (
    //-IPIC Interface

  input [ADDR_WIDTH-1:0]        Bus2IP_Addr,
  input                         Bus2IP_RNW,
  input                         Bus2IP_CS,
  input [DATA_WIDTH-1:0]        Bus2IP_Data,
  output reg [DATA_WIDTH-1:0]   IP2Bus_Data,
  output reg                    IP2Bus_WrAck,
  output reg                    IP2Bus_RdAck,
  output                        IP2Bus_Error,

  input [ADDR_WIDTH-1:0]        Bus2IP_Addr_ps,
  input                         Bus2IP_RNW_ps,
  input                         Bus2IP_CS_ps,
  input [DATA_WIDTH-1:0]        Bus2IP_Data_ps,
  output reg [DATA_WIDTH-1:0]   IP2Bus_Data_ps,
  output reg                    IP2Bus_WrAck_ps,
  output reg                    IP2Bus_RdAck_ps,
  output                        IP2Bus_Error_ps,

    //- User registers
  input [31:0]                  tx_pcie_byte_cnt,
  input [31:0]                  rx_pcie_byte_cnt,
  input [31:0]                  tx_pcie_payload_cnt,
  input [31:0]                  rx_pcie_payload_cnt,

  input [11:0]                  init_fc_cpld,
  input [7:0]                   init_fc_cplh,
  input [11:0]                  init_fc_npd,
  input [7:0]                   init_fc_nph,
  input [11:0]                  init_fc_pd,
  input [7:0]                   init_fc_ph,
 
  output reg                    enable_checker1 = 0,
  output reg                    enable_generator1 = 0,
  output reg                    enable_loopback1 = 0,
  output reg  [15:0]            pkt_len1 = 'd768,
  input                         data_mismatch1,
 
  //- System signals
  input                         Clk,
  input                         Resetn
);

  //- Address offset definitions
  localparam [15:0] 
        //- Design Info registers
      DESIGN_VERSION      = 16'h9000,
        //- PCIe Performance Monitor
      TX_PCIE_BYTE_CNT    = 16'h900C,
      RX_PCIE_BYTE_CNT    = 16'h9010,
      TX_PCIE_PAYLOAD_CNT = 16'h9014,
      RX_PCIE_PAYLOAD_CNT = 16'h9018,
      INIT_FC_CPLD        = 16'h901C,
      INIT_FC_CPLH        = 16'h9020,
      INIT_FC_NPD         = 16'h9024,
      INIT_FC_NPH         = 16'h9028,
      INIT_FC_PD          = 16'h902C,
      INIT_FC_PH          = 16'h9030,
      
      PCIE_CAP_REG        = 16'h9034,
      PCIE_STS_REG        = 16'h903C, 
        //- PCIe-DMA Performance GEN/CHK - 0
      APP0_SOBEL_CTRL     = 16'h9100,
      APP0_OFFLOAD_CTRL   = 16'h9104,
      APP0_DISPLAY_CTRL   = 16'h9108,
        //- PCIe-DMA Performance GEN/CHK - 1
      APP1_ENABLE_GEN     = 16'h9200,
      APP1_PKT_LEN        = 16'h9204,
      APP1_ENABLE_LB_CHK  = 16'h9208,
      APP1_CHK_STATUS     = 16'h920C,
      
      PS_STATUS            = 16'h9400,
      PS_CONTROL           = 16'h9404,
      HOST_STATUS          = 16'h9300,
      HOST_CONTROL         = 16'h9304;

  wire [31:0]  pcie_cap_reg;
  wire [31:0]  pcie_sts_reg;

  reg  [31:0]  app0_sobel_ctrl_r   =  32'd0;
  reg  [31:0]  app0_offload_ctrl_r =  32'd0;
  reg  [31:0]  app0_display_ctrl_r =  32'd0;
  reg  [31:0]  app0_test_ctrl_r =  32'd0;
  reg  [31:0]  ps_status_r =  32'd0;
  reg  [31:0]  ps_control_r =  32'd0;
  reg  [31:0]  host_status_r =  32'd0;
  reg  [31:0]  host_control_r =  32'd0;

  assign IP2Bus_Error    = 1'b0;
  assign IP2Bus_Error_ps = 1'b0;

 /*
  * On the assertion of CS, RNW port is checked for read or a write
  * transaction. 
  * In case of a write transaction, the relevant register is written to and
  * WrAck generated.
  * In case of reads, the read data along with RdAck is generated.
  */
 
  always @(posedge Clk)
    if (Resetn == 1'b0)
    begin
      IP2Bus_Data   <= 32'd0;
      IP2Bus_WrAck  <= 1'b0;
      IP2Bus_RdAck  <= 1'b0;

      enable_generator1<= 1'b0;
      enable_checker1  <= 1'b0;
      enable_loopback1 <= 1'b1;
      pkt_len1 <= 16'd4096;
      app0_sobel_ctrl_r   <=  32'b0;
      app0_offload_ctrl_r <=  32'b0;
      app0_display_ctrl_r <=  32'b0;
      host_control_r <=  32'b0;
      host_status_r <=  32'b0;

    end
    else
    begin
        //- Write transaction
      if (Bus2IP_CS & ~Bus2IP_RNW)
      begin
       if(Bus2IP_Addr[15:8]=='h91)
        case (Bus2IP_Addr[7:0])
          APP0_SOBEL_CTRL[7:0]     : app0_sobel_ctrl_r   <= Bus2IP_Data;
          APP0_OFFLOAD_CTRL[7:0]   : app0_offload_ctrl_r <= Bus2IP_Data;
          APP0_DISPLAY_CTRL[7:0]   : app0_display_ctrl_r <= Bus2IP_Data;
        endcase
       else if(Bus2IP_Addr[15:8]=='h93)
        case (Bus2IP_Addr[7:0])
          HOST_CONTROL[7:0]     : host_control_r   <= Bus2IP_Data;
          HOST_STATUS[7:0]      : host_status_r <= Bus2IP_Data;
        endcase
       else if(Bus2IP_Addr[15:8]=='h92)
        case (Bus2IP_Addr[7:0])
          APP1_ENABLE_GEN[7:0] : enable_generator1  <= Bus2IP_Data[0];
          APP1_PKT_LEN[7:0]    : pkt_len1  <= Bus2IP_Data[15:0];
          APP1_ENABLE_LB_CHK[7:0]: begin
                                    enable_checker1 <= Bus2IP_Data[0];
                                    enable_loopback1<= Bus2IP_Data[1];
                                   end
        endcase
        IP2Bus_WrAck  <= 1'b1;
        IP2Bus_Data   <= 32'd0;
        IP2Bus_RdAck  <= 1'b0;  
      end
        //- Read transaction
      else if (Bus2IP_CS & Bus2IP_RNW)
      begin
       if(Bus2IP_Addr[15:8]=='h90) 
        case (Bus2IP_Addr[7:0])
            /* [31:20] : Rsvd
             * [19:16] : Device, 0 -> A7, 1 -> K7, 2 -> V7, 3-> Z7, 
             * [15:8]  : DMA version (major, minor)
             * [7:0]   : Design version (major, minor)
             */
          DESIGN_VERSION[7:0]  : IP2Bus_Data <= {12'd0,4'h3,8'h11,8'h17};
          TX_PCIE_BYTE_CNT[7:0] : IP2Bus_Data <= tx_pcie_byte_cnt;
          RX_PCIE_BYTE_CNT[7:0] : IP2Bus_Data <= rx_pcie_byte_cnt;
          TX_PCIE_PAYLOAD_CNT[7:0]: IP2Bus_Data <= tx_pcie_payload_cnt;
          RX_PCIE_PAYLOAD_CNT[7:0]: IP2Bus_Data <= rx_pcie_payload_cnt;
          INIT_FC_CPLD[7:0]  : IP2Bus_Data <= {20'd0,init_fc_cpld};
          INIT_FC_CPLH[7:0]  : IP2Bus_Data <= {24'd0,init_fc_cplh};
          INIT_FC_NPD[7:0]  : IP2Bus_Data <= {20'd0,init_fc_npd};
          INIT_FC_NPH[7:0]  : IP2Bus_Data <= {24'd0,init_fc_nph};
          INIT_FC_PD[7:0]  : IP2Bus_Data <= {20'd0,init_fc_pd};
          INIT_FC_PH[7:0]  : IP2Bus_Data <= {24'd0,init_fc_ph};
          
          PCIE_CAP_REG[7:0]    : IP2Bus_Data <= pcie_cap_reg;
          PCIE_STS_REG[7:0]    : IP2Bus_Data  <= pcie_sts_reg;

        endcase
       else if(Bus2IP_Addr[15:8]=='h91)
        case (Bus2IP_Addr[7:0])
          APP0_SOBEL_CTRL[7:0]     : IP2Bus_Data <= app0_sobel_ctrl_r;
          APP0_OFFLOAD_CTRL[7:0]   : IP2Bus_Data <= app0_offload_ctrl_r;
          APP0_DISPLAY_CTRL[7:0]  : IP2Bus_Data <= app0_display_ctrl_r;
        endcase
       else if(Bus2IP_Addr[15:8]=='h92)
        case (Bus2IP_Addr[7:0])
          APP1_ENABLE_GEN[7:0]     : IP2Bus_Data <= {31'd0,enable_generator1};
          APP1_PKT_LEN[7:0]        : IP2Bus_Data <= {16'd0,pkt_len1};
          APP1_ENABLE_LB_CHK[7:0]  : IP2Bus_Data <= {30'd0,enable_loopback1,enable_checker1};
          APP1_CHK_STATUS[7:0]     : IP2Bus_Data <= {31'd0,data_mismatch1}; 
        endcase
       else if(Bus2IP_Addr[15:8]=='h94)
        case (Bus2IP_Addr[7:0])
          PS_STATUS[7:0]     :       IP2Bus_Data      <= ps_status_r ;
          PS_CONTROL[7:0]     :       IP2Bus_Data      <= ps_control_r ;
        endcase
       else if(Bus2IP_Addr[15:8]=='h93)
        case (Bus2IP_Addr[7:0])
          HOST_CONTROL[7:0]     : IP2Bus_Data <= host_control_r;
          HOST_STATUS[7:0]      : IP2Bus_Data <= host_status_r ;
        endcase
        IP2Bus_RdAck  <= 1'b1;
        IP2Bus_WrAck  <= 1'b0;
      end
      else
      begin
        IP2Bus_Data   <= 32'd0;
        IP2Bus_WrAck  <= 1'b0;
        IP2Bus_RdAck  <= 1'b0;
      end
    end
 
 /*
  * On the assertion of CS, RNW port is checked for read or a write
  * transaction. 
  * In case of a write transaction, the relevant register is written to and
  * WrAck generated.
  * In case of reads, the read data along with RdAck is generated.
  */
 
  always @(posedge Clk)
    if (Resetn == 1'b0)
    begin
      IP2Bus_Data_ps   <= 32'd0;
      IP2Bus_WrAck_ps  <= 1'b0;
      IP2Bus_RdAck_ps  <= 1'b0;
      ps_control_r <=  32'b0;
      ps_status_r <=  32'b0;
    end
    else 
    begin
    if (Bus2IP_CS_ps & ~Bus2IP_RNW_ps)
    begin
       if((Bus2IP_Addr_ps[31:16]=='h4002) && (Bus2IP_Addr_ps[15:8]=='h94))
        case (Bus2IP_Addr_ps[7:0])
          PS_STATUS[7:0]     : ps_status_r   <= Bus2IP_Data_ps;
          PS_CONTROL[7:0]     : ps_control_r   <= Bus2IP_Data_ps;
        endcase
        IP2Bus_WrAck_ps  <= 1'b1;
        IP2Bus_Data_ps   <= 32'd0;
        IP2Bus_RdAck_ps  <= 1'b0;  
    end
        //- Read transaction
    else if (Bus2IP_CS_ps & Bus2IP_RNW_ps)
    begin
       if((Bus2IP_Addr_ps[31:16]=='h4002) && (Bus2IP_Addr_ps[15:8]=='h90)) 
        case (Bus2IP_Addr_ps[7:0])
            /* [31:20] : Rsvd
             * [19:16] : Device, 0 -> A7, 1 -> K7, 2 -> V7, 3 -> Z7, 
             * [15:8]  : DMA version (major, minor)
             * [7:0]   : Design version (major, minor)
             */
          DESIGN_VERSION[7:0]  : IP2Bus_Data_ps <= {12'd0,4'h3,8'h11,8'h17};
        endcase
       else if((Bus2IP_Addr_ps[31:16]=='h4002) && (Bus2IP_Addr_ps[15:8]=='h91))
        case (Bus2IP_Addr_ps[7:0])
          APP0_SOBEL_CTRL[7:0]     : IP2Bus_Data_ps <= app0_sobel_ctrl_r;
          APP0_OFFLOAD_CTRL[7:0]   : IP2Bus_Data_ps <= app0_offload_ctrl_r;
          APP0_DISPLAY_CTRL[7:0]   : IP2Bus_Data_ps <= app0_display_ctrl_r;
        endcase
       else if((Bus2IP_Addr_ps[31:16]=='h4002) && (Bus2IP_Addr_ps[15:8]=='h93))
        case (Bus2IP_Addr_ps[7:0])
          HOST_STATUS[7:0]     :       IP2Bus_Data_ps  <= host_status_r;
          HOST_CONTROL[7:0]     :       IP2Bus_Data_ps  <= host_control_r;
        endcase
       else if((Bus2IP_Addr_ps[31:16]=='h4002) && (Bus2IP_Addr_ps[15:8]=='h94))
        case (Bus2IP_Addr_ps[7:0])
          PS_STATUS[7:0]     :       IP2Bus_Data_ps  <= ps_status_r ;
          PS_CONTROL[7:0]     :       IP2Bus_Data_ps  <= ps_control_r;
        endcase
        IP2Bus_RdAck_ps  <= 1'b1;
        IP2Bus_WrAck_ps  <= 1'b0;
    end
    else
    begin
        IP2Bus_Data_ps   <= 32'd0;
        IP2Bus_WrAck_ps  <= 1'b0;
        IP2Bus_RdAck_ps  <= 1'b0;
    end
    end
 
endmodule
