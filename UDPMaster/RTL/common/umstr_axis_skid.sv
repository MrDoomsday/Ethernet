module umstr_axis_skid #(
    parameter T_DATA_WIDTH = 32,
    parameter T_KEEP_WIDTH = 2
) (
    input       logic                           clk,
    input       logic                           reset_n,


    input       logic   [T_DATA_WIDTH-1:0]      s_tdata_i,
    input       logic                           s_tvalid_i,
    input       logic                           s_tlast_i,
    input       logic   [T_KEEP_WIDTH-1:0]      s_tkeep_i, 
    output      logic                           s_tready_o,


    output      logic   [T_DATA_WIDTH-1:0]      m_tdata_o,
    output      logic                           m_tvalid_o,
    output      logic                           m_tlast_o,
    output      logic   [T_KEEP_WIDTH-1:0]      m_tkeep_o, 
    input       logic                           m_tready_i

);


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    logic                           s_ready_reg;
    logic                           s_ready_early;

    //промежуточный накопитель
    logic   [T_DATA_WIDTH-1:0]      store_tdata;
    logic                           store_tvalid, store_tvalid_next;
    logic                           store_tlast;
    logic   [T_KEEP_WIDTH-1:0]      store_tkeep; 

    //выходной регистр
    logic   [T_DATA_WIDTH-1:0]      m_tdata_reg;
    logic                           m_tvalid_reg, m_tvalid_reg_next;
    logic                           m_tlast_reg;
    logic   [T_KEEP_WIDTH-1:0]      m_tkeep_reg; 

    logic                           transfer_in2out, 
                                    transfer_in2store, 
                                    transfer_store2out;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    assign s_tready_o = s_ready_reg;
    // m_trdy_i - сдвигает конвейер независимо от его содержимого, в любом случае освобождается регистр store
    // !store_tvalid & (!s_tvalid_i | !m_tvalid_reg) - если накопитель пустой и: на входе отсутствуют валидные данные или регистр на выходе не содержит данных
    assign s_ready_early = m_tready_i | !store_tvalid & (!s_tvalid_i | !m_tvalid_reg);

    always_comb begin
        store_tvalid_next = store_tvalid;
        m_tvalid_reg_next = m_tvalid_reg;

        transfer_in2out = 1'b0;
        transfer_in2store = 1'b0;
        transfer_store2out = 1'b0;

        //s_ready_early = s_ready_reg;

        //если вход готов принимать данные
        if(s_tready_o) begin
            //если следующий модуль готов принимать данные или выходной регистр пустой 
            if(m_tready_i || !m_tvalid_reg) begin
                //s_ready_early = 1'b1;
                m_tvalid_reg_next = s_tvalid_i;
                transfer_in2out = 1'b1;
            end
            //если следующий модуль не готов принимать данные и выходной регистр не пустой - загружаем в накопитель
            else begin
                //s_ready_early = !s_tvalid_i;
                store_tvalid_next = s_tvalid_i;
                transfer_in2store = 1'b1;
            end
        end
        else if(m_tready_i) begin
            //s_ready_early = 1'b1;
            store_tvalid_next = 1'b0;
            m_tvalid_reg_next = store_tvalid;
            transfer_store2out = 1'b1;
        end
    end

    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            s_ready_reg     <=  1'b1;
            store_tvalid    <=  1'b0;
            m_tvalid_reg    <=  1'b0;
        end
        else begin
            s_ready_reg     <=  s_ready_early;
            store_tvalid    <=  store_tvalid_next;
            m_tvalid_reg    <=  m_tvalid_reg_next;
        end
    end



    always_ff @ (posedge clk) begin
        if(transfer_in2store) begin
            store_tdata     <=  s_tdata_i;
            store_tlast     <=  s_tlast_i;
            store_tkeep     <=  s_tkeep_i;
        end

        if(transfer_in2out) begin
            m_tdata_reg     <=  s_tdata_i;
            m_tlast_reg     <=  s_tlast_i;
            m_tkeep_reg     <=  s_tkeep_i;
        end
        else if(transfer_store2out) begin
            m_tdata_reg     <=  store_tdata;
            m_tlast_reg     <=  store_tlast;
            m_tkeep_reg     <=  store_tkeep;
        end
    end


    assign m_tdata_o    = m_tdata_reg;
    assign m_tvalid_o   = m_tvalid_reg;
    assign m_tlast_o    = m_tlast_reg;
    assign m_tkeep_o    = m_tkeep_reg;

endmodule