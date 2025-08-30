vlib work
vlog fifo_async_tb.v
vsim async_tb +testcase=ALL_WRITES_AND_ALL_READS
#add wave -position insertpoint sim:/async_tb/dut/*
do wave.do
run -all
