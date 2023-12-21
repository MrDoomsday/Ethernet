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



endmodule