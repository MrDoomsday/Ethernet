onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ip_udp_packer_tb/DUT/clk
add wave -noupdate /ip_udp_packer_tb/DUT/reset_n
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/hdr_ip_dest_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/hdr_ip_src_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/hdr_port_dest_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/hdr_port_src_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/user_tdata_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/user_tvld_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/user_tlast_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/user_tkeep_i
add wave -noupdate -expand -group in /ip_udp_packer_tb/DUT/user_trdy_o
add wave -noupdate -expand -group out /ip_udp_packer_tb/DUT/ip_udp_tdata_o
add wave -noupdate -expand -group out /ip_udp_packer_tb/DUT/ip_udp_tvld_o
add wave -noupdate -expand -group out /ip_udp_packer_tb/DUT/ip_udp_tlast_o
add wave -noupdate -expand -group out /ip_udp_packer_tb/DUT/ip_udp_tkeep_o
add wave -noupdate -expand -group out /ip_udp_packer_tb/DUT/ip_udp_rdy_i
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/strm_pipe
add wave -noupdate -expand -group debug -expand -subitemconfig {{/ip_udp_packer_tb/DUT/ipv4_udp_hdr[0]} -expand} /ip_udp_packer_tb/DUT/ipv4_udp_hdr
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ready_pipe
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum01_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum01
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum02_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum02
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum03_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum03
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum04_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum04
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum05_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum05
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum11_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum11
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum12_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum12
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum13_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum13
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum21_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum21
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum22_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum22
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum31_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/udp_checksum_sum31
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum00_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum00
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum01_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum01
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum02_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum02
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum10_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum10
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum11_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum11
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum20_temp
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/ip_checksum_sum20
add wave -noupdate -expand -group debug /ip_udp_packer_tb/DUT/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7678 ns} 0} {{Cursor 2} {3290 ns} 1}
quietly wave cursor active 1
configure wave -namecolwidth 350
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
WaveRestoreZoom {7280 ns} {9360 ns}
