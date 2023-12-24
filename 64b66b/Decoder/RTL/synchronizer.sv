module synchronizer (
    input bit clk,
    input bit reset_n,

//AXI Stream input
    input   bit     [65:0]  s_axis_tdata,
    input   bit             s_axis_tvalid,
    output  bit             s_axis_tready,

//AXI Stream output
    output   bit     [1:0]   m_axis_ttype,//type word, 2'b11, 2'b00 - illegal
    output   bit     [63:0]  m_axis_tdata,
    output   bit             m_axis_tvalid,
    input    bit             m_axis_tready
);

bit [65:0] data_pipe;

enum bit [1:0] {
    search_sync,//ищем хотя-бы одно вхождение синхросигнала
    pre_sync, 
    sync
} state, state_next;

//первое вхождение синхромаркера
bit [9:0] search_first_sync_cnt, search_first_sync_cnt_next;//необходим для поиска первого синхромаркера
wire search_first_sync_max;//если мы досчитали до лимита (1023), то сбрасываемся и выставляем следующую позицию на сдвиговом регистре

//проверка правильности найденного вхождения - если подряд придет 1024 синхромаркера - считаем синхронизацию успешной
bit [9:0] counter_pre_sync, counter_pre_sync_next;//Счетчик успешных синхронизаций
wire counter_pre_sync_max;
bit sync_ok;

//для сдвигового регистра
bit [6:0] pos_sync;//указывает позицию смещения в сдвиговом регистре
bit [63:0] data_sync;

//pipeline
always_ff @ (posedge clk) begin
    if(s_axis_tready && s_axis_tvalid) data_pipe <= s_axis_tdata;
end

//shift register
always_ff @ (posedge clk) begin
    if(s_axis_tready && s_axis_tvalid) begin
        case(pos_sync)
            7'd0: data_sync <= data_pipe;
            7'd1: data_sync <= {s_axis_tdata[0], data_pipe[65:1]};
            7'd2: data_sync <= {s_axis_tdata[1:0], data_pipe[65:2]};
            7'd3: data_sync <= {s_axis_tdata[2:0], data_pipe[65:3]};
            7'd4: data_sync <= {s_axis_tdata[3:0], data_pipe[65:4]};
            7'd5: data_sync <= {s_axis_tdata[4:0], data_pipe[65:5]};
            7'd6: data_sync <= {s_axis_tdata[5:0], data_pipe[65:6]};
            7'd7: data_sync <= {s_axis_tdata[6:0], data_pipe[65:7]};
            7'd8: data_sync <= {s_axis_tdata[7:0], data_pipe[65:8]};
            7'd9: data_sync <= {s_axis_tdata[8:0], data_pipe[65:9]};
            7'd10: data_sync <= {s_axis_tdata[9:0], data_pipe[65:10]};
            7'd11: data_sync <= {s_axis_tdata[10:0], data_pipe[65:11]};
            7'd12: data_sync <= {s_axis_tdata[11:0], data_pipe[65:12]};
            7'd13: data_sync <= {s_axis_tdata[12:0], data_pipe[65:13]};
            7'd14: data_sync <= {s_axis_tdata[13:0], data_pipe[65:14]};
            7'd15: data_sync <= {s_axis_tdata[14:0], data_pipe[65:15]};
            7'd16: data_sync <= {s_axis_tdata[15:0], data_pipe[65:16]};
            7'd17: data_sync <= {s_axis_tdata[16:0], data_pipe[65:17]};
            7'd18: data_sync <= {s_axis_tdata[17:0], data_pipe[65:18]};
            7'd19: data_sync <= {s_axis_tdata[18:0], data_pipe[65:19]};
            7'd20: data_sync <= {s_axis_tdata[19:0], data_pipe[65:20]};
            7'd21: data_sync <= {s_axis_tdata[20:0], data_pipe[65:21]};
            7'd22: data_sync <= {s_axis_tdata[21:0], data_pipe[65:22]};
            7'd23: data_sync <= {s_axis_tdata[22:0], data_pipe[65:23]};
            7'd24: data_sync <= {s_axis_tdata[23:0], data_pipe[65:24]};
            7'd25: data_sync <= {s_axis_tdata[24:0], data_pipe[65:25]};
            7'd26: data_sync <= {s_axis_tdata[25:0], data_pipe[65:26]};
            7'd27: data_sync <= {s_axis_tdata[26:0], data_pipe[65:27]};
            7'd28: data_sync <= {s_axis_tdata[27:0], data_pipe[65:28]};
            7'd29: data_sync <= {s_axis_tdata[28:0], data_pipe[65:29]};
            7'd30: data_sync <= {s_axis_tdata[29:0], data_pipe[65:30]};
            7'd31: data_sync <= {s_axis_tdata[30:0], data_pipe[65:31]};
            7'd32: data_sync <= {s_axis_tdata[31:0], data_pipe[65:32]};
            7'd33: data_sync <= {s_axis_tdata[32:0], data_pipe[65:33]};
            7'd34: data_sync <= {s_axis_tdata[33:0], data_pipe[65:34]};
            7'd35: data_sync <= {s_axis_tdata[34:0], data_pipe[65:35]};
            7'd36: data_sync <= {s_axis_tdata[35:0], data_pipe[65:36]};
            7'd37: data_sync <= {s_axis_tdata[36:0], data_pipe[65:37]};
            7'd38: data_sync <= {s_axis_tdata[37:0], data_pipe[65:38]};
            7'd39: data_sync <= {s_axis_tdata[38:0], data_pipe[65:39]};
            7'd40: data_sync <= {s_axis_tdata[39:0], data_pipe[65:40]};
            7'd41: data_sync <= {s_axis_tdata[40:0], data_pipe[65:41]};
            7'd42: data_sync <= {s_axis_tdata[41:0], data_pipe[65:42]};
            7'd43: data_sync <= {s_axis_tdata[42:0], data_pipe[65:43]};
            7'd44: data_sync <= {s_axis_tdata[43:0], data_pipe[65:44]};
            7'd45: data_sync <= {s_axis_tdata[44:0], data_pipe[65:45]};
            7'd46: data_sync <= {s_axis_tdata[45:0], data_pipe[65:46]};
            7'd47: data_sync <= {s_axis_tdata[46:0], data_pipe[65:47]};
            7'd48: data_sync <= {s_axis_tdata[47:0], data_pipe[65:48]};
            7'd49: data_sync <= {s_axis_tdata[48:0], data_pipe[65:49]};
            7'd50: data_sync <= {s_axis_tdata[49:0], data_pipe[65:50]};
            7'd51: data_sync <= {s_axis_tdata[50:0], data_pipe[65:51]};
            7'd52: data_sync <= {s_axis_tdata[51:0], data_pipe[65:52]};
            7'd53: data_sync <= {s_axis_tdata[52:0], data_pipe[65:53]};
            7'd54: data_sync <= {s_axis_tdata[53:0], data_pipe[65:54]};
            7'd55: data_sync <= {s_axis_tdata[54:0], data_pipe[65:55]};
            7'd56: data_sync <= {s_axis_tdata[55:0], data_pipe[65:56]};
            7'd57: data_sync <= {s_axis_tdata[56:0], data_pipe[65:57]};
            7'd58: data_sync <= {s_axis_tdata[57:0], data_pipe[65:58]};
            7'd59: data_sync <= {s_axis_tdata[58:0], data_pipe[65:59]};
            7'd60: data_sync <= {s_axis_tdata[59:0], data_pipe[65:60]};
            7'd61: data_sync <= {s_axis_tdata[60:0], data_pipe[65:61]};
            7'd62: data_sync <= {s_axis_tdata[61:0], data_pipe[65:62]};
            7'd63: data_sync <= {s_axis_tdata[62:0], data_pipe[65:63]};
            7'd64: data_sync <= {s_axis_tdata[63:0], data_pipe[65:64]};
            7'd65: data_sync <= {s_axis_tdata[64:0], data_pipe[65]};
            default: data_sync <= data_pipe;
        endcase
    end
