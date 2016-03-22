
# This is the replacement for init_user
#ps7_post_config

# Write to one of the tap registers and read it back again
proc test_registers {} {
  puts [mrd_phys 0x43c00000 10]
  puts [mwr_phys 0x43c00000 0xdeadbeef]
  puts [mrd_phys 0x43c00000 10]
}

# strip takes a register/value string from XMD and returns just the value
proc strip {input} {
  return [string range $input 12 19]
}

# Parse a scatter-gather descriptor and print it in a human-readable way
proc parse_sg {sg_base} {
  puts "SG descriptor $sg_base$"
  puts [mrd_phys $sg_base 10];
  set DESC_CTRL [mrd_phys [expr {"$sg_base" + 0x18}]];
  set DESC_CTRL [strip $DESC_CTRL];
  puts "  Control: $DESC_CTRL"
  if {[expr 0x$DESC_CTRL & 0x08000000]} {
    puts "    TX Start-of-frame";
  }
  if {[expr 0x$DESC_CTRL & 0x04000000]} {
    puts "    TX End-of-frame";
  }
  puts "    Length: [string range $DESC_CTRL 3 7]";
  
  set DESC_STATUS [mrd_phys [expr {"$sg_base" + 0x1C}]];
  set DESC_STATUS [strip $DESC_STATUS];
  
  puts "  Status: $DESC_STATUS"
  if {[expr 0x$DESC_STATUS & 0x80000000]} {
    puts "    Completed";
  }
  if {[expr 0x$DESC_STATUS & 0x40000000]} {
    puts "    DMADecErr";
  }
  if {[expr 0x$DESC_STATUS & 0x20000000]} {
    puts "    DMASlaveErr";
  }
  if {[expr 0x$DESC_STATUS & 0x10000000]} {
    puts "    DMAIntErr";
  }
  puts "    Transferred: [string range $DESC_STATUS 3 7]";
}

# Parse all the bits in the DMA register space, and print them in a
# human-readable way.  "Direction" should be a string describing
# which DMA engine we're using (e.g., "MM2S" or "S2MM", or perhaps
# something more descriptive)
proc parse_dma {direction address} {
  set DMACR [mrd_phys [expr {$address + 0x00}]];
  set DMACR [strip $DMACR];
  puts "$direction DMACR: $DMACR";
  if {[expr 0x$DMACR % 2] == 1} {
    puts "  run";
  } else {
    puts "  stop";
  }
  
  set DMASR [mrd_phys [expr {$address + 0x04}]];
  set DMASR [strip $DMASR];
  puts "$direction DMASR: $DMASR"
  if {[expr 0x$DMASR & 0x00000001]} {
    puts "  Halted";
  } else {
    puts "  Running";
  }
  if {[expr 0x$DMASR & 0x00000002]} {
    puts "  Idle";
  } else {
    puts "  Not idle";
  }
  if {[expr 0x$DMASR & 0x00000008]} {
    puts "  Scatter-gather mode";
  } else {
    puts "  Simple DMA mode";
  }
  
  puts "  error: [string range $DMASR 4 6]"
  if {[expr 0x$DMASR & 0x00004000]} {
    puts "    Error interrupt occured";
  }
  if {[expr 0x$DMASR & 0x00001000]} {
    puts "    IOC_Irq: Completed descriptor";
  }
  if {[expr 0x$DMASR & 0x00000200]} {
    puts "    DMADecErr: SG slave error";
  }
  if {[expr 0x$DMASR & 0x00000100]} {
    puts "    DMADecErr: SG internal error";
  }
  if {[expr 0x$DMASR & 0x00000040]} {
    puts "    DMADecErr: Decode error";
  }
  if {[expr 0x$DMASR & 0x00000020]} {
    puts "    DMASlvErr";
  }

  set CURDESC [mrd_phys [expr {$address + 0x08}]];
  set CURDESC [strip $CURDESC];
  puts "$direction CURDESC: $CURDESC"
}

proc parse_all {} {
  parse_dma MM2S 0x40400000;
  parse_dma S2MM 0x40400030;
  parse_sg 0x01000000;
  parse_sg 0x01000040;
  parse_sg 0x02000000;
  parse_sg 0x02000040;
}

