class axil_access;

virtual s_axil_intf vif_s_axil;
configuration cfg;


function new();
endfunction


virtual task run();
    reset_port();
    wait(vif_s_axil.reset_n);
    repeat(10) @(posedge vif_s_axil.clk);

    write_transaction(5'h0, 32'h0);//CONTROL
    //BOARD (SOURCE) PARAMETERS
    write_transaction(5'h1, {16'h0, cfg.mac_board[47:32]});//MAC_HIGH
    write_transaction(5'h2, cfg.mac_board[31:0]);//MAC_LOW
    write_transaction(5'h3, cfg.ip_board[31:0]);//IP
    write_transaction(5'h4, {16'h0, cfg.port_board[15:0]});//port

    //DESTINATION PARAMETERS
    for(int i = 0; i < cfg.AMOUNT_DEST_ADDRESS; i++) begin
        write_transaction(5'h5, i[31:0]);//Address cells
        write_transaction(5'h6, {16'h0, cfg.mac_dest[i][47:32]});//MAC_HIGH
        write_transaction(5'h7, cfg.mac_dest[i][31:0]);//MAC_LOW
        write_transaction(5'h8, cfg.ip_dest[i][31:0]);//IP
        write_transaction(5'h9, {16'h0, cfg.port_dest[i][15:0]});//port
        write_transaction(5'hA, {29'h0, 3'b111});//write
    end

    repeat(10) @(posedge vif_s_axil.clk);

    $display("Write control OK, time = %0d ns", $time());
endtask

virtual task reset_port();
    vif_s_axil.awaddr   <= 7'h0;
    vif_s_axil.awprot   <= 3'h0;
    vif_s_axil.awvalid  <= 1'b0;

    vif_s_axil.wdata    <= 32'h0;
    vif_s_axil.wstrb    <= 4'h0;
    vif_s_axil.wvalid   <= 1'b0;

    vif_s_axil.bready   <= 1'b1;
    
    vif_s_axil.araddr   <= 7'h0;
    vif_s_axil.arprot   <= 3'h0;
    vif_s_axil.arvalid  <= 1'b0;

    vif_s_axil.rready   <= 1'b1;
endtask

virtual task write_transaction(logic [4:0] address, logic [31:0] data);
    fork
        begin
            vif_s_axil.awaddr   <= {address, 2'b00};
            vif_s_axil.awprot   <= 3'h0;
            vif_s_axil.awvalid  <= 1'b1;
            do begin
                @(posedge vif_s_axil.clk);
            end
            while(~vif_s_axil.awready);
            vif_s_axil.awaddr   <= 7'h0;
            vif_s_axil.awprot   <= 3'h0;
            vif_s_axil.awvalid  <= 1'b0;        
        end
        begin
            vif_s_axil.wdata    <= data;
            vif_s_axil.wstrb    <= 4'hF;
            vif_s_axil.wvalid   <= 1'b1;
            do begin
                @(posedge vif_s_axil.clk);
            end
            while(~vif_s_axil.wready);
            vif_s_axil.wdata    <= 32'h0;
            vif_s_axil.wstrb    <= 4'h0;
            vif_s_axil.wvalid   <= 1'b0;
        end
        begin
            do begin
                @(posedge vif_s_axil.clk);
            end
            while(~(vif_s_axil.bready && vif_s_axil.bvalid));
            if(vif_s_axil.bresp > 2'b00) begin
                $display("Error for write, addr = %0h, data = %0h", address, data);
            end
            @(posedge vif_s_axil.clk);
        end
    join
endtask

endclass