end

assign sync_ok = data_sync[65] ^ data_sync[64];//1 - 2'b01, 2'b10, 0 - 2'b00, 2'b11;

always_ff @(posedge clk or negedge reset_n) begin
    if(!reset_n) state <= search_sync;
    else state <= state_next;
end


always_comb begin
    state_next = state;
    search_first_sync_cnt_next = search_first_sync_cnt;
    counter_pre_sync_next = counter_pre_sync;
    s_axis_tready = 1'b1;

    case(state)
        search_sync: begin
            counter_pre_sync_next = 10'h0;
            if(s_axis_tvalid) begin
                search_first_sync_cnt_next = search_first_sync_cnt + 10'h1;
                if(sync_ok && search_first_sync_max) state_next = pre_sync;
            end
        end

        pre_sync: begin
            search_first_sync_cnt_next = 10'h0;
            if(s_axis_tvalid) begin
                counter_pre_sync_next = counter_pre_sync + 10'h1;
                if(!sync_ok) state_next = search_sync;
                else if(sync_ok && counter_pre_sync_max) state_next = sync;
            end
        end

        sync: begin
            s_axis_tready = m_axis_tready;
            if(s_axis_tvalid && !sync_ok) state_next = search_sync;
        end

        default: begin
            state_next = search_sync;
        end
    endcase
end


assign search_first_sync_max = &search_first_sync_cnt;
assign counter_pre_sync_max = &counter_pre_sync;


always_ff @ (posedge clk) begin
    search_first_sync_cnt <= search_first_sync_cnt_next;
    counter_pre_sync <= counter_pre_sync_next;
end

always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) pos_sync <= 7'h0;
    else if(s_axis_tvalid && !sync_ok && ((state == search_sync) && search_first_sync_max || (state == pre_sync))) begin
        if(pos_sync < 7'd65) pos_sync <= pos_sync + 7'h1;
        else pos_sync <= 7'h0;
    end
end



//output data
always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) m_axis_tvalid <= 1'b0;
    else if(m_axis_tready) m_axis_tvalid <= s_axis_tvalid & (state == sync);
end

always_ff @ (posedge clk) begin
    if(m_axis_tready) {m_axis_ttype, m_axis_tdata} <= data_sync;
end

endmodule