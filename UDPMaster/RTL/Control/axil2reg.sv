module axil2reg #(
    parameter bit [47:0] MAC_BOARD_DEFAULT = 48'h012345678901,
    parameter bit [31:0] IP_BOARD_DEFAULT = 32'h12345678,
    parameter bit [15:0] PORT_BOARD_DEFAULT = 16'h1234,

    parameter bit [31:0] SERIAL_NUMBER = 32'h12345678,
    parameter bit [31:0] WRANDCODE_DEFAULT = 32'h12345678,
    parameter bit [31:0] WBURSTCODE_DEFAULT = 32'h12345678,
    parameter bit [31:0] RRANDCODE_DEFAULT = 32'h12345678,
    parameter bit [31:0] RBURSTCODE_DEFAULT = 32'h12345678,

    parameter bit LOCKED_SN = 1,
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
    output      logic   [31:0]      cntrl_control_o,
    //src parameter
    output      logic   [47:0]      cntrl_mac_src_o,
    output      logic   [31:0]      cntrl_ip_src_o,
    output      logic   [15:0]      cntrl_port_src_o,
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
    wire    [6:0]       reg_wr_addr;
    wire    [31:0]      reg_wr_data;
    wire    [3:0]       reg_wr_strb;
    wire                reg_wr_en;
    reg                 reg_wr_wait;
    reg                 reg_wr_ack;

    wire    [6:0]       reg_rd_addr;
    wire                reg_rd_en;
    reg     [31:0]      reg_rd_data;
    reg                 reg_rd_wait;
    reg                 reg_rd_ack;



    wire [4:0] wr_aligned_address = reg_wr_addr[6:2];
    wire [4:0] rd_aligned_address = reg_rd_addr[6:2];


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    axil_reg_if #
    (
        // Width of data bus in bits
        .DATA_WIDTH(32),
        // Width of address bus in bits
        .ADDR_WIDTH(7),
        // Width of wstrb (width of data bus in words)
        .STRB_WIDTH(4),
        // Timeout delay (cycles)
        .TIMEOUT(10)
    ) axil_reg_if_inst (
        .clk                (clk                        ),
        .rst                (~reset_n                   ),

        /*
        * AXI-Lite slave interface
        */
    //write channel
        .s_axil_awaddr		(s_axil_awaddr              ),
        .s_axil_awprot		(s_axil_awprot              ),
        .s_axil_awvalid	    (s_axil_awvalid             ),
        .s_axil_awready	    (s_axil_awready             ),
        .s_axil_wdata		(s_axil_wdata               ),
        .s_axil_wstrb		(s_axil_wstrb               ),
        .s_axil_wvalid		(s_axil_wvalid              ),
        .s_axil_wready		(s_axil_wready              ),
        .s_axil_bresp		(s_axil_bresp               ),
        .s_axil_bvalid		(s_axil_bvalid              ),
        .s_axil_bready		(s_axil_bready              ),
    //read channel
        .s_axil_araddr		(s_axil_araddr              ),
        .s_axil_arprot		(s_axil_arprot              ),
        .s_axil_arvalid 	(s_axil_arvalid             ),
        .s_axil_arready	    (s_axil_arready             ),
        .s_axil_rdata		(s_axil_rdata               ),
        .s_axil_rresp		(s_axil_rresp               ),
        .s_axil_rvalid		(s_axil_rvalid              ),
        .s_axil_rready		(s_axil_rready              ),

    /*
    * Register interface
    */
        .reg_wr_addr        (reg_wr_addr                ),
        .reg_wr_data        (reg_wr_data                ),
        .reg_wr_strb        (reg_wr_strb                ),
        .reg_wr_en          (reg_wr_en                  ),
        .reg_wr_wait        (reg_wr_wait                ),
        .reg_wr_ack         (reg_wr_ack                 ),

        .reg_rd_addr        (reg_rd_addr                ),
        .reg_rd_en          (reg_rd_en                  ),
        .reg_rd_data        (reg_rd_data                ),
        .reg_rd_wait        (reg_rd_wait                ),
        .reg_rd_ack         (reg_rd_ack                 )
    );




