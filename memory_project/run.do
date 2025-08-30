vlib work
vlog mem_tb_cases.v
vsim top +testcase=FIRST_HALF_OF_MEM
#add wave -r sim:/top/dut/*
do wave.do
run -all
