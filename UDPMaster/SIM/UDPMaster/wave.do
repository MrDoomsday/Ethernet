onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /udpmaster_tb/DUT/clk
add wave -noupdate /udpmaster_tb/DUT/reset_n
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_awaddr
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_awprot
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_awvalid
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_awready
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_wdata
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_wstrb
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_wvalid
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_wready
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_bresp
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_bvalid
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_bready
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_araddr
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_arprot
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_arvalid
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_arready
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_rdata
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_rresp
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_rvalid
add wave -noupdate -group AXILite /udpmaster_tb/DUT/s_axil_rready
add wave -noupdate -expand -group user_data /udpmaster_tb/DUT/user_tid_i
add wave -noupdate -expand -group user_data /udpmaster_tb/DUT/user_tdata_i
add wave -noupdate -expand -group user_data /udpmaster_tb/DUT/user_tvld_i
add wave -noupdate -expand -group user_data /udpmaster_tb/DUT/user_tlast_i
add wave -noupdate -expand -group user_data /udpmaster_tb/DUT/user_tkeep_i
add wave -noupdate -expand -group user_data /udpmaster_tb/DUT/user_trdy_o
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awaddr
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awlen
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awsize
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awburst
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awlock
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awcache
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awprot
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awqos
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awregion
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awvalid
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_awready
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_wdata
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_wstrb
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_wlast
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_wvalid
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_wready
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_bresp
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_bvalid
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_bready
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_araddr
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arlen
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arsize
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arburst
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arlock
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arcache
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arprot
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arqos
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arregion
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arvalid
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_arready
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_rdata
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_rresp
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_rlast
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_rvalid
add wave -noupdate -group AXIMaster /udpmaster_tb/DUT/m_axi_rready
add wave -noupdate -expand -group for_tse /udpmaster_tb/DUT/for_tse_tdata_o
add wave -noupdate -expand -group for_tse /udpmaster_tb/DUT/for_tse_tvld_o
add wave -noupdate -expand -group for_tse /udpmaster_tb/DUT/for_tse_tlast_o
add wave -noupdate -expand -group for_tse /udpmaster_tb/DUT/for_tse_tkeep_o
add wave -noupdate -expand -group for_tse /udpmaster_tb/DUT/for_tse_trdy_i
add wave -noupdate -expand -group from_tse /udpmaster_tb/DUT/from_tse_tdata_i
add wave -noupdate -expand -group from_tse /udpmaster_tb/DUT/from_tse_tvld_i
add wave -noupdate -expand -group from_tse /udpmaster_tb/DUT/from_tse_tlast_i
add wave -noupdate -expand -group from_tse /udpmaster_tb/DUT/from_tse_tkeep_i
add wave -noupdate -expand -group from_tse /udpmaster_tb/DUT/from_tse_trdy_o
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_sd_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_sd_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_sd_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_sd_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_sd_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_au_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_au_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_au_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_au_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_au_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_arp_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_arp_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_arp_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_arp_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/splt_arp_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_hdr_mac_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_hdr_mac_src
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_hdr_ip_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_hdr_ip_src
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_hdr_port_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_hdr_port_src
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/sd_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/au_hdr_mac_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/au_hdr_mac_src
add wave -noupdate -group debug /udpmaster_tb/DUT/au_hdr_ip_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/au_hdr_ip_src
add wave -noupdate -group debug /udpmaster_tb/DUT/au_hdr_port_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/au_hdr_port_src
add wave -noupdate -group debug /udpmaster_tb/DUT/au_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/au_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/au_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/au_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/au_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/us_hdr_mac_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/us_hdr_mac_src
add wave -noupdate -group debug /udpmaster_tb/DUT/us_hdr_ip_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/us_hdr_ip_src
add wave -noupdate -group debug /udpmaster_tb/DUT/us_hdr_port_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/us_hdr_port_src
add wave -noupdate -group debug /udpmaster_tb/DUT/us_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/us_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/us_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/us_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/us_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_hdr_mac_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_hdr_mac_src
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_hdr_ip_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_hdr_ip_src
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_hdr_port_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_hdr_port_src
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/mux_trdy
add wave -noupdate -group debug /udpmaster_tb/DUT/ip_udp_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/ip_udp_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/ip_udp_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/ip_udp_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/ip_udp_rdy
add wave -noupdate -group debug /udpmaster_tb/DUT/in_mac_fifo_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/out_mac_fifo_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/in_mac_fifo_tvalid
add wave -noupdate -group debug /udpmaster_tb/DUT/out_mac_fifo_tvalid
add wave -noupdate -group debug /udpmaster_tb/DUT/in_mac_fifo_tready
add wave -noupdate -group debug /udpmaster_tb/DUT/out_mac_fifo_tready
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_mac_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_mac_src
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_mac_vld
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_mac_type
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_mac_rdy
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_tdata
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_tvld
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_tlast
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_tkeep
add wave -noupdate -group debug /udpmaster_tb/DUT/arp_response_rdy
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_mac_src_board
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_ip_src_board
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_port_src_board
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_addr_cell_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_mac_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_ip_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_port_dest
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_cell_dest_wr
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_mac_dest_rdata
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_ip_dest_rdata
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_port_dest_rdata
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_serial_number
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_wrandcode
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_wburstcode
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_rrandcode
add wave -noupdate -group debug /udpmaster_tb/DUT/cntrl_rburstcode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18342670 ns} 1} {{Cursor 2} {18340350 ns} 1} {{Cursor 3} {18340430 ns} 0}
quietly wave cursor active 3
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
WaveRestoreZoom {18340314 ns} {18340703 ns}
