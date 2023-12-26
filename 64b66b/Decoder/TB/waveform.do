onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /decoder_tb/DUT/clk
add wave -noupdate /decoder_tb/DUT/reset_n
add wave -noupdate -expand -group s_axis /decoder_tb/DUT/s_axis_tdata
add wave -noupdate -expand -group s_axis /decoder_tb/DUT/s_axis_tvalid
add wave -noupdate -expand -group s_axis /decoder_tb/DUT/s_axis_tready
add wave -noupdate -expand -group m_axis /decoder_tb/DUT/m_axis_ttype
add wave -noupdate -expand -group m_axis /decoder_tb/DUT/m_axis_tdata
add wave -noupdate -expand -group m_axis /decoder_tb/DUT/m_axis_tvalid
add wave -noupdate -expand -group m_axis /decoder_tb/DUT/m_axis_tready
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/clk
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/reset_n
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/s_axis_tdata
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/s_axis_tvalid
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/s_axis_tready
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/m_axis_tdata
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/m_axis_tvalid
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/m_axis_tready
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/data_pipe
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/valid_pipe
add wave -noupdate -expand -group converter_64to66 /decoder_tb/DUT/converter_64b_to_66b_inst/point
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/clk
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/reset_n
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/s_axis_tdata
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/s_axis_tvalid
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/s_axis_tready
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/m_axis_ttype
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/m_axis_tdata
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/m_axis_tvalid
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/m_axis_tready
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/data_pipe
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/state
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/state_next
add wave -noupdate -group synchronizer -radix unsigned /decoder_tb/DUT/synchronizer_inst/search_first_sync_cnt
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/search_first_sync_max
add wave -noupdate -group synchronizer -radix unsigned /decoder_tb/DUT/synchronizer_inst/counter_pre_sync
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/counter_pre_sync_max
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/sync_ok
add wave -noupdate -group synchronizer -radix unsigned /decoder_tb/DUT/synchronizer_inst/pos_sync
add wave -noupdate -group synchronizer /decoder_tb/DUT/synchronizer_inst/data_sync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {190 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 269
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
WaveRestoreZoom {0 ns} {4878 ns}
