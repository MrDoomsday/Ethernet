module umstr_mux_ipudp (
    input       logic clk,
    input       logic reset_n,

    //search device ports - sd
    input       logic   [47:0]  sd_hdr_mac_dest_i,
                                sd_hdr_mac_src_i,
    input       logic   [31:0]  sd_hdr_ip_dest_i, 
                                sd_hdr_ip_src_i,
    input       logic   [15:0]  sd_hdr_port_dest_i, 
                                sd_hdr_port_src_i,

    input       logic   [31:0]  sd_tdata_i,
    input       logic           sd_tvld_i,
    input       logic           sd_tlast_i,
	input       logic   [3:0]   sd_tkeep_i, 
    output      logic           sd_trdy_o,

    //AXI2UDP - au
    input       logic   [47:0]  au_hdr_mac_dest_i,
                                au_hdr_mac_src_i,
    input       logic   [31:0]  au_hdr_ip_dest_i, 
                                au_hdr_ip_src_i,
    input       logic   [15:0]  au_hdr_port_dest_i, 
                                au_hdr_port_src_i,

    input       logic   [31:0]  au_tdata_i,
    input       logic           au_tvld_i,
    input       logic           au_tlast_i,
	input       logic   [3:0]   au_tkeep_i, 
    output      logic           au_trdy_o,

    //user stream - us
    input       logic   [47:0]  us_hdr_mac_dest_i,
                                us_hdr_mac_src_i,
    input       logic   [31:0]  us_hdr_ip_dest_i, 
                                us_hdr_ip_src_i,
    input       logic   [15:0]  us_hdr_port_dest_i, 
                                us_hdr_port_src_i,

    input       logic   [31:0]  us_tdata_i,
    input       logic           us_tvld_i,
    input       logic           us_tlast_i,
	input       logic   [3:0]   us_tkeep_i, 
    output      logic           us_trdy_o,
    
    //output mux 
    output      logic   [47:0]  mux_hdr_mac_dest_o,
                                mux_hdr_mac_src_o,
    output      logic   [31:0]  mux_hdr_ip_dest_o, 
                                mux_hdr_ip_src_o,
    output      logic   [15:0]  mux_hdr_port_dest_o, 
                                mux_hdr_port_src_o,
    output      logic           mux_tvld_hdr_vld_o,
    
    output      logic   [31:0]  mux_tdata_o,
    output      logic           mux_tvld_o,
    output      logic           mux_tlast_o,
	output      logic   [3:0]   mux_tkeep_o, 
    input       logic           mux_trdy_i


);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    enum logic [1:0] {
        IDLE,
        CH_SD,
        CH_AU,
        CH_US
    } state, state_next;


    wire ready;
    logic sd_tlast_old, au_tlast_old, us_tlast_old;

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
        sd_trdy_o = ~sd_tvld_i;
        au_trdy_o = ~au_tvld_i;
        us_trdy_o = ~us_tvld_i;

        case(state)
            IDLE: begin
                if(sd_tvld_i) begin
                    state_next = CH_SD;
                end
                else if(au_tvld_i) begin
                    state_next = CH_AU;
                end
                else if(us_tvld_i) begin
                    state_next = CH_US;
                end
            end

            CH_SD: begin
                sd_trdy_o = ready;
                if(ready && sd_tvld_i && sd_tlast_i) begin
                    if(au_tvld_i) state_next = CH_AU;
                    else if(us_tvld_i) state_next = CH_US;
                    else state_next = IDLE;
                end
            end

            CH_AU: begin
                au_trdy_o = ready;
                if(ready && au_tvld_i && au_tlast_i) begin
                    if(us_tvld_i) state_next = CH_US;
                    else if(sd_tvld_i) state_next = CH_SD;
                    else state_next = IDLE;
                end
            end

            CH_US: begin
                us_trdy_o = ready;
                if(ready && us_tvld_i && us_tlast_i) begin
                    if(sd_tvld_i) state_next = CH_SD;
                    else if(au_tvld_i) state_next = CH_AU;
                    else state_next = IDLE;
                end
            end

            default: begin
                state_next = CH_SD;
            end
        endcase
    end


    assign ready = ~mux_trdy_i & mux_tvld_o ? 1'b0 : 1'b1;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            sd_tlast_old <= 1'b1;
            au_tlast_old <= 1'b1;
            us_tlast_old <= 1'b1;
        end
        else begin
            if(sd_trdy_o && sd_tvld_i) begin
                sd_tlast_old <= sd_tlast_i;
            end

            if(au_trdy_o && au_tvld_i) begin
                au_tlast_old <= au_tlast_i;    
            end

            if(us_trdy_o && us_tvld_i) begin
                us_tlast_old <= us_tlast_i;
            end
        end 
    end


