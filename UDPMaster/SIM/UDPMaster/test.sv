class test #(parameter ID_WIDTH = 10);

    virtual stream_intf vif_tse_in;//triple speed ethernet in
    virtual stream_intf vif_tse_out;//triple speed ethernet out
    virtual stream_intf #(.ID_WIDTH(ID_WIDTH)) vif_us_in;//user stream in
    virtual s_axil_intf vif_s_axil;

    environment #(.ID_WIDTH(ID_WIDTH)) env;
    configuration cfg;
    axil_access axil_init;

    //generator
    mailbox #(axis_packet)  mbx_tse_gen2drv;
    mailbox #(axis_packet #(.ID_WIDTH(ID_WIDTH))) mbx_us_gen2drv;

    mailbox #(axis_packet) mbx_tse_gen2scb;
    mailbox #(axis_packet #(.ID_WIDTH(ID_WIDTH))) mbx_us_gen2scb;


    //output for tse
    mailbox #(axis_packet) mbx_master_mon2scb;


    function new(
        virtual s_axil_intf vif_s_axil,
        virtual stream_intf vif_tse_in,
        virtual stream_intf vif_tse_out,
        virtual stream_intf #(.ID_WIDTH(ID_WIDTH)) vif_us_in
    );

        this.vif_s_axil     = vif_s_axil;
        this.vif_tse_in     = vif_tse_in;
        this.vif_tse_out    = vif_tse_out;
        this.vif_us_in      = vif_us_in;

        //create object
        env = new();
        cfg = new(ID_WIDTH);
        axil_init = new();

        if(!cfg.randomize()) begin
            $display("Error configuration randomize...");
            $fatal();
        end

        mbx_tse_gen2drv = new();
        mbx_us_gen2drv = new();
        mbx_tse_gen2scb = new();
        mbx_us_gen2scb = new();

        mbx_master_mon2scb = new();


        //проброс конфигурации
        axil_init.cfg = cfg;
        
        env.agent_tse_in.gen.cfg = cfg;
        env.agent_tse_in.drv.cfg = cfg;
        
        env.agent_userstream.gen.cfg = cfg;
        env.agent_userstream.drv.cfg = cfg;

        env.agent_tse_out.drv.cfg = cfg;
        
        env.scb.cfg = cfg;

        //подключение mailbox'ов 
        env.agent_tse_in.gen.mbx_gen2drv = mbx_tse_gen2drv;
        env.agent_tse_in.drv.mbx_gen2drv = mbx_tse_gen2drv;
        env.agent_tse_in.gen.mbx_gen2scb = mbx_tse_gen2scb;
        env.scb.mbx_tse_in = mbx_tse_gen2scb;

        env.agent_userstream.gen.mbx_gen2drv = mbx_us_gen2drv;
        env.agent_userstream.drv.mbx_gen2drv = mbx_us_gen2drv;
        env.agent_userstream.gen.mbx_gen2scb = mbx_us_gen2scb;
        env.scb.mbx_us_in = mbx_us_gen2scb;

        env.agent_tse_out.mon.mbx_mon2scb = mbx_master_mon2scb;
        env.scb.mbx_tse_out = mbx_master_mon2scb;

        //подключение интерфейсов 
        axil_init.vif_s_axil = this.vif_s_axil;

        env.agent_tse_in.drv.vif_stream = this.vif_tse_in;
        env.agent_userstream.drv.vif_stream = this.vif_us_in;

        env.agent_tse_out.drv.vif_stream = this.vif_tse_out;
        env.agent_tse_out.mon.vif_stream = this.vif_tse_out;        
    endfunction

    virtual task run();
        //reset ports - сброс входных значений на портах, т.к. в противном случае там будут X-состояния и симуляция не пойдет
        env.agent_tse_in.drv.reset_port();
        env.agent_tse_out.drv.reset_port();
        env.agent_userstream.drv.reset_port();
        //загрезка конфигурационных регистров
        axil_init.run();
        //запуск работы сценария
        fork
            env.run();
            wait_done();
            timeout();
        join
    endtask

    virtual task timeout();
        repeat(cfg.timeout_value) @(posedge vif_tse_out.clk);
        $display("********TEST FAILED********");
        $display("Timeout...");
        $stop();
    endtask

    virtual task wait_done();
        wait(env.scb.arp_done & env.scb.eth2axi_done & env.scb.us_done);
        //ARP report
        $display("------------------------------------------------------------------");
        $display("Count all ARP-transaction = %0d", env.scb.cnt_arp_all_transaction);
        $display("Count checked ARP-transaction = %0d", env.scb.cnt_arp_check_transaction);
        $display("Count error ARP-transaction = %0d", env.scb.cnt_arp_error_transaction);

        //user data report
        $display("------------------------------------------------------------------");

        //Eth2AXI report
        $display("------------------------------------------------------------------");


        if(env.scb.cnt_arp_error_transaction > 0) begin
            $display("********TEST FAILED********");
        end
        else begin
            $display("********TEST PASSED********");
        end
        $stop();
    endtask


endclass