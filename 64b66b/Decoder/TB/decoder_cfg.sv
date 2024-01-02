//  Class: decoder_cfg
//
class decoder_cfg;
    
    //generator
    rand int count_init_rand_bits;//число бит, которые сдвинут сгенерированный поток относительно нормального расположения
    rand int count_packet_gen;//сколько пакетов генерировать генератору


    //driver sink
    rand int sink_transaction_pause_min;
    rand int sink_transaction_pause_max;

    //driver source
    rand int source_ready_delay_enable_min;//длительность выставления одного сигнала ready на приемной стороне
    rand int source_ready_delay_enable_max;
    
    rand int source_ready_delay_disable_min;
    rand int source_ready_delay_disable_max;

    int timeout_cycles = 10_000_000;
    

    constraint count_packet_gen_c {
        count_init_rand_bits inside {[0:63]};
        count_packet_gen inside {[50000:100000]};
    }

    constraint sink_transaction_pause_c {
        sink_transaction_pause_min inside {[0:10]};
        sink_transaction_pause_max inside {[0:10]};
        sink_transaction_pause_max > sink_transaction_pause_min;
    }

    constraint source_ready_delay_enable_c {
        source_ready_delay_enable_min inside {[0:10]};
        source_ready_delay_enable_max inside {[0:10]};
        source_ready_delay_enable_max > source_ready_delay_enable_min;
    }
    
    constraint source_ready_delay_disable_c {
        source_ready_delay_disable_min inside {[0:10]};
        source_ready_delay_disable_max inside {[0:10]};
        source_ready_delay_disable_max > source_ready_delay_disable_min;
    }


    function void post_randomize();
        string str;
        str = $sformatf("Init random bits = %0d\n", count_init_rand_bits);
        str = {str, $sformatf("Count packet generate = %0d\n", count_packet_gen)};

        str = {str, $sformatf("Min pause transaction for input = %0d\n", sink_transaction_pause_min)};
        str = {str, $sformatf("Max pause transaction for input = %0d\n", sink_transaction_pause_max)};

        str = {str, $sformatf("Min ready for source enable = %0d\n", source_ready_delay_enable_min)};
        str = {str, $sformatf("Max ready for source enable = %0d\n", source_ready_delay_enable_max)};

        str = {str, $sformatf("Min ready for source disable = %0d\n", source_ready_delay_disable_min)};
        str = {str, $sformatf("Max ready for source disable = %0d\n", source_ready_delay_disable_max)};

        $display(str);
    endfunction

endclass: decoder_cfg
