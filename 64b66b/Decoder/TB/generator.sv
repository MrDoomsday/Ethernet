class generator;

    decoder_cfg cfg;
    mailbox #(packet) mbx_gen2scb;//эталонная последовательность, которая подвергается скремблированию
    mailbox #(packet) mbx_gen2drv;
    

    virtual task run();
        gen_transaction();
    endtask
    
    virtual task gen_transaction();
        packet p;
        bit [65:0] data_array [];//промежуточный массив для скремблирования данных и добавления смещающих бит
        bit [65:0] init_rand_bits;
        bit [57:0] x;//сдвиговый регистр для скремблирования полезной нагрузки
        bit aligned_queue [$];//в данную очередь мы складываем побитно 66-битные данные, а потом восстанавливаем 64-битные. Это самый просто вариант
        /*
            1. Генерация стрима 66b
            2. Помещаем в mailbox эталонную последовательность для будущего анализа sequencer'ом 
            3. Скремблируем
            4. Генерируем случайное количество бит для смещения синхромаркера 64b/66b
            5. Отправляем в очередь для драйвера mbx_gen2drv
        */
        data_array = new[cfg.count_packet_gen];

        for(int i = 0; i < cfg.count_packet_gen; i++) begin
            p = new();//создаем экземпляр одной транзакции
            if(!p.randomize()) begin
                $display("Randomize packet error");
                $fatal();
            end
            mbx_gen2scb.put(p);
            data_array[i] = p.tdata;
            
            //скремблируем текущее слово данных, но не трогам синхромаркер
            for (int j = 0; j < 64; j++) begin
                data_array[i][j] = data_array[i][j] ^ x[38] ^ x[57];
                for(int k = 57; k > 0; k--) begin
                    x[k] = x[k-1];
                end
                x[0] = data_array[i][j];
            end

            //добавляем произвольное начальное количество бит к массиву для смещения синхромаркера
            if(i == 0) begin
                if(!std::randomize(init_rand_bits) with {
                    init_rand_bits[65:64] inside {2'b00, 2'b11};
                }) begin
                    $display("Error initial padding randomize!");
                    $fatal();
                end
                //добавляем биты смещения
                for(int j = 0; j < cfg.count_init_rand_bits; j++) begin
                    aligned_queue.push_back(init_rand_bits[j]);
                end
            end

            //добавляем текущее слово к общему массиву
            for(int j = 0; j < 66; j++) begin
                aligned_queue.push_back(data_array[i][j]);
            end

            if(aligned_queue.size() >= 64) begin
                p = new();//создаем новый объект пакета. Если этого не сделать, то будем работать со ссылкой на старый
                p.tdata[65:64] = 2'b00;
                for(int j = 0; j < 64; j++) begin
                    p.tdata[j] = aligned_queue.pop_front();
                end
                mbx_gen2drv.put(p);//добавляем в очередь для отправки драйвером
            end
        end
    endtask

endclass