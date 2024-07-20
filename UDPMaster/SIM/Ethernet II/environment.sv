class environment;


    agent_axis agnt_axis;
    agent_axim agnt_axim;
    scoreboard scb;


    function new();
        agnt_axis = new();
        agnt_axim = new();
        scb = new();
    endfunction


    virtual task run();
        fork
            agnt_axis.run();
            agnt_axim.run();
            scb.run();
        join
    endtask

endclass