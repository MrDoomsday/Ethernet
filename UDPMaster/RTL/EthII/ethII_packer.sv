module ethII_packer (
    input       logic clk,
    input       logic reset_n,

    //заголовок идет синхронно с пакетом (при приеме первого слова заголовок уже выставлен)
    input       logic   [47:0]  hdr_mac_dest_i, 
                                hdr_mac_src_i,//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    input       logic           hdr_mac_vld_i,
    output      logic           hdr_mac_rdy_o,

    input       logic   [31:0]  user_tdata_i,
    input       logic           user_tvld_i,
    input       logic           user_tlast_i,
	input       logic   [3:0]   user_tkeep_i, 
    output      logic           user_trdy_o,


    output      logic   [31:0]  ethii_ip_udp_tdata_o,
    output      logic           ethii_ip_udp_tvld_o,
    output      logic           ethii_ip_udp_tlast_o,
    output      logic   [3:0]   ethii_ip_udp_tkeep_o,
    input       logic           ethii_ip_udp_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    enum logic [3:0] {
        IDLE, 
        SEND_MAC_DST, 
        SEND_MAC_DST_SRC, 
        SEND_MAC_DEST,
        SEND_ETH_TYPE,
        SEND_DATA,
        SEND_TLAST
    } state, state_next;

    logic   [47:0]  mac_dst_reg, mac_src_reg;
    logic           mac_save_reg;
    logic   [31:0]  user_data_save;
    logic   [3:0]   user_keep_save;//требуется для правильного завершения пакета
    logic           rdy;


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) state <= IDLE;
        else state <= state_next;
    end


    always_comb begin
        state_next = state;
        hdr_mac_rdy_o = ~hdr_mac_vld_i;
        user_trdy_o = ~user_tvld_i;
        mac_save_reg = 1'b0;

        case(state)
            IDLE: begin
                hdr_mac_rdy_o = 1'b1;
                if(hdr_mac_vld_i) begin
                    mac_save_reg = 1'b1;
                    state_next = SEND_MAC_DST;
                end
            end
            
            SEND_MAC_DST: begin
                if(rdy) begin
                    state_next = SEND_MAC_DST_SRC;
                end
            end

            SEND_MAC_DST_SRC: begin
                if(rdy) begin
                    state_next = SEND_MAC_DEST;
                end                
            end

            SEND_MAC_DEST: begin
                if(rdy) begin
                    state_next = SEND_ETH_TYPE;
                end
            end

            SEND_ETH_TYPE: begin
                user_trdy_o = rdy;
                if(user_tvld_i && rdy) begin//здесь никаких дополнительных условий, т.к. пакет меньше четырех байт протоколом не поддерживается
                    state_next = SEND_DATA;
                end
            end
            
            SEND_DATA: begin
                user_trdy_o = rdy;
                if(user_tvld_i && user_tlast_i && rdy) begin
                    if((user_tkeep_i == 4'b1000) || (user_tkeep_i == 4'b1100)) begin
                        if(hdr_mac_vld_i) begin//это сделано для того, чтобы не тратить дополнительно время на переход в состояние IDLE, а сразу подгружать MAC-адреса
                            hdr_mac_rdy_o = 1'b1;
                            mac_save_reg = 1'b1;
                            state_next = SEND_MAC_DST;
                        end
                        else begin                            
                            state_next = IDLE;
                        end
                    end
                    else begin
                        state_next = SEND_TLAST;
                    end
                end
            end

            SEND_TLAST: begin
                if(rdy) begin
                    if(hdr_mac_vld_i) begin//это сделано для того, чтобы не тратить дополнительно время на переход в состояние IDLE, а сразу подгружать MAC-адреса
                        hdr_mac_rdy_o = 1'b1;
                        mac_save_reg = 1'b1;
                        state_next = SEND_MAC_DST;
                    end
                    else begin                            
                        state_next = IDLE;
                    end
                end
            end

            default: state_next = IDLE;
        endcase
    end


    always_ff @ (posedge clk) begin
        if(mac_save_reg) begin
            mac_dst_reg <= hdr_mac_dest_i;
            mac_src_reg <= hdr_mac_src_i;
        end

        if(((state == SEND_ETH_TYPE) || (state == SEND_DATA)) && user_tvld_i && rdy) begin
            user_data_save <= user_tdata_i;
            user_keep_save <= user_tkeep_i;
        end
    end

    assign rdy = ethii_ip_udp_tvld_o & ~ethii_ip_udp_rdy_i ? 1'b0 : 1'b1;

//выходной трафик
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            ethii_ip_udp_tvld_o <= 1'b0;
        end
        else if(rdy) begin
            ethii_ip_udp_tvld_o <= 1'b0;
            case(state)
                SEND_MAC_DST,
                SEND_MAC_DST_SRC,
                SEND_MAC_DEST: begin
                    ethii_ip_udp_tvld_o <= 1'b1;
                end
                SEND_ETH_TYPE: begin
                    ethii_ip_udp_tvld_o <= user_tvld_i;
                end
                SEND_DATA: begin
                    ethii_ip_udp_tvld_o <= user_tvld_i;
                end
                SEND_TLAST: begin
                    ethii_ip_udp_tvld_o <= 1'b1;
                end
                default: ethii_ip_udp_tvld_o <= 1'b0;
            endcase
        end
    end

    always_ff @ (posedge clk) begin
        if(rdy) begin
            ethii_ip_udp_tdata_o <= 32'h0;
            ethii_ip_udp_tlast_o <= 1'b0;
            ethii_ip_udp_tkeep_o <= 4'h0;
            case(state)
                SEND_MAC_DST: begin
                    ethii_ip_udp_tdata_o <= mac_dst_reg[47:16];
                end
                SEND_MAC_DST_SRC: begin
                    ethii_ip_udp_tdata_o <= {mac_dst_reg[15:0], mac_src_reg[47:32]};
                end
                SEND_MAC_DEST: begin
                    ethii_ip_udp_tdata_o <= mac_src_reg[31:0];
                end
                SEND_ETH_TYPE: begin
                    ethii_ip_udp_tdata_o <= {16'h0800, user_tdata_i[31:16]};//type=16'h0800 - IPv4
                end
                SEND_DATA: begin
                    ethii_ip_udp_tdata_o <= {user_data_save[15:0], user_tdata_i[31:16]};
                    if(user_tvld_i && user_tlast_i) begin
                        if(user_tkeep_i == 4'b1000) begin
                            ethii_ip_udp_tkeep_o <= 4'b1110;
                            ethii_ip_udp_tlast_o <= 1'b1;
                        end
                        else if(user_tkeep_i == 4'b1100) begin
                            ethii_ip_udp_tkeep_o <= 4'b1111;
                            ethii_ip_udp_tlast_o <= 1'b1;                            
                        end
                    end 
                end
                SEND_TLAST: begin
                    ethii_ip_udp_tdata_o <= {user_data_save[15:0], 16'h0};
                    ethii_ip_udp_tlast_o <= 1'b1;
                    if(user_keep_save == 4'b1111) begin
                        ethii_ip_udp_tkeep_o <= 4'b1100;
                    end
                    else if(user_keep_save == 4'b1110) begin
                        ethii_ip_udp_tkeep_o <= 4'b1000;
                    end
                end
                default: begin
                    ethii_ip_udp_tdata_o <= 32'h0;
                    ethii_ip_udp_tlast_o <= 1'b0;
                    ethii_ip_udp_tkeep_o <= 4'h0;
                end
            endcase
        end
    end

endmodule