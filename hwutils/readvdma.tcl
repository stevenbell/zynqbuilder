# Reads the registers from a VDMA core and prints out a human-readable
# summary of what's actually going on.
#
# Steven Bell <sebell@stanford.edu>
# 13 January 2015

# Assume that we've already connected to the target, i.e.:
# connect arm hw

set DMA_ADDR 0x43000000; # Base address of the VDMA core

# strip takes a register/value string from XMD and returns just the value
proc strip {input} {
  return [string range $input 12 19]
}


# S2MM
set DMACR [mrd_phys [expr {$DMA_ADDR + 0x30}]];
set DMACR [strip $DMACR];
puts "S2MM DMACR: $DMACR"
if {[expr 0x$DMACR % 2] == 1} {
  puts "  run";
} else {
  puts "  stop";
}

set DMASR [mrd_phys [expr {$DMA_ADDR + 0x34}]];
set DMASR [strip $DMASR];
puts "S2MM DMASR: $DMASR"
if {[expr 0x$DMASR % 2] == 1} {
  puts "  halted";
} else {
  puts "  running";
}
puts "  error: [string range $DMASR 4 6]"
if {[expr 0x$DMASR & 0x00000800]} {
  puts "    SOFLateErr";
}
if {[expr 0x$DMASR & 0x00000100]} {
  puts "    EOLEarlyErr";
}

# Note that this stops when there's an error (even if the engine
# keeps going with more frames).
set FRMPTR [mrd_phys [expr {$DMA_ADDR + 0x28}]];
set FRMPTR [strip $FRMPTR];
#puts "Current frame pointer: [string range $FRMPTR 0 1]"
puts "Current frame pointer: $FRMPTR"

# set N_FRAMESTORES [mrd_phys [expr {$DMA_ADDR + 0x48}]];
# set N_FRAMESTORES [strip $N_FRAMESTORES];
# puts "Number of framestores: [string range $N_FRAMESTORES 6 7]"

set VSIZE [mrd_phys [expr {$DMA_ADDR + 0xA0}]];
set VSIZE [string range [strip $VSIZE] 4 7]; # Least significant half
set VSIZE_dec [format %d 0x$VSIZE]
puts "Vsize: $VSIZE ($VSIZE_dec)"

set HSIZE [mrd_phys [expr {$DMA_ADDR + 0xA4}]];
set HSIZE [string range [strip $HSIZE] 4 7]; # Least significant half
set HSIZE_dec [format %d 0x$HSIZE]
puts "Hsize: $HSIZE ($HSIZE_dec)"

set STRIDE [mrd_phys [expr {$DMA_ADDR + 0xA8}]];
set STRIDE [string range [strip $STRIDE] 4 7]; # Least significant half
set STRIDE_dec [format %d 0x$STRIDE]
puts "Stride: $STRIDE ($STRIDE_dec)"

puts "Start addresses";
puts [mrd_phys [expr {$DMA_ADDR + 0xac}] 10];

puts "";
puts "Data samples";
for {set i 0} {$i < 3} {incr i} {
  set addr [mrd_phys [expr {$DMA_ADDR + 0xac + 4 * $i}]];
  set addr [strip $addr]
  puts [mrd_phys 0x$addr 10];
}

#puts "Done."

