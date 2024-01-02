class test;

    decoder_cfg cfg;
    environment env;

    virtual axis_sink vif_axis_sink;
    virtual axis_source vif_axis_source;

    mailbox #(packet) mbx_gen2drv;
    mailbox #(packet) mbx_gen2scb;
    mailbox #(packet) mbx_src_mon2scb;
    


    function new(virtual axis_sink vif_axis_sink, virtual axis_source vif_axis_source);
        //подключение интерфейсов
        this.vif_axis_sink = vif_axis_sink;
        this.vif_axis_source = vif_axis_source;

        //создание экземпляров
        cfg = new();
        env = new();

        mbx_gen2drv = new();
        mbx_gen2scb = new();
        mbx_src_mon2scb = new();

        //рандомизация конфигурации и её проброс в соответствующие классы
        if(!cfg.randomize()) begin
            $display("Error configure randomization");
            $fatal();
        end

        env.agnt_snk.gen_sink.cfg = cfg;
        env.agnt_snk.drv_sink.cfg = cfg;
        env.agnt_src.drv_src.cfg = cfg;
        env.scb.cfg = cfg;

        //подключение mailbox'ов 
        env.agnt_snk.gen_sink.mbx_gen2scb = mbx_gen2scb;
        env.scb.mbx_in = mbx_gen2scb;//подключение эталонной последовательности к scoreboard для проверки
        env.agnt_snk.gen_sink.mbx_gen2drv = mbx_gen2drv;
        env.agnt_snk.drv_sink.mbx_gen2drv = mbx_gen2drv;
        env.agnt_src.mon_src.mbx_mon2scb = mbx_src_mon2scb;
        env.scb.mbx_out = mbx_src_mon2scb;

        //проброс интерфейсов
        env.agnt_snk.drv_sink.vif_axis_sink = this.vif_axis_sink;
        env.agnt_src.drv_src.vif_axis_source = this.vif_axis_source;
        env.agnt_src.mon_src.vif_axis_source = this.vif_axis_source;
    endfunction


    virtual task run();
        fork
            timeout();
            env.run();
            reset_checker();
        join_none

        wait(env.scb.done);
        disable fork;
        if(env.scb.cnt_error > 0) $display("****TEST FAILED****");
        else $display("++++TEST PASSED++++");
        $stop();
    endtask

    virtual task reset_checker();//для 
        env.scb.flag_reset_n = 0;
        wait(vif_axis_sink.reset_n);
        env.scb.flag_reset_n = 1;
    endtask

    virtual task timeout();
        repeat(cfg.timeout_cycles) @ (posedge vif_axis_sink.clk);
        $display("Timeout!!!!");
        $stop();
    endtask


endclass