# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.USE_MGMT { PARAM_VALUE.USE_MGMT } {
	# Procedure called to update USE_MGMT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_MGMT { PARAM_VALUE.USE_MGMT } {
	# Procedure called to validate USE_MGMT
	return true
}

proc update_PARAM_VALUE.USE_TEST { PARAM_VALUE.USE_TEST } {
	# Procedure called to update USE_TEST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_TEST { PARAM_VALUE.USE_TEST } {
	# Procedure called to validate USE_TEST
	return true
}

proc update_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to update AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_DATA_WIDTH { PARAM_VALUE.AXI_DATA_WIDTH } {
	# Procedure called to validate AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_LEN_WIDTH { PARAM_VALUE.AXI_LEN_WIDTH } {
	# Procedure called to update AXI_LEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_LEN_WIDTH { PARAM_VALUE.AXI_LEN_WIDTH } {
	# Procedure called to validate AXI_LEN_WIDTH
	return true
}

proc update_PARAM_VALUE.T_AXI_ADDR_WIDTH { PARAM_VALUE.T_AXI_ADDR_WIDTH } {
	# Procedure called to update T_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.T_AXI_ADDR_WIDTH { PARAM_VALUE.T_AXI_ADDR_WIDTH } {
	# Procedure called to validate T_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to update AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_ADDR_WIDTH { PARAM_VALUE.AXI_ADDR_WIDTH } {
	# Procedure called to validate AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.MAX_S2C { PARAM_VALUE.MAX_S2C } {
	# Procedure called to update MAX_S2C when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_S2C { PARAM_VALUE.MAX_S2C } {
	# Procedure called to validate MAX_S2C
	return true
}

proc update_PARAM_VALUE.MAX_C2S { PARAM_VALUE.MAX_C2S } {
	# Procedure called to update MAX_C2S when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_C2S { PARAM_VALUE.MAX_C2S } {
	# Procedure called to validate MAX_C2S
	return true
}

proc update_PARAM_VALUE.NUM_S2C { PARAM_VALUE.NUM_S2C } {
	# Procedure called to update NUM_S2C when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_S2C { PARAM_VALUE.NUM_S2C } {
	# Procedure called to validate NUM_S2C
	return true
}

proc update_PARAM_VALUE.NUM_C2S { PARAM_VALUE.NUM_C2S } {
	# Procedure called to update NUM_C2S when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_C2S { PARAM_VALUE.NUM_C2S } {
	# Procedure called to validate NUM_C2S
	return true
}

proc update_PARAM_VALUE.USER_CONTROL_WIDTH { PARAM_VALUE.USER_CONTROL_WIDTH } {
	# Procedure called to update USER_CONTROL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USER_CONTROL_WIDTH { PARAM_VALUE.USER_CONTROL_WIDTH } {
	# Procedure called to validate USER_CONTROL_WIDTH
	return true
}

proc update_PARAM_VALUE.USER_STATUS_WIDTH { PARAM_VALUE.USER_STATUS_WIDTH } {
	# Procedure called to update USER_STATUS_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USER_STATUS_WIDTH { PARAM_VALUE.USER_STATUS_WIDTH } {
	# Procedure called to validate USER_STATUS_WIDTH
	return true
}

proc update_PARAM_VALUE.M_INT_VECTORS { PARAM_VALUE.M_INT_VECTORS } {
	# Procedure called to update M_INT_VECTORS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_INT_VECTORS { PARAM_VALUE.M_INT_VECTORS } {
	# Procedure called to validate M_INT_VECTORS
	return true
}

proc update_PARAM_VALUE.AXI_BE_WIDTH { PARAM_VALUE.AXI_BE_WIDTH } {
	# Procedure called to update AXI_BE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_BE_WIDTH { PARAM_VALUE.AXI_BE_WIDTH } {
	# Procedure called to validate AXI_BE_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.NUM_S2C { MODELPARAM_VALUE.NUM_S2C PARAM_VALUE.NUM_S2C } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_S2C}] ${MODELPARAM_VALUE.NUM_S2C}
}

proc update_MODELPARAM_VALUE.NUM_C2S { MODELPARAM_VALUE.NUM_C2S PARAM_VALUE.NUM_C2S } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_C2S}] ${MODELPARAM_VALUE.NUM_C2S}
}

proc update_MODELPARAM_VALUE.USER_CONTROL_WIDTH { MODELPARAM_VALUE.USER_CONTROL_WIDTH PARAM_VALUE.USER_CONTROL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USER_CONTROL_WIDTH}] ${MODELPARAM_VALUE.USER_CONTROL_WIDTH}
}