/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*
word(byte)
    0x0 (0x0)  - control (reserved)
    //source
    0x1 (0x4) - {16'h0, MAC_BOARD[47:32]} - MAC-адрес ядра
    0x2 (0x8) - MAC_BOARD[31:0] - MAC-адрес ядра
    0x3 (0xC) - IP_BOARD[31:0] - IP-адрес ядра
    0x4 (0x10) - {16'h0, PORT_BOARD[15:0]} - UDP PORT ядра

    //destinations
    0x5 (0x14) - ADDR_CELLS_DEST[31:0] - адрес заполняемой ячеки с параметрами конкретного канала
    0x6 (0x18) - MAC_DEST[47:32] - MAC-адрес назначения для канала, выбранного в ADDR_CELLS_DEST
    0x7 (0x1C) - MAC_DEST_LOW[31:0] - MAC-адрес назначения для канала, выбранного в ADDR_CELLS_DEST
    0x8 (0x20) - IP_DEST[31:0] - IP-адрес назначения для канала, выбранного в ADDR_CELLS_DEST
    0x9 (0x24) - PORT[15:0] назначения для канала, выбранного в ADDR_CELLS_DEST
    0xA (0x28) - WRITE_CELL[2:0] - строб записи данных во внутреннюю память для выбранного канала в ADDR_CELLS_DEST


    //ID's
    0xB (0x2C) - SERIAL_NUMBER[31:0] - уникальный серийный номер экземпляра ядра UDPMaster, можно переназначить его программным способом
    0xC (0x30) - WRANDCODE[31:0] - уникальный идентификатор транзакции записи по массиву адресов
    0xD (0x34) - WBURSTCODE[31:0] - уникальный идентификатор транзакции записи массива регистров в режиме burst с начальным адресом
    0xE (0x38) - RRANDCODE[31:0] - уникальный идентификатор транзакции чтения по массиву адресов
    0xF (0x3C) - RBURSTCODE[31:0] - уникальный идентификатор транзакции чтения массива регистров в режиме burst с начальным адресом
*/
    assign reg_wr_wait = 1'b0;
    assign reg_rd_wait = 1'b0;


    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) reg_wr_ack <= 1'b0;
        else if(reg_wr_ack) reg_wr_ack <= 1'b0;
        else reg_wr_ack <= reg_wr_en;
    end

//  0x0 - control
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) cntrl_control_o <= 32'h0;
        else if(reg_wr_en && (wr_aligned_address == 5'h0) && reg_wr_ack) begin
            if(reg_wr_strb[3])  cntrl_control_o[31:24]   <= reg_wr_data[31:24];
            if(reg_wr_strb[2])  cntrl_control_o[23:16]   <= reg_wr_data[23:16];
            if(reg_wr_strb[1])  cntrl_control_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_control_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//MAC_BOARD
//  0x1 (0x4) - MAC_BOARD[47:32]
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) cntrl_mac_src_o[47:32] <= MAC_BOARD_DEFAULT[47:32];
        else if(reg_wr_en && (wr_aligned_address == 5'h1) && reg_wr_ack) begin
            if(reg_wr_strb[1])  cntrl_mac_src_o[47:40]   <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_mac_src_o[39:32]  <= reg_wr_data[7:0];
        end
    end
//  0x2 (0x8) - MAC_BOARD[31:0]
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) cntrl_mac_src_o[31:0] <= MAC_BOARD_DEFAULT[31:0];
        else if(reg_wr_en && (wr_aligned_address == 5'h2) && reg_wr_ack) begin
            if(reg_wr_strb[3])  cntrl_mac_src_o[31:24]   <= reg_wr_data[31:24];
            if(reg_wr_strb[2])  cntrl_mac_src_o[23:16]   <= reg_wr_data[23:16];
            if(reg_wr_strb[1])  cntrl_mac_src_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_mac_src_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//  0x3(0xC) - IP_BOARD[31:0]
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) cntrl_ip_src_o[31:0] <= IP_BOARD_DEFAULT[31:0];
        else if(reg_wr_en && (wr_aligned_address == 5'h3) && reg_wr_ack) begin
            if(reg_wr_strb[3])  cntrl_ip_src_o[31:24]   <= reg_wr_data[31:24];
            if(reg_wr_strb[2])  cntrl_ip_src_o[23:16]   <= reg_wr_data[23:16];
            if(reg_wr_strb[1])  cntrl_ip_src_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_ip_src_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//  0x4(0x10) - PORT_BOARD[15:0]
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) cntrl_port_src_o[15:0] <= PORT_BOARD_DEFAULT[15:0];
        else if(reg_wr_en && (wr_aligned_address == 5'h4) && reg_wr_ack) begin
            if(reg_wr_strb[1])  cntrl_port_src_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_port_src_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//    0x5 (0x14) - ADDR_CELLS_DEST[31:0] - адрес заполняемой ячеки с параметрами конкретного канала
    always_ff @ (posedge clk) begin
        if(reg_wr_en && (wr_aligned_address == 5'h5) && reg_wr_ack) begin
            if(reg_wr_strb[3])  cntrl_addr_cell_dest_o[31:24]   <= reg_wr_data[31:24];
            if(reg_wr_strb[2])  cntrl_addr_cell_dest_o[23:16]   <= reg_wr_data[23:16];
            if(reg_wr_strb[1])  cntrl_addr_cell_dest_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_addr_cell_dest_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//    0x6 (0x18) - MAC_DEST[47:32] - MAC-адрес назначения для канала, выбранного в ADDR_CELLS_DEST
    always_ff @ (posedge clk) begin
        if(reg_wr_en && (wr_aligned_address == 5'h6) && reg_wr_ack) begin
            if(reg_wr_strb[1])  cntrl_mac_dest_o[47:40]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_mac_dest_o[39:32]     <= reg_wr_data[7:0];
        end
    end

//    0x7 (0x1C) - MAC_DEST_LOW[31:0] - MAC-адрес назначения для канала, выбранного в ADDR_CELLS_DEST
    always_ff @ (posedge clk) begin
        if(reg_wr_en && (wr_aligned_address == 5'h7) && reg_wr_ack) begin
            if(reg_wr_strb[3])  cntrl_mac_dest_o[31:24]   <= reg_wr_data[31:24];
            if(reg_wr_strb[2])  cntrl_mac_dest_o[23:16]   <= reg_wr_data[23:16];
            if(reg_wr_strb[1])  cntrl_mac_dest_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_mac_dest_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//    0x8 (0x20) - IP_DEST[31:0] - IP-адрес назначения для канала, выбранного в ADDR_CELLS_DEST
    always_ff @ (posedge clk) begin
        if(reg_wr_en && (wr_aligned_address == 5'h8) && reg_wr_ack) begin
            if(reg_wr_strb[3])  cntrl_ip_dest_o[31:24]   <= reg_wr_data[31:24];
            if(reg_wr_strb[2])  cntrl_ip_dest_o[23:16]   <= reg_wr_data[23:16];
            if(reg_wr_strb[1])  cntrl_ip_dest_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_ip_dest_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//    0x9 (0x24) - PORT назначения для канала, выбранного в ADDR_CELLS_DEST
    always_ff @ (posedge clk) begin
        if(reg_wr_en && (wr_aligned_address == 5'h9) && reg_wr_ack) begin
            if(reg_wr_strb[1])  cntrl_port_dest_o[15:8]    <= reg_wr_data[15:8];
            if(reg_wr_strb[0])  cntrl_port_dest_o[7:0]     <= reg_wr_data[7:0];
        end
    end

//    0xA (0x28) - WRITE_CELL - строб записи данных во внутреннюю память
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) cntrl_cell_dest_wr_o <= 3'h0;
        else if(reg_wr_en && (wr_aligned_address == 5'hA) && reg_wr_ack) begin
            if(reg_wr_strb[0])  cntrl_cell_dest_wr_o[2:0]     <= reg_wr_data[2:0];
        end
        else begin
            cntrl_cell_dest_wr_o <= 3'h0;
        end
    end

    generate
    //0xB (0x2C) - SERIAL_NUMBER[31:0] - уникальный серийный номер экземпляра ядра UDPMaster, можно переназначить его программным способом
        if(LOCKED_SN) begin:gen_locked_sn
            assign cntrl_serial_number_o = SERIAL_NUMBER[31:0];
        end
        else begin
            always_ff @ (posedge clk or negedge reset_n) begin
                if(!reset_n) cntrl_serial_number_o = SERIAL_NUMBER[31:0];
                else if(reg_wr_en && (wr_aligned_address == 5'hB) && reg_wr_ack) begin
                    if(reg_wr_strb[3])  cntrl_serial_number_o[31:24]   <= reg_wr_data[31:24];
                    if(reg_wr_strb[2])  cntrl_serial_number_o[23:16]   <= reg_wr_data[23:16];
                    if(reg_wr_strb[1])  cntrl_serial_number_o[15:8]    <= reg_wr_data[15:8];
                    if(reg_wr_strb[0])  cntrl_serial_number_o[7:0]     <= reg_wr_data[7:0];
                end
            end
        end

    //0xC (0x30) - WRANDCODE[31:0] - уникальный идентификатор транзакции записи по массиву адресов
    //0xD (0x34) - WBURSTCODE[31:0] - уникальный идентификатор транзакции записи массива регистров в режиме burst с начальным адресом
        if(LOCKED_WCODE) begin:gen_locked_wc
            assign cntrl_wrandcode_o = WRANDCODE_DEFAULT[31:0];
            assign cntrl_wburstcode_o = WBURSTCODE_DEFAULT[31:0];

        end
        else begin
            always_ff @ (posedge clk or negedge reset_n) begin
                if(!reset_n) cntrl_wrandcode_o = WRANDCODE_DEFAULT[31:0];
                else if(reg_wr_en && (wr_aligned_address == 5'hC) && reg_wr_ack) begin
                    if(reg_wr_strb[3])  cntrl_wrandcode_o[31:24]   <= reg_wr_data[31:24];
                    if(reg_wr_strb[2])  cntrl_wrandcode_o[23:16]   <= reg_wr_data[23:16];
                    if(reg_wr_strb[1])  cntrl_wrandcode_o[15:8]    <= reg_wr_data[15:8];
                    if(reg_wr_strb[0])  cntrl_wrandcode_o[7:0]     <= reg_wr_data[7:0];
                end
            end

            always_ff @ (posedge clk or negedge reset_n) begin
                if(!reset_n) cntrl_wburstcode_o = WBURSTCODE_DEFAULT[31:0];
                else if(reg_wr_en && (wr_aligned_address == 5'hD) && reg_wr_ack) begin
                    if(reg_wr_strb[3])  cntrl_wburstcode_o[31:24]   <= reg_wr_data[31:24];
                    if(reg_wr_strb[2])  cntrl_wburstcode_o[23:16]   <= reg_wr_data[23:16];
                    if(reg_wr_strb[1])  cntrl_wburstcode_o[15:8]    <= reg_wr_data[15:8];
                    if(reg_wr_strb[0])  cntrl_wburstcode_o[7:0]     <= reg_wr_data[7:0];
                end
            end
        end

    //0xE (0x38) - RRANDCODE[31:0] - уникальный идентификатор транзакции чтения по массиву адресов
    //0xF (0x3C) - RBURSTCODE[31:0] - уникальный идентификатор транзакции чтения массива регистров в режиме burst с начальным адресом
        if(LOCKED_RCODE) begin:gen_locked_rc
            assign cntrl_rrandcode_o = RRANDCODE_DEFAULT[31:0];
            assign cntrl_rburstcode_o = RBURSTCODE_DEFAULT[31:0];
        end
        else begin
            always_ff @ (posedge clk or negedge reset_n) begin
                if(!reset_n) cntrl_rrandcode_o = RRANDCODE_DEFAULT[31:0];
                else if(reg_wr_en && (wr_aligned_address == 5'hE) && reg_wr_ack) begin
                    if(reg_wr_strb[3])  cntrl_rrandcode_o[31:24]   <= reg_wr_data[31:24];
                    if(reg_wr_strb[2])  cntrl_rrandcode_o[23:16]   <= reg_wr_data[23:16];
                    if(reg_wr_strb[1])  cntrl_rrandcode_o[15:8]    <= reg_wr_data[15:8];
                    if(reg_wr_strb[0])  cntrl_rrandcode_o[7:0]     <= reg_wr_data[7:0];
                end
            end

            always_ff @ (posedge clk or negedge reset_n) begin
                if(!reset_n) cntrl_rburstcode_o = RBURSTCODE_DEFAULT[31:0];
                else if(reg_wr_en && (wr_aligned_address == 5'hF) && reg_wr_ack) begin
                    if(reg_wr_strb[3])  cntrl_rburstcode_o[31:24]   <= reg_wr_data[31:24];
                    if(reg_wr_strb[2])  cntrl_rburstcode_o[23:16]   <= reg_wr_data[23:16];
                    if(reg_wr_strb[1])  cntrl_rburstcode_o[15:8]    <= reg_wr_data[15:8];
                    if(reg_wr_strb[0])  cntrl_rburstcode_o[7:0]     <= reg_wr_data[7:0];
                end
            end
        end
    endgenerate


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            ASSERTIONS       ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
//unknown register
    SVA_CHECK_CONTROL_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        !$isunknown(cntrl_control_o)
    ) else $error("SVA error: control register is unknown!");

    SVA_CHECK_MAC_SRC_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        !$isunknown(cntrl_mac_src_o)
    ) else $error("SVA error: MAC SRC register is unknown!");

    SVA_CHECK_IP_SRC_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        !$isunknown(cntrl_ip_src_o)
    ) else $error("SVA error: IP SRC register is unknown!");

    SVA_CHECK_PORT_SRC_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        !$isunknown(cntrl_port_src_o)
    ) else $error("SVA error: PORT SRC register is unknown!");
    
//check cells parameter
    SVA_CHECK_ADDR_CELL_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        cntrl_cell_dest_wr_o > 0 |-> !$isunknown(cntrl_addr_cell_dest_o)
    ) else $error("SVA error: ADDRESS_CELL register is unknown!");

    SVA_CHECK_MAC_DEST_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        cntrl_cell_dest_wr_o[0] |-> !$isunknown(cntrl_mac_dest_o)
    ) else $error("SVA error: MAC DEST register is unknown!");

    SVA_CHECK_IP_DEST_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        cntrl_cell_dest_wr_o[1] |-> !$isunknown(cntrl_ip_dest_o)
    ) else $error("SVA error: IP DEST register is unknown!");

    SVA_CHECK_PORT_DEST_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        cntrl_cell_dest_wr_o[2] |-> !$isunknown(cntrl_port_dest_o)
    ) else $error("SVA error: PORT DEST register is unknown!");

endmodule
