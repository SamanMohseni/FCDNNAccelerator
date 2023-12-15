`timescale 1ns / 1ps

module CoreCover (
	input wire clk_pll,
	input wire in,
	output wire out
	);
	
	// Inputs
	wire [26:0] mul_in_1_single;
	wire [431:0] mul_in_1_pack;
	wire [431:0] mul_in_2_pack;
	wire [431:0] add_in_1_pack;
	wire [431:0] add_in_2_pack;
	wire [26:0] add_in_2_single;
	wire [7:0] exp;
	wire [1:0] mul_in_1_mux_sel_left;
	wire [1:0] mul_in_1_mux_sel_right;
	wire [1:0] mul_in_2_mux_sel;
	wire sigmoid_pipe_mux_sel;
	wire [1:0] sigmoid_pipe_extend_controll;
	wire add_in_1_mux_sel_left;
	wire [1:0] add_in_1_mux_sel_right;
	wire [1:0] add_in_2_mux_sel;
	wire [1:0] add_in_2_mid_mux_sel;
	wire sigmoid_output_mux_sel;

	// Outputs
	wire [431:0] mul_out_pack;
	wire [431:0] add_out_pack;
	wire [26:0] add_out_single;
	wire [26:0] sigmoid;
	
	reg [1806 : 0] mix;
	
	assign mul_in_1_single = mix[26 : 0];
	assign mul_in_1_pack = mix[458 : 27];
	assign mul_in_2_pack = mix[890 : 459];
	assign add_in_1_pack = mix[1322 : 891];
	assign add_in_2_pack = mix[1754 : 1323];
	assign add_in_2_single = mix[1781 : 1755];
	assign exp = mix[1789 : 1782];
	assign mul_in_1_mux_sel_left = mix[1791 : 1790];
	assign mul_in_1_mux_sel_right = mix[1793 : 1792];
	assign mul_in_2_mux_sel = mix[1795 : 1794];
	assign sigmoid_pipe_mux_sel = mix[1796 : 1796];
	assign sigmoid_pipe_extend_controll = mix[1798 : 1797];
	assign add_in_1_mux_sel_left = mix[1799 : 1799];
	assign add_in_1_mux_sel_right = mix[1801 : 1800];
	assign add_in_2_mux_sel = mix[1803 : 1802];
	assign add_in_2_mid_mux_sel = mix[1805 : 1804];
	assign sigmoid_output_mux_sel = mix[1806 : 1806];

	
	Core core (
		.clk_pll(clk_pll), 
		.mul_in_1_single(mul_in_1_single), 
		.mul_in_1_pack(mul_in_1_pack), 
		.mul_in_2_pack(mul_in_2_pack), 
		.add_in_1_pack(add_in_1_pack), 
		.add_in_2_pack(add_in_2_pack), 
		.add_in_2_single(add_in_2_single), 
		.exp(exp), 
		.mul_in_1_mux_sel_left(mul_in_1_mux_sel_left), 
		.mul_in_1_mux_sel_right(mul_in_1_mux_sel_right), 
		.mul_in_2_mux_sel(mul_in_2_mux_sel), 
		.sigmoid_pipe_mux_sel(sigmoid_pipe_mux_sel), 
		.sigmoid_pipe_extend_controll(sigmoid_pipe_extend_controll), 
		.add_in_1_mux_sel_left(add_in_1_mux_sel_left), 
		.add_in_1_mux_sel_right(add_in_1_mux_sel_right), 
		.add_in_2_mux_sel(add_in_2_mux_sel), 
		.add_in_2_mid_mux_sel(add_in_2_mid_mux_sel), 
		.sigmoid_output_mux_sel(sigmoid_output_mux_sel), 
		.mul_out_pack(mul_out_pack), 
		.add_out_pack(add_out_pack), 
		.add_out_single(add_out_single), 
		.sigmoid(sigmoid)
	);
	
	//set inputs:
	always @(posedge clk_pll)
	begin
		mix = {mix[1805:0], in};
	end
	
	//set outputs:
	assign out = (^mul_out_pack) ^ (^add_out_pack) ^ (^add_out_single) ^ (^sigmoid);
	
endmodule
