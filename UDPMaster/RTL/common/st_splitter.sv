module st_splitter (
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

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    assign rdy_global = sd_trdy_i & au_trdy_i & arp_trdy_i;//по умолчанию все модули должны держать активное ready!
    assign from_tse_trdy_o = rdy_global;

    assign sd_tdata_o   = from_tse_tdata_i;
    assign sd_tvld_o    = from_tse_tvld_i & rdy_global;
    assign sd_tlast_o   = from_tse_tlast_i;
    assign sd_tkeep_o   = from_tse_tkeep_i;


    assign au_tdata_o   = from_tse_tdata_i;
    assign au_tvld_o    = from_tse_tvld_i & rdy_global;
    assign au_tlast_o   = from_tse_tlast_i;
    assign au_tkeep_o   = from_tse_tkeep_i;


    assign arp_tdata_o  = from_tse_tdata_i;
    assign arp_tvld_o   = from_tse_tvld_i & rdy_global;
    assign arp_tlast_o  = from_tse_tlast_i;
    assign arp_tkeep_o  = from_tse_tkeep_i;

    
endmodule