//выходной каскад
    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            mux_tvld_o <= 1'b0;
            mux_tvld_hdr_vld_o <= 1'b0;
        end
        else if(ready) begin
            mux_tvld_hdr_vld_o <= 1'b0;
            mux_tvld_o <= 1'b0;
            case(state)
                CH_SD:  begin
                    mux_tvld_o <= sd_tvld_i;
                    mux_tvld_hdr_vld_o <= sd_tvld_i & sd_tlast_old;
                end
                CH_AU:  begin
                    mux_tvld_o <= au_tvld_i;
                    mux_tvld_hdr_vld_o <= au_tvld_i & au_tlast_old;
                end
                CH_US:  begin
                    mux_tvld_o <= us_tvld_i;
                    mux_tvld_hdr_vld_o <= us_tvld_i & us_tlast_old;
                end
                default: begin
                    mux_tvld_o <= 1'b0;
                    mux_tvld_hdr_vld_o <= 1'b0;
                end
            endcase
        end
    end



    always_ff @(posedge clk) begin
        if(ready) begin
            mux_hdr_mac_dest_o  <= 48'h0;
            mux_hdr_mac_src_o   <= 48'h0;
            mux_hdr_ip_dest_o   <= 32'h0;
            mux_hdr_ip_src_o    <= 32'h0;
            mux_hdr_port_dest_o <= 16'h0;
            mux_hdr_port_src_o  <= 16'h0;

            mux_tdata_o         <= 32'h0;
            mux_tlast_o         <= 1'b0;
            mux_tkeep_o         <= 4'h0;

            case(state)
                CH_SD: begin
                    mux_hdr_mac_dest_o  <= sd_hdr_mac_dest_i;
                    mux_hdr_mac_src_o   <= sd_hdr_mac_src_i;
                    mux_hdr_ip_dest_o   <= sd_hdr_ip_dest_i;
                    mux_hdr_ip_src_o    <= sd_hdr_ip_src_i;
                    mux_hdr_port_dest_o <= sd_hdr_port_dest_i;
                    mux_hdr_port_src_o  <= sd_hdr_port_src_i;

                    mux_tdata_o         <= sd_tdata_i;
                    mux_tlast_o         <= sd_tlast_i;
                    mux_tkeep_o         <= sd_tkeep_i;
                end

                CH_AU: begin
                    mux_hdr_mac_dest_o  <= au_hdr_mac_dest_i;
                    mux_hdr_mac_src_o   <= au_hdr_mac_src_i;
                    mux_hdr_ip_dest_o   <= au_hdr_ip_dest_i;
                    mux_hdr_ip_src_o    <= au_hdr_ip_src_i;
                    mux_hdr_port_dest_o <= au_hdr_port_dest_i;
                    mux_hdr_port_src_o  <= au_hdr_port_src_i;

                    mux_tdata_o         <= au_tdata_i;
                    mux_tlast_o         <= au_tlast_i;
                    mux_tkeep_o         <= au_tkeep_i;
                end

                CH_US: begin
                    mux_hdr_mac_dest_o  <= us_hdr_mac_dest_i;
                    mux_hdr_mac_src_o   <= us_hdr_mac_src_i;
                    mux_hdr_ip_dest_o   <= us_hdr_ip_dest_i;
                    mux_hdr_ip_src_o    <= us_hdr_ip_src_i;
                    mux_hdr_port_dest_o <= us_hdr_port_dest_i;
                    mux_hdr_port_src_o  <= us_hdr_port_src_i;

                    mux_tdata_o         <= us_tdata_i;
                    mux_tlast_o         <= us_tlast_i;
                    mux_tkeep_o         <= us_tkeep_i;
                end

                default: begin
                    mux_hdr_mac_dest_o  <= 48'h0;
                    mux_hdr_mac_src_o   <= 48'h0;
                    mux_hdr_ip_dest_o   <= 32'h0;
                    mux_hdr_ip_src_o    <= 32'h0;
                    mux_hdr_port_dest_o <= 16'h0;
                    mux_hdr_port_src_o  <= 16'h0;
        
                    mux_tdata_o         <= 32'h0;
                    mux_tlast_o         <= 1'b0;
                    mux_tkeep_o         <= 4'h0;
                end
            endcase
        end        
    end


endmodule