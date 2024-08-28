//  Interface: stream_intf
//
    interface stream_intf #(parameter ID_WIDTH = 1) (
            input bit clk,
            input bit reset_n
        );

        logic       [ID_WIDTH-1:0]  tid;
        logic       [31:0]          tdata;
        logic                       tlast;
        logic                       tvalid;
        logic       [3:0]           tkeep;
        logic                       tready;


        SVA_CHECK_STABLE_VLD: assert property (
            @(posedge clk) disable iff(!reset_n) 
            tvalid & ~tready |-> ##1 tvalid
        ) else $error("SVA error: VALID change 1->0 for ready is equal to 0");

        SVA_CHECK_STABLE_PKT: assert property (
            @(posedge clk) disable iff(!reset_n)
            tvalid & ~tready |-> ##1 $stable({tid, tdata, tlast, tkeep})
        ) else $error("SVA error: tid, tdata, tlast or tkeep change for valid & !ready");

    endinterface: stream_intf


    interface s_axil_intf (
        input bit clk,
        input bit reset_n
    );
    
        logic   [6:0]       awaddr;
        logic   [2:0]       awprot;
        logic               awvalid;
        logic               awready;
        logic   [31:0]      wdata;
        logic   [3:0]       wstrb;
        logic               wvalid;
        logic               wready;
        logic   [1:0]       bresp;
        logic               bvalid;
        logic               bready;
        logic   [6:0]       araddr;
        logic   [2:0]       arprot;
        logic               arvalid;
        logic               arready;
        logic   [31:0]      rdata;
        logic   [1:0]       rresp;
        logic               rvalid;
        logic               rready;

    endinterface