// -------------------------------------------------------------------------
//
//  PROJECT: PCI Express Core
//  COMPANY: Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//             (c) Copyright 2009 by Northwest Logic, Inc.
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

module report_assertions (

    core_rst_n,
    core_clk,

    mgmt_pcie_status
);



// ----------------------
// -- Port Definitions --
// ----------------------

input                               core_rst_n;
input                               core_clk;

input   [1535:0]                    mgmt_pcie_status;


// ----------------
// -- Port Types --
// ----------------

wire                                core_rst_n;
wire                                core_clk;

wire    [1535:0]                    mgmt_pcie_status;


// -------------------
// -- Local Signals --
// -------------------

wire                                pl_link_up;
wire                                dl_link_up;
wire    [5:0]                       neg_link_w;
wire    [1:0]                       link_speed;
wire    [5:0]                       state;
wire    [15:0]                      sub_state;
wire    [2:0]                       rx_l0s_state;
wire    [4:0]                       pm_state;
wire    [3:0]                       mgmt_lane_rev_status;

reg                                 r_pl_link_up;
reg                                 r_dl_link_up;
reg     [5:0]                       r_neg_link_w;
reg     [1:0]                       r_link_speed;
reg     [5:0]                       r_state;
reg     [15:0]                      r_sub_state;
reg     [2:0]                       r_rx_l0s_state;
reg     [4:0]                       r_pm_state;
reg     [3:0]                       r_mgmt_lane_rev_status;

reg                                 expect_malformed_tlp;
reg                                 expect_poisoned_tlp;
reg                                 expect_tx_completer_abort;
reg                                 expect_rx_completer_abort;
reg                                 expect_unsupported_request;
reg                                 expect_unexpected_completion;
reg                                 expect_nak;
reg                                 expect_physical_error;
reg                                 expect_replay_timeout;
reg                                 expect_ecrc_failure;
reg                                 expect_completion_timeout;
reg                                 expect_completer_abort;
reg                                 expect_ucorr_internal_error;



// ---------------
// -- Equations --
// ---------------

// Initialize expect regs
initial
begin
    expect_malformed_tlp         = 1'b0;
    expect_poisoned_tlp          = 1'b0;
    expect_tx_completer_abort    = 1'b0;
    expect_rx_completer_abort    = 1'b0;
    expect_unsupported_request   = 1'b0;
    expect_unexpected_completion = 1'b0;
    expect_nak                   = 1'b0;
    expect_physical_error        = 1'b0;
    expect_replay_timeout        = 1'b0;
    expect_ecrc_failure          = 1'b0;
    expect_completion_timeout    = 1'b0;
    expect_completer_abort       = 1'b0;
    expect_ucorr_internal_error  = 1'b0;
end

assign pl_link_up           = mgmt_pcie_status[0];
assign dl_link_up           = mgmt_pcie_status[1];
assign neg_link_w           = mgmt_pcie_status[31:26];
assign link_speed           = mgmt_pcie_status[25:24];

assign state                = mgmt_pcie_status[  7:  2]; // lts_state
assign mgmt_lane_rev_status = mgmt_pcie_status[943:940]; // Lane Reversal Status[3:0]
assign sub_state            = mgmt_pcie_status[959:944]; // lts_state - substate
assign rx_l0s_state         = mgmt_pcie_status[930:928]; // rx_l0s lts_state
assign pm_state             = mgmt_pcie_status[923:919]; // pm_state

