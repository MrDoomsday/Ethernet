class generator_slave;

    configuration cfg;

    mailbox #(axis_packet) mbx_gen2drv;
    mailbox #(mac_packet) mbx_genmac2drv;
    
    
    
    axis_packet p;
    mac_packet mp;

    function new();
    endfunction

    virtual task run();
        repeat(cfg.count_transaction) begin
            gen_transaction();
            gen_mac_addresses();
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

    virtual task gen_mac_addresses();
        mp = new();
        if(!mp.randomize()) begin
            $display("Error randomization mac addresses...");
            $fatal();
        end

        mbx_genmac2drv.put(mp);
    endtask

endclass