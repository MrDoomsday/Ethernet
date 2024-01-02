class agent_sink;
    
    generator gen_sink;
    driver_sink drv_sink;


    function new();
        gen_sink = new();
        drv_sink = new();
    endfunction

    virtual task run();
        fork
            gen_sink.run();
            drv_sink.run();
        join
    endtask

endclass


class agent_source;

    driver_source drv_src;
    monitor_source mon_src;

    function new();
        drv_src = new();
        mon_src = new();
    endfunction

    virtual task run();
        fork
            drv_src.run();
            mon_src.run();
        join
    endtask

endclass