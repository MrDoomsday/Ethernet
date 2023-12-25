//конфигурация тестового стенда
    `include "decoder_cfg.sv"
// интерфейсы для подключения к портам модуля
    `include "axis_sink.sv"
    `include "axis_source.sv"
//экземпляр класса пакета
    `include "packet.sv"

//генератор
    `include "generator.sv"


module decoder_tb();
    
    localparam PERIOD = 20;

    bit clk;
    bit reset_n;

    axis_sink intf_axis_sink(clk, reset_n);
    axis_source intf_axis_source(clk, reset_n);
    




    decoder64b66b DUT (
        .clk            (clk),
        .reset_n        (reset_n),
    
    //AXI Stream input
        .s_axis_tdata   (intf_axis_sink.tdata),
        .s_axis_tvalid  (intf_axis_sink.tvalid),
        .s_axis_tready  (intf_axis_sink.tready),
    
    //AXI Stream output
        .m_axis_ttype   (intf_axis_source.ttype),//user type word, 2'b11, 2'b00 - illegal
        .m_axis_tdata   (intf_axis_source.tdata),
        .m_axis_tvalid  (intf_axis_source.tvalid),
        .m_axis_tready  (intf_axis_source.tready)
    
    );




    task gen_reset_n();
        reset_n <= 1'b0;
        repeat(10) @(posedge clk);
        reset_n <= 1'b0;
    endtask


    always begin
        clk = 1'b0;
        #(PERIOD/2);
        clk = 1'b1;
        #(PERIOD/2);
    end
    
endmodule