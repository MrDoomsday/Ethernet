class scoreboard;

    mailbox #(packet) mbx_in;
    mailbox #(packet) mbx_out;

    decoder_cfg cfg;
    bit done;
    bit flag_reset_n;
    int cnt_skip_transaction;//число пропущенных эталонных транзакций (в общем случе неизвестно за какое время настроится синхронизатор) и какие валидные данные он начнет выдавать
    int cnt_complete_transaction;
    int cnt_error;//число пакетов с ошибками


    virtual task run();
        done = 0;
        wait(flag_reset_n);//дожидаемся сигнала сброса
        check_first_word();
        forever begin
            check();
        end
    endtask

    //данная задача ждет первое принятое слово от DUT и проверяет его наличие в списке эталонных транзакций
    virtual task check_first_word();
        packet p_etalon, p_receive;
        mbx_in.get(p_etalon);
        mbx_out.get(p_receive);//ждем первого слова
        
        
        while(mbx_in.num() > 0) begin//достаем эталонные данные до тех пор пока не попадется первый элемент, выданный модулем
            mbx_in.get(p_etalon);
            if(p_etalon.tdata[63:0] == p_receive.tdata[63:0] && p_etalon.tdata[65:64] == p_receive.tdata[65:64]) begin
                $display("First word compare, data etalon = %0h, data receive = %0h", p_etalon.tdata[63:0], p_receive.tdata[63:0]);
                $display("Number skip transaction = %0d", cnt_skip_transaction);
                break;
            end
            cnt_skip_transaction++;
        end

        if(mbx_in.num() == 0) begin//мы извлекли все эталонные транзакции, но совпадений не нашли - значит DUT работает неправильно 
            $display("Error search transaction...");
            $stop();
        end
    endtask



    //данная задача выполняет проверку всех остальных транзакций - они должны совпадать
    virtual task check();
        packet p_etalon, p_receive;

        //следующие слова должны повторять эталонную последовательность в генераторе
        mbx_in.get(p_etalon);
        mbx_out.get(p_receive);

        if(p_etalon.tdata[65:64] != p_receive.tdata[65:64]) begin
            $display("****Error type... Type etalon = %0h, type receive = %0h****", p_etalon.tdata[65:64], p_receive.tdata[65:64]);
            $error();
            cnt_error++;
        end

        if(p_etalon.tdata[63:0] != p_receive.tdata[63:0]) begin
            $display("****Error data... Data etalon = %0h, data receive = %0h****", p_etalon.tdata[63:0], p_receive.tdata[63:0]);
            $error();
            cnt_error++;
        end

        cnt_complete_transaction++;
        if(cnt_complete_transaction >= cfg.count_packet_gen - cnt_complete_transaction) begin
            $display("Count transaction check = %0d", cnt_complete_transaction);
            done = 1;//мы проверили достаточное количество пакетов
        end
    endtask

endclass