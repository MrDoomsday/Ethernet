module ip_udp_packer #(
    parameter FIFO_SIZE_DATA = 10,
    parameter FIFO_SIZE_HDR = 10
)(
    input       logic clk,
    input       logic reset_n,

    //заголовок идет синхронно с пакетом (при приеме первого слова заголовок уже выставлен)
    input       logic   [31:0]  hdr_ip_dest_i, 
                                hdr_ip_src_i,//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    input       logic   [15:0]  hdr_port_dest_i, 
                                hdr_port_src_i,

    input       logic   [31:0]  user_tdata_i,
    input       logic           user_tvld_i,
    input       logic           user_tlast_i,
	input       logic   [3:0]   user_tkeep_i, 
    output      logic           user_trdy_o,


    output      logic   [31:0]  ip_udp_tdata_o,
    output      logic           ip_udp_tvld_o,
    output      logic           ip_udp_tlast_o,
    output      logic   [3:0]   ip_udp_tkeep_o,
    input       logic           ip_udp_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*
    Спецификация в rfc791
    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |Version|  IHL  |Type of Service|          Total Length         |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |         Identification        |Flags|      Fragment Offset    |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |  Time to Live |    Protocol   |         Header Checksum       |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                       Source Address                          |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                    Destination Address                        |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    |                    Options                    |    Padding    |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

    Что будет использоваться по умолчанию
    {16'h4500, total length[15:0]}
    {16'h0000, 16'h0000}
    {8'hFF, 8'h11, CSum[15:0]}
    IP_SRC[31:0]
    IP_DST[31:0]



    Спецификация rfc768
    Заголовок UDP-пакета
    0      7 8     15 16    23 24    31
    +--------+--------+--------+--------+
    |     Source      |   Destination   |
    |      Port       |      Port       |
    +--------+--------+--------+--------+
    |                 |                 |
    |     Length      |    Checksum     |
    +--------+--------+--------+--------+

    //псевдозаголовок для вычисления контрольной суммы
    0      7 8     15 16    23 24    31
    +--------+--------+--------+--------+
    |          source address           |
    +--------+--------+--------+--------+
    |        destination address        |
    +--------+--------+--------+--------+
    |  zero  |protocol|   UDP length    |
    +--------+--------+--------+--------+
*/

	typedef struct packed
	{	
		//ip header - 160 bit
		logic [15:0] ip_ver_dsf;//0x4500
		logic [15:0] ip_total_length;
		logic [15:0] ip_identificator;
		logic [15:0] ip_offset_frag;//0x0000
		logic [7:0]  ip_time_to_live;
		logic [7:0]  ip_protocol;//udp
		logic [15:0] ip_checksum;
		logic [31:0] ip_src;
		logic [31:0] ip_dst;
		
		//udp header - 64 bit
		logic [15:0] udp_port_src;
		logic [15:0] udp_port_dst;
		logic [15:0] udp_length;
		logic [15:0] udp_checksum;	
	} ipv4_udp_header; 

	typedef struct packed 
	{
		logic [31:0] 	tdata;
		logic 			tvalid;
		logic 			tlast;
		logic [3:0]		tkeep;
	} stream_pipe;

	stream_pipe [6:0] strm_pipe;
	ipv4_udp_header [6:0] ipv4_udp_hdr;

	logic ready_pipe;

			
			
//udp calculation checksum
	//cascade 0
	reg [16:0] udp_checksum_sum01_temp;
	reg [15:0] udp_checksum_sum01;
	reg [16:0] udp_checksum_sum02_temp;
	reg [15:0] udp_checksum_sum02;
	reg [16:0] udp_checksum_sum03_temp;
	reg [15:0] udp_checksum_sum03;
	reg [16:0] udp_checksum_sum04_temp;
	reg [15:0] udp_checksum_sum04;
	reg [16:0] udp_checksum_sum05_temp;
	reg [15:0] udp_checksum_sum05;
	//cascade 1
	reg [16:0] udp_checksum_sum11_temp;
	reg [15:0] udp_checksum_sum11;
	reg [16:0] udp_checksum_sum12_temp;
	reg [15:0] udp_checksum_sum12;
	reg [16:0] udp_checksum_sum13_temp;
	reg [15:0] udp_checksum_sum13;
	//cascade 2
	reg [16:0] udp_checksum_sum21_temp;
	reg [15:0] udp_checksum_sum21;
	reg [16:0] udp_checksum_sum22_temp;
	reg [15:0] udp_checksum_sum22;
	//cascade 3
	reg [16:0] udp_checksum_sum31_temp;
	reg [15:0] udp_checksum_sum31;
	
	// ip calculation checksum 
	//cascade 0
	reg [16:0] ip_checksum_sum00_temp;
	reg [15:0] ip_checksum_sum00;
	reg [16:0] ip_checksum_sum01_temp;
	reg [15:0] ip_checksum_sum01;
	reg [16:0] ip_checksum_sum02_temp;
	reg [15:0] ip_checksum_sum02;
	//cascade 1
	reg [16:0] ip_checksum_sum10_temp;
	reg [15:0] ip_checksum_sum10;
	reg [16:0] ip_checksum_sum11_temp;
	reg [15:0] ip_checksum_sum11;	
	//cascade 2
	reg [16:0] ip_checksum_sum20_temp;
	reg [15:0] ip_checksum_sum20;
	
//конечный автомат для отправки пакета IP/UDP
	enum logic [3:0] {
		IDLE,
		SEND_IP_LEN, 
		SEND_IP_ID, 
		SEND_IP_CSUM, 
		SEND_IP_SRC, 
		SEND_IP_DST, 
		SEND_UDP_PORTS,
		SEND_UDP_LEN_CSUM,
		SEND_USER_DATA
	} state, state_next;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
	get_stream_len_csum #(
		.FIFO_SIZE_DATA(FIFO_SIZE_DATA),
		.FIFO_SIZE_HDR(FIFO_SIZE_HDR)
	) get_stream_len_csum_inst (
		.clk                (clk		),
		.reset_n            (reset_n	),

	//заголовок идет синхронно с пакетом (при приеме первого слова заголовок уже выставлен)
		.hdr_ip_dest_i      (hdr_ip_dest_i		), 
		.hdr_ip_src_i       (hdr_ip_src_i		),
		.hdr_port_dest_i    (hdr_port_dest_i	), 
		.hdr_port_src_i     (hdr_port_src_i		),
		.user_tdata_i       (user_tdata_i		),
		.user_tvld_i        (user_tvld_i		),
		.user_tlast_i       (user_tlast_i		),
		.user_tkeep_i       (user_tkeep_i		), 
		.user_trdy_o        (user_trdy_o		),

	//выходной поток
		.hdr_ip_dest_o      (ipv4_udp_hdr[0].ip_dst			), 
		.hdr_ip_src_o       (ipv4_udp_hdr[0].ip_src			),
		.hdr_port_dest_o    (ipv4_udp_hdr[0].udp_port_dst	), 
		.hdr_port_src_o     (ipv4_udp_hdr[0].udp_port_src	),
		.user_data_csum_o   (ipv4_udp_hdr[0].udp_checksum	),
		.user_data_len_o    (ipv4_udp_hdr[0].udp_length		), 

		.user_tdata_o       (strm_pipe[0].tdata		),
		.user_tvld_o        (strm_pipe[0].tvalid	),
		.user_tlast_o       (strm_pipe[0].tlast		),
		.user_tkeep_o       (strm_pipe[0].tkeep		),
		.user_trdy_i        (ready_pipe				)
	);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
//cascade 1	
/*		
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin 
			strm_pipe[1].tvalid <= 1'h0;
		end 
		else if(ready_pipe) begin 
			strm_pipe[1].tvalid <= strm_pipe[0].tvalid;
		end 
	end

	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			strm_pipe[1].tdata <= strm_pipe[0].tdata;
			strm_pipe[1].tlast <= strm_pipe[0].tlast;
			strm_pipe[1].tkeep <= strm_pipe[0].tkeep;
		end 
	end


	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			//ip
			ipv4_udp_hdr[1].ip_total_length 	<= ipv4_udp_hdr[0].ip_total_length + 5'd28;//length data + 8 byte header udp + 20 byte header ip 
			ipv4_udp_hdr[1].ip_identificator 	<= 16'h0;
			//udp
			ipv4_udp_hdr[1].udp_length 			<= ipv4_udp_hdr[0].udp_length + 8'h8;//length data + length udp 
			ipv4_udp_hdr[1].udp_checksum 		<= ipv4_udp_hdr[0].udp_checksum;//not full calculated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end 
	end
*/
//
	assign strm_pipe[1] 					= 	strm_pipe[0];
	assign ipv4_udp_hdr[1].ip_src 			= 	ipv4_udp_hdr[0].ip_src;
	assign ipv4_udp_hdr[1].ip_dst 			= 	ipv4_udp_hdr[0].ip_dst;
	assign ipv4_udp_hdr[1].ip_total_length 	= 	ipv4_udp_hdr[0].udp_length + 5'd28;//length data + 8 byte header udp + 20 byte header ip 
	assign ipv4_udp_hdr[1].ip_identificator = 	16'h0;

	assign ipv4_udp_hdr[1].udp_length 		= 	ipv4_udp_hdr[0].udp_length + 8'h8;//length data + length udp 
	assign ipv4_udp_hdr[1].udp_checksum 	= 	ipv4_udp_hdr[0].udp_checksum;//not full calculated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	assign ipv4_udp_hdr[1].udp_port_src 	= 	ipv4_udp_hdr[0].udp_port_src;
	assign ipv4_udp_hdr[1].udp_port_dst 	= 	ipv4_udp_hdr[0].udp_port_dst;
			
//*********************************************************************************************************************************************************************************************************************************			
//cascade 2
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin 
			strm_pipe[2].tvalid <= 1'h0;
		end 
		else if(ready_pipe) begin 
			strm_pipe[2].tvalid <= strm_pipe[1].tvalid;
		end 
	end

	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			strm_pipe[2].tdata <= strm_pipe[1].tdata;
			strm_pipe[2].tlast <= strm_pipe[1].tlast;
			strm_pipe[2].tkeep <= strm_pipe[1].tkeep;
		end 
	end

		
		
	always_ff @(posedge clk) begin
		if(ready_pipe) begin
			//ip
			ipv4_udp_hdr[2].ip_total_length 		<= ipv4_udp_hdr[1].ip_total_length;//length data + 8 byte header udp + 20 byte header ip 
			ipv4_udp_hdr[2].ip_identificator 		<= ipv4_udp_hdr[1].ip_identificator;
			ipv4_udp_hdr[2].ip_src 					<= ipv4_udp_hdr[1].ip_src;
			ipv4_udp_hdr[2].ip_dst 					<= ipv4_udp_hdr[1].ip_dst;
			
			//udp
			ipv4_udp_hdr[2].udp_port_src 			<= ipv4_udp_hdr[1].udp_port_src;
			ipv4_udp_hdr[2].udp_port_dst 			<= ipv4_udp_hdr[1].udp_port_dst;
			ipv4_udp_hdr[2].udp_length 				<= ipv4_udp_hdr[1].udp_length;//length data
			ipv4_udp_hdr[2].udp_checksum 			<= ipv4_udp_hdr[1].udp_checksum;//not full calculated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end 
	end	

	assign	udp_checksum_sum01_temp = ipv4_udp_hdr[2].ip_src[31:16] + ipv4_udp_hdr[2].ip_src[15:0];
	assign	udp_checksum_sum02_temp = ipv4_udp_hdr[2].ip_dst[31:16] + ipv4_udp_hdr[2].ip_dst[15:0];

	assign	udp_checksum_sum03_temp = ipv4_udp_hdr[2].udp_length + 8'h11;//8'h11 = {8'h0, 8'h11}
	assign	udp_checksum_sum04_temp	= ipv4_udp_hdr[2].udp_port_src[15:0] + ipv4_udp_hdr[2].udp_port_dst[15:0];				
	assign	udp_checksum_sum05_temp = ipv4_udp_hdr[2].udp_length + ipv4_udp_hdr[2].udp_checksum;

		
	
//*********************************************************************************************************************************************************************************************************************************
//cascade 3 	
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin 
			strm_pipe[3].tvalid <= 1'h0;
		end 
		else if(ready_pipe) begin 
			strm_pipe[3].tvalid <= strm_pipe[2].tvalid;
		end 
	end

	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			strm_pipe[3].tdata <= strm_pipe[2].tdata;
			strm_pipe[3].tlast <= strm_pipe[2].tlast;
			strm_pipe[3].tkeep <= strm_pipe[2].tkeep;
		end 
	end


					
	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			//ip
			ipv4_udp_hdr[3].ip_total_length 	<= ipv4_udp_hdr[2].ip_total_length;//length data + 8 byte header udp + 20 byte header ip 
			ipv4_udp_hdr[3].ip_identificator 	<= ipv4_udp_hdr[2].ip_identificator;
			ipv4_udp_hdr[3].ip_src 				<= ipv4_udp_hdr[2].ip_src;
			ipv4_udp_hdr[3].ip_dst 				<= ipv4_udp_hdr[2].ip_dst;
			
			//udp
			ipv4_udp_hdr[3].udp_port_src 		<= ipv4_udp_hdr[2].udp_port_src;
			ipv4_udp_hdr[3].udp_port_dst 		<= ipv4_udp_hdr[2].udp_port_dst;
			ipv4_udp_hdr[3].udp_length 			<= ipv4_udp_hdr[2].udp_length;//length data
			ipv4_udp_hdr[3].udp_checksum 		<= ipv4_udp_hdr[2].udp_checksum;//not full calculated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end 
	end
	
//checksum udp calculate;
	always_ff @(posedge clk) begin
		if(ready_pipe && strm_pipe[2].tvalid) begin 
			udp_checksum_sum01 <= udp_checksum_sum01_temp[15:0] + udp_checksum_sum01_temp[16];//source IP[31:16] + source IP[15:0]
			udp_checksum_sum02 <= udp_checksum_sum02_temp[15:0] + udp_checksum_sum02_temp[16];//destination IP[31:16] + destination IP[15:0]
			udp_checksum_sum03 <= udp_checksum_sum03_temp[15:0] + udp_checksum_sum03_temp[16];//{zeros, protocol} + UDP_length
			udp_checksum_sum04 <= udp_checksum_sum04_temp[15:0] + udp_checksum_sum04_temp[16];//source port + destination port 
			udp_checksum_sum05 <= udp_checksum_sum05_temp[15:0] + udp_checksum_sum05_temp[16];//length data + crc_data
		end 
	end
	
//checksum udp calculate - continue;
	assign	udp_checksum_sum11_temp = udp_checksum_sum01 + udp_checksum_sum02;
	assign	udp_checksum_sum12_temp = udp_checksum_sum03 + udp_checksum_sum04;



//checksum ip calculate			
	assign ip_checksum_sum00_temp = 16'hC511 						+ ipv4_udp_hdr[3].ip_total_length + ipv4_udp_hdr[3].ip_identificator;//16'hC511 = 16'h4500 + 16'h0000 + 16'8011; - add constant header
	assign ip_checksum_sum01_temp = ipv4_udp_hdr[3].ip_src[31:16] 	+ ipv4_udp_hdr[3].ip_src[15:0];
	assign ip_checksum_sum02_temp = ipv4_udp_hdr[3].ip_dst[31:16] 	+ ipv4_udp_hdr[3].ip_dst[15:0];
	

	
	
//*********************************************************************************************************************************************************************************************************************************
//cascade 4 	
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin 
			strm_pipe[4].tvalid <= 1'h0;
		end 
		else if(ready_pipe) begin 
			strm_pipe[4].tvalid <= strm_pipe[3].tvalid;
		end 
	end

	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			strm_pipe[4].tdata <= strm_pipe[3].tdata;
			strm_pipe[4].tlast <= strm_pipe[3].tlast;
			strm_pipe[4].tkeep <= strm_pipe[3].tkeep;
		end 
	end

					
					
					
	always_ff @(posedge clk) begin
		if(ready_pipe) begin		
			//ip
			ipv4_udp_hdr[4].ip_total_length 	<= ipv4_udp_hdr[3].ip_total_length;//length data + 8 byte header udp + 20 byte header ip 
			ipv4_udp_hdr[4].ip_identificator 	<= ipv4_udp_hdr[3].ip_identificator;
			ipv4_udp_hdr[4].ip_src 				<= ipv4_udp_hdr[3].ip_src;
			ipv4_udp_hdr[4].ip_dst 				<= ipv4_udp_hdr[3].ip_dst;
			
			//udp
			ipv4_udp_hdr[4].udp_port_src 		<= ipv4_udp_hdr[3].udp_port_src;
			ipv4_udp_hdr[4].udp_port_dst 		<= ipv4_udp_hdr[3].udp_port_dst;
			ipv4_udp_hdr[4].udp_length 			<= ipv4_udp_hdr[3].udp_length;//length data + + length udp header (8 byte)
			ipv4_udp_hdr[4].udp_checksum 		<= ipv4_udp_hdr[3].udp_checksum;//not full calculated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end 
	end
		
		


	always_ff @(posedge clk) begin
		if(ready_pipe && strm_pipe[3].tvalid) begin 
			udp_checksum_sum11 <= udp_checksum_sum11_temp[15:0] + udp_checksum_sum11_temp[16];//source IP[31:16] + source IP[15:0]
			udp_checksum_sum12 <= udp_checksum_sum12_temp[15:0] + udp_checksum_sum12_temp[16];//destination IP[31:16] + destination IP[15:0]
			udp_checksum_sum13 <= udp_checksum_sum05;

			ip_checksum_sum00 <= ip_checksum_sum00_temp[15:0] + ip_checksum_sum00_temp[16];
			ip_checksum_sum01 <= ip_checksum_sum01_temp[15:0] + ip_checksum_sum01_temp[16];
			ip_checksum_sum02 <= ip_checksum_sum02_temp[15:0] + ip_checksum_sum02_temp[16];
		end 
	end

//checksum udp calculate - continue;
	assign	udp_checksum_sum21_temp = udp_checksum_sum11 + udp_checksum_sum12;

//checksum ip calculate			
	assign ip_checksum_sum10_temp = ip_checksum_sum00 + ip_checksum_sum01;			
		
	



	
//*********************************************************************************************************************************************************************************************************************************
//cascade 5	
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin 
			strm_pipe[5].tvalid <= 1'h0;
		end 
		else if(ready_pipe) begin 
			strm_pipe[5].tvalid <= strm_pipe[4].tvalid;
		end 
	end

	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			strm_pipe[5].tdata <= strm_pipe[4].tdata;
			strm_pipe[5].tlast <= strm_pipe[4].tlast;
			strm_pipe[5].tkeep <= strm_pipe[4].tkeep;
		end 
	end
					
				
					
	always_ff @(posedge clk) begin
		if(ready_pipe) begin
			//ip
			ipv4_udp_hdr[5].ip_total_length 	<= ipv4_udp_hdr[4].ip_total_length;//length data + 8 byte header udp + 20 byte header ip 
			ipv4_udp_hdr[5].ip_identificator 	<= ipv4_udp_hdr[4].ip_identificator;
			ipv4_udp_hdr[5].ip_src 				<= ipv4_udp_hdr[4].ip_src;
			ipv4_udp_hdr[5].ip_dst 				<= ipv4_udp_hdr[4].ip_dst;
			
			//udp
			ipv4_udp_hdr[5].udp_port_src 		<= ipv4_udp_hdr[4].udp_port_src;
			ipv4_udp_hdr[5].udp_port_dst 		<= ipv4_udp_hdr[4].udp_port_dst;
			ipv4_udp_hdr[5].udp_length 			<= ipv4_udp_hdr[4].udp_length;//length data + + length udp header (8 byte)
			ipv4_udp_hdr[5].udp_checksum 		<= ipv4_udp_hdr[4].udp_checksum;//not full calculated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end 
	end	
		
		
	always_ff @(posedge clk) begin
		if(ready_pipe && strm_pipe[4].tvalid) begin 
			udp_checksum_sum21 <= udp_checksum_sum21_temp[15:0] + udp_checksum_sum21_temp[16];
			udp_checksum_sum22 <= udp_checksum_sum13;

			ip_checksum_sum10 <= ip_checksum_sum10_temp[15:0] + ip_checksum_sum10_temp[16];
			ip_checksum_sum11 <= ip_checksum_sum02;
		end 
	end		

	
//checksum udp calculate - continue;
	assign	udp_checksum_sum31_temp = udp_checksum_sum21 + udp_checksum_sum22;

//checksum ip calculate - continue;
	assign ip_checksum_sum20_temp = ip_checksum_sum10 + ip_checksum_sum11;





//*********************************************************************************************************************************************************************************************************************************
//cascade 6
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) begin 
			strm_pipe[6].tvalid <= 1'h0;
		end 
		else if(ready_pipe) begin 
			strm_pipe[6].tvalid <= strm_pipe[5].tvalid;
		end 
	end

	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			strm_pipe[6].tdata <= strm_pipe[5].tdata;
			strm_pipe[6].tlast <= strm_pipe[5].tlast;
			strm_pipe[6].tkeep <= strm_pipe[5].tkeep;
		end 
	end
					
					
					
	always_ff @(posedge clk) begin
		if(ready_pipe) begin 
			//ip
			ipv4_udp_hdr[6].ip_total_length 		<= ipv4_udp_hdr[5].ip_total_length;// 16 bit
			ipv4_udp_hdr[6].ip_identificator 		<= ipv4_udp_hdr[5].ip_identificator;//16 bit
			ipv4_udp_hdr[6].ip_src 					<= ipv4_udp_hdr[5].ip_src;//32 bit
			ipv4_udp_hdr[6].ip_dst 					<= ipv4_udp_hdr[5].ip_dst;//32 bit
			ipv4_udp_hdr[6].ip_checksum 			<= ~(ip_checksum_sum20_temp[15:0] + ip_checksum_sum20_temp[16]);//16 bit
			
			//udp
			ipv4_udp_hdr[6].udp_port_src 			<= ipv4_udp_hdr[5].udp_port_src;//16 bit 
			ipv4_udp_hdr[6].udp_port_dst 			<= ipv4_udp_hdr[5].udp_port_dst;//16 bit 
			ipv4_udp_hdr[6].udp_length 				<= ipv4_udp_hdr[5].udp_length;//16 bit 
			ipv4_udp_hdr[6].udp_checksum 			<= ~(udp_checksum_sum31_temp[15:0] + udp_checksum_sum31_temp[16]);//16 bit
		end 
	end


