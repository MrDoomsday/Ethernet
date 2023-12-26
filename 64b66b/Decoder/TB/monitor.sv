class monitor_source;
    mailbox #(packet) mbx_mon2scb;
    virtual axis_source vif_axis_source;

    virtual task run();
        wait(vif_axis_source.reset_n);

        forever begin
            mon_src();
        end
    endtask

    virtual task mon_src();
        packet p = new();

        @(posedge vif_axis_source.clk);
        if(vif_axis_source.tready && vif_axis_source.tvalid) begin
            p.tdata = {vif_axis_source.ttype, vif_axis_source.tdata};
            mbx_mon2scb.put(p);
        end
    endtask

endclass