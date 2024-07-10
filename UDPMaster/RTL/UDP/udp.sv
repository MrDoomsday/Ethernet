/*
MAP REGISTER

Destination parameter 
	{3'b000, avmm_address[channel_width-1:0]} - MAC_high
	{3'b001, avmm_address[channel_width-1:0]} - MAC_low
	{3'b010, avmm_address[channel_width-1:0]} - IP
	{3'b011, avmm_address[channel_width-1:0]} - Port

Source parameter
	{3'b100, {channel_width{1'b0}}} - MAC_high
	{3'b101, {channel_width{1'b0}}} - MAC_low
	{3'b110, {channel_width{1'b0}}} - IP
	{3'b111, {channel_width{1'b0}}} - Port


*/

module udp
#
(
	parameter channel_width = 8,
	parameter depth_fifo = 12,

	
	parameter [47:0] mac_src = 48'h38D547C9617C,
	parameter [31:0] ip_src = 32'hC0A80162,
	parameter [15:0] port_src = 16'd666
)
(
	input clk,
	input clk_mm,
	input reset_n,

	
	
	//avsi data
	input 	logic [channel_width-1:0] 	avsi_channel,
	input  	logic [31:0]				avsi_data,
	input  	logic  						avsi_valid,
	output 	logic  						avsi_ready,
	input  	logic  						avsi_sop,
	input  	logic  						avsi_eop,
	input  	logic [1:0] 				avsi_empty,


	//avsi tse
	input  	logic [31:0]	avsi_tse_data,
	input  	logic  			avsi_tse_valid,
	output 	logic  			avsi_tse_ready,
	input  	logic  			avsi_tse_sop,
	input  	logic  			avsi_tse_eop,
	input  	logic [1:0] 	avsi_tse_empty,




	input	logic							avmm_write,
	output 	logic 							avmm_waitrequest,
	input	logic	[31:0]					avmm_writedata,
	input	logic	[channel_width + 2:0]	avmm_address,
	input 	logic	[3:0] 					avmm_byteenable,
	input 	logic 							avmm_read,
	output 	logic [31:0] 					avmm_readdata,


	//avso data		
	output  	logic [31:0]	avso_tse_data,
	output  	logic  			avso_tse_valid,
	output  	logic  			avso_tse_sop,
	output  	logic  			avso_tse_eop,
	input 		logic  			avso_tse_ready,
	output  	logic [1:0] 	avso_tse_empty,
	



	
	//conduit 
	output logic [47:0] coe_mac_source,
	output logic [31:0] coe_ip_source,
	output logic [15:0]	coe_port_source


);




//avso arp reply		
logic [31:0]		arp_data;
logic  				arp_valid;
logic  				arp_sop;
logic  				arp_eop;
logic  				arp_ready;
logic [1:0] 		arp_empty;


//avso udp packet		
logic [31:0]		udp_data;
logic  				udp_valid;
logic  				udp_sop;
logic  				udp_eop;
logic  				udp_ready;
logic [1:0] 		udp_empty;

	
	
	
typedef struct packed 
{
	logic [channel_width-1:0] channel;
	logic [31:0] data;
	logic valid;
	logic sop;
	logic eop;
	logic [1:0] empty;
	logic ready;
} connect_modules_avst;

typedef struct packed 
{
	logic [63:0] data;
	logic valid;
	logic ready;
} connect_modules_descriptor;

connect_modules_avst empty_check_to_receive_packet;

connect_modules_avst 		receive_packet_to_create_packet_avst;
connect_modules_descriptor 	receive_packet_to_create_packet_desc;


connect_modules_avst 		create_packet_to_calculate_parameter_avst;
connect_modules_descriptor	create_packet_to_calculate_parameter_desc;

connect_modules_avst send_packet_to_align_packet_avst;


connect_modules_avst 	calculate_parameter_to_send_packet_avst;
wire [271:0]calculate_parameter_to_send_packet_header;






empty_check empty_check_inst
(
	.clk		(clk),
	.reset_n	(reset_n),


	//avsi data	
	.avsi_channel(avsi_channel),
	.avsi_data	(avsi_data),
	.avsi_valid	(avsi_valid),
	.avsi_sop	(avsi_sop),
	.avsi_eop	(avsi_eop),
	.avsi_ready	(avsi_ready),
	.avsi_empty	(avsi_empty),
			
		
			
	//avso data		
	.avso_channel(empty_check_to_receive_packet.channel),
	.avso_data	(empty_check_to_receive_packet.data),
	.avso_valid	(empty_check_to_receive_packet.valid),
	.avso_sop	(empty_check_to_receive_packet.sop),
	.avso_eop	(empty_check_to_receive_packet.eop),
	.avso_ready	(empty_check_to_receive_packet.ready),
	.avso_empty	(empty_check_to_receive_packet.empty)
		
	
);
defparam empty_check_inst.channel_width = channel_width;








