module umstr_st_splitter (
    input       logic           clk,
    input       logic           reset_n,

    //from tse
    input       logic   [31:0]  from_tse_tdata_i,
    input       logic           from_tse_tvld_i,
    input       logic           from_tse_tlast_i,
	input       logic   [3:0]   from_tse_tkeep_i, 
    output      logic           from_tse_trdy_o,

    //for search device
    output      logic   [31:0]  sd_tdata_o,
    output      logic           sd_tvld_o,
    output      logic           sd_tlast_o,
	output      logic   [3:0]   sd_tkeep_o, 
    input       logic           sd_trdy_i,

    //for axi2udp
    output      logic   [31:0]  au_tdata_o,
    output      logic           au_tvld_o,
    output      logic           au_tlast_o,
	output      logic   [3:0]   au_tkeep_o, 
    input       logic           au_trdy_i,

    //for ARP
    output      logic   [31:0]  arp_tdata_o,
    output      logic           arp_tvld_o,
    output      logic           arp_tlast_o,
	output      logic   [3:0]   arp_tkeep_o, 
    input       logic           arp_trdy_i
);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    logic rdy_global;
    logic sd_rdy_in, au_rdy_in, arp_rdy_in;
/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    umstr_axis_skid #(
        .T_DATA_WIDTH(32),
        .T_KEEP_WIDTH(2)
    ) sd_skid (
        .clk        (clk),
        .reset_n    (reset_n),
    
        .s_tdata_i  (from_tse_tdata_i),
        .s_tvalid_i (from_tse_tvld_i & rdy_global),
        .s_tlast_i  (from_tse_tlast_i),
        .s_tkeep_i  (from_tse_tkeep_i), 
        .s_tready_o (sd_rdy_in),
    
    
        .m_tdata_o  (sd_tdata_o),
        .m_tvalid_o (sd_tvld_o),
        .m_tlast_o  (sd_tlast_o),
        .m_tkeep_o  (sd_tkeep_o), 
        .m_tready_i (sd_trdy_i)
    
    );


    umstr_axis_skid #(
        .T_DATA_WIDTH(32),
        .T_KEEP_WIDTH(2)
    ) au_skid (
        .clk         (clk),
        .reset_n     (reset_n),
    
        .s_tdata_i  (from_tse_tdata_i),
        .s_tvalid_i (from_tse_tvld_i & rdy_global),
        .s_tlast_i  (from_tse_tlast_i),
        .s_tkeep_i  (from_tse_tkeep_i), 
        .s_tready_o (au_rdy_in),
    
    
        .m_tdata_o  (au_tdata_o),
        .m_tvalid_o (au_tvld_o),
        .m_tlast_o  (au_tlast_o),
        .m_tkeep_o  (au_tkeep_o), 
        .m_tready_i (au_trdy_i)
    
    );

    umstr_axis_skid #(
        .T_DATA_WIDTH(32),
        .T_KEEP_WIDTH(2)
    ) arp_skid (
        .clk        (clk),
        .reset_n    (reset_n),
    
        .s_tdata_i  (from_tse_tdata_i),
        .s_tvalid_i (from_tse_tvld_i & rdy_global),
        .s_tlast_i  (from_tse_tlast_i),
        .s_tkeep_i  (from_tse_tkeep_i), 
        .s_tready_o (arp_rdy_in),
    
    
        .m_tdata_o  (arp_tdata_o),
        .m_tvalid_o (arp_tvld_o),
        .m_tlast_o  (arp_tlast_o),
        .m_tkeep_o  (arp_tkeep_o), 
        .m_tready_i (arp_trdy_i)
    
    );

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    assign rdy_global = sd_rdy_in & au_rdy_in & arp_rdy_in;//fifoшки всегда держат ready в высоком состоянии (пока не заполнены полностью)
    assign from_tse_trdy_o = rdy_global;

endmodule