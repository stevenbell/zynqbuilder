#Definitional proc to organize widgets for parameters.
proc create_gui { ipview } {
	set Page0 [ ipgui::add_page $ipview  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $ipview  -parent  $Page0  -name Component_Name ]
	set C_SET_RST_HIGH [ipgui::add_param $ipview -parent $Page0 -name C_SET_RST_HIGH]
	set C_USE_RST [ipgui::add_param $ipview -parent $Page0 -name C_USE_RST]
	set C_USE_SET [ipgui::add_param $ipview -parent $Page0 -name C_USE_SET]
	set C_USE_CE [ipgui::add_param $ipview -parent $Page0 -name C_USE_CE]
	set C_USE_ASYNCH [ipgui::add_param $ipview -parent $Page0 -name C_USE_ASYNCH]
	set C_SIZE [ipgui::add_param $ipview -parent $Page0 -name C_SIZE]
	set C_INIT [ipgui::add_param $ipview -parent $Page0 -name C_INIT]
}

proc C_SET_RST_HIGH_updated {ipview} {
	# Procedure called when C_SET_RST_HIGH is updated
	return true
}

proc validate_C_SET_RST_HIGH {ipview} {
	# Procedure called to validate C_SET_RST_HIGH
	return true
}

proc C_USE_RST_updated {ipview} {
	# Procedure called when C_USE_RST is updated
	return true
}

proc validate_C_USE_RST {ipview} {
	# Procedure called to validate C_USE_RST
	return true
}

proc C_USE_SET_updated {ipview} {
	# Procedure called when C_USE_SET is updated
	return true
}

proc validate_C_USE_SET {ipview} {
	# Procedure called to validate C_USE_SET
	return true
}

proc C_USE_CE_updated {ipview} {
	# Procedure called when C_USE_CE is updated
	return true
}

proc validate_C_USE_CE {ipview} {
	# Procedure called to validate C_USE_CE
	return true
}

proc C_USE_ASYNCH_updated {ipview} {
	# Procedure called when C_USE_ASYNCH is updated
	return true
}

proc validate_C_USE_ASYNCH {ipview} {
	# Procedure called to validate C_USE_ASYNCH
	return true
}

proc C_SIZE_updated {ipview} {
	# Procedure called when C_SIZE is updated
	return true
}

proc validate_C_SIZE {ipview} {
	# Procedure called to validate C_SIZE
	return true
}

proc C_INIT_updated {ipview} {
	# Procedure called when C_INIT is updated
	return true
}

proc validate_C_INIT {ipview} {
	# Procedure called to validate C_INIT
	return true
}


proc updateModel_C_SET_RST_HIGH {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_SET_RST_HIGH -of $ipview ]] [ipgui::get_modelparamspec C_SET_RST_HIGH -of $ipview ]

	return true
}

proc updateModel_C_USE_RST {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_USE_RST -of $ipview ]] [ipgui::get_modelparamspec C_USE_RST -of $ipview ]

	return true
}

proc updateModel_C_USE_SET {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_USE_SET -of $ipview ]] [ipgui::get_modelparamspec C_USE_SET -of $ipview ]

	return true
}

proc updateModel_C_USE_CE {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_USE_CE -of $ipview ]] [ipgui::get_modelparamspec C_USE_CE -of $ipview ]

	return true
}

proc updateModel_C_USE_ASYNCH {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_USE_ASYNCH -of $ipview ]] [ipgui::get_modelparamspec C_USE_ASYNCH -of $ipview ]

	return true
}

proc updateModel_C_SIZE {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_SIZE -of $ipview ]] [ipgui::get_modelparamspec C_SIZE -of $ipview ]

	return true
}

proc updateModel_C_INIT {ipview} {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value

	set_property modelparam_value [get_property value [ipgui::get_paramspec C_INIT -of $ipview ]] [ipgui::get_modelparamspec C_INIT -of $ipview ]

	return true
}

