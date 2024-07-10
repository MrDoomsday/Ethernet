class generator_slave;

    configuration cfg;

    mailbox #(axis_packet) mbx_gen2drv;
    
    
    axis_packet p;

    function new();
    endfunction

    virtual task run();
        repeat(cfg.count_transaction) begin
            gen_transaction();
        end
    endtask


    virtual task gen_transaction();
        p = new();

        if(!p.randomize with {
            len inside {[cfg.min_size_pkt:cfg.max_size_pkt]};
        }) begin
            $display("Error randomization packet for axi stream slave...");
            $fatal();
        end

        mbx_gen2drv.put(p);
    endtask

endclass