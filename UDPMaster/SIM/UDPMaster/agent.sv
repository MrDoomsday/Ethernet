class agent_axis_tse;

    generator_tse gen;
    driver_axis_tse drv;

    function new();
        gen = new();
        drv = new();
    endfunction

    virtual task run();
        fork
            gen.run();
            drv.run();
        join
    endtask


endclass

class agent_axis_userstream #(parameter ID_WIDTH = 10);

    generator_userstream #(.ID_WIDTH(ID_WIDTH)) gen;
    driver_axis_userstream #(.ID_WIDTH(ID_WIDTH)) drv;

    function new();
        gen = new();
        drv = new();
    endfunction

    virtual task run();
        fork
            gen.run();
            drv.run();
        join
    endtask


endclass

class agent_axim;

    driver_axim drv;
    monitor_axis mon;


    function new();
        drv = new();
        mon = new();
    endfunction

    virtual task run();
        fork
            drv.run();
            mon.run();
        join
    endtask

endclass