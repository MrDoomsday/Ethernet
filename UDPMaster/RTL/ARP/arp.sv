/*
	module for aligned packet  
*/

module arp
(

	input clk,
	input reset_n,


	//avsi data
	input  	logic [31:0]					avsi_data,
	input  	logic  							avsi_valid,
	output 	logic  							avsi_ready,
	input  	logic  							avsi_sop,
	input  	logic  							avsi_eop,
	input  	logic [1:0] 					avsi_empty,


	
	input logic [47:0] coe_mac_source,
	input logic [31:0] coe_ip_source,
	input logic [15:0] coe_port_source,
	
	

	//avso data		
	output  	logic [31:0]		avso_data,
	output  	logic  				avso_valid,
	output  	logic  				avso_sop,
	output  	logic  				avso_eop,
	input 		logic  				avso_ready,
	output  	logic [1:0] 		avso_empty


);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

	reg [47:0] mac_board;
	reg [31:0] ip_board;
	reg [15:0] port_board;

	typedef struct packed 
	{
		logic [31:0] 	data;
		logic 			valid;
		logic 			sop;
		logic 			eop;
		logic [1:0] 	empty;
	} stream;


	stream stream_f [2:0];
	reg [7:0] counter;
	reg arp_ok;


	reg [47:0] mac_destination_request, mac_destination_request_r;
	reg [47:0] mac_source_request, mac_source_request_r;
	reg [15:0] mac_type_packet_request, mac_type_packet_request_r;


	reg [15:0] hardware_type_request, hardware_type_request_r;
	reg [15:0] protocol_type_request, protocol_type_request_r;
	reg [15:0] opcode_request, opcode_request;



	reg [15:0] hardware_size_protocol_size_request, hardware_size_protocol_size_request_r;
	reg [47:0] sender_mac_address_request, sender_mac_address_request_r;
	reg [31:0] sender_ip_address_request, sender_ip_address_request_r;

	reg [47:0] target_mac_address_request, target_mac_address_request_r;
	reg [31:0] target_ip_address_request, target_ip_address_request_r;



	enum bit [3:0] {
		idle, 
		send_0, 
		send_1, 
		send_2, 
		send_3, 
		send_4, 
		send_5, 
		send_6, 
		send_7, 
		send_8, 
		send_9, 
		send_10, 
		send_11, 
		send_12, 
		send_13, 
		send_14
	} state, state_next;

	bit fsm_busy;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

	always_ff @ (posedge clk) begin
		mac_board 	<= coe_mac_source;
		ip_board 	<= coe_ip_source;
		port_board 	<= coe_port_source;
	end

//cascade 0 
	always_ff @ (posedge clk or negedge reset_n) begin
		if(!reset_n) stream_f[0].valid <= 'h0;
		else if(avsi_ready) stream_f[0].valid <= avsi_valid;
	end

	always_ff @ (posedge clk) begin
		if(avsi_ready) begin
			stream_f[0].data 	<= avsi_data;
			stream_f[0].sop 	<= avsi_sop;
			stream_f[0].eop 	<= avsi_eop;
			stream_f[0].empty 	<= avsi_empty;
		end
	end

	always_ff @ (posedge clk or negedge reset_n) begin
		if(!reset_n) counter <= 'h0;
		else if(avsi_ready && avsi_valid) begin
			if(avsi_sop) counter <= 8'h0;
			else counter <= counter + 1'b1;
		end
	end




			
