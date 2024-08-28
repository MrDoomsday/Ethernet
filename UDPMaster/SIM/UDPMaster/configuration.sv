class configuration;

            int             AMOUNT_DEST_ADDRESS;//число адресов назначения
    rand    bit [47:0]      mac_dest[];
    rand    bit [31:0]      ip_dest[];
    rand    bit [15:0]      port_dest[];
    

    function new(int ID_WIDTH);
        AMOUNT_DEST_ADDRESS = 2**ID_WIDTH;
        mac_dest    = new[AMOUNT_DEST_ADDRESS];
        ip_dest     = new[AMOUNT_DEST_ADDRESS];
        port_dest   = new[AMOUNT_DEST_ADDRESS];
    endfunction

//address board
    rand    bit [47:0] mac_board;
    rand    bit [31:0] ip_board;         
    rand    bit [15:0] port_board; 

//for generator transaction
    //параметры генерации пакетов для интерфейса TSE
            //размер пакета
            int     tse_min_size_pkt = 8;//с учетом вышестоящих заголовков длина меньше этого значения никогда не встретится
            int     tse_max_size_pkt = 100;

            //пауза между пакетами
            int     tse_min_pause_pkt = 0;
            int     tse_max_pause_pkt = 10;

            //пауза между словами в пакете
            int     tse_min_pause_word = 0;
            int     tse_max_pause_word = 2;
            
            //число генерируемых транзакций
            int     tse_count_transaction = 10_000;

    //параметры для генерации пакетов с рандомными данными для упаковки в UDP
            //размер пакета
            int     usd_min_size_pkt = 8;//с учетом вышестоящих заголовков длина меньше этого значения никогда не встретится
            int     usd_max_size_pkt = 100;

            //пауза между пакетами
            int     usd_min_pause_pkt = 0;
            int     usd_max_pause_pkt = 10;

            //пауза между словами в пакете
            int     usd_min_pause_word = 0;
            int     usd_max_pause_word = 2;
            
            int     usd_count_transaction = 10_000;


//for receiver transaction
//длительность низкого уровня ready на приемном конце 
            int     min_low_ready = 0;
            int     max_low_ready = 10;
//длительность высокого уровня ready на приемном конце
            int     min_high_ready = 0;
            int     max_high_ready = 10;



//GLOBAL 
    int timeout_value = 1000_000_000;



    function void post_randomize();
        string str;
        str = $sformatf(        "TSE: Minimal size packet =                 %d\n", tse_min_size_pkt);
        str = {str, $sformatf(  "TSE: Maximal size packet =                 %d\n", tse_max_size_pkt)};
        str = {str, $sformatf(  "TSE: Minimal pause for word in packet =    %d\n", tse_min_pause_word)};
        str = {str, $sformatf(  "TSE: Maximal pause for word in packet =    %d\n", tse_max_pause_word)};
        str = {str, $sformatf(  "TSE: Minimal pause for packet =            %d\n", tse_min_pause_pkt)};
        str = {str, $sformatf(  "TSE: Maximal pause for packet =            %d\n", tse_max_pause_pkt)};
        str = {str, $sformatf(  "TSE: Amount transacrion    =               %d\n", tse_count_transaction)};

        str = {str, $sformatf(  "USD: Minimal size packet =                 %d\n", usd_min_size_pkt)};
        str = {str, $sformatf(  "USD: Maximal size packet =                 %d\n", usd_max_size_pkt)};
        str = {str, $sformatf(  "USD: Minimal pause for word in packet =    %d\n", usd_min_pause_word)};
        str = {str, $sformatf(  "USD: Maximal pause for word in packet =    %d\n", usd_max_pause_word)};
        str = {str, $sformatf(  "USD: Minimal pause for packet =            %d\n", usd_min_pause_pkt)};
        str = {str, $sformatf(  "USD: Maximal pause for packet =            %d\n", usd_max_pause_pkt)};
        str = {str, $sformatf(  "USD: Amount transaction =                  %d\n", usd_count_transaction)};


        str = {str, $sformatf(  "Minimal low level for ready =              %d\n", min_low_ready)};
        str = {str, $sformatf(  "Maximal low level for ready =              %d\n", max_low_ready)};
        str = {str, $sformatf(  "Minimal high level for ready =             %d\n", min_high_ready)};
        str = {str, $sformatf(  "Maximal high level for ready =             %d\n", max_high_ready)};
        
        str = {str, $sformatf(  "Board: MAC = %0h, IP = %0h, port = %0d       \n", mac_board, ip_board, port_board)};
        $display(str);

        // for(int i = 0; i < AMOUNT_DEST_ADDRESS; i++) begin
        //     $display("Cell[%0d]: MAC = %0h, IP = %0h, UDP Port = %0d", i, mac_dest[i], ip_dest[i], port_dest[i]);
        // end
    endfunction

endclass