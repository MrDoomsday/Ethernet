module umstr_get_stream_len_csum #(
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

//выходной поток
    output      logic   [31:0]  hdr_ip_dest_o, 
                                hdr_ip_src_o,//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    output      logic   [15:0]  hdr_port_dest_o, 
                                hdr_port_src_o,
    output      logic   [15:0]  user_data_csum_o,
    output      logic   [15:0]  user_data_len_o, 
    output      logic   [31:0]  user_tdata_o,
    output      logic           user_tvld_o,
    output      logic           user_tlast_o,
    output      logic   [3:0]   user_tkeep_o,
    input       logic           user_trdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    logic   [2:0][31:0]     hdr_ip_dest_reg, hdr_ip_src_reg;
    logic   [2:0][15:0]     hdr_port_dest_reg, hdr_port_src_reg;
    logic   [2:0][31:0]     strm_tdata_reg;
    logic   [2:0]           strm_tlast_reg, strm_tvld_reg;
    logic   [2:0][3:0]      strm_tkeep_reg;

    logic   [2:0][15:0]     strm_len, strm_csum;
    wire                    rdy;
    logic                   previous_last;//for detect start packet
    logic   [3:0]           cnt_vld_bytes;


    logic                   fifo_strm_rdy_in, fifo_hdr_rdy_in;
    logic                   fifo_strm_rdy_out, fifo_hdr_rdy_out;
    logic                   fifo_hdr_vld_out;

    enum logic [1:0] {IDLE, SEND_PKT} state, state_next;


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    umstr_axis_fifo #(
        .T_DATA_WIDTH(32+1+4),//data + last + tkeep
        .SIZE(FIFO_SIZE_DATA)
    ) fifo_stream (
        .clk            (clk),
        .reset_n        (reset_n),

        //input stream
        .s_data_i       ({strm_tdata_reg[1], strm_tlast_reg[1], strm_tkeep_reg[1]}),
        .s_valid_i      (strm_tvld_reg[1] & rdy),
        .s_ready_o      (fifo_strm_rdy_in),

        //output stream
        .m_data_o       ({strm_tdata_reg[2], strm_tlast_reg[2], strm_tkeep_reg[2]}),
        .m_valid_o      (strm_tvld_reg[2]),
        .m_ready_i      (fifo_strm_rdy_out),

        .fifo_empty_o   (),
        .fifo_full_o    ()
    );

    umstr_axis_fifo #(
        .T_DATA_WIDTH(32+32+32+32),//data checksum[15:0] + data length[15:0] + port_src[15:0] + port_dest[15:0] + ip_src[31:0] + ip_dest[31:0]
        .SIZE(FIFO_SIZE_HDR)
    ) fifo_header (
        .clk            (clk),
        .reset_n        (reset_n),

        //input stream
        .s_data_i       ({strm_len[1], strm_csum[1], hdr_port_src_reg[1], hdr_port_dest_reg[1], hdr_ip_src_reg[1], hdr_ip_dest_reg[1]}),
        .s_valid_i      (strm_tvld_reg[1] & strm_tlast_reg[1] & rdy),
        .s_ready_o      (fifo_hdr_rdy_in),

        //output stream
        .m_data_o       ({strm_len[2], strm_csum[2], hdr_port_src_reg[2], hdr_port_dest_reg[2], hdr_ip_src_reg[2], hdr_ip_dest_reg[2]}),
        .m_valid_o      (fifo_hdr_vld_out),
        .m_ready_i      (fifo_hdr_rdy_out),

        .fifo_empty_o   (),
        .fifo_full_o    ()
    );

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

