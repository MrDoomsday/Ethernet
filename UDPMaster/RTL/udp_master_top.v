module udp_master_top #(
    parameter SERIAL_NUMBER = 32'h14082024,
    parameter LOCKED_SN = 1,//блокировка изменения серийного номера ядра
    parameter LOCKED_WCODE = 1,//блокировка изменения идентификаторов для записи по регистрам
    parameter LOCKED_RCODE = 1,//блоктровка изменения идентификаторов для чтения по регистрам

    parameter UID_WIDTH = 10,//ширина порта канала
    parameter FIFO_SIZE_DATA = 10,
    parameter FIFO_SIZE_HDR = 10,
    parameter FIFO_SIZE_MAC = 10,

    // Width of data bus in bits
    parameter DATA_WIDTH = 32,
    // Width of address bus in bits
    parameter ADDR_WIDTH = 32,
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8)
)(
    input       wire                        clk,
    input       wire                        reset_n,


    //AXI Lite control
    input       wire    [6:0]               s_axil_awaddr,
    input       wire    [2:0]               s_axil_awprot,
    input       wire                        s_axil_awvalid,
    output      wire                        s_axil_awready,
    input       wire    [31:0]              s_axil_wdata,
    input       wire    [3:0]               s_axil_wstrb,
    input       wire                        s_axil_wvalid,
    output      wire                        s_axil_wready,
    output      wire    [1:0]               s_axil_bresp,
    output      wire                        s_axil_bvalid,
    input       wire                        s_axil_bready,
    input       wire    [6:0]               s_axil_araddr,
    input       wire    [2:0]               s_axil_arprot,
    input       wire                        s_axil_arvalid,
    output      wire                        s_axil_arready,
    output      wire    [31:0]              s_axil_rdata,
    output      wire    [1:0]               s_axil_rresp,
    output      wire                        s_axil_rvalid,
    input       wire                        s_axil_rready,

    //user payload
    input       wire    [UID_WIDTH-1:0]     user_tid_i,
    input       wire    [31:0]              user_tdata_i,
    input       wire                        user_tvld_i,
    input       wire                        user_tlast_i,
	input       wire    [3:0]               user_tkeep_i, 
    output      wire                        user_trdy_o,



    //AXI-4 for access external registers
    output      wire    [ADDR_WIDTH-1:0]    m_axi_awaddr,
    output      wire    [7:0]               m_axi_awlen,
    output      wire    [2:0]               m_axi_awsize,
    output      wire    [1:0]               m_axi_awburst,
    output      wire                        m_axi_awlock,
    output      wire    [3:0]               m_axi_awcache,
    output      wire    [2:0]               m_axi_awprot,
    output      wire    [3:0]               m_axi_awqos,
    output      wire    [3:0]               m_axi_awwireion,
    output      wire                        m_axi_awvalid,
    input       wire                        m_axi_awready,
    output      wire    [DATA_WIDTH-1:0]    m_axi_wdata,
    output      wire    [STRB_WIDTH-1:0]    m_axi_wstrb,
    output      wire                        m_axi_wlast,
    output      wire                        m_axi_wvalid,
    input       wire                        m_axi_wready,
    input       wire    [1:0]               m_axi_bresp,
    input       wire                        m_axi_bvalid,
    output      wire                        m_axi_bready,

    output      wire    [ADDR_WIDTH-1:0]    m_axi_araddr,
    output      wire    [7:0]               m_axi_arlen,
    output      wire    [2:0]               m_axi_arsize,
    output      wire    [1:0]               m_axi_arburst,
    output      wire                        m_axi_arlock,
    output      wire    [3:0]               m_axi_arcache,
    output      wire    [2:0]               m_axi_arprot,
    output      wire    [3:0]               m_axi_arqos,
    output      wire    [3:0]               m_axi_arwireion,
    output      wire                        m_axi_arvalid,
    input       wire                        m_axi_arready,
    input       wire    [DATA_WIDTH-1:0]    m_axi_rdata,
    input       wire    [1:0]               m_axi_rresp,
    input       wire                        m_axi_rlast,
    input       wire                        m_axi_rvalid,
    output      wire                        m_axi_rready,


    //for MAC-core (triple speed ethernet (Altera, Xilinx))
    output      wire    [31:0]              for_tse_tdata_o,
    output      wire                        for_tse_tvld_o,
    output      wire                        for_tse_tlast_o,
	output      wire    [3:0]               for_tse_tkeep_o, 
    input       wire                        for_tse_trdy_i,

    //from tse
    input       wire    [31:0]              from_tse_tdata_i,
    input       wire                        from_tse_tvld_i,
    input       wire                        from_tse_tlast_i,
	input       wire    [3:0]               from_tse_tkeep_i, 
    output      wire                        from_tse_trdy_o

);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
//splitter
    //for search device
    wire    [31:0]      splt_sd_tdata;
    wire                splt_sd_tvld;
    wire                splt_sd_tlast;
	wire    [3:0]       splt_sd_tkeep;
    wire                splt_sd_trdy;

    //for axi2udp
    wire    [31:0]      splt_au_tdata;
    wire                splt_au_tvld;
    wire                splt_au_tlast;
	wire    [3:0]       splt_au_tkeep; 
    wire                splt_au_trdy;

    //for ARP
    wire    [31:0]      splt_arp_tdata;
    wire                splt_arp_tvld;
    wire                splt_arp_tlast;
	wire    [3:0]       splt_arp_tkeep; 
    wire                splt_arp_trdy;


