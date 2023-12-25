module descrambler (
    input bit clk,
    input bit reset_n,

//AXI Stream input
    input   bit     [1:0]   s_axis_ttype,//user signal, 2'b11, 2'b00 - illegal
    input   bit     [63:0]  s_axis_tdata,
    input   bit             s_axis_tvalid,
    output  bit             s_axis_tready,

//AXI Stream output
    output   bit     [1:0]   m_axis_ttype,//user signal, 2'b11, 2'b00 - illegal
    output   bit     [63:0]  m_axis_tdata,
    output   bit             m_axis_tvalid,
    input    bit             m_axis_tready

);

bit [63:0] s_axis_tdata_old;
bit s_axis_tvalid_old;


//Scrambler polynom G(x) = 1 + x^39 + x^58
function bit [63:0] coder_6466b(bit [63:0] data_in, bit [63:0] data_old);
    bit [127:0] concat_bit; 
    bit [63:0] result;
    
    concat_bit = {64'h0, data_old};
    for(int i = 0; i < 64; i++) begin
        concat_bit[64+i] = data_in[i] ^ concat_bit[64+i-39] ^ concat_bit[64+i-58];
    end

    return concat_bit[127:64];
endfunction



always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        s_axis_tdata_old <= 64'h0;
        s_axis_tvalid_old <= 1'b0;
    end
    else if(s_axis_tready && s_axis_tvalid) begin
        s_axis_tdata_old <= s_axis_tdata;
        s_axis_tvalid_old <= 1'b1;
    end
end


always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) m_axis_tvalid <= 1'b0;
    else if(m_axis_tready) m_axis_tvalid <= s_axis_tvalid & s_axis_tvalid_old;
end

always_ff @ (posedge clk) begin
    if(m_axis_tready) begin
        m_axis_ttype <= s_axis_ttype;
        m_axis_tdata <= coder_6466b(s_axis_tdata, s_axis_tdata_old);
    end
end

assign s_axis_tready = m_axis_tready;

endmodule