class axis_packet;

    rand int len;

    rand    bit     [31:0]      ip_dest; 
    rand    bit     [31:0]      ip_src;//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    rand    bit     [15:0]      port_dest; 
    rand    bit     [15:0]      port_src;
    rand    bit     [31:0]      data [];
    rand    bit     [3:0]       keep;
            bit                 last;

            bit     [15:0]      pkt_csum;
            bit     [15:0]      pkt_len;


    constraint c_packet {
        len > 0;
        len -> {
            data.size() == len;
        }  
    }

    constraint c_ip_fields {
        ip_dest > 0;
        ip_src > 0;
    }


    constraint c_udp_fields {
        port_dest > 0;
        port_src > 0;
    }


endclass