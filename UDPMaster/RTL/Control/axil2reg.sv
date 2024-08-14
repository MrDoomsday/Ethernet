module axil2reg #(
    parameter bit [31:0] SERIAL_NUMBER = 32'h12345678,
    parameter bit LOCKED_SN = 0,
    parameter bit LOCKED_WCODE = 1,
    parameter bit LOCKED_RCODE = 1
)(
    input       logic               clk,
    input       logic               reset_n,

    input       logic   [6:0]       s_axil_awaddr,
    input       logic   [2:0]       s_axil_awprot,
    input       logic               s_axil_awvalid,
    output      logic               s_axil_awready,
    input       logic   [31:0]      s_axil_wdata,
    input       logic   [3:0]       s_axil_wstrb,
    input       logic               s_axil_wvalid,
    output      logic               s_axil_wready,
    output      logic   [1:0]       s_axil_bresp,
    output      logic               s_axil_bvalid,
    input       logic               s_axil_bready,
    input       logic   [6:0]       s_axil_araddr,
    input       logic   [2:0]       s_axil_arprot,
    input       logic               s_axil_arvalid,
    output      logic               s_axil_arready,
    output      logic   [31:0]      s_axil_rdata,
    output      logic   [1:0]       s_axil_rresp,
    output      logic               s_axil_rvalid,
    input       logic               s_axil_rready,


//control register
    //src parameter
    output      logic   [47:0]      cntrl_mac_src_o,
    output      logic   [31:0]      cntrl_ip_src_o,
    output      logic   [15:0]      cntrl_port_o,
    //dst parameter
    output      logic   [31:0]      cntrl_addr_cell_dest_o,//адрес текущей ячейки с адресами назначения конкретного канала
    output      logic   [47:0]      cntrl_mac_dest_o,
    output      logic   [31:0]      cntrl_ip_dest_o,
    output      logic   [15:0]      cntrl_port_dest_o,
    output      logic   [2:0]       cntrl_cell_dest_wr_o,//стробы записи, [0] - mac_write, [1] - ip write, [2] - port write

    input       logic   [47:0]      cntrl_mac_dest_rdata_i,
    input       logic   [31:0]      cntrl_ip_dest_rdata_i,
    input       logic   [15:0]      cntrl_port_dest_rdata_i,

    output      logic   [31:0]      cntrl_serial_number_o,//уникальный серийный номер экземпляра ядра UDPMaster, можно переназначить его программным способом
    
    output      logic   [31:0]      cntrl_wrandcode_o,//уникальный идентификатор транзакции записи по массиву адресов
    output      logic   [31:0]      cntrl_wburstcode_o,//уникальный идентификатор транзакции записи массива регистров в режиме burst с начальным адресом
    output      logic   [31:0]      cntrl_rrandcode_o,//уникальный идентификатор транзакции чтения по массиву адресов
    output      logic   [31:0]      cntrl_rburstcode_o//уникальный идентификатор транзакции чтения массива регистров в режиме burst с начальным адресом
);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/




/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/



/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/



endmodule