//connect multiplexer for IP-packet
    wire    [47:0]      sd_hdr_mac_dest, sd_hdr_mac_src;
    wire    [31:0]      sd_hdr_ip_dest, sd_hdr_ip_src;
    wire    [15:0]      sd_hdr_port_dest, sd_hdr_port_src;
    wire    [31:0]      sd_tdata;
    wire                sd_tvld;
    wire                sd_tlast;
    wire    [3:0]       sd_tkeep;
    wire                sd_trdy;
    wire    [47:0]      au_hdr_mac_dest, au_hdr_mac_src;
    wire    [31:0]      au_hdr_ip_dest, au_hdr_ip_src;
    wire    [15:0]      au_hdr_port_dest, au_hdr_port_src;
    wire    [31:0]      au_tdata;
    wire                au_tvld;
    wire                au_tlast;
    wire    [3:0]       au_tkeep;
    wire                au_trdy;
    wire    [47:0]      us_hdr_mac_dest, us_hdr_mac_src;
    wire    [31:0]      us_hdr_ip_dest, us_hdr_ip_src;
    wire    [15:0]      us_hdr_port_dest, us_hdr_port_src;
    wire    [31:0]      us_tdata;
    wire                us_tvld;
    wire                us_tlast;
    wire    [3:0]       us_tkeep;
    wire                us_trdy;
    wire    [47:0]      mux_hdr_mac_dest, mux_hdr_mac_src;
    wire    [31:0]      mux_hdr_ip_dest, mux_hdr_ip_src;
    wire    [15:0]      mux_hdr_port_dest, mux_hdr_port_src;
    wire    [31:0]      mux_tdata;
    wire                mux_tvld;
    wire                mux_tlast;
    wire    [3:0]       mux_tkeep;
    wire                mux_trdy;

//packet IP/UDP
    wire    [31:0]      ip_udp_tdata;
    wire                ip_udp_tvld;
    wire                ip_udp_tlast;
    wire    [3:0]       ip_udp_tkeep;
    wire                ip_udp_rdy;

//for fifo MAC addresses
    wire                mac_ip_udp_ready;
    wire    [95:0]      in_mac_fifo_tdata, out_mac_fifo_tdata;
    wire                in_mac_fifo_tvalid, out_mac_fifo_tvalid;
    wire                in_mac_fifo_tready, out_mac_fifo_tready;


//for ARP module
    wire 	[47:0]  	arp_response_mac_dest, arp_response_mac_src;
    wire 			    arp_response_mac_vld;
    wire 	[15:0]	    arp_response_mac_type;
    wire 			    arp_response_mac_rdy;

    wire    [31:0]      arp_response_tdata;
    wire                arp_response_tvld;
    wire                arp_response_tlast;
    wire    [3:0]       arp_response_tkeep;
    wire                arp_response_rdy;

