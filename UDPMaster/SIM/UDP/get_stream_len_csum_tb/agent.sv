class agent_axis;

    generator_slave gen;
    driver_axis drv;
    minitor_axis mon;


    function new();
        gen = new();
        drv = new();
        mon = new();
    endfunction

    virtual task run();
        fork
            gen.run();
            drv.run();
            mon.run();
        join
    endtask

endclass


class agent_axim;

    driver_axim drv;
    minitor_axis mon;


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