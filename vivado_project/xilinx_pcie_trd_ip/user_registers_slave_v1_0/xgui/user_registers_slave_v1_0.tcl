#Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ ipgui::add_page $IPINST  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $IPINST  -parent  $Page0  -name Component_Name ]
	set C_DPHASE_TIMEOUT [ipgui::add_param $IPINST -parent $Page0 -name C_DPHASE_TIMEOUT -widget radioGroup]
	set C_S_AXI_MIN_SIZE_PS [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_MIN_SIZE_PS]
	set C_S_AXI_MIN_SIZE [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_MIN_SIZE]
	set C_NUM_ADDRESS_RANGES [ipgui::add_param $IPINST -parent $Page0 -name C_NUM_ADDRESS_RANGES -widget radioGroup]
	set C_TOTAL_NUM_CE [ipgui::add_param $IPINST -parent $Page0 -name C_TOTAL_NUM_CE -widget radioGroup]
	set C_HIGH_ADDRESS_PS [ipgui::add_param $IPINST -parent $Page0 -name C_HIGH_ADDRESS_PS]
	set C_BASE_ADDRESS_PS [ipgui::add_param $IPINST -parent $Page0 -name C_BASE_ADDRESS_PS]
	set C_HIGH_ADDRESS [ipgui::add_param $IPINST -parent $Page0 -name C_HIGH_ADDRESS]
	set C_BASE_ADDRESS [ipgui::add_param $IPINST -parent $Page0 -name C_BASE_ADDRESS]
	set C_S_AXI_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_DATA_WIDTH -widget radioGroup]
	set C_S_AXI_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_S_AXI_ADDR_WIDTH -widget radioGroup]
}

proc update_PARAM_VALUE.C_DPHASE_TIMEOUT { PARAM_VALUE.C_DPHASE_TIMEOUT } {
	# Procedure called to update C_DPHASE_TIMEOUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DPHASE_TIMEOUT { PARAM_VALUE.C_DPHASE_TIMEOUT } {
	# Procedure called to validate C_DPHASE_TIMEOUT
	return true
}

proc update_PARAM_VALUE.C_S_AXI_MIN_SIZE_PS { PARAM_VALUE.C_S_AXI_MIN_SIZE_PS } {
	# Procedure called to update C_S_AXI_MIN_SIZE_PS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_MIN_SIZE_PS { PARAM_VALUE.C_S_AXI_MIN_SIZE_PS } {
	# Procedure called to validate C_S_AXI_MIN_SIZE_PS
	return true
}

proc update_PARAM_VALUE.C_S_AXI_MIN_SIZE { PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to update C_S_AXI_MIN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_MIN_SIZE { PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to validate C_S_AXI_MIN_SIZE
	return true
}

proc update_PARAM_VALUE.C_NUM_ADDRESS_RANGES { PARAM_VALUE.C_NUM_ADDRESS_RANGES } {
	# Procedure called to update C_NUM_ADDRESS_RANGES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_ADDRESS_RANGES { PARAM_VALUE.C_NUM_ADDRESS_RANGES } {
	# Procedure called to validate C_NUM_ADDRESS_RANGES
	return true
}

proc update_PARAM_VALUE.C_TOTAL_NUM_CE { PARAM_VALUE.C_TOTAL_NUM_CE } {
	# Procedure called to update C_TOTAL_NUM_CE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_TOTAL_NUM_CE { PARAM_VALUE.C_TOTAL_NUM_CE } {
	# Procedure called to validate C_TOTAL_NUM_CE
	return true
}

proc update_PARAM_VALUE.C_HIGH_ADDRESS_PS { PARAM_VALUE.C_HIGH_ADDRESS_PS } {
	# Procedure called to update C_HIGH_ADDRESS_PS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HIGH_ADDRESS_PS { PARAM_VALUE.C_HIGH_ADDRESS_PS } {
	# Procedure called to validate C_HIGH_ADDRESS_PS
	return true
}

proc update_PARAM_VALUE.C_BASE_ADDRESS_PS { PARAM_VALUE.C_BASE_ADDRESS_PS } {
	# Procedure called to update C_BASE_ADDRESS_PS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BASE_ADDRESS_PS { PARAM_VALUE.C_BASE_ADDRESS_PS } {
	# Procedure called to validate C_BASE_ADDRESS_PS
	return true
}

proc update_PARAM_VALUE.C_HIGH_ADDRESS { PARAM_VALUE.C_HIGH_ADDRESS } {
	# Procedure called to update C_HIGH_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_HIGH_ADDRESS { PARAM_VALUE.C_HIGH_ADDRESS } {
	# Procedure called to validate C_HIGH_ADDRESS
	return true
}

proc update_PARAM_VALUE.C_BASE_ADDRESS { PARAM_VALUE.C_BASE_ADDRESS } {
	# Procedure called to update C_BASE_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BASE_ADDRESS { PARAM_VALUE.C_BASE_ADDRESS } {
	# Procedure called to validate C_BASE_ADDRESS
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_BASE_ADDRESS { MODELPARAM_VALUE.C_BASE_ADDRESS PARAM_VALUE.C_BASE_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BASE_ADDRESS}] ${MODELPARAM_VALUE.C_BASE_ADDRESS}
}

