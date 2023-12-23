module converter_64b_to_66b (
    input bit clk,
    input bit reset_n,

//AXI Stream input
    input   bit     [63:0]  s_axis_tdata,
    input   bit             s_axis_tvalid,
    output  bit             s_axis_tready,

//AXI Stream output
    output   bit     [65:0]  m_axis_tdata,
    output   bit             m_axis_tvalid,
    input    bit             m_axis_tready
);


bit [1:0][63:0] data_pipe;
bit [1:0] valid_pipe;
bit [5:0] point;

assign s_axis_tready = m_axis_tready;


always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) valid_pipe <= 2'b00;
    else if(s_axis_tready && s_axis_tvalid) begin
        valid_pipe[0] <= 1'b1;
        valid_pipe[1] <= valid_pipe[0];
    end
end

always_ff @ (posedge clk) begin
    if(s_axis_tready && s_axis_tvalid) begin
        data_pipe[0] <= s_axis_tdata;
        data_pipe[1] <= data_pipe[0];
    end
end

//****************************************************************************************
//data output*****************************************************************************
always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) point <= 6'h0;
    else if(m_axis_tready && valid_pipe[1]) begin
        if(point < 6'd32) point <= point + 6'd1;
        else point <= 6'h0;
    end
end

always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) m_axis_tvalid <= 1'b0;
    else if(m_axis_tready) m_axis_tvalid <= valid_pipe[1] & (point < 6'd32);
end


always_ff @ (posedge clk) begin
    if(m_axis_tready && valid_pipe[1]) begin
        case(point)
            6'd0:   m_axis_tdata <= {data_pipe[1][1:0], data_pipe[0][63:0]};
            6'd1:   m_axis_tdata <= {data_pipe[1][3:0], data_pipe[0][63:2]};
            6'd2:   m_axis_tdata <= {data_pipe[1][5:0], data_pipe[0][63:4]};
            6'd3:   m_axis_tdata <= {data_pipe[1][7:0], data_pipe[0][63:6]};
            6'd4:   m_axis_tdata <= {data_pipe[1][9:0], data_pipe[0][63:8]};
            6'd5:   m_axis_tdata <= {data_pipe[1][11:0], data_pipe[0][63:10]};
            6'd6:   m_axis_tdata <= {data_pipe[1][13:0], data_pipe[0][63:12]};
            6'd7:   m_axis_tdata <= {data_pipe[1][15:0], data_pipe[0][63:14]};
            6'd8:   m_axis_tdata <= {data_pipe[1][17:0], data_pipe[0][63:16]};
            6'd9:   m_axis_tdata <= {data_pipe[1][19:0], data_pipe[0][63:18]};
            6'd10:   m_axis_tdata <= {data_pipe[1][21:0], data_pipe[0][63:20]};
            6'd11:   m_axis_tdata <= {data_pipe[1][23:0], data_pipe[0][63:22]};
            6'd12:   m_axis_tdata <= {data_pipe[1][25:0], data_pipe[0][63:24]};
            6'd13:   m_axis_tdata <= {data_pipe[1][27:0], data_pipe[0][63:26]};
            6'd14:   m_axis_tdata <= {data_pipe[1][29:0], data_pipe[0][63:28]};
            6'd15:   m_axis_tdata <= {data_pipe[1][31:0], data_pipe[0][63:30]};
            6'd16:   m_axis_tdata <= {data_pipe[1][33:0], data_pipe[0][63:32]};
            6'd17:   m_axis_tdata <= {data_pipe[1][35:0], data_pipe[0][63:34]};
            6'd18:   m_axis_tdata <= {data_pipe[1][37:0], data_pipe[0][63:36]};
            6'd19:   m_axis_tdata <= {data_pipe[1][39:0], data_pipe[0][63:38]};
            6'd20:   m_axis_tdata <= {data_pipe[1][41:0], data_pipe[0][63:40]};
            6'd21:   m_axis_tdata <= {data_pipe[1][43:0], data_pipe[0][63:42]};
            6'd22:   m_axis_tdata <= {data_pipe[1][45:0], data_pipe[0][63:44]};
            6'd23:   m_axis_tdata <= {data_pipe[1][47:0], data_pipe[0][63:46]};
            6'd24:   m_axis_tdata <= {data_pipe[1][49:0], data_pipe[0][63:48]};
            6'd25:   m_axis_tdata <= {data_pipe[1][51:0], data_pipe[0][63:50]};
            6'd26:   m_axis_tdata <= {data_pipe[1][53:0], data_pipe[0][63:52]};
            6'd27:   m_axis_tdata <= {data_pipe[1][55:0], data_pipe[0][63:54]};
            6'd28:   m_axis_tdata <= {data_pipe[1][57:0], data_pipe[0][63:56]};
            6'd29:   m_axis_tdata <= {data_pipe[1][59:0], data_pipe[0][63:58]};
            6'd30:   m_axis_tdata <= {data_pipe[1][61:0], data_pipe[0][63:60]};
            6'd31:   m_axis_tdata <= {data_pipe[1][63:0], data_pipe[0][63:62]};
            default: m_axis_tdata <= {data_pipe[1][1:0], data_pipe[0][63:0]};
        endcase
    end
end


endmodule