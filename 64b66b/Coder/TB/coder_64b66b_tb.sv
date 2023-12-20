module coder64b66b_tb();

    localparam CLK_PERIOD = 20;

    reg clk;
    reg reset_n;

//AXI Stream input
    reg      [1:0]   s_axis_ttype;//user signal, 2'b11, 2'b00 - illegal
    reg      [63:0]  s_axis_tdata;
    reg              s_axis_tvalid;
    wire             s_axis_tready;

//AXI Stream output
    wire     [66:0]  m_axis_tdata;
    wire             m_axis_tvalid;
    reg              m_axis_tready;


    coder64b66b DUT(
        .clk    (clk),
        .reset_n(reset_n),

    //AXI Stream input
        .s_axis_ttype   (s_axis_ttype),//user signal, 2'b11, 2'b00 - illegal
        .s_axis_tdata   (s_axis_tdata),
        .s_axis_tvalid  (s_axis_tvalid),
        .s_axis_tready  (s_axis_tready),

    //AXI Stream output
        .m_axis_tdata   (m_axis_tdata),
        .m_axis_tvalid  (m_axis_tvalid),
        .m_axis_tready  (m_axis_tready)
    );


/*******************TEST*******************/
typedef struct {
    rand int delay;//интервал между транзакциями
    rand bit [1:0] ttype;
    rand bit [63:0] tdata;
} stream;


mailbox #(stream) mbx_gen2drv = new();//от генератора транзакция к драйверу
mailbox #(stream) mbx_in_monitor = new();//для мониторинга транзакций, отправленных на входной порт
mailbox #(stream) mbx_out_monitor = new();//для мониторинга транзакций, передаваемых с выходного порта


//generate reset signal
task gen_reset();
    reset_n <= 1'b0;
    repeat(10) @ (posedge clk);
    reset_n <= 1'b1;
endtask

//timeout...
task timeout(int timeout_cycles);
    repeat(timeout_cycles) @ (posedge clk);
    $display("TIMEOUT");
    $stop();
endtask

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************        SINK  MODULE       *************************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
task reset_s_axis();//инициализация входного порта
    wait(~reset_n);
    s_axis_ttype <= 2'h0;
    s_axis_tdata <= 64'h0;
    s_axis_tvalid <= 1'b0;
    wait(reset_n);
endtask

task gen_transaction_unit(int delay_min, int delay_max);//генерация одного слова
    stream p;

    if(!std::randomize(p) with {
        p.delay inside{[delay_min:delay_max]};
        p.ttype inside{2'b10, 2'b01};
        //p.tdata > 0;
    }) begin
        $error("Can't randomize!");
        $stop();
    end

    mbx_gen2drv.put(p);//помещаем транзакцию в mailbox для драйвера
endtask

task gen_transaction(int word_amount, int delay_min, int delay_max);//генерация всего набора
    for(int i = 0; i < word_amount; i++) begin
        gen_transaction_unit(delay_min, delay_max);
    end
endtask

task driver_s_axis(stream p);//пере
    s_axis_ttype <= p.ttype;
    s_axis_tdata <= p.tdata;
    s_axis_tvalid <= 1'b1;

    do begin
        @(posedge clk);
    end
    while(!s_axis_tready);

    s_axis_ttype <= 2'h0;
    s_axis_tdata <= 64'h0;
    s_axis_tvalid <= 1'b0;

    repeat(p.delay) @ (posedge clk);
endtask

task sender_s_axis();//отправляет транзакции с очереди транзакций на драйвер
    stream s;

    wait(reset_n);
    @(posedge clk);

    forever begin
        mbx_gen2drv.get(s);
        driver_s_axis(s);
    end
endtask

task monitor_s_axis();//проводит наблюдение за входными портами
    stream p;

    wait(reset_n);

    forever begin
        @(posedge clk);
        if(s_axis_tready && s_axis_tvalid) begin
            p.ttype = s_axis_ttype;
            p.tdata = s_axis_tdata;
            mbx_in_monitor.put(p);
        end
    end
