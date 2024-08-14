/*
    Данный модуль в соответствии с каналом направляет трафик на заранее заданные адреса (MAC dest, IP dest и port dest), соответствующие каналу
    При этом адрес источника (устройство отправителя) только один (MAC src, IP src и port src)
    Зачем несколько адресов назначения? Вдруг придется отправлять разные потоки данных, например с массива разных АЦП и т.д - вариантов применения чрезвычайно много
*/

module user_data_packer #(
    parameter ID_WIDTH = 10//ширина порта канала
)(
    input       logic                   clk,
    input       logic                   reset_n,


//control
    //source address
    input       logic   [47:0]          cntrl_mac_src_i, 
    input       logic   [31:0]          cntrl_ip_src_i,
    input       logic   [15:0]          cntrl_port_src_i,

    //update destination adresses
    input       logic   [ID_WIDTH-1:0]  cntrl_addr_cell_dest_i,//адрес текущей ячейки с адресами назначения конкретного канала
    input       logic   [47:0]          cntrl_mac_dest_i,
    input       logic   [31:0]          cntrl_ip_dest_i,
    input       logic   [15:0]          cntrl_port_dest_i,
    input       logic   [2:0]           cntrl_cell_dest_wr_i,//стробы записи, [0] - mac_write, [1] - ip write, [2] - port write

    output      logic   [47:0]          cntrl_mac_dest_rdata_o,
    output      logic   [31:0]          cntrl_ip_dest_rdata_o,
    output      logic   [15:0]          cntrl_port_dest_rdata_o,


//user strem input
    input       logic   [ID_WIDTH-1:0]  user_in_tid_i,
    input       logic   [31:0]          user_in_tdata_i,
    input       logic                   user_in_tvld_i,
    input       logic                   user_in_tlast_i,
	input       logic   [3:0]           user_in_tkeep_i, 
    output      logic                   user_in_trdy_o,

//user stream output
    //header
    output      logic   [47:0]          hdr_mac_dest_o, 
                                        hdr_mac_src_o,
    output      logic   [31:0]          hdr_ip_dest_o, 
                                        hdr_ip_src_o,//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    output      logic   [15:0]          hdr_port_dest_o, 
                                        hdr_port_src_o,
    //data
    output      logic   [31:0]          user_out_tdata_o,
    output      logic                   user_out_tvld_o,
    output      logic                   user_out_tlast_o,
    output      logic   [3:0]           user_out_tkeep_o,
    input       logic                   user_out_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    typedef struct packed 
    {
        logic [ID_WIDTH-1:0] tid;
        logic [31:0] 	tdata;
        logic 			tvalid;
        logic 			tlast;
        logic [3:0]		tkeep;
    } stream_pipe;

    logic [47:0]    mac_dest_rdram, mac_dest_reg;
    logic [31:0]    ip_dest_rdram, ip_dest_reg;
    logic [15:0]    port_dest_rdram, port_dest_reg;
    logic           locked_id;
    stream_pipe strm_pipe;
    logic rdy;
        

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    dual_port_ram #(
        .DATA_WIDTH(48), 
        .ADDR_WIDTH(ID_WIDTH)
    ) mac_dest_table (
        .clk_a      (clk), 
        .data_a     (cntrl_mac_dest_i), 
        .addr_a     (cntrl_addr_cell_dest_i), 
        .we_a       (cntrl_cell_dest_wr_i[0]), 
        .q_a        (cntrl_mac_dest_rdata_o), 

        .clk_b      (clk),
        .data_b     (48'h0),
        .addr_b     (locked_id ? strm_pipe.tid : user_in_tid_i),
        .we_b       (1'b0), 
        .q_b        (mac_dest_rdram)
    );

    dual_port_ram #(
        .DATA_WIDTH(32), 
        .ADDR_WIDTH(ID_WIDTH)
    ) ip_dest_table (
        .clk_a      (clk), 
        .data_a     (cntrl_ip_dest_i), 
        .addr_a     (cntrl_addr_cell_dest_i), 
        .we_a       (cntrl_cell_dest_wr_i[1]), 
        .q_a        (cntrl_ip_dest_rdata_o), 

        .clk_b      (clk),
        .data_b     (32'h0),
        .addr_b     (locked_id ? strm_pipe.tid : user_in_tid_i),
        .we_b       (1'b0), 
        .q_b        (ip_dest_rdram)
    );

    dual_port_ram #(
        .DATA_WIDTH(16), 
        .ADDR_WIDTH(ID_WIDTH)
    ) port_dest_table (
        .clk_a      (clk), 
        .data_a     (cntrl_port_dest_i), 
        .addr_a     (cntrl_addr_cell_dest_i), 
        .we_a       (cntrl_cell_dest_wr_i[2]), 
        .q_a        (cntrl_port_dest_rdata_o), 

        .clk_b      (clk),
        .data_b     (16'h0),
        .addr_b     (locked_id ? strm_pipe.tid : user_in_tid_i),
        .we_b       (1'b0), 
        .q_b        (port_dest_rdram)
    );


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    
    //pipeline
    
    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) strm_pipe.tvalid <= 1'b0;
        else if(rdy) strm_pipe.tvalid <= user_in_tvld_i;
    end

    always_ff @(posedge clk) begin
        if(rdy) begin
            strm_pipe.tid   <= user_in_tid_i;
            strm_pipe.tdata <= user_in_tdata_i;
            strm_pipe.tlast <= user_in_tlast_i;
            strm_pipe.tkeep <= user_in_tkeep_i;
        end
    end

    assign user_in_trdy_o = rdy;
    assign locked_id = strm_pipe.tvalid & !rdy;//это критичный момент, так как мультиплексор на входе адреса памяти добавляет задержку, что приводит к уменьшению рабочей тактовой частоты
    assign rdy = user_out_tvld_o & ~user_out_rdy_i ? 1'b0 : 1'b1;



    //output cascade
    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) user_out_tvld_o <= 1'b0;
        else if(rdy) user_out_tvld_o <= strm_pipe.tvalid;
    end


    always_ff @(posedge clk) begin
        if(rdy) begin
            hdr_mac_dest_o  <= mac_dest_rdram;
            hdr_mac_src_o   <= cntrl_mac_src_i;
            hdr_ip_dest_o   <= ip_dest_rdram; 
            hdr_ip_src_o    <= cntrl_ip_src_i;
            hdr_port_dest_o <= port_dest_rdram;
            hdr_port_src_o  <= cntrl_port_src_i;

            user_out_tdata_o <= strm_pipe.tdata;
            user_out_tlast_o <= strm_pipe.tlast;
            user_out_tkeep_o <= strm_pipe.tkeep;
        end
    end

endmodule