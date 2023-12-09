module coder64b66b (
    input bit clk,
    input bit reset_n,

//AXI Stream input
    input   bit     [1:0]   s_axis_ttype,//user signal, 2'b11, 2'b00 - illegal
    input   bit     [63:0]  s_axis_tdata,
    input   bit             s_axis_tvalid,
    output  bit             s_axis_tready,

//AXI Stream output
    output   bit     [66:0]  m_axis_tdata,
    output   bit             m_axis_tvalid,
    input    bit             m_axis_tready

);

/**Declaration**/
bit [63:0] m_tdata_old;


/**Logic**/
assign s_axis_tready = m_axis_tready;

always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) m_axis_tvalid <= 1'b0;
    else if(m_axis_tready) m_axis_tvalid <= s_axis_tvalid;
end

//Scrambler polynom G(x) = 1 + x^39 + x^58
always_ff @ (posedge clk) begin
    if(s_axis_tready && s_axis_tvalid) m_axis_tdata <= {s_axis_ttype, s_axis_tdata ^ {m_axis_tdata[24:0], m_tdata_old[63:25]} ^ {m_axis_tdata[5:0], m_tdata_old[63:25]}};
    if(m_axis_tready && m_axis_tvalid) m_tdata_old <= m_axis_tdata;
end
    
endmodule