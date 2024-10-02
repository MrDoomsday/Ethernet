/*
	module for aligned packet  
*/
module umstr_arp (

	input 		logic 			clk,
	input 		logic 			reset_n,


//control singal
    //source address - это адрес устройства (можно условно назвать его сетевой картой)
    input       logic   [47:0]  cntrl_mac_src_i, 
    input       logic   [31:0]  cntrl_ip_src_i,
    input       logic   [15:0]  cntrl_port_src_i,

//input packet
    input       logic   [31:0]	arp_request_tdata_i,
    input       logic           arp_request_tvld_i,
    input       logic           arp_request_tlast_i,
	input       logic   [3:0]   arp_request_tkeep_i, 
    output      logic           arp_request_trdy_o,	
	

//output packet
	output 		logic 	[47:0]	arp_response_mac_dest_o,
								arp_response_mac_src_o,
	output 		logic 	[15:0]	arp_response_mac_type_o,
	output 		logic 			arp_response_mac_vld_o,
	input 		logic 			arp_response_mac_rdy_i,

    output      logic   [31:0]  arp_response_tdata_o,
    output      logic           arp_response_tvld_o,
    output      logic           arp_response_tlast_o,
    output      logic   [3:0]   arp_response_tkeep_o,
    input       logic           arp_response_rdy_i

);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
	enum bit [5:0] {
		SC_IDLE,
		SC_CHECK[0:9],
		SC_WAIT_LAST,
		SC_CHECK_TYPE,
		SC_WAIT_ANSWER
	} state_check, state_check_next;//автомат для проверки входящего пакета на принадлежность к протоколу ARP

	reg arp_ok;
	logic arp_request_trdy_next;

	reg [47:0] mac_destination_request, mac_destination_request_r;
	reg [47:0] mac_source_request, mac_source_request_r;
	reg [15:0] mac_type_packet_request, mac_type_packet_request_r;


	reg [15:0] hardware_type_request, hardware_type_request_r;
	reg [15:0] protocol_type_request, protocol_type_request_r;
	reg [15:0] opcode_request, opcode_request_r;



	reg [15:0] hardware_size_protocol_size_request, hardware_size_protocol_size_request_r;
	reg [47:0] sender_mac_address_request, sender_mac_address_request_r;
	reg [31:0] sender_ip_address_request, sender_ip_address_request_r;

	reg [47:0] target_mac_address_request, target_mac_address_request_r;
	reg [31:0] target_ip_address_request, target_ip_address_request_r;

	logic fsm_send_busy, fsm_send_busy_next;

	enum logic [3:0] {
		RP_IDLE,
		RP_SEND_MAC,
		RP_SEND[0:6]
	} state_resp, state_resp_next;
	
	logic resp_rdy;
	logic resp_mac_rdy;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) state_check <= SC_IDLE;
		else state_check <= state_check_next;
	end

	
	always_comb begin
		state_check_next = state_check;
		arp_request_trdy_next = arp_request_trdy_o;
		
		case(state_check)
			SC_IDLE: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK0;
				end
			end
			
			SC_CHECK0: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK1;
				end			
			end
			
			SC_CHECK1: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK2;
				end			
			end
			
			SC_CHECK2: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK3;
				end
			end
			
			SC_CHECK3: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK4;
				end			
			end
			
			SC_CHECK4: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK5;
				end
			end
			
			SC_CHECK5: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK6;
				end
			end
			
			SC_CHECK6: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK7;
				end
			end
			
			SC_CHECK7: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK8;
				end
			end
			
			SC_CHECK8: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) state_check_next = SC_IDLE;
					else state_check_next = SC_CHECK9;
				end
			end
			
			SC_CHECK9: begin
				if(arp_request_tvld_i) begin
					if(arp_request_tlast_i) begin
						arp_request_trdy_next = 1'b0;
						state_check_next = SC_CHECK_TYPE;
					end
					else begin
						state_check_next = SC_WAIT_LAST;
					end
				end
			end

			SC_WAIT_LAST: begin
				if(arp_request_tvld_i && arp_request_tlast_i) begin
					arp_request_trdy_next = 1'b0;//пока мы проверяем пакет, то не хотим принимать что-то еще
					state_check_next = SC_CHECK_TYPE;
				end
			end

			SC_CHECK_TYPE: begin
				if(arp_ok) begin
					if(fsm_send_busy) 
						state_check_next = SC_WAIT_ANSWER;
					else begin
						arp_request_trdy_next = 1'b1;
						state_check_next = SC_IDLE;
					end
				end
				else begin
					arp_request_trdy_next = 1'b1;
					state_check_next = SC_IDLE;
				end
			end

			SC_WAIT_ANSWER: begin
				if(!fsm_send_busy) begin
					arp_request_trdy_next = 1'b1;
					state_check_next = SC_IDLE;
				end
			end
			
			default: state_check_next = SC_IDLE;
		endcase
	end

	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) 
			arp_request_trdy_o <= 1'b1;
		else 
			arp_request_trdy_o <= arp_request_trdy_next;
	end
	