endtask

task master_s_axis(int word_amount, int delay_min, int delay_max);//топовый модуль по отправке на s_axis 
    reset_s_axis();
    fork
        gen_transaction(word_amount, delay_min, delay_max);
        sender_s_axis();
        monitor_s_axis();
    join
endtask

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************        SOURCE   MODULE     ************************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
task reset_m_axis();
    wait(~reset_n);
    m_axis_tready <= 1'b0;
    wait(reset_n);
endtask

task drive_ready_m_axis(int delay_min, int delay_max);//управляем сигналом ready на выходе
    int delay;
    forever begin
        delay = $urandom_range(delay_min, delay_max);

        repeat(delay) @ (posedge clk);
        m_axis_tready <= 1'b1;
        @(posedge clk);
        m_axis_tready <= 1'b0;
    end
endtask

task monitor_m_axi();//мониторим то, что вышло из модуля
    stream s;

    wait(reset_n);

    forever begin
        @(posedge clk);

        if(m_axis_tready && m_axis_tvalid) begin
            {s.ttype, s.tdata} = m_axis_tdata;
            mbx_out_monitor.put(s);
        end
    end
endtask

task master_m_axis(int delay_min, int delay_max);//собираем всё вместе
    reset_m_axis();
    fork
        drive_ready_m_axis(delay_min, delay_max);
        monitor_m_axi();
    join
endtask

task check_transaction(int master_word_amount);
    stream s_in, s_out;
    bit [63:0] data_out_etalon;//рассчитывается на однобитных данных
    bit [57:0] x;//промежуточные значения при вычислении полинома

    int counter_checked_transaction;

    wait(reset_n);

    forever begin
        mbx_in_monitor.get(s_in);
        mbx_out_monitor.get(s_out);

        if(s_in.ttype != s_out.ttype) begin
            $error("---------Type packet FAILED---------, s_type = %h, m_type = %h", s_in.ttype, s_out.ttype);
            $stop();
        end

        //распишем однобитный полином для тестирования 
        for (int i = 0; i < 64; i++) begin
            data_out_etalon[i] = s_in.tdata[i] ^ x[38] ^ x[57];
            
            for(int j = 57; j > 0; j--) begin
                x[j] = x[j-1];
            end
            x[0] = data_out_etalon[i];
        end

        if(s_out.tdata != data_out_etalon) begin
            $error("---------data packet FAILED, data output = %h, etalon output = %h---------", s_out.tdata, data_out_etalon);
            $stop();
        end
        else begin
            $display("**********data packet PASSED, data input = %h, data output = %h**********", s_out.tdata, data_out_etalon);
        end
        counter_checked_transaction++;
        if(counter_checked_transaction == master_word_amount) begin
            $display("****************************************************************TEST PASSED****************************************************************");
            $stop();
        end
    end
endtask


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************        TEST        ********************************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

//clock generator
always begin
    clk = 1'b0;
    #(CLK_PERIOD/2);
    clk = 1'b1;
    #(CLK_PERIOD/2);
end

task test(int master_word_amount, int master_delay_min, int master_delay_max, int timeout_cycles, int slave_ready_delay_min, int slave_ready_delay_max);
    fork
        master_s_axis(master_word_amount, master_delay_min, master_delay_max);
        master_m_axis(slave_ready_delay_min, slave_ready_delay_max);
        check_transaction(master_word_amount);
        timeout(timeout_cycles);
    join
endtask

initial begin
    fork
        gen_reset();
    join_none

    test(
        .master_word_amount(10000),//число пакетов 
        .master_delay_min(0),
        .master_delay_max(10),
        .timeout_cycles(200_000),
        .slave_ready_delay_min(1),
        .slave_ready_delay_max(10)
    );
end

endmodule