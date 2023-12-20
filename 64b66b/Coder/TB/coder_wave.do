onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /coder64b66b_tb/DUT/clk
add wave -noupdate /coder64b66b_tb/DUT/reset_n
add wave -noupdate -expand -group s_axis /coder64b66b_tb/DUT/s_axis_ttype
add wave -noupdate -expand -group s_axis /coder64b66b_tb/DUT/s_axis_tdata
add wave -noupdate -expand -group s_axis /coder64b66b_tb/DUT/s_axis_tvalid
add wave -noupdate -expand -group s_axis /coder64b66b_tb/DUT/s_axis_tready
add wave -noupdate -expand -group m_axis /coder64b66b_tb/DUT/m_axis_tdata
add wave -noupdate -expand -group m_axis /coder64b66b_tb/DUT/m_axis_tvalid
add wave -noupdate -expand -group m_axis /coder64b66b_tb/DUT/m_axis_tready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {395528 ns} {400225 ns}
