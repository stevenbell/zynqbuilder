vlib work

vlog -f files_ms.f

vsim -L secureip -L unisims_ver -L unimacro_ver -l pcie_log.txt work.tb_top work.glbl

onbreak {resume}

run -all

quit -sim