receive_packet receive_packet_inst
(
	.clk		(clk),
	.reset_n	(reset_n),

	//avsi data 
	.avsi_channel(empty_check_to_receive_packet.channel),
	.avsi_data	(empty_check_to_receive_packet.data),
	.avsi_valid	(empty_check_to_receive_packet.valid),
	.avsi_sop	(empty_check_to_receive_packet.sop),
	.avsi_eop	(empty_check_to_receive_packet.eop),
	.avsi_empty	(empty_check_to_receive_packet.empty),
	.avsi_ready	(empty_check_to_receive_packet.ready),		
	
	
	
	//avso data
	.avso_data	(receive_packet_to_create_packet_avst.data),
	.avso_valid	(receive_packet_to_create_packet_avst.valid),
	.avso_sop	(receive_packet_to_create_packet_avst.sop),
	.avso_eop	(receive_packet_to_create_packet_avst.eop),
	.avso_empty	(receive_packet_to_create_packet_avst.empty),
	.avso_ready	(receive_packet_to_create_packet_avst.ready),

	
	.avso_desc_data		(receive_packet_to_create_packet_desc.data),
	.avso_desc_valid	(receive_packet_to_create_packet_desc.valid),
	.avso_desc_ready	(receive_packet_to_create_packet_desc.ready)
);



defparam receive_packet_inst.channel_width = channel_width;
defparam receive_packet_inst.depth_fifo = depth_fifo;








create_packet create_packet_inst
(
	.clk		(clk),
	.reset_n	(reset_n),
		
	//avsi data
	.avsi_data	(receive_packet_to_create_packet_avst.data),
	.avsi_valid	(receive_packet_to_create_packet_avst.valid),
	.avsi_sop	(receive_packet_to_create_packet_avst.sop),
	.avsi_eop	(receive_packet_to_create_packet_avst.eop),
	.avsi_empty	(receive_packet_to_create_packet_avst.empty),
	.avsi_ready	(receive_packet_to_create_packet_avst.ready),	
		

	//avsi descriptor 	
	.avsi_desc_data	(receive_packet_to_create_packet_desc.data),
	.avsi_desc_valid(receive_packet_to_create_packet_desc.valid),
	.avsi_desc_ready(receive_packet_to_create_packet_desc.ready),
		
		
	//avso data
	.avso_data	(create_packet_to_calculate_parameter_avst.data),
	.avso_desc	(create_packet_to_calculate_parameter_desc.data),
	.avso_valid	(create_packet_to_calculate_parameter_avst.valid),
	.avso_ready	(create_packet_to_calculate_parameter_avst.ready),
	.avso_sop	(create_packet_to_calculate_parameter_avst.sop),
	.avso_eop	(create_packet_to_calculate_parameter_avst.eop),
	.avso_empty	(create_packet_to_calculate_parameter_avst.empty)


);


