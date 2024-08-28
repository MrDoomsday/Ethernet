class scoreboard #(parameter ID_WIDTH = 10);

    mailbox #(axis_packet) mbx_tse_in;//данные, полученные от TSE модуля
    mailbox #(axis_packet) mbx_tse_out;//данные для отправки на TSE модуль
    mailbox #(axis_packet #(.ID_WIDTH(ID_WIDTH))) mbx_us_in;//user stream

    //axis_packet p_in, p_out;
    //axis_packet #(.ID_WIDTH(ID_WIDTH)) p_us;


    //парсер входных пакетов на UDPMaster
    mailbox #(axis_packet) mbx_arp_in;
    mailbox #(axis_packet) mbx_eth2axi_in;

    //парсер выходных пакетов от UDPMaster
    mailbox #(axis_packet) mbx_arp_out;//для сбора ответов на ARP-запросы
    mailbox #(axis_packet) mbx_eth2axi_out;//для сбора ответов на запросы Eth2AXI
    mailbox #(axis_packet) mbx_us_out;//для сбора UDP-пакетов, в которые упакованы пользовательские данные


    configuration cfg;

    int cnt_transaction;
    int cnt_error_transaction;

    int cnt_arp_check_transaction = 0;//количество проверенных пакетов ARP
    int cnt_arp_error_transaction = 0;//количество ошибочных пакетов ARP
    int cnt_arp_all_transaction = 0;//полное количество ARP пакетов, полученное от генератора
    bit arp_done = 0;

    int cnt_eth2axi_all_transaction = 0;
    bit eth2axi_done = 1;//Ethernet2AXI

    bit us_done = 1;//user stream

    function new();
        mbx_arp_in = new();
        mbx_eth2axi_in = new();
        mbx_arp_out = new();
        mbx_eth2axi_out = new();
        mbx_us_out = new();
    endfunction

    virtual task run();
        fork
            forever begin
                parse_tse_in();//парсинг пакетов
            end

            forever begin
                parse_tse_out();//парсинг пакетов
            end

            forever begin
                check_pkt(); 
            end                
        join
    endtask


    virtual task check_pkt();
        fork
            forever begin
                check_arp_packet();
            end 
            // forever begin
                
            // end    
        join
    endtask

    //разбрасываем по разным очередям разные типы входных пакетов
    virtual task parse_tse_in();
        axis_packet p_in;
        mbx_tse_in.get(p_in);
        if(p_in.type_pkt == ARP) begin
            mbx_arp_in.put(p_in);
            cnt_arp_all_transaction++;//здесь мы посчитаем сколько транзакций ARP было сгенерировано
            //$display("ARP detected");
        end
        else if(p_in.type_pkt == Eth2AXI) begin
            mbx_eth2axi_in.put(p_in);
            cnt_eth2axi_all_transaction++;//здесь мы посчитаем сколько транзакций Ethernet2AXI было сгенерировано
            //$display("Ethernet to AXI detected");
        end
        // else if(p_in.type_pkt == RAW) begin
        //     //ничего не делаем, пакет будет проигнорирован
        // end
    endtask

    //разбрасываем по очередям разные типы выходных пакетов
    virtual task parse_tse_out();
        axis_packet p_out;
        mbx_tse_out.get(p_out);

        if(arp_detect(p_out)) mbx_arp_out.put(p_out);
        else if(eth2axi_detect(p_out)) mbx_eth2axi_out.put(p_out);
        else if(userdata_detect(p_out)) mbx_us_out.put(p_out);

    endtask

    virtual function bit arp_detect(axis_packet p);//проверяет является ли пакет ARP-ответом
        if( {p.data[1][15:0], p.data[2][31:0]} == cfg.mac_board &&//check MAC Source
            p.data[3][31:16] == 16'h0806 && //hardware type - ARP
            p.data[3][15:0] == 16'h0001 //hardware type - Ethernet
        ) begin
            return 1;
        end
        else begin
            return 0;
        end
    endfunction

    virtual function bit eth2axi_detect(axis_packet p);//проверяет является ли пакет ARP-ответом
        return 0;
    endfunction

    virtual function bit userdata_detect(axis_packet p);//проверяет является ли пакет ARP-ответом
        return 0;
    endfunction


    virtual task check_arp_packet();
        bit error_flag;//выставляем при обнаружении любой из ошибок
        logic [47:0] mac_dest_in, mac_dest_out;
        logic [47:0] mac_src_in, mac_src_out;
        logic [15:0] mac_type_in, mac_type_out;
        logic [15:0] arp_hard_type_in, arp_hard_type_out;
        logic [15:0] arp_prot_type_in, arp_prot_type_out;
        logic [7:0]  arp_hard_size_in, arp_hard_size_out;
        logic [7:0]  arp_prot_size_in, arp_prot_size_out;
        logic [15:0] arp_opcode_in, arp_opcode_out;
        logic [47:0] arp_sender_mac_addr_in, arp_sender_mac_addr_out;
        logic [31:0] arp_sender_ip_addr_in, arp_sender_ip_addr_out;
        logic [47:0] arp_target_mac_addr_in, arp_target_mac_addr_out;
        logic [31:0] arp_target_ip_addr_in, arp_target_ip_addr_out;        
        axis_packet arp_request, arp_response;

        error_flag = 0;
        mbx_arp_in.get(arp_request);
        mbx_arp_out.get(arp_response);

        //arp request field
        mac_dest_in         = {arp_request.data[0][31:0], arp_request.data[1][31:16]};
        mac_src_in          = {arp_request.data[1][15:0], arp_request.data[2][31:0]};
        mac_type_in         = arp_request.data[3][31:16];
        
        arp_hard_type_in    = arp_request.data[3][15:0];
        arp_prot_type_in    = arp_request.data[4][31:16];
        arp_hard_size_in    = arp_request.data[4][15:8];
        arp_prot_size_in    = arp_request.data[4][7:0];
        arp_opcode_in       = arp_request.data[5][31:16];

        arp_sender_mac_addr_in  = {arp_request.data[5][15:0], arp_request.data[6][31:0]};
        arp_sender_ip_addr_in   = arp_request.data[7][31:0];

        arp_target_mac_addr_in  = {arp_request.data[8][31:0], arp_request.data[9][31:16]};
        arp_target_ip_addr_in   = {arp_request.data[9][15:0], arp_request.data[10][31:16]};

        //arp response field
        mac_dest_out         = {arp_response.data[0][31:0], arp_response.data[1][31:16]};
        mac_src_out          = {arp_response.data[1][15:0], arp_response.data[2][31:0]};
        mac_type_out         = arp_response.data[3][31:16];
        
        arp_hard_type_out    = arp_response.data[3][15:0];
        arp_prot_type_out    = arp_response.data[4][31:16];
        arp_hard_size_out    = arp_response.data[4][15:8];
        arp_prot_size_out    = arp_response.data[4][7:0];
        arp_opcode_out       = arp_response.data[5][31:16];

        arp_sender_mac_addr_out  = {arp_response.data[5][15:0], arp_response.data[6][31:0]};
        arp_sender_ip_addr_out   = arp_response.data[7][31:0];

        arp_target_mac_addr_out  = {arp_response.data[8][31:0], arp_response.data[9][31:16]};
        arp_target_ip_addr_out   = {arp_response.data[9][15:0], arp_response.data[10][31:16]};

        //check
        if(mac_dest_out != mac_src_in) begin
            $error("ARP error: The response MAC address does not match the request MAC address");
            error_flag = 1;
        end

        // if(arp_hard_type_out != 16'h0001) begin//его уже проверяем выше
        //     $error("ARP error: Hardware type does not match Ethernet");
        //     error_flag = 1;
        // end

        if(arp_prot_type_out != 16'h0800) begin
            $error("ARP error: Protocol type does not match IPv4");
            error_flag = 1;
        end

        if(arp_hard_size_out != arp_hard_size_in) begin
            $error("ARP error: The hardware size field value in the response is not equal to the field value in the request");
            error_flag = 1;
        end

        if(arp_prot_size_out != arp_prot_size_in) begin
            $error("ARP error: The protocol size field value in the response is not equal to the field value in the request");
            error_flag = 1;
        end

        if(arp_opcode_out != 16'h0002) begin
            $error("ARP error: The opcode field value is not 'reply' type");
            error_flag = 1;
        end

        if(arp_sender_mac_addr_out != cfg.mac_board) begin//ядро отвечает всегда только своим адресом, который у него в параметрах
            $error("ARP error: The sender MAС address of the response does not match the configuration parameters");
            error_flag = 1;
        end

        if(arp_sender_ip_addr_out != cfg.ip_board) begin//ядро отвечает всегда только своим адресом, который у него в параметрах
            $error("ARP error: The sender IP address of the response does not match the configuration parameters");
            error_flag = 1;
        end

        if(arp_target_mac_addr_out != arp_sender_mac_addr_in) begin
            $error("ARP error: The Target MAC address of the response packet does not match the Sender MAC address of the request packet");
            error_flag = 1;
        end

        if(arp_target_ip_addr_out != arp_sender_ip_addr_in) begin
            $error("ARP error: The Target IP address of the response packet does not match the Sender IP address of the request packet");
            error_flag = 1;
        end

        //$display("ARP check successfull");
        cnt_arp_check_transaction++;
        if(error_flag) begin
            cnt_arp_error_transaction++;
            cnt_error_transaction++;
        end

        if(cnt_arp_check_transaction >= cnt_arp_all_transaction) begin
            $display("ARP test complete");
            arp_done = 1;//заданное количество ARP-пакетов обработано
        end
        //$display("all arp = %0d, cnt check transaction = %0d", cnt_arp_all_transaction, cnt_arp_check_transaction);
    endtask

endclass