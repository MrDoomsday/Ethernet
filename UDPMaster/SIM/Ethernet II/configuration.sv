class configuration;

//for generator transaction
            //размер пакета
            int     min_size_pkt = 8;//с учетом вышестоящих заголовков длина меньше этого значения никогда не встретится
            int     max_size_pkt = 100;

            //пауза между пакетами
            int     min_pause_pkt = 0;
            int     max_pause_pkt = 10;

            //пауза между словами в пакете
            int     min_pause_word = 0;
            int     max_pause_word = 2;

            


//for receiver transaction
//длительность низкого уровня ready на приемном конце 
            int     min_low_ready = 0;
            int     max_low_ready = 10;
//длительность высокого уровня ready на приемном конце
            int     min_high_ready = 0;
            int     max_high_ready = 10;



//GLOBAL 
    int count_transaction = 10_000;
    int timeout_value = 1000_000_000;



    function void post_randomize();
        string str;
        str = $sformatf(        "Minimal size packet =              %d\n", min_size_pkt);
        str = {str, $sformatf(  "Maximal size packet =              %d\n", max_size_pkt)};

        str = {str, $sformatf(  "Minimal pause for word in packet = %d\n", min_pause_word)};
        str = {str, $sformatf(  "Maximal pause for word in packet = %d\n", max_pause_word)};

        str = {str, $sformatf(  "Minimal pause for packet =         %d\n", min_pause_pkt)};
        str = {str, $sformatf(  "Maximal pause for packet =         %d\n", max_pause_pkt)};

        str = {str, $sformatf(  "Minimal low level for ready =      %d\n", min_low_ready)};
        str = {str, $sformatf(  "Maximal low level for ready =      %d\n", max_low_ready)};
        str = {str, $sformatf(  "Minimal high level for ready =     %d\n", min_high_ready)};
        str = {str, $sformatf(  "Maximal high level for ready =     %d\n", max_high_ready)};
        
        $display(str);
    endfunction

endclass