class scoreboard;

    mailbox #(mac_packet) mbx_mac;
    mailbox #(axis_packet) mbx_in;
    mailbox #(axis_packet) mbx_out;

    mac_packet p_mac;
    axis_packet p_in, p_out;


    configuration cfg;

    bit done = 0;
    int cnt_transaction;
    int cnt_error_transaction;



    function new();
    endfunction

    virtual task run();
        forever begin
            check_pkt(); 
        end
    endtask


    virtual task check_pkt();
        int size_data_in;
        int size_data_out;
        mailbox payload_in, payload_out;

        mbx_mac.get(p_mac);
        mbx_out.get(p_out);
        mbx_in.get(p_in);

        //подсчет полной длины полезной нагрузки пакетов (в байтах)
        size_data_in = 4*(p_in.data.size()-1)+p_in.keep[3]+p_in.keep[2]+p_in.keep[1]+p_in.keep[0];
        size_data_out = 4*(p_out.data.size()-1)+p_out.keep[3]+p_out.keep[2]+p_out.keep[1]+p_out.keep[0]-14;//учитываем добавленный заголовок 6+6+2=14

        //check length user payload
        if(size_data_in != size_data_out) begin//у нас добавляется заголовок размеров 27 байт
            $display("Error size data array, out = %0d, in = %0d", size_data_out, size_data_in);
            $fatal();
            cnt_error_transaction++;
        end

        //check mac destination
        if(p_mac.dest != {p_out.data[0][31:0], p_out.data[1][31:16]}) begin
            $error("Error MAC destination, out = %0h, in = %0h", {p_out.data[0][31:0], p_out.data[1][15:0]}, p_mac.dest);
            cnt_error_transaction++;            
        end

        //check mac source
        if(p_mac.src != {p_out.data[1][15:0], p_out.data[2][31:0]}) begin
            $error("Error MAC source, out = %0h, in = %0h", {p_out.data[1][15:0], p_out.data[2][31:0]}, p_mac.src);
            cnt_error_transaction++;            
        end        

        //check type payload Ethernet II packet
        if(p_out.data[3][31:16] != p_mac.ttype) begin
            $error("Error type payload, out = %0h, in = %0h", p_out.data[3][31:16], p_mac.ttype);
            cnt_error_transaction++;            
        end        

        //check payload
        payload_in = new();
        for(int i = 0; i < p_in.data.size(); i++) begin
            if(i == p_in.data.size()-1) begin
                if(p_in.keep[3]) payload_in.put(p_in.data[i][31:24]);
                if(p_in.keep[2]) payload_in.put(p_in.data[i][23:16]);
                if(p_in.keep[1]) payload_in.put(p_in.data[i][15:8]);
                if(p_in.keep[0]) payload_in.put(p_in.data[i][7:0]);                
            end
            else begin
                payload_in.put(p_in.data[i][31:24]);
                payload_in.put(p_in.data[i][23:16]);
                payload_in.put(p_in.data[i][15:8]);
                payload_in.put(p_in.data[i][7:0]);
            end
        end

        payload_out = new();
        for(int i = 3; i < p_out.data.size(); i++) begin//пропустим часть заголовка
            if(i == p_out.data.size()-1) begin
                if(p_out.keep[3]) payload_out.put(p_out.data[i][31:24]);
                if(p_out.keep[2]) payload_out.put(p_out.data[i][23:16]);
                if(p_out.keep[1]) payload_out.put(p_out.data[i][15:8]);
                if(p_out.keep[0]) payload_out.put(p_out.data[i][7:0]);                
            end
            else begin
                payload_out.put(p_out.data[i][31:24]);
                payload_out.put(p_out.data[i][23:16]);
                payload_out.put(p_out.data[i][15:8]);
                payload_out.put(p_out.data[i][7:0]);
            end
        end


        for(int i = 0; i < payload_out.num(); i++) begin
            logic [7:0] byte_in, byte_out;

            //выбросим из рассмотрения оставшиеся заголовочные байты
            if(i < 2) begin
                payload_out.get(byte_out);
                continue;
            end

            payload_in.get(byte_in);
            payload_out.get(byte_out);
            if(byte_out != byte_in) begin
                $error("Error payload[%0d], out = %0h, in = %0h", i, byte_out, byte_in);
                cnt_error_transaction++;            
            end  
        end


        cnt_transaction++;

        if(cnt_transaction >= cfg.count_transaction) begin
            done = 1;
        end
    endtask

endclass