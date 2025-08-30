vlib work
vlog moore_detect_tb.v
vsim moore_tb
add wave -r sim:/moore_tb/dut/*
run -all
