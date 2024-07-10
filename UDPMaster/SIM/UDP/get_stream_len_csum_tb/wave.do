onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /get_stream_len_csum_tb/DUT/clk
add wave -noupdate /get_stream_len_csum_tb/DUT/reset_n
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/hdr_ip_dest_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/hdr_ip_src_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/hdr_port_dest_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/hdr_port_src_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/user_tdata_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/user_tvld_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/user_tlast_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/user_tkeep_i
add wave -noupdate -expand -group in /get_stream_len_csum_tb/DUT/user_trdy_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/hdr_ip_dest_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/hdr_ip_src_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/hdr_port_dest_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/hdr_port_src_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_data_csum_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_data_len_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_tdata_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_tvld_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_tlast_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_tkeep_o
add wave -noupdate -expand -group out /get_stream_len_csum_tb/DUT/user_trdy_i
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/hdr_ip_dest_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/hdr_ip_src_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/hdr_port_dest_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/hdr_port_src_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_tdata_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_tlast_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_tvld_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_tkeep_reg
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_len
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_csum
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/rdy
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/pkt_proc
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/cnt_vld_bytes
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/fifo_strm_rdy_in
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/fifo_hdr_rdy_in
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/fifo_strm_rdy_out
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/fifo_hdr_rdy_out
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/fifo_hdr_vld_out
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/state
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/state_next
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/csum_data_tmp
add wave -noupdate -expand -group debug /get_stream_len_csum_tb/DUT/strm_csum_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 297
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
WaveRestoreZoom {0 ns} {1068 ns}
