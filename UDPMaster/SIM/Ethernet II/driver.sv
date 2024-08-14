class driver_axis;

    configuration cfg;
    mailbox #(axis_packet) mbx_gen2drv;
    mailbox #(mac_packet) mbx_genmac2drv;//special for mac address

    
    virtual stream_intf vif_stream;
    virtual mac_intf vif_mac;


    axis_packet p;
    mac_packet mp;

    function new();
    endfunction

    virtual task run();
        reset_port();
        wait(vif_stream.reset_n);
        fork
            forever begin
                drive();
            end            
            forever begin
                drive_mac();
            end
        join

    endtask

    virtual task reset_port();
        vif_mac.dest        <= 48'h0;
        vif_mac.src         <= 48'h0;//dest - на какой MAC пойдет пакет, src - с какого MAC пакет будет отправлен
        vif_mac.ttype       <= 16'h0;
        vif_mac.vld         <= 1'b0;

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
            delay inside {[cfg.min_pause_pkt:cfg.max_pause_pkt]};
        }) begin
            $display("Error randomization pause for pkt");
            $fatal();
        end

        for(int i = 0; i < p.data.size(); i++) begin
            if(!std::randomize(pause_word) with {
                pause_word inside {[cfg.min_pause_word:cfg.max_pause_word]};
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

    virtual task drive_mac();
        mbx_genmac2drv.get(mp);

        vif_mac.dest    <= mp.dest;
        vif_mac.src     <= mp.src;
        vif_mac.ttype   <= mp.ttype;
        vif_mac.vld     <= 1'b1;
        do begin
            @(posedge vif_mac.clk);
        end
        while(~vif_mac.rdy);

        vif_mac.dest    <= 48'h0;
        vif_mac.src     <= 48'h0;
        vif_mac.ttype   <= 16'h0;
        vif_mac.vld     <= 1'b0;
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
