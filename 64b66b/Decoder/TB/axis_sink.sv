interface axis_sink(input bit clk, input bit reset_n);
    bit [63:0] tdata;
    bit tvalid;
    bit tready;
endinterface