class scoreboard;

    mailbox #(axis_packet) mbx_in;
    mailbox #(axis_packet) mbx_out;
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
        logic [16:0] ip_csum, udp_csum;

        mbx_out.get(p_out);
        mbx_in.get(p_in);

        //подсчет полной длины полезной нагрузки пакетов (в байтах)
        size_data_in = 4*(p_in.data.size()-1)+p_in.keep[3]+p_in.keep[2]+p_in.keep[1]+p_in.keep[0];
        size_data_out = 4*(p_out.data.size()-7-1)+p_out.keep[3]+p_out.keep[2]+p_out.keep[1]+p_out.keep[0];//учитываем добавленный заголовок (7 DW)

        //check length user payload
        if(size_data_in != size_data_out) begin//у нас добавляется заголовок размеров 27 байт
            $display("Error size data array, out = %0d, in = %0d", size_data_out, size_data_in);
            $fatal();
            cnt_error_transaction++;
        end

        //check data in packet
        for(int i = 0; i < size_data_out; i++) begin
            if(p_in.data[i] != p_out.data[7+i]) begin
                $display("Error data array, out[%0d] = %0h, in[%0d] = %0h", i, p_out.data[7+i], i, p_in.data[i]);
                $error();
                cnt_error_transaction++;
            end
        end


        //check header IP and UDP
        //IP packet+++++++++++++++++++++++++++++++++++++++++++++++++
        if(p_in.ip_dest != p_out.data[4]) begin
            $display("IP dest error, out = %0h, in = %0h", p_out.data[4], p_in.ip_dest);
            $error();
            cnt_error_transaction++;            
        end
        if(p_in.ip_src != p_out.data[3]) begin
            $display("IP src error, out = %0h, in = %0h", p_out.data[3], p_in.ip_src);
            $error();
            cnt_error_transaction++;
        end
        //checksum
        ip_csum = get_csum_ip_header(p_out);
        if(ip_csum != p_out.data[2][15:0]) begin
            $display("IP header control sum failed, calc = %0h, pkt = %0h", ip_csum, p_out.data[2][15:0]);
            $error();
            cnt_error_transaction++;            
        end
        //length
        if(p_out.data[0][15:0] != (size_data_out + 28)) begin//28 байт это длина пакета с учетом заголовков
            $display("IP header length failed, calc = %0h, pkt = %0h", size_data_out + 28, p_out.data[0][15:0]);
            $error();
            cnt_error_transaction++;
        end
        
        //UDP packet+++++++++++++++++++++++++++++++++++++++++++++++++
        if(p_in.port_dest != p_out.data[5][15:0]) begin
            $display("UDP port dest error, out = %0d, in = %0d", p_out.data[5][15:0], p_in.port_dest);
            $error();
            cnt_error_transaction++;            
        end
        if(p_in.port_src != p_out.data[5][31:16]) begin
            $display("UDP port src error, out = %0d, in = %0d", p_out.data[5][31:16], p_in.port_src);
            $error();
            cnt_error_transaction++;            
        end
        //udp checksum
        udp_csum = get_csum_udp_header(p_out);
        if(udp_csum != p_out.data[6][15:0]) begin
            $display("UDP header control sum failed, calc = %0h, pkt = %0h", udp_csum, p_out.data[6][15:0]);
            $error();
            cnt_error_transaction++;            
        end
        //length
        if(p_out.data[6][31:16] != (size_data_out + 8)) begin
            $display("UDP header length failed, calc = %0h, pkt = %0h", size_data_out + 8, p_out.data[6][31:16]);
            $error();
            cnt_error_transaction++;            
        end

        //last
        if(p_in.last != p_out.last) begin
            $display("Error last, out = %0b, in = %0b", p_out.last, p_in.last);
            $error();
            cnt_error_transaction++;
        end

        //keep
        if(p_in.keep != p_out.keep) begin
            $display("Error keep, out = %0b, in = %0b", p_out.keep, p_in.keep);
            $error();
            cnt_error_transaction++;
        end


        cnt_transaction++;

        if(cnt_transaction >= cfg.count_transaction) begin
            done = 1;
        end
    endtask

    //для подсчета контрольной суммы IP-пакета
    virtual function logic [15:0] get_csum_ip_header(axis_packet pkt);
        logic [4:0][31:0] ip_header;
        logic [32:0] temp_csum;
        logic [16:0] result;

        temp_csum = 33'h0;
        for(int i = 0; i < 5; i++) ip_header[i] = pkt.data[i];
        
        temp_csum += ip_header[0];
        temp_csum += ip_header[1];
        temp_csum = (temp_csum[31:0] + temp_csum[32]) & 33'hFFFFFFFF;//обнуляем старший бит


        temp_csum += {ip_header[2][31:16], 16'h0};//при расчете контрольной суммы мы это поле принимаем равным нулю
        temp_csum = (temp_csum[31:0] + temp_csum[32]) & 33'hFFFFFFFF;//обнуляем старший бит
        

        for(int i = 3; i < 5; i++) begin
            temp_csum += ip_header[i];
            temp_csum = (temp_csum[31:0] + temp_csum[32]) & 33'hFFFFFFFF;
        end

        result = temp_csum[31:16] + temp_csum[15:0];
        result = result[15:0] + {15'h0, result[16]};

        return ~result[15:0];
    endfunction

    //для подсчета контрольной суммы UDP-пакета
    virtual function logic [15:0] get_csum_udp_header(axis_packet pkt);
        logic [4:0][31:0] pseudo_header;
        logic [32:0] temp_csum;
        logic [16:0] result;

        temp_csum = 33'h0;

        pseudo_header[0] = pkt.data[3];//ip source
        pseudo_header[1] = pkt.data[4];//ip destination
        pseudo_header[2] = {16'h0011, pkt.data[6][31:16]};//protocol and udp length (заголовок + данные)
        pseudo_header[3] = pkt.data[5];//{port src, port dest}
        pseudo_header[4] = {pkt.data[6][31:16], 16'h0};//обнуляем поле контрольной суммы


        temp_csum += pseudo_header[0];
        for(int i = 1; i < 5; i++) begin
            temp_csum += pseudo_header[i];
            temp_csum = (temp_csum[31:0] + temp_csum[32]) & 33'hFFFFFFFF;
        end

        //добавляем данные после всех заголовков
        for(int i = 7; i < pkt.data.size(); i++) begin
            temp_csum += pkt.data[i];
            temp_csum = (temp_csum[31:0] + temp_csum[32]) & 33'hFFFFFFFF;
        end

        result = temp_csum[31:16] + temp_csum[15:0];
        result = result[15:0] + {15'h0, result[16]};

        return ~result[15:0];
    endfunction

endclass