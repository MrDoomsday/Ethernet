class environment #(parameter ID_WIDTH = 10);

    //tse in
    agent_axis_tse agent_tse_in;

    //userstream
    agent_axis_userstream #(.ID_WIDTH(ID_WIDTH)) agent_userstream;

    //tse out
    agent_axim agent_tse_out;

    //scoreboard
    scoreboard #(.ID_WIDTH(ID_WIDTH)) scb;


    function new();
        agent_tse_in        = new();
        agent_tse_out       = new();
        agent_userstream    = new();
        scb                 = new();
    endfunction


    virtual task run();
        fork
            agent_tse_in.run();
            agent_tse_out.run();
            agent_userstream.run();
            scb.run();
        join
    endtask

endclass