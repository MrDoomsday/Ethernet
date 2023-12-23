module decoder64b66b (
    input bit clk,
    input bit reset_n,

//AXI Stream input
    input   bit     [63:0]  s_axis_tdata,
    input   bit             s_axis_tvalid,
    output  bit             s_axis_tready,

//AXI Stream output
    output   bit     [1:0]   m_axis_ttype,//utype word, 2'b11, 2'b00 - illegal
    output   bit     [63:0]  m_axis_tdata,
    output   bit             m_axis_tvalid,
    input    bit             m_axis_tready

);

//connect converter to synchronizer
bit     [65:0]  conv_to_sync_tdata;
bit             conv_to_sync_tvalid;
bit             conv_to_sync_tready;

//connect synchronizer to descrambler
bit     [1:0]   sync_to_desc_ttype;
bit     [63:0]  sync_to_desc_tdata;
bit             sync_to_desc_tvalid;
bit             sync_to_desc_tready;



converter_64b_to_66b converter_64b_to_66b_inst (
    .clk            (clk),
    .reset_n        (reset_n),

//AXI Stream input
    .s_axis_tdata   (s_axis_tdata),
    .s_axis_tvalid  (s_axis_tvalid),
    .s_axis_tready  (s_axis_tready),

//AXI Stream output
    .m_axis_tdata   (conv_to_sync_tdata),
    .m_axis_tvalid  (conv_to_sync_tvalid),
    .m_axis_tready  (conv_to_sync_tready)
);


synchronizer synchronizer_inst(
    .clk            (clk),
    .reset_n        (reset_n),

//AXI Stream input
    .s_axis_tdata   (conv_to_sync_tdata),
    .s_axis_tvalid  (conv_to_sync_tvalid),
    .s_axis_tready  (conv_to_sync_tready),

//AXI Stream output
    .m_axis_ttype   (sync_to_desc_ttype),//type word, 2'b11, 2'b00 - illegal
    .m_axis_tdata   (sync_to_desc_tdata),
    .m_axis_tvalid  (sync_to_desc_tvalid),
    .m_axis_tready  (sync_to_desc_tready)
);


descrambler descrambler_inst(
    .clk            (clk),
    .reset_n        (reset_n),

//AXI Stream input
    .s_axis_ttype   (sync_to_desc_ttype),//type word, 2'b11, 2'b00 - illegal
    .s_axis_tdata   (sync_to_desc_tdata),
    .s_axis_tvalid  (sync_to_desc_tvalid),
    .s_axis_tready  (sync_to_desc_tready),

//AXI Stream output
    .m_axis_ttype   (m_axis_ttype),//type word, 2'b11, 2'b00 - illegal
    .m_axis_tdata   (m_axis_tdata),
    .m_axis_tvalid  (m_axis_tvalid),
    .m_axis_tready  (m_axis_tready)
);


endmodule