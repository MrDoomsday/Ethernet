class driver_sink;

    decoder_cfg cfg;
    mailbox #(packet) mbx_gen2drv;
    virtual axis_sink vif_axis_sink;


    virtual task run();
        packet p;
        reset_sink();

        wait(vif_axis_sink.reset_n);//только при отсутствующем сбросе мы можем работать

        forever begin
            mbx_gen2drv.get(p);
            drive_sink(p);
        end
    endtask

    virtual task reset_sink();
        vif_axis_sink.tdata <= 64'h0;
        vif_axis_sink.tvalid <= 1'b0;
    endtask

    virtual task drive_sink(packet p);
        int delay;
        if(!std::randomize(delay) with {
            delay inside {[cfg.sink_transaction_pause_min:cfg.sink_transaction_pause_max]};
        }) begin
            $error();
            $display("Driver error delay randomize");
        end

        vif_axis_sink.tdata <= p.tdata[63:0];
        vif_axis_sink.tvalid <= 1'b1;
        do begin
            @(posedge vif_axis_sink.clk);
        end 
        while(~vif_axis_sink.tready);

        vif_axis_sink.tdata <= 64'h0;
        vif_axis_sink.tvalid <= 1'b0;
        repeat(delay) @ (posedge vif_axis_sink.clk);
    endtask

endclass


class driver_source;

    decoder_cfg cfg;
    virtual axis_source vif_axis_source;

    virtual task run();
        reset_source();
        wait(vif_axis_source.reset_n);

        forever begin
            drive_source();
        end
    endtask

    virtual task reset_source();
        vif_axis_source.tready <= 1'b0;
    endtask


    virtual task drive_source();
        int delay_disable;
        int delay_enable;

        if(!std::randomize(delay_disable) with {
            delay_disable inside {[cfg.source_ready_delay_enable_min:cfg.source_ready_delay_enable_max]};
        }) begin
            $error();
            $display("Error randomize delay disable...");
        end

        if(!std::randomize(delay_enable) with {
            delay_enable inside {[cfg.source_ready_delay_disable_min:cfg.source_ready_delay_disable_max]};
        }) begin
            $error();
            $display("Error randomize delay enable...");
        end

        vif_axis_source.tready <= 1'b1;
        repeat(delay_enable) @(posedge vif_axis_source.clk);
        vif_axis_source.tready <= 1'b0;
        repeat(delay_disable) @(posedge vif_axis_source.clk);
    endtask

endclass