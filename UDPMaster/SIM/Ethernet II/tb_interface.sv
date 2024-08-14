//  Interface: mac_intf
//
    interface mac_intf (
            input bit clk,
            input bit reset_n
        );

        logic       [47:0]      dest, src;//dest - на какой MAC пойдет пакет, src - с какого MAC пакет будет отправлен
        logic       [15:0]      ttype;
        logic                   vld;
        logic                   rdy;

        SVA_CHECK_STABLE_HEADER: assert property (
            @(posedge clk) disable iff(!reset_n)
            vld & ~rdy |-> ##1 $stable({dest, src, ttype, vld})
        ) else $error("SVA error: MAC header not stable for ready=0");

    endinterface: mac_intf


//  Interface: stream_intf
//
    interface stream_intf (
            input bit clk,
            input bit reset_n
        );

    
        logic       [31:0]      tdata;
        logic                   tlast;
        logic                   tvalid;
        logic       [3:0]       tkeep;
        logic                   tready;


        SVA_CHECK_STABLE_VLD: assert property (
            @(posedge clk) disable iff(!reset_n) 
            tvalid & ~tready |-> ##1 tvalid
        ) else $error("SVA error: VALID change 1->0 for ready is equal to 0");

        SVA_CHECK_STABLE_PKT: assert property (
            @(posedge clk) disable iff(!reset_n)
            tvalid & ~tready |-> ##1 $stable({tdata, tlast, tkeep})
        ) else $error("SVA error: tdata, tlast or tkeep change for valid & !ready");

    endinterface: stream_intf
