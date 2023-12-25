class generator;

    decoder_cfg gen_cfg;
    mailbox #(packet) mbx_gen2scb;//эталонная послеовательность, которая подвергается скремблированию
    mailbox #(packet) mbx_gen2drv;
    

    virtual task run();
        gen_transaction();
    endtask
    
    virtual task gen_transaction();
        packet p;
        bit [65:0] data_array [];//промежуточный массив для скремблирования данных и добавления смещающих бит
        bit [65:0] init_rand_bits;
        bit [57:0] x;//для скремблирования полезной нагрузки
        
        /*
            1. Генерация стрима 66b
            2. Помещаем в mailbox эталонную последовательность для будущего анализа sequencer'ом 
            3. Скремблируем
            4. Генерируем случайное количество бит для смещения синхромаркера 64b/66b
            5. Отправляем в очередь для драйвера mbx_gen2drv
        */
        data_array = new[gen_cfg.count_packet_gen];

        for(int i = 0; i < gen_cfg.count_packet_gen; i++) begin
            if(!p.randomize()) begin
                $error();
                $display("Randomize packet error");
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
                    $error();
                    $display("Error initial padding randomize!");
                end
                p.tdata = 66'(data_array[i] << gen_cfg.count_init_rand_bits) | 66'(init_rand_bits >> (66 - gen_cfg.count_init_rand_bits));
            end
            else begin
                p.tdata = 66'(data_array[i] << gen_cfg.count_init_rand_bits) | 66'(data_array[i-1] >> (66 - gen_cfg.count_init_rand_bits));
            end
            mbx_gen2drv.put(p);//добавляем в очередь для отправки драйвером
        end
    endtask

endclass