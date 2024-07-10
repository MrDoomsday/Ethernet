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
        logic [16:0] csum_in, csum_out;

        mbx_out.get(p_out);
        mbx_in.get(p_in);

        size_data_in = p_in.data.size();
        size_data_out = p_out.data.size();

        //check length
        if(size_data_in != size_data_out) begin
            $display("Error size data array, out = %0d, in = %0d", p_out.data.size(), p_in.data.size());
            $fatal();
            cnt_error_transaction++;
        end
        //проверка правильности расчета длины пакета модулем
        if( (4*(size_data_in-1) + p_in.keep[3]+p_in.keep[2]+p_in.keep[1]+p_in.keep[0]) != p_out.pkt_len || 
            (4*(size_data_out-1) + p_out.keep[3]+p_out.keep[2]+p_out.keep[1]+p_out.keep[0]) != p_out.pkt_len) begin
            $display("Module return error length, module = %0d bytes, out = %0d bytes, in = %0d bytes", p_out.pkt_len, 
                                                                                                        4*(size_data_out-1) + p_out.keep[3]+p_out.keep[2]+p_out.keep[1]+p_out.keep[0], 
                                                                                                        4*(size_data_in-1) + p_in.keep[3]+p_in.keep[2]+p_in.keep[1]+p_in.keep[0]);
            $error();
            cnt_error_transaction++;
        end

        //check data in packet
        for(int i = 0; i < size_data_out; i++) begin
            if(p_in.data[i] != p_out.data[i]) begin
                $display("Error data array, out[%0d] = %0h, in[%0d] = %0h", i, p_out.data.size(), i, p_in.data.size());
                $error();
                cnt_error_transaction++;
            end
        end

        //check control sum for data
        csum_in = 'h0;
        csum_out = 'h0;

        for(int i = 0; i < size_data_out; i++) begin
            logic [16:0] csum_tmp;

            csum_tmp = p_in.data[i][31:16] + p_in.data[i][15:0];
            csum_tmp = csum_tmp[15:0] + {15'h0, csum_tmp[16]};
            csum_in += csum_tmp[15:0];
            csum_in = csum_in[15:0] + {15'h0, csum_in[16]};
            
            csum_tmp = p_out.data[i][31:16] + p_out.data[i][15:0];
            csum_tmp = csum_tmp[15:0] + {15'h0, csum_tmp[16]};
            csum_out += csum_tmp[15:0];
            csum_out = csum_out[15:0] + {15'h0, csum_out[16]};
            
            if(i == size_data_out-1) begin
                //$display("csum %0h, %0h", csum_in, csum_out);
                if((csum_in != p_out.pkt_csum) || (csum_out != p_out.pkt_csum)) begin
                    $display("Error control sum, module = %0h, out = %0h, in = %0h", p_out.pkt_csum, csum_out, csum_in);
                    $error();
                    cnt_error_transaction++;
                end
            end
        end


        //check field packet
        //IP address
        if(p_in.ip_dest != p_out.ip_dest || p_in.ip_src != p_out.ip_src) begin
            $error("Error IP in packet");
            $display("IP dest out = %0d.%0d.%0d.%0d, in = %0d.%0d.%0d.%0d", p_out.ip_dest[31:24], p_out.ip_dest[23:16], p_out.ip_dest[15:8], p_out.ip_dest[7:0], p_in.ip_dest[31:24], p_in.ip_dest[23:16], p_in.ip_dest[15:8], p_in.ip_dest[7:0]);
            $display("IP src out = %0d.%0d.%0d.%0d, in = %0d.%0d.%0d.%0d", p_out.ip_src[31:24], p_out.ip_src[23:16], p_out.ip_src[15:8], p_out.ip_src[7:0], p_in.ip_src[31:24], p_in.ip_src[23:16], p_in.ip_src[15:8], p_in.ip_src[7:0]);
            $error();
            cnt_error_transaction++;
        end

        //UDP ports
        if(p_in.port_dest != p_out.port_dest || p_in.port_src != p_out.port_src) begin
            $error("Error PORT in packet");
            $display("Port dest out = %0d, in = %0d", p_out.port_dest, p_in.port_dest);
            $display("Port src out = %0d, in = %0d", p_out.port_src, p_in.port_src);
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


endclass