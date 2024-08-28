class driver_axis_tse;

    configuration cfg;
    mailbox #(axis_packet) mbx_gen2drv;

    
    virtual stream_intf vif_stream;


    axis_packet p;

    function new();
    endfunction

    virtual task run();
        reset_port();
        wait(vif_stream.reset_n);
        forever begin
            drive();
        end
    endtask

    virtual task reset_port();
        vif_stream.tdata    <= 32'h0;
        vif_stream.tlast    <= 1'b0;
        vif_stream.tkeep    <= 4'h0;
        vif_stream.tvalid   <= 1'b0;
    endtask

    virtual task drive();
        int delay;
        int pause_word;
        mbx_gen2drv.get(p);


        if(!std::randomize(delay) with {
            delay inside {[cfg.tse_min_pause_pkt:cfg.tse_max_pause_pkt]};
        }) begin
            $display("Error randomization pause for pkt");
            $fatal();
        end

        for(int i = 0; i < p.data.size(); i++) begin
            if(!std::randomize(pause_word) with {
                pause_word inside {[cfg.tse_min_pause_word:cfg.tse_max_pause_word]};
            }) begin
                $display("Error randomization pause for word");
                $fatal();
            end

            vif_stream.tdata     <= p.data[i];
            vif_stream.tlast     <= i == (p.data.size()-1);
            vif_stream.tkeep     <= (i == (p.data.size()-1)) ? p.keep : 4'hF;
            vif_stream.tvalid    <= 1'b1;

            do begin
                @(posedge vif_stream.clk);
            end
            while(!vif_stream.tready);
            //выдерживаем паузу между отдельными словами в пакете
            vif_stream.tvalid    <= 1'b0;
            repeat(pause_word) @(posedge vif_stream.clk);
        end
        vif_stream.tdata    <= 32'h0;
        vif_stream.tlast    <= 1'b0;
        vif_stream.tkeep    <= 4'h0;
        vif_stream.tvalid   <= 1'b0;

        repeat(delay) @(posedge vif_stream.clk);
    endtask
endclass

class driver_axis_userstream #(parameter ID_WIDTH = 10);

    configuration cfg;
    mailbox #(axis_packet #(.ID_WIDTH(ID_WIDTH))) mbx_gen2drv;

    
    virtual stream_intf #(.ID_WIDTH(ID_WIDTH)) vif_stream;
    axis_packet #(.ID_WIDTH(ID_WIDTH)) p;

    function new();
    endfunction

    virtual task run();
        reset_port();
        wait(vif_stream.reset_n);
        forever begin
            drive();
        end
    endtask

    virtual task reset_port();
        vif_stream.tid      <= {ID_WIDTH{1'b0}};
        vif_stream.tdata    <= 32'h0;
        vif_stream.tlast    <= 1'b0;
        vif_stream.tkeep    <= 4'h0;
        vif_stream.tvalid   <= 1'b0;
    endtask

    virtual task drive();
        int delay;
        int pause_word;
        mbx_gen2drv.get(p);


        if(!std::randomize(delay) with {
            delay inside {[cfg.usd_min_pause_pkt:cfg.usd_max_pause_pkt]};
        }) begin
            $display("Error randomization pause for pkt");
            $fatal();
        end

        for(int i = 0; i < p.data.size(); i++) begin
            if(!std::randomize(pause_word) with {
                pause_word inside {[cfg.usd_min_pause_word:cfg.usd_max_pause_word]};
            }) begin
                $display("Error randomization pause for word");
                $fatal();
            end

            vif_stream.tid       <= p.id;
            vif_stream.tdata     <= p.data[i];
            vif_stream.tlast     <= i == (p.data.size()-1);
            vif_stream.tkeep     <= (i == (p.data.size()-1)) ? p.keep : 4'hF;
            vif_stream.tvalid    <= 1'b1;

            do begin
                @(posedge vif_stream.clk);
            end
            while(!vif_stream.tready);
            //выдерживаем паузу между отдельными словами в пакете
            vif_stream.tvalid    <= 1'b0;
            repeat(pause_word) @(posedge vif_stream.clk);
        end
        vif_stream.tid      <= {ID_WIDTH{1'b0}};
        vif_stream.tdata    <= 32'h0;
        vif_stream.tlast    <= 1'b0;
        vif_stream.tkeep    <= 4'h0;
        vif_stream.tvalid   <= 1'b0;

        repeat(delay) @(posedge vif_stream.clk);
    endtask
endclass

class driver_axim;

    configuration cfg;

    virtual stream_intf vif_stream;


    function new();
    endfunction


    virtual task run();
        reset_port();
        wait(vif_stream.reset_n);
        forever begin
            drive();
        end
    endtask


    virtual task reset_port();
        vif_stream.tready <= 1'b0;
    endtask


    virtual task drive();
        int delay_low, delay_high;

        if(!std::randomize(delay_low) with {
            delay_low inside {[cfg.min_low_ready:cfg.max_low_ready]};
        }) begin
            $display("Erorr randomization master_ready low level signal...");
            $fatal();
        end

        if(!std::randomize(delay_high) with {
            delay_high inside {[cfg.min_high_ready:cfg.max_high_ready]};
        }) begin
            $display("Erorr randomization master_ready high level signal...");
            $fatal();
        end

        vif_stream.tready <= 1'b1;
        repeat(delay_high) @ (posedge vif_stream.clk);
        vif_stream.tready <= 1'b0;
        repeat(delay_low) @ (posedge vif_stream.clk);
    endtask


endclass
