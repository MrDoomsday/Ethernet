onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /eth_II_packer_tb/DUT/clk
add wave -noupdate /eth_II_packer_tb/DUT/reset_n
add wave -noupdate -expand -group header /eth_II_packer_tb/DUT/hdr_mac_dest_i
add wave -noupdate -expand -group header /eth_II_packer_tb/DUT/hdr_mac_src_i
add wave -noupdate -expand -group header /eth_II_packer_tb/DUT/hdr_mac_vld_i
add wave -noupdate -expand -group header /eth_II_packer_tb/DUT/hdr_mac_rdy_o
add wave -noupdate -expand -group user_in /eth_II_packer_tb/DUT/user_tdata_i
add wave -noupdate -expand -group user_in /eth_II_packer_tb/DUT/user_tvld_i
add wave -noupdate -expand -group user_in /eth_II_packer_tb/DUT/user_tlast_i
add wave -noupdate -expand -group user_in /eth_II_packer_tb/DUT/user_tkeep_i
add wave -noupdate -expand -group user_in /eth_II_packer_tb/DUT/user_trdy_o
add wave -noupdate -expand -group ethernet_ii_out /eth_II_packer_tb/DUT/ethii_ip_udp_tdata_o
add wave -noupdate -expand -group ethernet_ii_out /eth_II_packer_tb/DUT/ethii_ip_udp_tvld_o
add wave -noupdate -expand -group ethernet_ii_out /eth_II_packer_tb/DUT/ethii_ip_udp_tlast_o
add wave -noupdate -expand -group ethernet_ii_out /eth_II_packer_tb/DUT/ethii_ip_udp_tkeep_o
add wave -noupdate -expand -group ethernet_ii_out /eth_II_packer_tb/DUT/ethii_ip_udp_rdy_i
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/state
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/state_next
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/mac_dst_reg
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/mac_src_reg
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/mac_save_reg
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/user_data_save
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/user_keep_save
add wave -noupdate -expand -group debug /eth_II_packer_tb/DUT/rdy
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
WaveRestoreZoom {0 ns} {4683 ns}
