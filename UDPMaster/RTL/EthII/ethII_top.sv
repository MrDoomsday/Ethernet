module ethII_top (
    input       logic clk,
    input       logic reset_n,


    //ARP payload
    input       logic   [47:0]  arp_mac_dest_i, 
                                arp_mac_src_i,
    input       logic   [15:0]  arp_mac_type_i,
    input       logic           arp_mac_vld_i,
    output      logic           arp_mac_rdy_o,

    input       logic   [31:0]  arp_tdata_i,
    input       logic           arp_tvld_i,
    input       logic           arp_tlast_i,
	input       logic   [3:0]   arp_tkeep_i, 
    output      logic           arp_trdy_o,

    //IPv4 payload
    input       logic   [47:0]  ipv4_mac_dest_i, 
                                ipv4_mac_src_i,
    input       logic   [15:0]  ipv4_mac_type_i,
    input       logic           ipv4_mac_vld_i,
    output      logic           ipv4_mac_rdy_o,

    input       logic   [31:0]  ipv4_tdata_i,
    input       logic           ipv4_tvld_i,
    input       logic           ipv4_tlast_i,
	input       logic   [3:0]   ipv4_tkeep_i, 
    output      logic           ipv4_trdy_o,


    output      logic   [31:0]  ethii_ip_udp_tdata_o,
    output      logic           ethii_ip_udp_tvld_o,
    output      logic           ethii_ip_udp_tlast_o,
    output      logic   [3:0]   ethii_ip_udp_tkeep_o,
    input       logic           ethii_ip_udp_rdy_i

);



/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/


    wire    [47:0]  hdr_mac_dest, hdr_mac_src;
    wire    [15:0]  hdr_mac_type;
    wire            hdr_mac_vld;
    reg             hdr_mac_rdy;
    wire    [31:0]  user_tdata;
    wire            user_tvld;
    wire            user_tlast;
    wire    [3:0]   user_tkeep;
    reg             user_trdy;



/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    ethII_mux ethII_mux_inst (
        .clk            (clk),
        .reset_n        (reset_n),
        .arp_mac_dest_i (arp_mac_dest_i),
        .arp_mac_src_i  (arp_mac_src_i),
        .arp_mac_type_i (arp_mac_type_i),
        .arp_mac_vld_i  (arp_mac_vld_i),
        .arp_mac_rdy_o  (arp_mac_rdy_o),
        .arp_tdata_i    (arp_tdata_i),
        .arp_tvld_i     (arp_tvld_i),
        .arp_tlast_i    (arp_tlast_i),
        .arp_tkeep_i    (arp_tkeep_i),
        .arp_trdy_o     (arp_trdy_o),
        .ipv4_mac_dest_i(ipv4_mac_dest_i),
        .ipv4_mac_src_i (ipv4_mac_src_i),
        .ipv4_mac_type_i(ipv4_mac_type_i),
        .ipv4_mac_vld_i (ipv4_mac_vld_i),
        .ipv4_mac_rdy_o (ipv4_mac_rdy_o),
        .ipv4_tdata_i   (ipv4_tdata_i),
        .ipv4_tvld_i    (ipv4_tvld_i),
        .ipv4_tlast_i   (ipv4_tlast_i),
        .ipv4_tkeep_i   (ipv4_tkeep_i),
        .ipv4_trdy_o    (ipv4_trdy_o),

        .hdr_mac_dest_o (hdr_mac_dest),
        .hdr_mac_src_o  (hdr_mac_src),
        .hdr_mac_type_o (hdr_mac_type),
        .hdr_mac_vld_o  (hdr_mac_vld),
        .hdr_mac_rdy_i  (hdr_mac_rdy),
        .user_tdata_o   (user_tdata),
        .user_tvld_o    (user_tvld),
        .user_tlast_o   (user_tlast),
        .user_tkeep_o   (user_tkeep),
        .user_trdy_i    (user_trdy)
    );

    ethII_packer  ethII_packer_inst (
        .clk            (clk),
        .reset_n        (reset_n),
        .hdr_mac_dest_i (hdr_mac_dest),
        .hdr_mac_src_i  (hdr_mac_src),
        .hdr_mac_type_i (hdr_mac_type),
        .hdr_mac_vld_i  (hdr_mac_vld),
        .hdr_mac_rdy_o  (hdr_mac_rdy),
        .user_tdata_i   (user_tdata),
        .user_tvld_i    (user_tvld),
        .user_tlast_i   (user_tlast),
        .user_tkeep_i   (user_tkeep),
        .user_trdy_o    (user_trdy),

        .ethii_ip_udp_tdata_o   (ethii_ip_udp_tdata_o),
        .ethii_ip_udp_tvld_o    (ethii_ip_udp_tvld_o),
        .ethii_ip_udp_tlast_o   (ethii_ip_udp_tlast_o),
        .ethii_ip_udp_tkeep_o   (ethii_ip_udp_tkeep_o),
        .ethii_ip_udp_rdy_i     (ethii_ip_udp_rdy_i)
    );
endmodule