//control module (AXI-Lite to REG)
    wire    [47:0]      cntrl_mac_src_board;
    wire    [31:0]      cntrl_ip_src_board;
    wire    [15:0]      cntrl_port_src_board;
    wire    [31:0]      cntrl_addr_cell_dest;
    wire    [47:0]      cntrl_mac_dest;
    wire    [31:0]      cntrl_ip_dest;
    wire    [15:0]      cntrl_port_dest;
    wire    [2:0]       cntrl_cell_dest_wr;
    wire    [47:0]      cntrl_mac_dest_rdata;
    wire    [31:0]      cntrl_ip_dest_rdata;
    wire    [15:0]      cntrl_port_dest_rdata;

    wire   [31:0]       cntrl_serial_number;//уникальный серийный номер экземпляра ядра UDPMaster, можно переназначить его программным способом
    wire   [31:0]       cntrl_wrandcode;//уникальный идентификатор транзакции записи по массиву адресов
    wire   [31:0]       cntrl_wburstcode;//уникальный идентификатор транзакции записи массива регистров в режиме burst с начальным адресом
    wire   [31:0]       cntrl_rrandcode;//уникальный идентификатор транзакции чтения по массиву адресов
    wire   [31:0]       cntrl_rburstcode;//уникальный идентификатор транзакции чтения массива регистров в режиме burst с начальным адресом

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/


    axil2reg #(
        .SERIAL_NUMBER  (SERIAL_NUMBER),
        .LOCKED_SN      (LOCKED_SN),
        .LOCKED_WCODE   (LOCKED_WCODE),
        .LOCKED_RCODE   (LOCKED_RCODE)
    ) axil2reg_inst (
        .clk                        (clk),
        .reset_n                    (reset_n),

        .s_axil_awaddr              (s_axil_awaddr),
        .s_axil_awprot              (s_axil_awprot),
        .s_axil_awvalid             (s_axil_awvalid),
        .s_axil_awready             (s_axil_awready),
        .s_axil_wdata               (s_axil_wdata),
        .s_axil_wstrb               (s_axil_wstrb),
        .s_axil_wvalid              (s_axil_wvalid),
        .s_axil_wready              (s_axil_wready),
        .s_axil_bresp               (s_axil_bresp),
        .s_axil_bvalid              (s_axil_bvalid),
        .s_axil_bready              (s_axil_bready),

        .s_axil_araddr              (s_axil_araddr),
        .s_axil_arprot              (s_axil_arprot),
        .s_axil_arvalid             (s_axil_arvalid),
        .s_axil_arready             (s_axil_arready),
        .s_axil_rdata               (s_axil_rdata),
        .s_axil_rresp               (s_axil_rresp),
        .s_axil_rvalid              (s_axil_rvalid),
        .s_axil_rready              (s_axil_rready),


    //control register
        //src parameter
        .cntrl_mac_src_o            (cntrl_mac_src_board),
        .cntrl_ip_src_o             (cntrl_ip_src_board),
        .cntrl_port_o               (cntrl_port_src_board),
        //dst parameter
        .cntrl_addr_cell_dest_o     (cntrl_addr_cell_dest),//адрес текущей ячейки с адресами назначения конкретного канала
        .cntrl_mac_dest_o           (cntrl_mac_dest),
        .cntrl_ip_dest_o            (cntrl_ip_dest),
        .cntrl_port_dest_o          (cntrl_port_dest),
        .cntrl_cell_dest_wr_o       (cntrl_cell_dest_wr),//стробы записи, [0] - mac_write, [1] - ip write, [2] - port write

        .cntrl_mac_dest_rdata_i     (cntrl_mac_dest_rdata),
        .cntrl_ip_dest_rdata_i      (cntrl_ip_dest_rdata),
        .cntrl_port_dest_rdata_i    (cntrl_port_dest_rdata),

        .cntrl_serial_number_o      (cntrl_serial_number),//уникальный серийный номер экземпляра ядра UDPMaster, можно переназначить его программным способом
        .cntrl_wrandcode_o          (cntrl_wrandcode),//уникальный идентификатор транзакции записи по массиву адресов
        .cntrl_wburstcode_o         (cntrl_wburstcode),//уникальный идентификатор транзакции записи массива регистров в режиме burst с начальным адресом
        .cntrl_rrandcode_o          (cntrl_rrandcode),//уникальный идентификатор транзакции чтения по массиву адресов
        .cntrl_rburstcode_o         (cntrl_rburstcode)//уникальный идентификатор транзакции чтения массива регистров в режиме burst с начальным адресом
    );


    user_data_packer # (
      .ID_WIDTH(UID_WIDTH)
    ) user_data_packer_inst (
      .clk                      (clk),
      .reset_n                  (reset_n),

      .cntrl_mac_src_i          (cntrl_mac_src_board),
      .cntrl_ip_src_i           (cntrl_ip_src_board),
      .cntrl_port_src_i         (cntrl_port_src_board),
      .cntrl_addr_cell_dest_i   (cntrl_addr_cell_dest[UID_WIDTH-1:0]),
      .cntrl_mac_dest_i         (cntrl_mac_dest),
      .cntrl_ip_dest_i          (cntrl_ip_dest),
      .cntrl_port_dest_i        (cntrl_port_dest),
      .cntrl_cell_dest_wr_i     (cntrl_cell_dest_wr),
      .cntrl_mac_dest_rdata_o   (cntrl_mac_dest_rdata),
      .cntrl_ip_dest_rdata_o    (cntrl_ip_dest_rdata),
      .cntrl_port_dest_rdata_o  (cntrl_port_dest_rdata),

      .user_in_tid_i            (user_tid_i),
      .user_in_tdata_i          (user_tdata_i),
      .user_in_tvld_i           (user_tvld_i),
      .user_in_tlast_i          (user_tlast_i),
      .user_in_tkeep_i          (user_tkeep_i),
      .user_in_trdy_o           (user_trdy_o),

      .hdr_mac_dest_o           (us_hdr_mac_dest),
      .hdr_mac_src_o            (us_hdr_mac_src),
      .hdr_ip_dest_o            (us_hdr_ip_dest),
      .hdr_ip_src_o             (us_hdr_ip_src),
      .hdr_port_dest_o          (us_hdr_port_dest),
      .hdr_port_src_o           (us_hdr_port_src),
      .user_out_tdata_o         (us_tdata),
      .user_out_tvld_o          (us_tvld),
      .user_out_tlast_o         (us_tlast),
      .user_out_tkeep_o         (us_tkeep),
      .user_out_rdy_i           (us_trdy)
    );
  

    st_splitter st_splitter_inst (
        .clk                (clk),
        .reset_n            (reset_n),
        .from_tse_tdata_i   (from_tse_tdata_i),
        .from_tse_tvld_i    (from_tse_tvld_i),
        .from_tse_tlast_i   (from_tse_tlast_i),
        .from_tse_tkeep_i   (from_tse_tkeep_i),
        .from_tse_trdy_o    (from_tse_trdy_o),

        .sd_tdata_o         (splt_sd_tdata),
        .sd_tvld_o          (splt_sd_tvld),
        .sd_tlast_o         (splt_sd_tlast),
        .sd_tkeep_o         (splt_sd_tkeep),
        .sd_trdy_i          (splt_sd_trdy),
        .au_tdata_o         (splt_au_tdata),
        .au_tvld_o          (splt_au_tvld),
        .au_tlast_o         (splt_au_tlast),
        .au_tkeep_o         (splt_au_tkeep),
        .au_trdy_i          (splt_au_trdy),
        .arp_tdata_o        (splt_arp_tdata),
        .arp_tvld_o         (splt_arp_tvld),
        .arp_tlast_o        (splt_arp_tlast),
        .arp_tkeep_o        (splt_arp_tkeep),
        .arp_trdy_i         (splt_arp_trdy)
    );


    
    mux_ipudp mux_ipudp_inst (
        .clk                    (clk),
        .reset_n                (reset_n),
        .sd_hdr_mac_dest_i      (sd_hdr_mac_dest),
        .sd_hdr_mac_src_i       (sd_hdr_mac_src),
        .sd_hdr_ip_dest_i       (sd_hdr_ip_dest),
        .sd_hdr_ip_src_i        (sd_hdr_ip_src),
        .sd_hdr_port_dest_i     (sd_hdr_port_dest),
        .sd_hdr_port_src_i      (sd_hdr_port_src),
        .sd_tdata_i             (sd_tdata),
        .sd_tvld_i              (sd_tvld),
        .sd_tlast_i             (sd_tlast),
        .sd_tkeep_i             (sd_tkeep),
        .sd_trdy_o              (sd_trdy),
        .au_hdr_mac_dest_i      (au_hdr_mac_dest),
        .au_hdr_mac_src_i       (au_hdr_mac_src),
        .au_hdr_ip_dest_i       (au_hdr_ip_dest),
        .au_hdr_ip_src_i        (au_hdr_ip_src),
        .au_hdr_port_dest_i     (au_hdr_port_dest),
        .au_hdr_port_src_i      (au_hdr_port_src),
        .au_tdata_i             (au_tdata),
        .au_tvld_i              (au_tvld),
        .au_tlast_i             (au_tlast),
        .au_tkeep_i             (au_tkeep),
        .au_trdy_o              (au_trdy),
        .us_hdr_mac_dest_i      (us_hdr_mac_dest),
        .us_hdr_mac_src_i       (us_hdr_mac_src),
        .us_hdr_ip_dest_i       (us_hdr_ip_dest),
        .us_hdr_ip_src_i        (us_hdr_ip_src),
        .us_hdr_port_dest_i     (us_hdr_port_dest),
        .us_hdr_port_src_i      (us_hdr_port_src),
        .us_tdata_i             (us_tdata),
        .us_tvld_i              (us_tvld),
        .us_tlast_i             (us_tlast),
        .us_tkeep_i             (us_tkeep),
        .us_trdy_o              (us_trdy),

        .mux_hdr_mac_dest_o     (mux_hdr_mac_dest),
        .mux_hdr_mac_src_o      (mux_hdr_mac_src),
        .mux_hdr_ip_dest_o      (mux_hdr_ip_dest),
        .mux_hdr_ip_src_o       (mux_hdr_ip_src),
        .mux_hdr_port_dest_o    (mux_hdr_port_dest),
        .mux_hdr_port_src_o     (mux_hdr_port_src),
        .mux_tdata_o            (mux_tdata),
        .mux_tvld_o             (mux_tvld),
        .mux_tlast_o            (mux_tlast),
        .mux_tkeep_o            (mux_tkeep),
        .mux_trdy_i             (mux_trdy)
    );



    ip_udp_packer #(
        .FIFO_SIZE_DATA(FIFO_SIZE_DATA),
        .FIFO_SIZE_HDR(FIFO_SIZE_HDR)
    ) ip_udp_packer_inst (
        .clk                (clk),
        .reset_n            (reset_n),
    
        //заголовок идет синхронно с пакетом (при приеме первого слова заголовок уже выставлен)
        .hdr_ip_dest_i      (mux_hdr_ip_dest), 
        .hdr_ip_src_i       (mux_hdr_ip_src),//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
        .hdr_port_dest_i    (mux_hdr_port_dest), 
        .hdr_port_src_i     (mux_hdr_port_src),
    
        .user_tdata_i       (mux_tdata),
        .user_tvld_i        (mux_tvld & mac_ip_udp_ready),
        .user_tlast_i       (mux_tlast),
        .user_tkeep_i       (mux_tkeep), 
        .user_trdy_o        (mux_trdy),
    
    
        .ip_udp_tdata_o     (ip_udp_tdata),
        .ip_udp_tvld_o      (ip_udp_tvld),
        .ip_udp_tlast_o     (ip_udp_tlast),
        .ip_udp_tkeep_o     (ip_udp_tkeep),
        .ip_udp_rdy_i       (ip_udp_rdy)
    );


    axis_fifo # (
        .T_DATA_WIDTH   (48+48),//mac src + mac dest
        .SIZE           (FIFO_SIZE_MAC)
    ) mac_fifo_inst (
        .clk        (clk),
        .reset_n    (reset_n),

        .s_data_i   (in_mac_fifo_tdata),
        .s_valid_i  (in_mac_fifo_tvalid & mac_ip_udp_ready),
        .s_ready_o  (in_mac_fifo_tready),
        
        .m_data_o   (out_mac_fifo_tdata),
        .m_valid_o  (out_mac_fifo_tvalid),
        .m_ready_i  (out_mac_fifo_tready)
    );




    arp arp_inst (
        .clk                    (clk),
        .reset_n                (reset_n),
        .cntrl_mac_src_i        (cntrl_mac_src_board),
        .cntrl_ip_src_i         (cntrl_ip_src_board),
        .cntrl_port_src_i       (cntrl_port_src_board),
        
        .arp_request_tdata_i    (splt_arp_tdata),
        .arp_request_tvld_i     (splt_arp_tvld),
        .arp_request_tlast_i    (splt_arp_tlast),
        .arp_request_tkeep_i    (splt_arp_tkeep),
        .arp_request_trdy_o     (splt_arp_trdy),
        
        .arp_response_mac_dest_o(arp_response_mac_dest),
        .arp_response_mac_src_o (arp_response_mac_src),
        .arp_response_mac_type_o(arp_response_mac_type),
        .arp_response_mac_vld_o (arp_response_mac_vld),
        .arp_response_mac_rdy_i (arp_response_mac_rdy),
        .arp_response_tdata_o   (arp_response_tdata),
        .arp_response_tvld_o    (arp_response_tvld),
        .arp_response_tlast_o   (arp_response_tlast),
        .arp_response_tkeep_o   (arp_response_tkeep),
        .arp_response_rdy_i     (arp_response_rdy)
    );


    ethII_top ethII_top_inst (
        .clk                    (clk),
        .reset_n                (reset_n),

        .arp_mac_dest_i         (arp_response_mac_dest),
        .arp_mac_src_i          (arp_response_mac_src),
        .arp_mac_type_i         (arp_response_mac_type),
        .arp_mac_vld_i          (arp_response_mac_vld),
        .arp_mac_rdy_o          (arp_response_mac_rdy),
        .arp_tdata_i            (arp_response_tdata),
        .arp_tvld_i             (arp_response_tvld),
        .arp_tlast_i            (arp_response_tlast),
        .arp_tkeep_i            (arp_response_tkeep),
        .arp_trdy_o             (arp_response_rdy),

        .ipv4_mac_dest_i        (out_mac_fifo_tdata[95:48]),
        .ipv4_mac_src_i         (out_mac_fifo_tdata[47:0]),
        .ipv4_mac_type_i        (16'h0800),
        .ipv4_mac_vld_i         (out_mac_fifo_tvalid),
        .ipv4_mac_rdy_o         (out_mac_fifo_tready),
        .ipv4_tdata_i           (ip_udp_tdata),
        .ipv4_tvld_i            (ip_udp_tvld),
        .ipv4_tlast_i           (ip_udp_tlast),
        .ipv4_tkeep_i           (ip_udp_tkeep),
        .ipv4_trdy_o            (ip_udp_rdy),


        .ethii_ip_udp_tdata_o   (for_tse_tdata_o),
        .ethii_ip_udp_tvld_o    (for_tse_tvld_o),
        .ethii_ip_udp_tlast_o   (for_tse_tlast_o),
        .ethii_ip_udp_tkeep_o   (for_tse_tkeep_o),
        .ethii_ip_udp_rdy_i     (for_tse_trdy_i)
    );


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    assign mac_ip_udp_ready = mux_trdy & in_mac_fifo_tready;
    assign in_mac_fifo_tdata = {mux_hdr_mac_dest, mux_hdr_mac_src};

    //это пока для отключения портов, т.к. модули еще не написаны
    assign sd_tvld = 1'b0;
    assign au_tvld = 1'b0;

    assign splt_sd_trdy = 1'b1;
    assign splt_au_trdy = 1'b1;

endmodule