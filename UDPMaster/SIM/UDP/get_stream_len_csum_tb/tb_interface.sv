//  Interface: stream_intf
//
    interface stream_intf (
            input bit clk,
            input bit reset_n
        );

        logic       [31:0]      ip_dest, ip_src;//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
        logic       [15:0]      port_dest, port_src;
    
        logic       [15:0]      csum;//только для выходного порта
        logic       [15:0]      len;//только для выходного порта

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

        SVA_CHECK_STABLE_HEADER: assert property (
            @(posedge clk) disable iff(!reset_n)
            tvalid & ~tready |-> ##1 $stable({ip_dest, ip_src, port_dest, port_src})
        ) else $error("SVA error: IP/UDP header not stable for ready=0");

    endinterface: stream_intf