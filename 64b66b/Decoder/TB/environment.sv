class environment;

    agent_sink agnt_snk;
    agent_source agnt_src;
    //scoreboard scb;

    function new();
        agnt_snk = new();
        agnt_src = new();
        //scb = new();
    endfunction

    virtual task run();
        fork
            agnt_snk.run();
            agnt_src.run();
            //scb.run();
        join
    endtask

endclass