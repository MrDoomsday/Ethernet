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

module eth_II_packer_tb();

    bit                             clk;
    bit                             reset_n;

    mac_intf    s_mac_intf(clk, reset_n);
    stream_intf s_intf  (clk, reset_n);
    stream_intf m_intf  (clk, reset_n);
    test test_n;

ethII_packer DUT (
    .clk            (clk            ),
    .reset_n        (reset_n        ),

    //заголовок идет синхронно с пакетом (при приеме первого слова заголовок уже выставлен)
    .hdr_mac_dest_i (s_mac_intf.dest  ),
    .hdr_mac_src_i  (s_mac_intf.src   ),//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    .hdr_mac_type_i (s_mac_intf.ttype ),
    .hdr_mac_vld_i  (s_mac_intf.vld   ),
    .hdr_mac_rdy_o  (s_mac_intf.rdy   ),

    .user_tdata_i   (s_intf.tdata   ),
    .user_tvld_i    (s_intf.tvalid  ),
    .user_tlast_i   (s_intf.tlast   ),
	.user_tkeep_i   (s_intf.tkeep   ),
    .user_trdy_o    (s_intf.tready  ),


    .ethii_ip_udp_tdata_o   (m_intf.tdata   ),
    .ethii_ip_udp_tvld_o    (m_intf.tvalid  ),
    .ethii_ip_udp_tlast_o   (m_intf.tlast   ),
    .ethii_ip_udp_tkeep_o   (m_intf.tkeep   ),
    .ethii_ip_udp_rdy_i     (m_intf.tready  )
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
            s_mac_intf,
            s_intf,
            m_intf
        );

        fork
            test_n.run();
            gen_reset();
        join
    end


endmodule