//cascade 0
    //strm
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) strm_tvld_reg[0] <= 1'b0;
        else if(rdy) strm_tvld_reg[0] <= user_tvld_i;
    end


    always_ff @ (posedge clk) begin
        if(rdy) begin
            hdr_ip_dest_reg[0]      <= hdr_ip_dest_i;
            hdr_ip_src_reg[0]       <= hdr_ip_src_i;
            hdr_port_dest_reg[0]    <= hdr_port_dest_i;
            hdr_port_src_reg[0]     <= hdr_port_src_i;

            strm_tdata_reg[0]   <= user_tdata_i;
            strm_tkeep_reg[0]   <= user_tkeep_i;
            strm_tlast_reg[0]   <= user_tlast_i;
            cnt_vld_bytes       <= user_tkeep_i[3] + user_tkeep_i[2] + user_tkeep_i[1] + user_tkeep_i[0];//подсчет числа валидных байтов
        end
    end


    wire [16:0] csum_data_tmp = user_tdata_i[31:16] + user_tdata_i[15:0];

    always_ff @ (posedge clk) begin
        if(rdy && user_tvld_i) begin
            strm_csum[0] <= csum_data_tmp[15:0] + {15'h0, csum_data_tmp[16]};
        end
    end

    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) previous_last <= 1'b1;
        else if(rdy && strm_tvld_reg[0]) begin
            previous_last <= strm_tlast_reg[0];
        end
    end    

//cascade 1

    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) strm_tvld_reg[1] <= 1'b0;
        else if(rdy) strm_tvld_reg[1] <= strm_tvld_reg[0];
    end

    always_ff @ (posedge clk) begin
        if(rdy) begin
            if(strm_tvld_reg[0] && previous_last) begin
                hdr_ip_dest_reg[1]      <= hdr_ip_dest_reg[0];
                hdr_ip_src_reg[1]       <= hdr_ip_src_reg[0];
                hdr_port_dest_reg[1]    <= hdr_port_dest_reg[0];
                hdr_port_src_reg[1]     <= hdr_port_src_reg[0];
            end

            strm_tdata_reg[1]   <= strm_tdata_reg[0];
            strm_tkeep_reg[1]   <= strm_tkeep_reg[0];
            strm_tlast_reg[1]   <= strm_tlast_reg[0];
        end
    end

    logic [16:0] strm_csum_next;
    assign strm_csum_next = strm_csum[1] + strm_csum[0];//накапливаем результаты

    always_ff @ (posedge clk) begin
        if(rdy && strm_tvld_reg[0]) begin
            if(previous_last) begin//сбрасываем в начальное положение
                strm_len[1] <= cnt_vld_bytes;
                strm_csum[1] <= strm_csum[0];
            end
            else begin
                strm_len[1] <= strm_len[1] + cnt_vld_bytes;
                strm_csum[1] <= strm_csum_next[15:0] + {15'h0, strm_csum_next[16]};
            end
        end
    end

    assign rdy = fifo_strm_rdy_in & fifo_hdr_rdy_in;
    assign user_trdy_o = rdy;

// автомат по отправке пакетов 
    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) state <= IDLE;
        else state <= state_next;
    end

    always_comb begin
        state_next = state;
        fifo_strm_rdy_out = ~strm_tvld_reg[2];
        fifo_hdr_rdy_out = ~fifo_hdr_vld_out;


        case(state)
            IDLE: begin
                fifo_hdr_rdy_out = user_tvld_o & ~user_trdy_i ? 1'b0 : 1'b1;//не читаем заголовок до тех пор, пока есть данные для передачи
                if(fifo_hdr_vld_out && fifo_hdr_rdy_out) begin
                    state_next = SEND_PKT;
                end
            end

            SEND_PKT: begin
                fifo_strm_rdy_out = user_trdy_i;
                if(user_trdy_i && strm_tvld_reg[2] && strm_tlast_reg[2]) begin
                    state_next = IDLE;
                end
            end

            default: begin
                state_next = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if((state == IDLE) && fifo_hdr_vld_out && fifo_hdr_rdy_out) begin
            hdr_ip_dest_o       <= hdr_ip_dest_reg[2];
            hdr_ip_src_o        <= hdr_ip_src_reg[2];
            hdr_port_dest_o     <= hdr_port_dest_reg[2]; 
            hdr_port_src_o      <= hdr_port_src_reg[2];
            user_data_csum_o    <= strm_csum[2];
            user_data_len_o     <= strm_len[2];
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) user_tvld_o <= 1'b0;
        else if(user_trdy_i) user_tvld_o <= (state == SEND_PKT) & strm_tvld_reg[2];
    end

    always_ff @(posedge clk) begin
        if(user_trdy_i) begin
            user_tdata_o <= strm_tdata_reg[2];
            user_tlast_o <= strm_tlast_reg[2];
            user_tkeep_o <= strm_tkeep_reg[2];
        end
    end


endmodule