class generator_tse;

    configuration cfg;
    mailbox #(axis_packet) mbx_gen2drv;
    mailbox #(axis_packet) mbx_gen2scb;//to scoreboard
    axis_packet p;

    function new();
    endfunction

    virtual task run();
        repeat(cfg.tse_count_transaction) begin
            gen_transaction();
        end
    endtask


    virtual task gen_transaction();
        p = new();
        p.set_src_parameter(cfg.mac_board, cfg.ip_board, cfg.port_board);//пробрасываем параметры 

        if(!p.randomize with {
            len inside {[cfg.tse_min_size_pkt:cfg.tse_max_size_pkt]};
        }) begin
            $display("Error randomization packet for axis tse...");
            $fatal();
        end

        mbx_gen2drv.put(p);
        mbx_gen2scb.put(p);
    endtask

endclass


class generator_userstream #(parameter ID_WIDTH = 10);

    configuration cfg;
    mailbox #(axis_packet #(.ID_WIDTH(ID_WIDTH))) mbx_gen2drv;
    mailbox #(axis_packet #(.ID_WIDTH(ID_WIDTH))) mbx_gen2scb;
    axis_packet #(.ID_WIDTH(ID_WIDTH)) p;

    function new();
    endfunction

    virtual task run();
        repeat(cfg.usd_count_transaction) begin
            gen_transaction();
        end
    endtask


    virtual task gen_transaction();
        p = new();

        if(!p.randomize with {
            len inside {[cfg.usd_min_size_pkt:cfg.usd_max_size_pkt]};
            type_pkt == type_pkt_t'(RAW);//произвольная пользовательская нагрузка
        }) begin
            $display("Error randomization packet for axis user stream...");
            $fatal();
        end

        mbx_gen2drv.put(p);
        mbx_gen2scb.put(p);
    endtask

endclass