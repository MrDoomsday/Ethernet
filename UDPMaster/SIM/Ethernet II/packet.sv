class mac_packet;


    rand    bit     [47:0]      dest;
    rand    bit     [47:0]      src;//dest - на какой MAC пойдет пакет, src - с какого MAC пакет будет отправлен


    constraint c_mac_fields {
        dest > 0;
        src > 0;
    }

endclass

class axis_packet;

    rand int len;


    rand    bit     [31:0]      data [];
    rand    bit     [3:0]       keep;
            bit                 last;


    constraint c_packet {
        len > 0;
        len -> {
            data.size() == len;
        }
        keep inside {4'b1111, 4'b1110, 4'b1100, 4'b1000};
        //необходимо обнулять неиспользуемые байты данных
        ~keep[0] -> data[len-1][7:0] == 8'h0;
        ~keep[1] -> data[len-1][15:8] == 8'h0;
        ~keep[2] -> data[len-1][23:16] == 8'h0;
        ~keep[3] -> data[len-1][31:24] == 8'h0;
    }


endclass
