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

// -------------------------------------------------------------------------
//
//  FUNCTIONAL DESCRIPTION
//
//  This module converts the input d represented in gray code into
//     its corresponding binary value which is output as q.
//
//  This function is completely combinatorial.  Applications requiring
//    high route frequencies should consider registering the q output
//    before using it.
//
//  LIMITATIONS:
//
//    This code is limited to a maximum input bit width of 16 bits.
//    The desired width for the function is chosen via the parameter 
//    WIDTH which has a valid range of 1-16.
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// MODULE

module ref_gray_to_bin (
    d,
    q
);



// PARAMETERS

parameter WIDTH = 7;        // Valid range: 1 to 16



// PORT DEFINITIONS

input   [WIDTH-1:0]         d;
output  [WIDTH-1:0]         q;



// PORT VARIABLES

wire    [WIDTH-1:0]         d;
reg     [WIDTH-1:0]         q;



// LOCAL VARIABLES

wire    [15:0]              g;
wire    [15:0]              temp;
integer                     i;



// EQUATIONS

assign g = { {(16-WIDTH){1'b0}}, d};



// Compute gray code to binary conversion
//   Do this in a temporary variable since only
//   WIDTH bits should be output
assign  temp  = { g[15], 
                 (g[15] ^ g[14]),
                 (g[15] ^ g[14] ^ g[13]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6] ^ g[5]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6] ^ g[5] ^ g[4]), 
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6] ^ g[5] ^ g[4] ^ g[3]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6] ^ g[5] ^ g[4] ^ g[3] ^ g[2]), 
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6] ^ g[5] ^ g[4] ^ g[3] ^ g[2] ^ g[1]),
                 (g[15] ^ g[14] ^ g[13] ^ g[12] ^ g[11] ^ g[10] ^ g[9] ^ g[8] ^ g[7] ^ g[6] ^ g[5] ^ g[4] ^ g[3] ^ g[2] ^ g[1] ^ g[0]) };

// Assign temp result to relevant output bits
always @(temp)
begin
    for (i=0; i<WIDTH; i=i+1)
        q[i] = temp[i];
end



endmodule
