vlib work
vlog melay_detec_tb.v
vsim melay_tb
add wave -r sim:/melay_tb/dut/*
run -all
