// Quartus Prime Verilog Template
// True Dual Port RAM with single clock

module dual_port_ram
#(
	parameter DATA_WIDTH=8, 
	parameter ADDR_WIDTH=6
)
(
	input ready,
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk_a, clk_b,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

(* ramstyle = "M4K" *) reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	
/*
initial 
	for(integer i = 0; i < 2**ADDR_WIDTH; i++)
		ram[i] = 'h0;
*/	
	
	// Port A 
	always @ (posedge clk_a)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	
	

	// Port B 
	always @ (posedge clk_b)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
		end 
/*			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end */
	end

	
always_ff @ (posedge clk_b)
	if(ready)
		q_b <= ram[addr_b];
		

endmodule
