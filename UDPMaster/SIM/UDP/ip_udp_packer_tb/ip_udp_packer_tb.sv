`include "tb_interface.sv"
`include "packet.sv"
`include "configuration.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

module ip_udp_packer_tb();

    localparam FIFO_SIZE_DATA = 1024;
    localparam FIFO_SIZE_HDR = 1024;

    bit                             clk;
    bit                             reset_n;


    stream_intf s_intf (clk, reset_n);
    stream_intf m_intf (clk, reset_n);
    test test_n;

    umstr_ip_udp_packer #(
        .FIFO_SIZE_DATA(FIFO_SIZE_DATA),
        .FIFO_SIZE_HDR(FIFO_SIZE_HDR)
    ) DUT (
        .clk            (clk                ),
        .reset_n        (reset_n            ),

        //заголовок идет синхронно с пакетом (при приеме первого слова заголовок уже выставлен)
        .hdr_ip_dest_i  (s_intf.ip_dest     ), 
        .hdr_ip_src_i   (s_intf.ip_src      ),//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
        .hdr_port_dest_i(s_intf.port_dest   ), 
        .hdr_port_src_i (s_intf.port_src    ),

        .user_tdata_i   (s_intf.tdata       ),
        .user_tvld_i    (s_intf.tvalid      ),
        .user_tlast_i   (s_intf.tlast       ),
        .user_tkeep_i   (s_intf.tkeep       ), 
        .user_trdy_o    (s_intf.tready      ),


        .ip_udp_tdata_o (m_intf.tdata       ),
        .ip_udp_tvld_o  (m_intf.tvalid      ),
        .ip_udp_tlast_o (m_intf.tlast       ),
        .ip_udp_tkeep_o (m_intf.tkeep       ),
        .ip_udp_rdy_i   (m_intf.tready      )
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
            s_intf,
            m_intf
        );

        fork
            test_n.run();
            gen_reset();
        join
    end


endmodule