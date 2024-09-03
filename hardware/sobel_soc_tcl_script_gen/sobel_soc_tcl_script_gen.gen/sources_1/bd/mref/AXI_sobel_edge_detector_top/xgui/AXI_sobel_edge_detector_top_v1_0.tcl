# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_COLUMNS" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_COLUMNS { PARAM_VALUE.C_COLUMNS } {
	# Procedure called to update C_COLUMNS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_COLUMNS { PARAM_VALUE.C_COLUMNS } {
	# Procedure called to validate C_COLUMNS
	return true
}


proc update_MODELPARAM_VALUE.C_COLUMNS { MODELPARAM_VALUE.C_COLUMNS PARAM_VALUE.C_COLUMNS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_COLUMNS}] ${MODELPARAM_VALUE.C_COLUMNS}
}