//отправка IP/UDP-пакета
	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) state <= IDLE;
		else state <= state_next;
	end

	always_comb begin
		state_next = state;
		ready_pipe = ~strm_pipe[6].tvalid;

		case(state)
			IDLE: begin
				if(strm_pipe[6].tvalid) begin
					state_next = SEND_IP_LEN;
				end
			end

			SEND_IP_LEN: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_IP_ID;
				end
			end 

			SEND_IP_ID: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_IP_CSUM;
				end
			end 

			SEND_IP_CSUM: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_IP_SRC;
				end
			end 

			SEND_IP_SRC: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_IP_DST;
				end
			end 

			SEND_IP_DST: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_UDP_PORTS;
				end
			end

			SEND_UDP_PORTS: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_UDP_LEN_CSUM;
				end
			end

			SEND_UDP_LEN_CSUM: begin
				if(ip_udp_rdy_i) begin
					state_next = SEND_USER_DATA;
				end
			end

			SEND_USER_DATA: begin
				ready_pipe = ip_udp_rdy_i;
				if(ip_udp_rdy_i && strm_pipe[6].tvalid && strm_pipe[6].tlast) begin
					if(strm_pipe[5].tvalid) state_next = SEND_IP_LEN;//для ускорения обработки пакетов, если данные следуют друг за другом
					else state_next = IDLE;
				end
			end

			default: begin
				state_next = IDLE;
			end
		endcase
	end

	always_ff @(posedge clk or negedge reset_n) begin
		if(!reset_n) ip_udp_tvld_o <= 1'b0;
		else if(ip_udp_rdy_i) begin
			ip_udp_tvld_o <= 1'b0;
			case(state)
				SEND_IP_LEN,
				SEND_IP_ID, 
				SEND_IP_CSUM, 
				SEND_IP_SRC, 
				SEND_IP_DST, 
				SEND_UDP_PORTS,
				SEND_UDP_LEN_CSUM: ip_udp_tvld_o <= 1'b1;
				SEND_USER_DATA: ip_udp_tvld_o <= strm_pipe[6].tvalid;
				default: ip_udp_tvld_o <= 1'b0;
			endcase
		end
	end

	always_ff @(posedge clk) begin
		if(ip_udp_rdy_i) begin
			ip_udp_tdata_o 	<= 32'h0;
			ip_udp_tlast_o 	<= 1'b0;
			ip_udp_tkeep_o 	<= 4'h0;

			case(state)
				SEND_IP_LEN: begin
					ip_udp_tdata_o <= {16'h4500, ipv4_udp_hdr[6].ip_total_length};
					ip_udp_tkeep_o 	<= 4'hF;
				end
				SEND_IP_ID: begin
					ip_udp_tdata_o <= {ipv4_udp_hdr[6].ip_identificator, 16'h0};
					ip_udp_tkeep_o 	<= 4'hF;
				end
				SEND_IP_CSUM: begin
					ip_udp_tdata_o <= {16'h8011, ipv4_udp_hdr[6].ip_checksum};
					ip_udp_tkeep_o 	<= 4'hF;
				end
				SEND_IP_SRC: begin
					ip_udp_tdata_o <= ipv4_udp_hdr[6].ip_src;
					ip_udp_tkeep_o 	<= 4'hF;				
				end
				SEND_IP_DST: begin
					ip_udp_tdata_o <= ipv4_udp_hdr[6].ip_dst;
					ip_udp_tkeep_o 	<= 4'hF;
				end
				SEND_UDP_PORTS: begin
					ip_udp_tdata_o <= {ipv4_udp_hdr[6].udp_port_src, ipv4_udp_hdr[6].udp_port_dst};
					ip_udp_tkeep_o 	<= 4'hF;
				end
				SEND_UDP_LEN_CSUM: begin
					ip_udp_tdata_o <= {ipv4_udp_hdr[6].udp_length, ipv4_udp_hdr[6].udp_checksum};
					ip_udp_tkeep_o 	<= 4'hF;
				end
				SEND_USER_DATA: begin
					ip_udp_tdata_o 	<= strm_pipe[6].tdata;
					ip_udp_tlast_o 	<= strm_pipe[6].tlast;
					ip_udp_tkeep_o 	<= strm_pipe[6].tkeep;
				end
				default: begin
					ip_udp_tdata_o 	<= 32'h0;
					ip_udp_tlast_o 	<= 1'b0;
					ip_udp_tkeep_o 	<= 4'h0;
				end
			endcase
		end
	end

endmodule