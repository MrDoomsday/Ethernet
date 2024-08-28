module ethII_mux (
    input       logic clk,
    input       logic reset_n,

//ARP payload
    input       logic   [47:0]  arp_mac_dest_i, 
                                arp_mac_src_i,
    input       logic   [15:0]  arp_mac_type_i,
    input       logic           arp_mac_vld_i,
    output      logic           arp_mac_rdy_o,

    input       logic   [31:0]  arp_tdata_i,
    input       logic           arp_tvld_i,
    input       logic           arp_tlast_i,
	input       logic   [3:0]   arp_tkeep_i, 
    output      logic           arp_trdy_o,

//IPv4 payload
    input       logic   [47:0]  ipv4_mac_dest_i, 
                                ipv4_mac_src_i,
    input       logic   [15:0]  ipv4_mac_type_i,
    input       logic           ipv4_mac_vld_i,
    output      logic           ipv4_mac_rdy_o,

    input       logic   [31:0]  ipv4_tdata_i,
    input       logic           ipv4_tvld_i,
    input       logic           ipv4_tlast_i,
	input       logic   [3:0]   ipv4_tkeep_i, 
    output      logic           ipv4_trdy_o,


//mux result 
    output      logic   [47:0]      hdr_mac_dest_o, 
                                    hdr_mac_src_o,
    output      logic   [15:0]      hdr_mac_type_o,
    output      logic               hdr_mac_vld_o,
    input       logic               hdr_mac_rdy_i,

    output      logic   [31:0]      user_tdata_o,
    output      logic               user_tvld_o,
    output      logic               user_tlast_o,
	output      logic   [3:0]       user_tkeep_o, 
    input       logic               user_trdy_i
);



/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    enum logic [2:0] {
        IDLE, 
        SEND_MAC_IPV4,
        SEND_PLD_IPV4,
        SEND_MAC_ARP,
        SEND_PLD_ARP
    } state, state_next;

    logic mac_rdy, pld_rdy;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) 
            state <= IDLE;
        else 
            state <= state_next;
    end


    always_comb begin
        state_next = state;
        arp_mac_rdy_o = ~arp_mac_vld_i;
        arp_trdy_o = ~arp_tvld_i;
        ipv4_mac_rdy_o = ~ipv4_mac_vld_i;
        ipv4_trdy_o = ~ipv4_tvld_i;

        case(state)
            IDLE: begin
                if(arp_mac_vld_i) begin
                    state_next = SEND_MAC_ARP;
                end
                else if(ipv4_mac_vld_i) begin
                    state_next = SEND_MAC_IPV4;
                end
            end

            SEND_MAC_IPV4: begin
                ipv4_mac_rdy_o = mac_rdy;
                if(mac_rdy) begin
                    state_next = SEND_PLD_IPV4;
                end
            end

            SEND_PLD_IPV4: begin
                ipv4_trdy_o = pld_rdy;
                if(ipv4_tvld_i && ipv4_tlast_i && pld_rdy) begin
                    if(arp_mac_vld_i) state_next = SEND_MAC_ARP;
                    else if(ipv4_mac_vld_i) state_next = SEND_MAC_IPV4;
                    else state_next = IDLE;
                end
            end

            SEND_MAC_ARP: begin
                arp_mac_rdy_o = mac_rdy;
                if(mac_rdy) begin
                    state_next = SEND_PLD_ARP;
                end
            end

            SEND_PLD_ARP: begin
                arp_trdy_o = pld_rdy;
                if(arp_tvld_i && arp_tlast_i && pld_rdy) begin
                    if(ipv4_mac_vld_i) state_next = SEND_MAC_IPV4;
                    else if(arp_mac_vld_i) state_next = SEND_MAC_ARP;
                    else state_next = IDLE;
                end
            end
            default: begin
                state_next = IDLE;
            end
        endcase
    end


    assign mac_rdy = hdr_mac_vld_o & ~hdr_mac_rdy_i ? 1'b0 : 1'b1;
    assign pld_rdy = user_tvld_o & ~user_trdy_i ? 1'b0 : 1'b1;


    //send MAC
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) hdr_mac_vld_o <= 1'b0;
        else if(mac_rdy) begin
            hdr_mac_vld_o <= 1'b0;
            case(state)
                SEND_MAC_IPV4: hdr_mac_vld_o <= ipv4_mac_vld_i;
                SEND_MAC_ARP: hdr_mac_vld_o <= arp_mac_vld_i;
                default: hdr_mac_vld_o <= 1'b0;
            endcase
        end
    end

    always_ff @ (posedge clk) begin
        if(mac_rdy) begin
            hdr_mac_dest_o  <= 48'h0;
            hdr_mac_src_o   <= 48'h0;
            hdr_mac_type_o  <= 16'h0;

            case(state)
                SEND_MAC_IPV4: begin
                    hdr_mac_dest_o  <= ipv4_mac_dest_i;
                    hdr_mac_src_o   <= ipv4_mac_src_i;
                    hdr_mac_type_o  <= ipv4_mac_type_i;
                end
                SEND_MAC_ARP: begin
                    hdr_mac_dest_o  <= arp_mac_dest_i;
                    hdr_mac_src_o   <= arp_mac_src_i;
                    hdr_mac_type_o  <= arp_mac_type_i;
                end
                default: begin
                    hdr_mac_dest_o  <= 48'h0;
                    hdr_mac_src_o   <= 48'h0;
                    hdr_mac_type_o  <= 16'h0;
                end
            endcase
        end
    end    

    //send payload
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            user_tvld_o <= 1'b0;
        end
        else if(pld_rdy) begin
            user_tvld_o <= 1'b0;
            case(state)
                SEND_PLD_IPV4:  user_tvld_o     <= ipv4_tvld_i;
                SEND_PLD_ARP:   user_tvld_o     <= arp_tvld_i;
                default:        user_tvld_o     <= 1'b0;
            endcase 
        end
    end

    always_ff @(posedge clk) begin
        if(pld_rdy) begin
            user_tdata_o <= 32'h0;
            user_tlast_o <= 1'b0;
            user_tkeep_o <= 4'h0;

            case(state)
                SEND_PLD_IPV4: begin
                    user_tdata_o <= ipv4_tdata_i;
                    user_tlast_o <= ipv4_tlast_i;
                    user_tkeep_o <= ipv4_tkeep_i;
                end
                SEND_PLD_ARP: begin
                    user_tdata_o <= arp_tdata_i;
                    user_tlast_o <= arp_tlast_i;
                    user_tkeep_o <= arp_tkeep_i;
                end
                default: begin
                    user_tdata_o <= 32'h0;
                    user_tlast_o <= 1'b0;
                    user_tkeep_o <= 4'h0;
                end
            endcase
        end
    end 
endmodule