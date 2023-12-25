//  Class: decoder_cfg
//
class decoder_cfg;
    
    //generator
    rand int count_init_rand_bits;//число бит, которые сдвинут сгенерированный поток относительно нормального расположения
    rand int count_packet_gen;//сколько пакетов генерировать генератору
    rand int count_packet_ok;//сколько пакетов необходимо для проверки дизайна


    //driver sink
    rand int sink_transaction_pause_min;
    rand int sink_transaction_pause_max;

    //driver source
    rand int source_ready_pause_min;
    rand int source_ready_pause_max;
    


    constraint count_packet_gen_c {
        count_init_rand_bits inside {[0:63]};
        count_packet_gen inside {[50000:100000]};
        count_packet_ok == (count_packet_gen - 4096);
    }

    constraint sink_transaction_pause_c {
        sink_transaction_pause_min inside {[0:10]};
        sink_transaction_pause_max inside {[0:10]};
        sink_transaction_pause_max > sink_transaction_pause_min;
    }

    constraint source_ready_pause_c {
        source_ready_pause_min inside {[0:10]};
        source_ready_pause_max inside {[0:10]};
        source_ready_pause_max > source_ready_pause_min;
    }
    

endclass: decoder_cfg