proc update_MODELPARAM_VALUE.C_HIGH_ADDRESS { MODELPARAM_VALUE.C_HIGH_ADDRESS PARAM_VALUE.C_HIGH_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HIGH_ADDRESS}] ${MODELPARAM_VALUE.C_HIGH_ADDRESS}
}

proc update_MODELPARAM_VALUE.C_BASE_ADDRESS_PS { MODELPARAM_VALUE.C_BASE_ADDRESS_PS PARAM_VALUE.C_BASE_ADDRESS_PS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BASE_ADDRESS_PS}] ${MODELPARAM_VALUE.C_BASE_ADDRESS_PS}
}

proc update_MODELPARAM_VALUE.C_HIGH_ADDRESS_PS { MODELPARAM_VALUE.C_HIGH_ADDRESS_PS PARAM_VALUE.C_HIGH_ADDRESS_PS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_HIGH_ADDRESS_PS}] ${MODELPARAM_VALUE.C_HIGH_ADDRESS_PS}
}

proc update_MODELPARAM_VALUE.C_TOTAL_NUM_CE { MODELPARAM_VALUE.C_TOTAL_NUM_CE PARAM_VALUE.C_TOTAL_NUM_CE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_TOTAL_NUM_CE}] ${MODELPARAM_VALUE.C_TOTAL_NUM_CE}
}

proc update_MODELPARAM_VALUE.C_NUM_ADDRESS_RANGES { MODELPARAM_VALUE.C_NUM_ADDRESS_RANGES PARAM_VALUE.C_NUM_ADDRESS_RANGES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_ADDRESS_RANGES}] ${MODELPARAM_VALUE.C_NUM_ADDRESS_RANGES}
}

proc update_MODELPARAM_VALUE.C_S_AXI_MIN_SIZE { MODELPARAM_VALUE.C_S_AXI_MIN_SIZE PARAM_VALUE.C_S_AXI_MIN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_MIN_SIZE}] ${MODELPARAM_VALUE.C_S_AXI_MIN_SIZE}
}

proc update_MODELPARAM_VALUE.C_S_AXI_MIN_SIZE_PS { MODELPARAM_VALUE.C_S_AXI_MIN_SIZE_PS PARAM_VALUE.C_S_AXI_MIN_SIZE_PS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_MIN_SIZE_PS}] ${MODELPARAM_VALUE.C_S_AXI_MIN_SIZE_PS}
}

proc update_MODELPARAM_VALUE.C_DPHASE_TIMEOUT { MODELPARAM_VALUE.C_DPHASE_TIMEOUT PARAM_VALUE.C_DPHASE_TIMEOUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DPHASE_TIMEOUT}] ${MODELPARAM_VALUE.C_DPHASE_TIMEOUT}
}

