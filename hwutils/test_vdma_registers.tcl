# WORK IN PROGRESS... it's working now, so I didn't finish this.
source /home/steven/work/camera_ifc/vivado_dpda/vivado_dpda.sdk/block_diagram_wrapper_hw_platform_0/ps7_init.tcl

# This is the replacement for init_user
ps7_post_config

# strip takes a register/value string from XMD and returns just the value
proc strip {input} {
  return [string range $input 12 19]
}