//register arp message 			
	always_ff @(posedge clk) begin
		if(arp_request_trdy_o && arp_request_tvld_i) begin 
			if(state_check == SC_IDLE) begin
				mac_destination_request[47:16] <= arp_request_tdata_i[31:0];
			end

			if(state_check == SC_CHECK0) begin 
				mac_destination_request[15:0] <= arp_request_tdata_i[31:16];
				mac_source_request[47:32] <= arp_request_tdata_i[15:0];
			end

			if(state_check == SC_CHECK1) begin
				mac_source_request[31:0] 	<= arp_request_tdata_i[31:0];
			end

			if(state_check == SC_CHECK2) begin
				mac_type_packet_request		<= arp_request_tdata_i[31:16];			
				hardware_type_request		<= arp_request_tdata_i[15:0];
			end

			if(state_check == SC_CHECK3) begin
				protocol_type_request				<= arp_request_tdata_i[31:16];
				hardware_size_protocol_size_request	<= arp_request_tdata_i[15:0];
			end

			if(state_check == SC_CHECK4) begin
				opcode_request	<= arp_request_tdata_i[31:16];
			end

			if(state_check == SC_CHECK4) begin
				sender_mac_address_request[47:32]	<= arp_request_tdata_i[15:0];
			end

			if(state_check == SC_CHECK5) begin
				sender_mac_address_request[31:0] <= arp_request_tdata_i[31:0];
			end

			if(state_check == SC_CHECK6) begin
				sender_ip_address_request[31:0] <= arp_request_tdata_i[31:0];
			end

			if(state_check == SC_CHECK7) begin
				target_mac_address_request[47:16] <= arp_request_tdata_i[31:0];
			end

			if(state_check == SC_CHECK8) begin
				target_mac_address_request[15:0] <= arp_request_tdata_i[31:16];
				target_ip_address_request[31:16] <= arp_request_tdata_i[15:0];
			end

			if(state_check == SC_CHECK9) begin
				target_ip_address_request[15:0] <= arp_request_tdata_i[31:16];
			end
		end 
	end	


	assign arp_ok = (state_check == SC_CHECK_TYPE | state_check == SC_WAIT_ANSWER) & 
					((mac_destination_request == 48'hFFFFFFFFFFFF) | (mac_destination_request == cntrl_mac_src_i)) & 
					(mac_type_packet_request == 16'h0806) & 
					(hardware_type_request == 16'h0001) & 
					(protocol_type_request == 16'h0800) & 
					(hardware_size_protocol_size_request == {8'h06, 8'h04}) & 
					(opcode_request == 16'h0001) & 
					//((target_mac_address_request == 47'h0) | (target_mac_address_request == coe_mac_source) & //возможно и не потребуется 
					(target_ip_address_request == cntrl_ip_src_i);


//фиксация полей пакета ARP в регистрах - для освобождения автомата по анализу входящих пакетов
	always_ff @(posedge clk) begin
		if(arp_ok && (state_check == SC_CHECK_TYPE || state_check == SC_WAIT_ANSWER) && !fsm_send_busy) begin
			mac_destination_request_r 				<= mac_destination_request;
			mac_source_request_r 					<= mac_source_request;
			mac_type_packet_request_r 				<= mac_type_packet_request;
			hardware_type_request_r 				<= hardware_type_request;
			protocol_type_request_r 				<= protocol_type_request;
			opcode_request_r 						<= opcode_request;
			hardware_size_protocol_size_request_r 	<= hardware_size_protocol_size_request;
			sender_mac_address_request_r 			<= sender_mac_address_request;
			sender_ip_address_request_r 			<= sender_ip_address_request;
			target_mac_address_request_r 			<= target_mac_address_request;
			target_ip_address_request_r 			<= target_ip_address_request;
		end
	end

/*
	Далее конечный автомат, который осуществляет последовательную отправку 
	ответов на ARP-запрос
*/

	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) state_resp <= RP_IDLE;
		else state_resp <= state_resp_next;
	end

	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) fsm_send_busy <= 1'b0;
		else fsm_send_busy <= fsm_send_busy_next;
	end


	always_comb begin
		state_resp_next = state_resp;
		fsm_send_busy_next = fsm_send_busy;
		
		case(state_resp)
			RP_IDLE: begin
				if(arp_ok) begin
					fsm_send_busy_next = 1'b1;
					state_resp_next = RP_SEND_MAC;
				end
				else state_resp_next = RP_IDLE;
			end

			RP_SEND_MAC: begin
				if(resp_mac_rdy) begin
					state_resp_next = RP_SEND0;
				end
			end
			
			RP_SEND0: begin 
				if(resp_rdy) state_resp_next = RP_SEND1;
				else state_resp_next = RP_SEND0;
			end	
							
			RP_SEND1: begin
				if(resp_rdy) state_resp_next = RP_SEND2;
				else state_resp_next = RP_SEND1;
			end
			
			RP_SEND2: begin
				if(resp_rdy) state_resp_next = RP_SEND3;
				else state_resp_next = RP_SEND2;
			end
			
			RP_SEND3: begin
				if(resp_rdy) state_resp_next = RP_SEND4;
				else state_resp_next = RP_SEND3;
			end
			
			RP_SEND4: begin
				if(resp_rdy) state_resp_next = RP_SEND5;
				else state_resp_next = RP_SEND4;
			end
			
			RP_SEND5: begin
				if(resp_rdy) state_resp_next = RP_SEND6;
				else state_resp_next = RP_SEND5;
			end
				
			RP_SEND6: begin
				if(resp_rdy) begin
					fsm_send_busy_next = 1'b0;
					state_resp_next = RP_IDLE;
				end
				else state_resp_next = RP_SEND6;
			end
			
			
			default: state_resp_next = RP_IDLE;
		endcase 
	end

//send mac address
	assign resp_mac_rdy = arp_response_mac_vld_o & ~arp_response_mac_rdy_i ? 1'b0 : 1'b1;
	
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin
			arp_response_mac_vld_o <= 1'b0;
		end
		else if(resp_mac_rdy) begin
			arp_response_mac_vld_o <= (state_resp == RP_SEND_MAC);
		end
	end

	always_ff @ (posedge clk) begin
		if(resp_mac_rdy) begin
			arp_response_mac_dest_o <= mac_source_request_r;
			arp_response_mac_src_o 	<= cntrl_mac_src_i;
			arp_response_mac_type_o <= 16'h0806;
		end
	end


//send payload
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) arp_response_tvld_o <= 1'h0;
		else if(resp_rdy) begin
			case(state_resp)
				RP_SEND0,		
				RP_SEND1,
				RP_SEND2,
				RP_SEND3,
				RP_SEND4,
				RP_SEND5,
				RP_SEND6:		arp_response_tvld_o <= 1'h1;
				default:		arp_response_tvld_o <= 1'h0;
			endcase 
		end
	end
				
	always_ff @(posedge clk) begin
		if(resp_rdy) begin
			arp_response_tdata_o <= 32'h0;
			arp_response_tlast_o <= 1'h0;
			arp_response_tkeep_o <= 4'b1111;

			case(state_resp)
				RP_IDLE: 	arp_response_tkeep_o <= 4'b0000;
				RP_SEND0: 	arp_response_tdata_o <= {16'h0001, 16'h0800};
				RP_SEND1: 	arp_response_tdata_o <= {16'h0604, 16'h0002};
				RP_SEND2: 	arp_response_tdata_o <= cntrl_mac_src_i[47:16];
				RP_SEND3: 	arp_response_tdata_o <= {cntrl_mac_src_i[15:0], cntrl_ip_src_i[31:16]};
				RP_SEND4: 	arp_response_tdata_o <= {cntrl_ip_src_i[15:0], sender_mac_address_request_r[47:32]};
				RP_SEND5: 	arp_response_tdata_o <= sender_mac_address_request_r[31:0];
				RP_SEND6: begin
					arp_response_tdata_o <= sender_ip_address_request_r[31:0];
					arp_response_tlast_o <= 1'b1;
				end

				default: begin
					arp_response_tdata_o <= 32'h0;
					arp_response_tlast_o <= 1'b0;
					arp_response_tkeep_o <= 4'b0000;
				end
			endcase 				
		end
	end
	
	assign resp_rdy = arp_response_tvld_o & ~arp_response_rdy_i ? 1'b0 : 1'b1;



endmodule 