//cascade 1
//register arp message 			
always_ff @ (posedge clk) begin
	if(avsi_ready && stream_f[0].valid) begin 
		if(counter == 16'h0) mac_destination_request[47:16] 		<= stream_f[0].data[31:0];
		if(counter == 16'h1) mac_destination_request[15:0] 			<= stream_f[0].data[31:16];
		if(counter == 16'h1) mac_source_request[47:32] 				<= stream_f[0].data[15:0];
		if(counter == 16'h2) mac_source_request[31:0] 				<= stream_f[0].data[31:0];		
		if(counter == 16'h3) mac_type_packet_request 				<= stream_f[0].data[31:16];			
		if(counter == 16'h3) hardware_type_request 					<= stream_f[0].data[15:0];
		if(counter == 16'h3) protocol_type_request 					<= stream_f[0].data[31:16];
		if(counter == 16'h4) hardware_size_protocol_size_request 	<= stream_f[0].data[15:0];
		if(counter == 16'h5) opcode_request 						<= stream_f[0].data[31:16];
		if(counter == 16'h5) sender_mac_address_request[47:32] 		<= stream_f[0].data[15:0];
		if(counter == 16'h6) sender_mac_address_request[31:0] 		<= stream_f[0].data[31:0];
		if(counter == 16'h7) sender_ip_address_request[31:0] 		<= stream_f[0].data[31:0];
		if(counter == 16'h8) target_mac_address_request[47:16] 		<= stream_f[0].data[31:0];
		if(counter == 16'h9) target_mac_address_request[15:0] 		<= stream_f[0].data[31:16];
		if(counter == 16'h9) target_ip_address_request[31:16] 		<= stream_f[0].data[15:0];
		if(counter == 16'hA) target_ip_address_request[15:0] 		<= stream_f[0].data[31:16];
	end 
end	

always_ff @ (posedge clk or negedge reset_n) begin
	if(!reset_n) stream_f[1] <= 'h0;
	else if(avsi_ready) stream_f[1] <= stream_f[0];
end

				
assign arp_ok = 	stream_f[1].valid & stream_f[1].eop &	
					((mac_destination_request == 48'hFFFFFFFFFFFF) | (mac_destination_request == mac_board)) & 
					(mac_type_packet_request == 16'h0806) & 
					(hardware_type_request == 16'h0001) & 
					(protocol_type_request == 16'h0800) & 
					(hardware_size_protocol_size_request == {8'h06, 8'h04}) & 
					(opcode_request == 16'h0001) & 
					//((target_mac_address_request == 47'h0) | (target_mac_address_request == coe_mac_source) & //возможно и не потребуется 
					(target_ip_address_request == ip_board);
						
//фиксация полей пакета ARP в регистрах
	always_ff @ (posedge clk) begin
		if(fsm_busy) fsm_busy <= (state == state10) & avso_ready ? 1'b0 : 1'b1;
		else fsm_busy <= arp_ok & (state == idle);

		if(arp_ok && !fsm_busy) begin
			mac_destination_request_r 				<= mac_destination_request;
			mac_source_request_r 					<= mac_source_request;
			mac_type_packet_request_r 				<= mac_type_packet_request;
			hardware_type_request_r 				<= hardware_type_request;
			protocol_type_request_r 				<= protocol_type_request;
			opcode_request 							<= opcode_request;
			hardware_size_protocol_size_request_r 	<= hardware_size_protocol_size_request;
			sender_mac_address_request_r 			<= sender_mac_address_request;
			sender_ip_address_request_r 			<= sender_ip_address_request;
			target_mac_address_request_r 			<= target_mac_address_request;
			target_ip_address_request_r 			<= target_ip_address_request;
		end
	end

/*
	Далее идет кончный автомат, который осуществляет последовательную отправку 
	ответов на ARP-запрос
*/
assign avsi_ready = ~(arp_ok & fsm_busy);

always_ff @ (posedge clk or negedge reset_n) begin
	if(!reset_n) state <= idle;
	else state <= state_next;
end		
		
		
always_comb begin
	case(state)
		idle:		if(arp_ok)		state_next = send_0;
					else 			state_next = idle;
						
		send_0:		if(avso_ready)	state_next = send_1;
					else 			state_next = send_0;
						
						
		send_1:		if(avso_ready)	state_next = send_2;
					else 			state_next = send_1;
						
		send_2:		if(avso_ready)	state_next = send_3;
					else 			state_next = send_2;
						
		send_3:		if(avso_ready)	state_next = send_4;
					else 			state_next = send_3;
						
		send_4:		if(avso_ready)	state_next = send_5;
					else 			state_next = send_4;
						
		send_5:		if(avso_ready)	state_next = send_6;
					else 			state_next = send_5;
						
		send_6:		if(avso_ready)	state_next = send_7;
					else 			state_next = send_6;
						
		send_7:		if(avso_ready)	state_next = send_8;
					else 			state_next = send_7;
						
		send_8:		if(avso_ready)	state_next = send_9;
					else 			state_next = send_8;
						
		send_9:		if(avso_ready)	state_next = send_10;
					else 			state_next = send_9;
						
		send_10:	if(avso_ready)	state_next = idle;
					else 			state_next = send_10;
						
		default:					state_next = idle;
	endcase 
end


				
	
always_ff @ (posedge clk or negedge reset_n)
	if(!reset_n) avso_valid <= 1'h0;
	else if(avso_ready) begin
		case(state)
			send_0,		
			send_1,
			send_2,
			send_3,
			send_4,
			send_5,
			send_6,
			send_7,
			send_8,
			send_9,
			send_10:		avso_valid <= 1'h1;
			default:		avso_valid <= 1'h0;
		endcase 
	end
	
				
always_ff @ (posedge clk) begin
	if(avso_ready) begin
		avso_data <= 32'h0;
		avso_sop <= 1'h0;
		avso_eop <= 1'h0;

		case(state)
			send_0:	begin
				avso_data <= mac_source_request_r[47:16];
				avso_sop <= 1'b1;
			end
			send_1:	avso_data <= {mac_source_request_r[15:0], mac_board[47:32]};
			send_2:	avso_data <= mac_board[31:0];
			send_3:	avso_data <= {16'h0806, 16'h0001};
			send_4:	avso_data <= {16'h0800, 16'h0604};
			send_5:	avso_data <= {16'h0002, mac_board[47:32]};
			send_6:	avso_data <= mac_board[31:0];
			send_7:	avso_data <= ip_board[31:0];
			send_8:	avso_data <= sender_mac_address_request_r[47:16];
			send_9:	avso_data <= {sender_mac_address_request_r[15:0], sender_ip_address_request_r[31:16]};
			send_10: begin
				avso_data <= {sender_ip_address_request_r[15:0], 16'h0};
				avso_eop <= 1'b1;
			end
			default: begin
				avso_data <= 32'h0;
				avso_sop <= 1'b0;
				avso_eop <= 1'b0;
			end
		endcase 				
	end
end			

assign avso_empty = 2'b00;
	
endmodule 