calculate_parameter calculate_parameter_inst
(
	.clk		(clk),
	.clk_mm		(clk_mm),
	.reset_n	(reset_n),



	.avmm_write			(avmm_write),
	.avmm_waitrequest	(avmm_waitrequest),
	.avmm_writedata		(avmm_writedata),
	.avmm_address		(avmm_address),
	.avmm_byteenable	(avmm_byteenable),
	.avmm_read			(avmm_read),
	.avmm_readdata		(avmm_readdata),

		
			
		
//avsi data
	.avsi_data	(create_packet_to_calculate_parameter_avst.data),
	.avsi_desc	(create_packet_to_calculate_parameter_desc.data),
	.avsi_valid	(create_packet_to_calculate_parameter_avst.valid),
	.avsi_ready	(create_packet_to_calculate_parameter_avst.ready),
	.avsi_sop	(create_packet_to_calculate_parameter_avst.sop),
	.avsi_eop	(create_packet_to_calculate_parameter_avst.eop),
	.avsi_empty	(create_packet_to_calculate_parameter_avst.empty),


		

//avso data		
	.avso_data	(calculate_parameter_to_send_packet_avst.data),
	.avso_valid	(calculate_parameter_to_send_packet_avst.valid),
	.avso_sop	(calculate_parameter_to_send_packet_avst.sop),
	.avso_eop	(calculate_parameter_to_send_packet_avst.eop),
	.avso_ready	(calculate_parameter_to_send_packet_avst.ready),
	.avso_empty	(calculate_parameter_to_send_packet_avst.empty),
//header packet 
	.avso_header(calculate_parameter_to_send_packet_header),
		
//Source mac/ip/port
	.avso_mac_src	(coe_mac_source),
	.avso_ip_src	(coe_ip_source),
	.avso_port_src	(coe_port_source),
	
	//update dhcp
	.avsi_ip_src_board_data	(32'h0),
	.avsi_ip_src_board_valid(1'b0)

);

defparam calculate_parameter_inst.channel_width 	= channel_width;
defparam calculate_parameter_inst.mac_src_initial 	= mac_src;
defparam calculate_parameter_inst.ip_src_initial 	= ip_src;
defparam calculate_parameter_inst.port_src_initial 	= port_src;





send_packet send_packet_inst
(
	.clk		(clk),
	.reset_n	(reset_n),


//avsi data		
	.avsi_data	(calculate_parameter_to_send_packet_avst.data),
	.avsi_valid	(calculate_parameter_to_send_packet_avst.valid),
	.avsi_sop	(calculate_parameter_to_send_packet_avst.sop),
	.avsi_eop	(calculate_parameter_to_send_packet_avst.eop),
	.avsi_ready	(calculate_parameter_to_send_packet_avst.ready),
	.avsi_empty	(calculate_parameter_to_send_packet_avst.empty),
	.avsi_header(calculate_parameter_to_send_packet_header),
				
		
//avso data		
	.avso_data	(send_packet_to_align_packet_avst.data),
	.avso_valid	(send_packet_to_align_packet_avst.valid),
	.avso_sop	(send_packet_to_align_packet_avst.sop),
	.avso_eop	(send_packet_to_align_packet_avst.eop),
	.avso_ready	(send_packet_to_align_packet_avst.ready),
	.avso_empty	(send_packet_to_align_packet_avst.empty)
		
);




align_packet align_packet_inst
(
	.clk		(clk),
	.reset_n	(reset_n),


//avsi data		
	.avsi_data	(send_packet_to_align_packet_avst.data),
	.avsi_valid	(send_packet_to_align_packet_avst.valid),
	.avsi_sop	(send_packet_to_align_packet_avst.sop),
	.avsi_eop	(send_packet_to_align_packet_avst.eop),
	.avsi_ready	(send_packet_to_align_packet_avst.ready),
	.avsi_empty	(send_packet_to_align_packet_avst.empty),
				
		
//avso data		
	.avso_data	(udp_data),
	.avso_valid	(udp_valid),
	.avso_sop	(udp_sop),
	.avso_eop	(udp_eop),
	.avso_ready	(udp_ready),
	.avso_empty	(udp_empty)
);



//******************************************************************ARP**********************************************************************

arp arp_inst
(
	.clk		(clk),
	.reset_n	(reset_n),


	//avsi data		
	.avsi_data	(avsi_tse_data),
	.avsi_valid	(avsi_tse_valid),
	.avsi_sop	(avsi_tse_sop),
	.avsi_eop	(avsi_tse_eop),
	.avsi_ready	(avsi_tse_ready),
	.avsi_empty	(avsi_tse_empty),
			
			
	.coe_mac_source		(coe_mac_source),
	.coe_ip_source		(coe_ip_source),
	.coe_port_source	(coe_port_source),
		
			
	//avso data		
	.avso_data	(arp_data),
	.avso_valid	(arp_valid),
	.avso_sop	(arp_sop),
	.avso_eop	(arp_eop),
	.avso_ready	(arp_ready),
	.avso_empty	(arp_empty)
);






multiplexer multiplexer_inst
(
	.clk		(clk),
	.reset_n	(reset_n),
		
	//one channel
	//.avsi_one_channel	(),
	.avsi_one_data	(udp_data),
	.avsi_one_valid	(udp_valid),
	.avsi_one_sop	(udp_sop),
	.avsi_one_eop	(udp_eop),
	.avsi_one_empty	(udp_empty),
	.avsi_one_ready	(udp_ready),
		
	//two channel
	//.avsi_two_channel	(),
	.avsi_two_data	(arp_data),
	.avsi_two_valid	(arp_valid),
	.avsi_two_sop	(arp_sop),
	.avsi_two_eop	(arp_eop),
	.avsi_two_empty	(arp_empty),
	.avsi_two_ready	(arp_ready),
		
		
	//output 
	//.avso_channel	(),
	.avso_data		(avso_tse_data),
	.avso_valid		(avso_tse_valid),
	.avso_sop		(avso_tse_sop),
	.avso_eop		(avso_tse_eop),
	.avso_empty		(avso_tse_empty),
	.avso_ready		(avso_tse_ready)
		

);

defparam multiplexer_inst.data_width = 32;
defparam multiplexer_inst.empty_width = 2;
defparam multiplexer_inst.channel_width = 1;


		




endmodule 