// Report assertions recorded in mgmt_pcie_status bus
always @(posedge core_clk or negedge core_rst_n)
begin
    if (core_rst_n == 1'b0)
    begin
        r_pl_link_up           <= 1'b0;
        r_dl_link_up           <= 1'b0;
        r_neg_link_w           <= 6'h0;
        r_link_speed           <= 2'b0;
        r_state                <= 6'h3f;    // Want to not be a valid state; so entry into DETECT is reported
        r_sub_state            <= 16'h1;    // Default to INACTIVE
        r_rx_l0s_state         <= 2'd0;     // Default to RX_LOS_L0
        r_pm_state             <= 5'd0;     // Default to IDLE
        r_mgmt_lane_rev_status <= 4'h0;
    end
    else
    begin
        r_pl_link_up           <= pl_link_up;
        r_dl_link_up           <= dl_link_up;
        r_neg_link_w           <= neg_link_w;
        r_link_speed           <= link_speed;
        r_state                <= state;
        r_sub_state            <= sub_state;
        r_rx_l0s_state         <= rx_l0s_state;
        r_pm_state             <= pm_state;
        r_mgmt_lane_rev_status <= mgmt_lane_rev_status;
    end
end

always @(posedge core_clk)
begin
    if (core_rst_n == 1'b1)
    begin
        // pl_link_up edge detect
        if (pl_link_up & ~r_pl_link_up)
            $display  ("%m : INFO : pl_link_up rising edge; time %t", $time);

        if (~pl_link_up & r_pl_link_up)
            $display  ("%m : INFO : pl_link_up falling edge; time %t", $time);

        // dl_link_up edge detect
        if (dl_link_up  & ~r_dl_link_up)
            $display  ("%m : INFO : dl_link_up rising edge; time %t", $time);

        if (~dl_link_up & r_dl_link_up)
            $display  ("%m : INFO : dl_link_up falling edge; time %t", $time);

        // Negotiated Link Speed change
        if (link_speed != r_link_speed)
        begin
            $display  ("%m : INFO : Negotiated Link Speed change; was %s; now %s; time %t",
                       (r_link_speed == 2'b10) ? "8g" : ((r_link_speed == 2'b01) ? "5g" : "2.5g"),
                       (link_speed   == 2'b10) ? "8g" : ((link_speed   == 2'b01) ? "5g" : "2.5g"),
                       $time);
        end

        // Negotiated Link Width change
        if (neg_link_w != r_neg_link_w)
        begin
            if (r_neg_link_w == 6'h0) // Undefined
                $display  ("%m : INFO : Negotiated Link Width change; was undefined; now x%d; time %t", neg_link_w, $time);
            else if (neg_link_w == 6'h0) // Undefined
                $display  ("%m : INFO : Negotiated Link Width change; was x%d; now undefined; time %t", r_neg_link_w, $time);
            else
                $display  ("%m : INFO : Negotiated Link Width change; was x%d; now x%d; time %t", r_neg_link_w, neg_link_w, $time);
        end

        if (mgmt_lane_rev_status != r_mgmt_lane_rev_status)
        begin
            $display  ("%m : INFO : Lane Reversal Status [x8_Rev, x4_Rev, x2_Rev, Full_Rev] Change; was [%d,%d,%d,%d]; now [%d,%d,%d,%d] : time %t",
                             r_mgmt_lane_rev_status[3], r_mgmt_lane_rev_status[2], r_mgmt_lane_rev_status[1], r_mgmt_lane_rev_status[0],
                               mgmt_lane_rev_status[3],   mgmt_lane_rev_status[2],   mgmt_lane_rev_status[1],   mgmt_lane_rev_status[0], $time);
        end

        if (state != r_state)
        begin
            case (state)
                4'h0    : $display  ("%m : INFO : Change to DETECT        : time %t", $time);
                4'h1    : $display  ("%m : INFO : Change to POLLING       : time %t", $time);
                4'h2    : $display  ("%m : INFO : Change to CFG           : time %t", $time);
                4'h3    : $display  ("%m : INFO : Change to L0            : time %t", $time);
                4'h4    : $display  ("%m : INFO : Change to REC           : time %t", $time);
                4'h5    : $display  ("%m : INFO : Change to DISABLE       : time %t", $time);
                4'h6    : $display  ("%m : INFO : Change to LOOPBACK      : time %t", $time);
                4'h7    : $display  ("%m : INFO : Change to HOT_RESET     : time %t", $time);
                4'h8    : $display  ("%m : INFO : Change to TX_L0S        : time %t", $time);
                4'h9    : $display  ("%m : INFO : Change to L1            : time %t", $time);
                4'ha    : $display  ("%m : INFO : Change to L2            : time %t", $time);
                default : $display  ("%m : ERROR : Change to UNKNOWN STATE : time %t", $time);
            endcase
        end

        if (pm_state != r_pm_state)
        begin
            case (pm_state)
                5'h0    : $display  ("%m : INFO : Change to PM_IDLE           : time %t", $time);
                5'h1    : $display  ("%m : INFO : Change to PM_L1_WAIT_IDLE   : time %t", $time);
                5'h2    : $display  ("%m : INFO : Change to PM_L1_WAIT_REPLAY : time %t", $time);
                5'h3    : $display  ("%m : INFO : Change to PM_L1_READY       : time %t", $time);
                5'h4    : $display  ("%m : INFO : Change to PM_L1_STOP_DLLP   : time %t", $time);
                5'h5    : $display  ("%m : INFO : Change to PM_L1             : time %t", $time);
                5'h6    : $display  ("%m : INFO : Change to PM_L1_1           : time %t", $time);
                5'h7    : $display  ("%m : INFO : Change to PM_L1_2_ENTRY     : time %t", $time);
                5'h8    : $display  ("%m : INFO : Change to PM_L1_2_IDLE      : time %t", $time);
                5'h9    : $display  ("%m : INFO : Change to PM_L1_2_EXIT      : time %t", $time);
                5'ha    : $display  ("%m : INFO : Change to PM_L1_EXIT        : time %t", $time);
                5'hb    : $display  ("%m : INFO : Change to PM_L2_WAIT_IDLE   : time %t", $time);
                5'hc    : $display  ("%m : INFO : Change to PM_L2_WAIT_REPLAY : time %t", $time);
                5'hd    : $display  ("%m : INFO : Change to PM_L23_READY      : time %t", $time);
                5'he    : $display  ("%m : INFO : Change to PM_L2_STOP_DLLP   : time %t", $time);
                5'hf    : $display  ("%m : INFO : Change to PM_L2             : time %t", $time);
                5'h10   : $display  ("%m : INFO : Change to PM_L0S            : time %t", $time);
                default : $display  ("%m : ERROR : Change to PM_UNKNOWN : time %t", $time);
            endcase
        end

        if (rx_l0s_state != r_rx_l0s_state)
        begin
            case (rx_l0s_state)
                4'h0    : $display  ("%m : INFO : Change to RX_L0S_L0      : time %t", $time);
                4'h1    : $display  ("%m : INFO : Change to RX_L0S_ENTRY   : time %t", $time);
                4'h2    : $display  ("%m : INFO : Change to RX_L0S_IDLE    : time %t", $time);
                4'h3    : $display  ("%m : INFO : Change to RX_L0S_FTS     : time %t", $time);
                4'h4    : $display  ("%m : INFO : Change to RX_L0S_REC     : time %t", $time);
                default : $display  ("%m : ERROR : Change to RX_LOS_UNKNOWN : time %t", $time);
            endcase
        end

        if ((sub_state != r_sub_state) & (sub_state != 0) & !$test$plusargs("pcie_substate_msgs_off"))
        begin
            case (state)
                4'h0    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate DETECT_INACTIVE   : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate DETECT_QUIET      : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate DETECT_SPD_CHG0   : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate DETECT_SPD_CHG1   : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate DETECT_ACTIVE0    : time %t", $time);
                                    16'b00000100000 : $display  ("%m : INFO : Change to substate DETECT_ACTIVE1    : time %t", $time);
                                    16'b00001000000 : $display  ("%m : INFO : Change to substate DETECT_ACTIVE2    : time %t", $time);
                                    16'b00010000000 : $display  ("%m : INFO : Change to substate DETECT_P1_TO_P0   : time %t", $time);
                                    16'b00100000000 : $display  ("%m : INFO : Change to substate DETECT_P0_TO_P1_0 : time %t", $time);
                                    16'b01000000000 : $display  ("%m : INFO : Change to substate DETECT_P0_TO_P1_1 : time %t", $time);
                                    16'b10000000000 : $display  ("%m : INFO : Change to substate DETECT_P0_TO_P1_2 : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'h1    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate POLLING_INACTIVE      : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate POLLING_ACTIVE_ENTRY  : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate POLLING_ACTIVE        : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate POLLING_CFG           : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate POLLING_COMP          : time %t", $time);
                                    16'b00000100000 : $display  ("%m : INFO : Change to substate POLLING_COMP_ENTRY    : time %t", $time);
                                    16'b00001000000 : $display  ("%m : INFO : Change to substate POLLING_COMP_EIOS     : time %t", $time);
                                    16'b00010000000 : $display  ("%m : INFO : Change to substate POLLING_COMP_EIOS_ACK : time %t", $time);
                                    16'b00100000000 : $display  ("%m : INFO : Change to substate POLLING_COMP_IDLE     : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE     : time %t", $time);
                                endcase
                            end
                4'h2    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate CFG_INACTIVE      : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate CFG_US_LW_START   : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate CFG_US_LW_ACCEPT  : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate CFG_US_LN_WAIT    : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate CFG_US_LN_ACCEPT  : time %t", $time);
                                    16'b00000100000 : $display  ("%m : INFO : Change to substate CFG_DS_LW_START   : time %t", $time);
                                    16'b00001000000 : $display  ("%m : INFO : Change to substate CFG_DS_LW_ACCEPT  : time %t", $time);
                                    16'b00010000000 : $display  ("%m : INFO : Change to substate CFG_DS_LN_WAIT    : time %t", $time);
                                    16'b00100000000 : $display  ("%m : INFO : Change to substate CFG_DS_LN_ACCEPT  : time %t", $time);
                                    16'b01000000000 : $display  ("%m : INFO : Change to substate CFG_COMPLETE      : time %t", $time);
                                    16'b10000000000 : $display  ("%m : INFO : Change to substate CFG_IDLE          : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'h3    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate L0_INACTIVE       : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate L0                : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate L0_TX_EL_IDLE     : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate L0_TX_IDLE_MIN    : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'h4    :   begin
                                case (sub_state)
                                    16'b000000000001: $display  ("%m : INFO : Change to substate REC_INACTIVE      : time %t", $time);
                                    16'b000000000010: $display  ("%m : INFO : Change to substate REC_RCVR_LOCK     : time %t", $time);
                                    16'b000000000100: $display  ("%m : INFO : Change to substate REC_RCVR_CFG      : time %t", $time);
                                    16'b000000001000: $display  ("%m : INFO : Change to substate REC_IDLE          : time %t", $time);
                                    16'b000000010000: $display  ("%m : INFO : Change to substate REC_SPEED0        : time %t", $time);
                                    16'b000000100000: $display  ("%m : INFO : Change to substate REC_SPEED1        : time %t", $time);
                                    16'b000001000000: $display  ("%m : INFO : Change to substate REC_SPEED2        : time %t", $time);
                                    16'b000010000000: $display  ("%m : INFO : Change to substate REC_SPEED3        : time %t", $time);
                                    16'b000100000000: $display  ("%m : INFO : Change to substate REC_EQ_PH0        : time %t", $time);
                                    16'b001000000000: $display  ("%m : INFO : Change to substate REC_EQ_PH1        : time %t", $time);
                                    16'b010000000000: $display  ("%m : INFO : Change to substate REC_EQ_PH2        : time %t", $time);
                                    16'b100000000000: $display  ("%m : INFO : Change to substate REC_EQ_PH3        : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'h5    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate DISABLE_INACTIVE  : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate DISABLE0          : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate DISABLE1          : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate DISABLE2          : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate DISABLE3          : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'h6    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate LOOPBACK_INACTIVE   : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate LOOPBACK_ENTRY      : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate LOOPBACK_ENTRY_EXIT : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate LOOPBACK_EIOS       : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate LOOPBACK_EIOS_ACK   : time %t", $time);
                                    16'b00000100000 : $display  ("%m : INFO : Change to substate LOOPBACK_IDLE       : time %t", $time);
                                    16'b00001000000 : $display  ("%m : INFO : Change to substate LOOPBACK_ACTIVE     : time %t", $time);
                                    16'b00010000000 : $display  ("%m : INFO : Change to substate LOOPBACK_EXIT0      : time %t", $time);
                                    16'b00100000000 : $display  ("%m : INFO : Change to substate LOOPBACK_EXIT1      : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE   : time %t", $time);
                                endcase
                            end
                4'h7    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate HOT_RESET_INACTIVE    : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate HOT_RESET             : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate HOT_RESET_MASTER_UP   : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate HOT_RESET_MASTER_DOWN : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE  : time %t", $time);
                                endcase
                            end
                4'h8    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate TX_L0S_INACTIVE   : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate TX_L0S_IDLE       : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate TX_L0S_TO_L0      : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate TX_L0S_FTS0       : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate TX_L0S_FTS1       : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'h9    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate L1_INACTIVE       : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate L1_IDLE           : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate L1_SUBSTATE       : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate L1_TO_L0          : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end
                4'ha    :   begin
                                case (sub_state)
                                    16'b00000000001 : $display  ("%m : INFO : Change to substate L2_INACTIVE       : time %t", $time);
                                    16'b00000000010 : $display  ("%m : INFO : Change to substate L2_IDLE           : time %t", $time);
                                    16'b00000000100 : $display  ("%m : INFO : Change to substate L2_TX_WAKE0       : time %t", $time);
                                    16'b00000001000 : $display  ("%m : INFO : Change to substate L2_TX_WAKE1       : time %t", $time);
                                    16'b00000010000 : $display  ("%m : INFO : Change to substate L2_EXIT           : time %t", $time);
                                    16'b00000100000 : $display  ("%m : INFO : Change to substate L2_SPEED          : time %t", $time);
                                    default         : $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
                                endcase
                            end

                default :   if (r_state != 6'h3f) // Don't display information for reset value
                                $display  ("%m : ERROR : Change to UNKNOWN SUB STATE : time %t", $time);
            endcase
        end
    end

    // TLP/DLLP Assertions
    if (mgmt_pcie_status[32]) $display  ("%m : WARNING : err_bad_dllp : A DLLP was received with a bad CRC; time %t", $time);
    if (expect_malformed_tlp)
    begin
        if (mgmt_pcie_status[33]) $display  ("%m : INFO : err_bad_tlp : A TLP was received with a bad CRC, sequence #, or a TLP ended in EDB and CRC != ~(expected CRC); time %t", $time);
        if (mgmt_pcie_status[34]) $display  ("%m : INFO : info_bad_tlp_crc_err : Subcase of err_bad_tlp : Bad LCRC; time %t", $time);
        if (mgmt_pcie_status[35]) $display  ("%m : INFO : info_bad_tlp_seq_err : Subcase of err_bad_tlp : Bad Sequence #; time %t", $time);
        if (mgmt_pcie_status[36]) $display  ("%m : INFO : info_bad_tlp_crc_n_err : Subcase of err_bad_tlp : On on EDB, but LCRC != ~(expected CRC); time %t", $time);
        if (mgmt_pcie_status[37]) $display  ("%m : INFO : err_malformed_tlp : A TLP was received with correct CRC and Seq #, but the packet was badly formed; time %t", $time);
    end
    else
    begin
        if (mgmt_pcie_status[33]) $display  ("%m : WARNING : err_bad_tlp : A TLP was received with a bad CRC, sequence #, or a TLP ended in EDB and CRC != ~(expected CRC); time %t", $time);
        if (mgmt_pcie_status[34]) $display  ("%m : WARNING : info_bad_tlp_crc_err : Subcase of err_bad_tlp : Bad LCRC; time %t", $time);
        if (mgmt_pcie_status[35]) $display  ("%m : WARNING : info_bad_tlp_seq_err : Subcase of err_bad_tlp : Bad Sequence #; time %t", $time);
        if (mgmt_pcie_status[36]) $display  ("%m : WARNING : info_bad_tlp_crc_n_err : Subcase of err_bad_tlp : On on EDB, but LCRC != ~(expected CRC); time %t", $time);
        if (mgmt_pcie_status[37]) $display  ("%m : ERROR : err_malformed_tlp : A TLP was received with correct CRC and Seq #, but the packet was badly formed; time %t", $time);
    end
    if (expect_replay_timeout)
        if (mgmt_pcie_status[38]) $display  ("%m : INFO : err_replay_timer_timeout : A replay was initiated because the replay timer timed out (positive acknowledgement was not received for a transmitted TLP); time %t", $time);
    else
        if (mgmt_pcie_status[38]) $display  ("%m : WARNING : err_replay_timer_timeout : A replay was initiated because the replay timer timed out (positive acknowledgement was not received for a transmitted TLP); time %t", $time);
    if (mgmt_pcie_status[39]) $display  ("%m : WARNING : err_replay_num_rollover : Three consecutive replays failed; the link transitioned into recovery to try to fix the link; time %t", $time);
    if (mgmt_pcie_status[40]) $display  ("%m : ERROR : err_dl_protocol_error : An ACK or NAK was received with an out of order sequence number (unsigned: new-old >= 2048); time %t", $time);
    if (expect_nak)
        if (mgmt_pcie_status[41]) $display  ("%m : INFO : info_nak_received : A NAK was received causing a replay (the other PCIe device requested a replay); time %t", $time);
    else
        if (mgmt_pcie_status[41]) $display  ("%m : WARNING : info_nak_received : A NAK was received causing a replay (the other PCIe device requested a replay); time %t", $time);
    if (mgmt_pcie_status[42]) $display  ("%m : WARNING : info_schedule_dupl_ack : A duplicate TLP was received; this is normal during replay but should not occur at other times; time %t", $time);
    if (mgmt_pcie_status[43]) $display  ("%m : WARNING : info_tlp_lost : The number of TLP starts (STP) did not equal the number of packets written into to the FIFO; there were NAKs or lost packets; time %t", $time);
    if (mgmt_pcie_status[44]) $display  ("%m : WARNING : advisory_non_fatal_error : An uncorrectable_error was downgraded to an Advisory Non-Fatal_error; time %t", $time);
    if (mgmt_pcie_status[45]) $display  ("%m : WARNING : corr_internal_error : An internal error occurred which was corrected; time %t", $time);
    if (mgmt_pcie_status[46]) $display  ("%m : WARNING : header_log_overflow : An uncorrectable_error occurred but it could not be logged because a previous header was logged and has not yet been read by software; time %t", $time);
    if (mgmt_pcie_status[47]) $display  ("%m : ERROR : surprise_down_error : The link unexpectedly went down; time %t", $time);
    if (expect_poisoned_tlp)
        if (mgmt_pcie_status[48]) $display  ("%m : INFO : poisoned_tlp_received : A poisoned TLP with data payload was received; time %t", $time);
    else
        if (mgmt_pcie_status[48]) $display  ("%m : ERROR : poisoned_tlp_received : A poisoned TLP with data payload was received; time %t", $time);
    if (mgmt_pcie_status[49]) $display  ("%m : ERROR : fc_protocol_error : A violation of the Flow Control protocol was detected; time %t", $time);
    if (expect_completion_timeout)
        if (mgmt_pcie_status[50]) $display  ("%m : INFO : completion_timeout : A request failed to be completed before the requestor's timeout period expired; time %t", $time);
    else
        if (mgmt_pcie_status[50]) $display  ("%m : ERROR : completion_timeout : A request failed to be completed before the requestor's timeout period expired; time %t", $time);
    if (expect_completer_abort)
        if (mgmt_pcie_status[51]) $display  ("%m : INFO : completer_abort : A request could not be completed and had to be aborted; time %t", $time);
    else
        if (mgmt_pcie_status[51]) $display  ("%m : ERROR : completer_abort : A request could not be completed and had to be aborted; time %t", $time);
    if (expect_unexpected_completion)
        if (mgmt_pcie_status[52]) $display  ("%m : INFO : unexpected_completion : An unexpected completion was received; completion with invalid Requestor ID or targeting a Tag which is not open; time %t", $time);
    else
        if (mgmt_pcie_status[52]) $display  ("%m : ERROR : unexpected_completion : An unexpected completion was received; completion with invalid Requestor ID or targeting a Tag which is not open; time %t", $time);
    if (mgmt_pcie_status[53]) $display  ("%m : ERROR : receiver_overflow : Core's receive buffer was overflowed; time %t", $time);
    if (expect_ecrc_failure)
        if (mgmt_pcie_status[54]) $display  ("%m : INFO : ecrc_check_failed : An ECRC failure was detected; time %t", $time);
    else
        if (mgmt_pcie_status[54]) $display  ("%m : ERROR : ecrc_check_failed : An ECRC failure was detected; time %t", $time);
    if (expect_unsupported_request)
        if (mgmt_pcie_status[55]) $display  ("%m : INFO : unsupported_request : An unsupported request was received; failed to hit a valid core resource (BAR, etc.); time %t", $time);
    else
        if (mgmt_pcie_status[55]) $display  ("%m : ERROR : unsupported_request : An unsupported request was received; failed to hit a valid core resource (BAR, etc.); time %t", $time);
    if (expect_ucorr_internal_error)
        if (mgmt_pcie_status[56]) $display  ("%m : INFO : ucorr_internal_error : An internal err occurred which was not corrected; time %t", $time);
    else
        if (mgmt_pcie_status[56]) $display  ("%m : ERROR : ucorr_internal_error : An internal err occurred which was not corrected; time %t", $time);

    // Physical Layer Assertions
    if (expect_physical_error)
        if (mgmt_pcie_status[68]) $display  ("%m : INFO : err_phy_err : A Physical Layer error was detected and reported (ERR_COR) during LTSSM: Configuration or L0 states; time %t", $time);
    else
        if (mgmt_pcie_status[68]) $display  ("%m : WARNING : err_phy_err : A Physical Layer error was detected and reported (ERR_COR) during LTSSM: Configuration or L0 states; time %t", $time);

    // Virtual Channel Assertions
    if (mgmt_pcie_status[90]) $display  ("%m : ERROR : rx buffer underflow posted : VC0_RX : P packet was read when there was not one to read; time %t", $time);
    if (mgmt_pcie_status[91]) $display  ("%m : ERROR : rx buffer underflow non-posted : VC0_RX : N packet was read when there was not one to read; time %t", $time);
    if (mgmt_pcie_status[92]) $display  ("%m : ERROR : rx buffer underflow completion : VC0_RX : C packet was read when there was not one to read; time %t", $time);

    // Local Bus Errors; note the core shares the local bus with the user for Interrupt and Error Message generation and to transmit Configuration Write/Read completions
    if (~expect_tx_completer_abort)
        if (mgmt_pcie_status[ 96]) $display  ("%m : WARNING : info_tx_completer_abort : A TLP completion was transmitted with Completer Abort status; time %t", $time);
    if (expect_unsupported_request)
        if (mgmt_pcie_status[ 97]) $display  ("%m : INFO : info_tx_unsupported_request: A TLP completion was transmitted with Unsupported Request status; time %t", $time);
    else
        if (mgmt_pcie_status[ 97]) $display  ("%m : WARNING : info_tx_unsupported_request: A TLP completion was transmitted with Unsupported Request status; time %t", $time);
    if (~expect_rx_completer_abort)
        if (mgmt_pcie_status[ 98]) $display  ("%m : WARNING : info_rx_completer_abort : A TLP completion was received with Completer Abort status; time %t", $time);
    if (expect_unsupported_request)
        if (mgmt_pcie_status[ 99]) $display  ("%m : INFO : info_rx_unsupported_request : A TLP completion was received with Unsupported Request status; time %t", $time);
    else
        if (mgmt_pcie_status[ 99]) $display  ("%m : WARNING : info_rx_unsupported_request : A TLP completion was received with Unsupported Request status; time %t", $time);
    if (expect_poisoned_tlp)
        if (mgmt_pcie_status[100]) $display  ("%m : INFO : info_tx_poisoned_tlp : A TLP write request was transmitted that was marked as poisoned; time %t", $time);
    else
        if (mgmt_pcie_status[100]) $display  ("%m : WARNING : info_tx_poisoned_tlp : A TLP write request was transmitted that was marked as poisoned; time %t", $time);
    if (expect_poisoned_tlp)
        if (mgmt_pcie_status[101]) $display  ("%m : INFO : info_rx_poisoned_tlp : A TLP was received that was marked as poisoned; time %t", $time);
    else
        if (mgmt_pcie_status[101]) $display  ("%m : WARNING : info_rx_poisoned_tlp : A TLP was received that was marked as poisoned; time %t", $time);
end



endmodule
