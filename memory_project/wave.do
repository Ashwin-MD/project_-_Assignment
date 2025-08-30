onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /top/dut/clk
add wave -noupdate -radix unsigned /top/dut/rst
add wave -noupdate -radix unsigned /top/dut/valid
add wave -noupdate -radix unsigned /top/dut/ready
add wave -noupdate -radix unsigned /top/dut/wr_rd
add wave -noupdate -radix unsigned /top/dut/addr
add wave -noupdate -radix unsigned /top/dut/wdata
add wave -noupdate -radix unsigned /top/dut/rdata
add wave -noupdate -radix unsigned /top/dut/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {545 ps} {735 ps}
