// --------------------------------------------------------------------------
//
//  PROJECT:             PCI Core
//  COMPANY:             Northwest Logic, Inc.
//
// ------------------------- CONFIDENTIAL ----------------------------------
//
//                 Copyright 2012 by Northwest Logic, Inc.
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

module util_sync_flops #
(  
    parameter   SYNC_RESET_VALUE = 1'b0  // Reset value for flops
)
(
    input       clk,                     // Posedge Clock
    input       rst_n,                   // Active low asynchronous reset
    input       d,                       // Data to synchronize
    output      q                        // Data after synchronization
);

// ---------------------
// -- Local Variables --
// ---------------------

(* SHREG_EXTRACT = "NO", ASYNC_REG = "TRUE" *) reg        s0;
(* SHREG_EXTRACT = "NO", ASYNC_REG = "TRUE" *) reg        s1;
wire next_s0;

`ifdef SIMULATION
// metastable sim code should not be present for synthesis

// additional define to allow disabling 
assign next_s0 = d;      
`else
assign next_s0 = d;      
`endif //  `ifdef SIMULATION

// ---------------
// -- Equations --
// ---------------

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)
    begin
        s0 <= SYNC_RESET_VALUE;
        s1 <= SYNC_RESET_VALUE;
    end
    else
    begin
        s0 <= next_s0;
        s1 <= s0;
    end
end

assign q = s1;
 `ifdef SIMULATION

initial
    begin
        #15;
        if ($test$plusargs("util_sync_flops_msgs_on"))
            $display ("Synchronizer instance : %m : Register s0 may have its setup and hold times violated");
    end
 `endif
endmodule

