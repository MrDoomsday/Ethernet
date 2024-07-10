class test;

    virtual stream_intf vif_slave;
    virtual stream_intf vif_master;

    environment env;
    configuration cfg;

    mailbox #(axis_packet) mbx_gen2drv;
    mailbox #(axis_packet) mbx_slave_mon2scb;
    mailbox #(axis_packet) mbx_master_mon2scb;

    function new(
        virtual stream_intf vif_slave,
        
        virtual stream_intf vif_master
    );

        this.vif_slave = vif_slave;
        this.vif_master = vif_master;

        //create object
        env = new();
        cfg = new();

        if(!cfg.randomize()) begin
            $display("Error configuration randomize...");
            $fatal();
        end

        mbx_gen2drv = new();
        mbx_slave_mon2scb = new();
        mbx_master_mon2scb = new();


        //проброс конфигурации
        env.agnt_axis.gen.cfg = cfg;
        env.agnt_axis.drv.cfg = cfg;

        env.agnt_axim.drv.cfg = cfg;
        env.scb.cfg = cfg;

        //подключение mailbox'ов 
        env.agnt_axis.gen.mbx_gen2drv = mbx_gen2drv;
        env.agnt_axis.drv.mbx_gen2drv = mbx_gen2drv;

        env.agnt_axis.mon.mbx_mon2scb = mbx_slave_mon2scb;
        env.scb.mbx_in = mbx_slave_mon2scb;

        env.agnt_axim.mon.mbx_mon2scb = mbx_master_mon2scb;
        env.scb.mbx_out = mbx_master_mon2scb;


        //подключение интерфейсов 
        env.agnt_axis.drv.vif_stream = this.vif_slave;
        env.agnt_axis.mon.vif_stream = this.vif_slave;        
        env.agnt_axim.drv.vif_stream = this.vif_master;
        env.agnt_axim.mon.vif_stream = this.vif_master;

    endfunction

    virtual task run();
        fork
            env.run();
            wait_done();
            timeout();
        join
    endtask

    virtual task timeout();
        repeat(cfg.timeout_value) @(posedge vif_master.clk);
        $display("********TEST FAILED********");
        $display("Timeout...");
        $stop();
    endtask

    virtual task wait_done();
        wait(env.scb.done);
        $display("Count transaction = %0d", env.scb.cnt_transaction);
        $display("Count error transaction = %0d", env.scb.cnt_error_transaction);
        if(env.scb.cnt_error_transaction > 0) begin
            $display("********TEST FAILED********");
        end
        else begin
            $display("********TEST PASSED********");
        end
        $stop();
    endtask

endclass