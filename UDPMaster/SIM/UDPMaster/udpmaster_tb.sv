`include "udp_master_pkg.sv"
`include "tb_interface.sv"
`include "packet.sv"
`include "configuration.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "axil_access.sv"
`include "test.sv"

module udpmaster_tb();

    localparam UID_WIDTH = 10;//ширина порта канала
    localparam FIFO_SIZE_DATA = 2048;
    localparam FIFO_SIZE_HDR = 2048;
    localparam FIFO_SIZE_MAC = 2048;

    localparam [47:0] MAC_BOARD_DEFAULT = 48'h012345678901;
    localparam [31:0] IP_BOARD_DEFAULT = 32'h12345678;
    localparam [15:0] PORT_BOARD_DEFAULT = 16'h1234;

    localparam LOCKED_SN = 1;//блокировка изменения серийного номера ядра
    localparam LOCKED_WCODE = 1;//блокировка изменения идентификаторов для записи по регистрам
    localparam LOCKED_RCODE = 1;//блокировка изменения идентификаторов для чтения по регистрам


    localparam [31:0] SERIAL_NUMBER = 32'h12345678;
    localparam [31:0] WRANDCODE_DEFAULT = 32'h12345678;
    localparam [31:0] WBURSTCODE_DEFAULT = 32'h12345678;
    localparam [31:0] RRANDCODE_DEFAULT = 32'h12345678;
    localparam [31:0] RBURSTCODE_DEFAULT = 32'h12345678;

    bit                             clk;
    bit                             reset_n;

    s_axil_intf vif_s_axil(clk, reset_n);//control interface
    stream_intf vif_tse_in(clk, reset_n);//triple speed ethernet in
    stream_intf vif_tse_out(clk, reset_n);//triple speed ethernet out
    stream_intf #(.ID_WIDTH(UID_WIDTH)) vif_us_in (clk, reset_n);//user stream in

    test #(.ID_WIDTH(UID_WIDTH)) test_n;

    udp_master_top #(
        .UID_WIDTH              (UID_WIDTH),//ширина порта канала
        .FIFO_SIZE_DATA         (FIFO_SIZE_DATA),
        .FIFO_SIZE_HDR          (FIFO_SIZE_HDR),
        .FIFO_SIZE_MAC          (FIFO_SIZE_MAC),
    
        .MAC_BOARD_DEFAULT      (MAC_BOARD_DEFAULT),
        .IP_BOARD_DEFAULT       (IP_BOARD_DEFAULT),
        .PORT_BOARD_DEFAULT     (PORT_BOARD_DEFAULT),
    
        .LOCKED_SN              (LOCKED_SN),//блокировка изменения серийного номера ядра
        .LOCKED_WCODE           (LOCKED_WCODE),//блокировка изменения идентификаторов для записи по регистрам
        .LOCKED_RCODE           (LOCKED_RCODE),//блокировка изменения идентификаторов для чтения по регистрам
    
    
        .SERIAL_NUMBER          (SERIAL_NUMBER),
        .WRANDCODE_DEFAULT      (WRANDCODE_DEFAULT),
        .WBURSTCODE_DEFAULT     (WBURSTCODE_DEFAULT),
        .RRANDCODE_DEFAULT      (RRANDCODE_DEFAULT),
        .RBURSTCODE_DEFAULT     (RBURSTCODE_DEFAULT)
    
    ) DUT (
        .clk                (clk                    ),
        .reset_n            (reset_n                ),
    

    //AXI Lite control
    //write channel
        .s_axil_awaddr		(vif_s_axil.awaddr      ),
        .s_axil_awprot		(vif_s_axil.awprot      ),
        .s_axil_awvalid	    (vif_s_axil.awvalid     ),
        .s_axil_awready	    (vif_s_axil.awready     ),
        .s_axil_wdata		(vif_s_axil.wdata       ),
        .s_axil_wstrb		(vif_s_axil.wstrb       ),
        .s_axil_wvalid		(vif_s_axil.wvalid      ),
        .s_axil_wready		(vif_s_axil.wready      ),
        .s_axil_bresp		(vif_s_axil.bresp       ),
        .s_axil_bvalid		(vif_s_axil.bvalid      ),
        .s_axil_bready		(vif_s_axil.bready      ),
    //read channel
        .s_axil_araddr		(vif_s_axil.araddr      ),
        .s_axil_arprot		(vif_s_axil.arprot      ),
        .s_axil_arvalid 	(vif_s_axil.arvalid     ),
        .s_axil_arready	    (vif_s_axil.arready     ),
        .s_axil_rdata		(vif_s_axil.rdata       ),
        .s_axil_rresp		(vif_s_axil.rresp       ),
        .s_axil_rvalid		(vif_s_axil.rvalid      ),
        .s_axil_rready		(vif_s_axil.rready      ),
        
        //user payload
        .user_tid_i         (vif_us_in.tid          ),
        .user_tdata_i       (vif_us_in.tdata        ),
        .user_tvld_i        (vif_us_in.tvalid       ),
        .user_tlast_i       (vif_us_in.tlast        ),
        .user_tkeep_i       (vif_us_in.tkeep        ), 
        .user_trdy_o        (vif_us_in.tready       ),
    

/*    
        //AXI-4 for access external registers
        output      wire    [63:0]              m_axi_awaddr,
        output      wire    [7:0]               m_axi_awlen,
        output      wire    [2:0]               m_axi_awsize,
        output      wire    [1:0]               m_axi_awburst,
        output      wire                        m_axi_awlock,
        output      wire    [3:0]               m_axi_awcache,
        output      wire    [2:0]               m_axi_awprot,
        output      wire    [3:0]               m_axi_awqos,
        output      wire    [3:0]               m_axi_awregion,
        output      wire                        m_axi_awvalid,
        input       wire                        m_axi_awready,
        output      wire    [31:0]              m_axi_wdata,
        output      wire    [3:0]               m_axi_wstrb,
        output      wire                        m_axi_wlast,
        output      wire                        m_axi_wvalid,
        input       wire                        m_axi_wready,
        input       wire    [1:0]               m_axi_bresp,
        input       wire                        m_axi_bvalid,
        output      wire                        m_axi_bready,
    
        output      wire    [63:0]              m_axi_araddr,
        output      wire    [7:0]               m_axi_arlen,
        output      wire    [2:0]               m_axi_arsize,
        output      wire    [1:0]               m_axi_arburst,
        output      wire                        m_axi_arlock,
        output      wire    [3:0]               m_axi_arcache,
        output      wire    [2:0]               m_axi_arprot,
        output      wire    [3:0]               m_axi_arqos,
        output      wire    [3:0]               m_axi_arregion,
        output      wire                        m_axi_arvalid,
        input       wire                        m_axi_arready,
        input       wire    [31:0]              m_axi_rdata,
        input       wire    [1:0]               m_axi_rresp,
        input       wire                        m_axi_rlast,
        input       wire                        m_axi_rvalid,
        output      wire                        m_axi_rready,
*/    
    
        //for MAC-core (triple speed ethernet (Altera, Xilinx))
        .for_tse_tdata_o    (vif_tse_out.tdata      ),
        .for_tse_tvld_o     (vif_tse_out.tvalid     ),
        .for_tse_tlast_o    (vif_tse_out.tlast      ),
        .for_tse_tkeep_o    (vif_tse_out.tkeep      ), 
        .for_tse_trdy_i     (vif_tse_out.tready     ),
    
        //from tse
        .from_tse_tdata_i   (vif_tse_in.tdata       ),
        .from_tse_tvld_i    (vif_tse_in.tvalid      ),
        .from_tse_tlast_i   (vif_tse_in.tlast       ),
        .from_tse_tkeep_i   (vif_tse_in.tkeep       ), 
        .from_tse_trdy_o    (vif_tse_in.tready      )
    );

    always begin
        clk = 1'b0;
        #10;
        clk = 1'b1;
        #10;
    end


    task gen_reset();
        reset_n <= 1'b0;
        repeat(10) @ (posedge clk);
        reset_n <= 1'b1;
    endtask

    initial begin
        test_n = new(
            vif_s_axil,
            vif_tse_in,
            vif_tse_out,
            vif_us_in
        );

        fork
            test_n.run();
            gen_reset();
        join
    end


endmodule
