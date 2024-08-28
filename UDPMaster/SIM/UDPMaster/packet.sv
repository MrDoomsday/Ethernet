//`include "udp_master_pkg.sv"
import udp_master_pkg::*;

class axis_packet #(
    parameter ID_WIDTH = 1
);

    rand    int                     len;
    rand    type_pkt_t              type_pkt;//тип пакета для генерации
    
    rand    bit     [ID_WIDTH-1:0]  id;
    rand    bit     [31:0]          data [];
    rand    bit     [3:0]           keep;
            bit                     last;


    //адреса назначения
    bit [47:0] mac_board;
    bit [31:0] ip_board;
    bit [15:0] port_board;

    //адреса виртуального источника
    rand bit [47:0] mac_src;
    rand bit [31:0] ip_src;
    rand bit [15:0] port_src;

    /*
        Инициализация полей, который будут необходимы для ARP-запросов и пакетов типа Eth2AXI
    */
    virtual function void set_src_parameter(logic [47:0] mac_board, logic [31:0] ip_board, logic [15:0] port_board);
        this.mac_board = mac_board;
        this.ip_board = ip_board;
        this.port_board = port_board;
    endfunction




    constraint c_type_pkt {
        type_pkt dist {ARP := 1, /*Eth2AXI := 10, */RAW := 100};
        //type_pkt inside {ARP/*, Eth2AXI := 10, RAW := 100*/};
    }


    constraint c_packet {
        type_pkt == ARP -> {
            //len == 60;//60 bytes in ARP packet
            data.size() == 11;

            mac_src < 48'hFFFFFFFFFFFF;
            ip_src < 32'hFFFFFFFF;

            //broadcast mac
            data[0] == 32'hFFFFFFFF;
            data[1] == {8'hFF, 8'hFF, mac_src[47:40], mac_src[39:32]};
            data[2] == {mac_src[31:24], mac_src[23:16], mac_src[15:8], mac_src[7:0]};
            data[3] == {16'h0806, 8'h00, 8'h01};
            data[4] == {8'h08, 8'h00, 8'h06, 8'h04};
            data[5] == {8'h00, 8'h01, mac_src[47:40], mac_src[39:32]};
            data[6] == {mac_src[31:24], mac_src[23:16], mac_src[15:8], mac_src[7:0]};
            //Sender IP address
            data[7] == {ip_src[31:24], ip_src[23:16], ip_src[15:8], ip_src[7:0]};
            //Target MAC address
            data[8] == {8'b0, 8'h0, 8'h0, 8'h0};
            data[9] == {8'h0, 8'h0, ip_board[31:24], ip_board[23:16]};
            data[10] == {ip_board[15:8], ip_board[7:0], 8'h0, 8'h0};
            keep == 4'b1100;
        }

        // type_pkt == type_pkt_t'(Eth2AXI) -> {

        // }

        type_pkt == RAW -> {
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
    }

endclass
