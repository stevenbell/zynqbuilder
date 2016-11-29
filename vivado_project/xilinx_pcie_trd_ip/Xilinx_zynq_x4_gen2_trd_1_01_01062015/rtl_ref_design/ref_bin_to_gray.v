// --------------------------------------------------------------------------
//
//  PROJECT:             PCI Core
//  COMPANY:             Northwest Logic, Inc.
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

// -------------------------------------------------------------------------
//
//  FUNCTIONAL DESCRIPTION
//
//  This module converts the input d represented in binary into
//    its corresponding Gray Code value which is output as q.
//
//  This function is completely combinatorial.  Applications requiring
//    high route frequencies should consider registering the q output
//    before using it.
//
// -------------------------------------------------------------------------

`timescale 1ps / 1ps



// MODULE

module ref_bin_to_gray (
    d,
    q
);



// PARAMETERS

parameter WIDTH = 7;        



// PORT DEFINITIONS

input   [WIDTH-1:0]         d;
output  [WIDTH-1:0]         q;



// PORT VARIABLES

wire    [WIDTH-1:0]         d;
reg     [WIDTH-1:0]         q;


// LOCAL VARIABLES
integer                     i;



// EQUATIONS

// Compute binary to Gray code conversion
always @(d)
begin
    for (i=0; i<WIDTH-1; i=i+1)
        q[i] = d[i] ^ d[i+1];

    // MSbit is a special case
    q[WIDTH-1] = d[WIDTH-1];
end



endmodule
