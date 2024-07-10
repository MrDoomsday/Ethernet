class axis_packet;

    rand int len;

    rand    bit     [31:0]      ip_dest; 
    rand    bit     [31:0]      ip_src;//dest - на какой IP пойдет пакет, src - с какого IP пакет будет отправлен
    rand    bit     [15:0]      port_dest; 
    rand    bit     [15:0]      port_src;
    rand    bit     [31:0]      data [];
    rand    bit     [3:0]       keep;
            bit                 last;


    constraint c_packet {
        len > 0;
        len -> {
            data.size() == len;
        }
        keep inside {4'b1111, 4'b1110, 4'b1100, 4'b1000};
        //необходимо обнулять неиспользуемые байты данных (обязательное требования для расчета контрольной суммы)
        ~keep[0] -> data[len-1][7:0] == 8'h0;
        ~keep[1] -> data[len-1][15:8] == 8'h0;
        ~keep[2] -> data[len-1][23:16] == 8'h0;
        ~keep[3] -> data[len-1][31:24] == 8'h0;
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