interface axis_source(input bit clk, input bit reset_n);
    bit [1:0] ttype;
    bit [63:0] tdata;
    bit tvalid;
    bit tready;
endinterface