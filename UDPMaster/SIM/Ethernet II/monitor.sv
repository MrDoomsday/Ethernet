class monitor_mac;

    mailbox #(mac_packet) mbx_mon2scb;
    virtual mac_intf vif_mac;
    mac_packet mp;


    function new();
    endfunction


    virtual task run();
        wait(vif_mac.reset_n);
        forever begin
            monitoring();
        end
    endtask

    virtual task monitoring();
        mp = new();

        @(posedge vif_mac.clk);

        if(vif_mac.vld && vif_mac.rdy) begin
            mp.dest = vif_mac.dest;
            mp.src = vif_mac.src;
            mp.ttype = vif_mac.ttype;
            mbx_mon2scb.put(mp);
        end
    endtask

endclass


class monitor_axis;

    //global
    mailbox #(axis_packet) mbx_mon2scb;
    virtual stream_intf vif_stream;
    axis_packet p;
    //local
    mailbox #(axis_packet) word_collection;//для коллекционирования отдельных слов, которые регистрируем от интерфейса

    function new();
        word_collection = new();
    endfunction

    virtual task run();
        wait(vif_stream.reset_n);
        forever begin
            monitoring();
        end
    endtask


    virtual task monitoring();
        /*
            планируется при помощи монитора собирать пакет из отдельных слов, которые наблюдаются на интерфейсе
        */
        @(posedge vif_stream.clk);
        if(vif_stream.tready && vif_stream.tvalid) begin
            p = new();
            if(!p.randomize() with {
                len == 1;
            }) begin //нужно создать однословный пакет для буферизации
                $display("Error randomization in monitor...");
                $fatal();
            end

            p.data[0]   = vif_stream.tdata;
            p.last      = vif_stream.tlast;
            p.keep      = vif_stream.tkeep;
            word_collection.put(p);

            if(vif_stream.tlast) begin//детектировано последнее слово в пакете, можно начать сборку пакета в один класс
                int size_pkt;

                size_pkt = word_collection.num();

                //создаем класс пакета
                p = new();
                if(!p.randomize() with {
                    len == size_pkt;
                }) begin
                    $display("Error randomization in monitor, last packet...");
                    $fatal();
                end
                /*
                    теперь извлекаем последовательно содержимое очереди 
                    с коллекцией отдельных слов word_collection
                    и собираем класс полного пакета p;
                    Другие поля (dest, id, last) одинаковы на протяжении всего пакета,
                    поэтому они не индексируются, а назначаются одинаково для всех итераций цикла
                */
                for(int i = 0; i < size_pkt; i++) begin
                    axis_packet pkt;
                    
                    word_collection.get(pkt);
                    
                    p.data[i]   = pkt.data[0];
                    p.last      = pkt.last;
                    p.keep      = pkt.keep;
                end

                word_collection = new();//уничтожаем старый объект и создаем новый
                mbx_mon2scb.put(p);//сохраняем пакет целиком
            end
        end
    endtask


endclass
