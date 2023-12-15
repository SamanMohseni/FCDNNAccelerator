`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:57:05 06/22/2018
// Design Name:   Core
// Module Name:   C:/Users/Saman/Documents/Xilinx Projects/NeuroChip/NeuroChip/CoreTest.v
// Project Name:  NeuroChip
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Core
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CoreTest;

	// Inputs
	reg clk_pll;
	reg [26:0] mul_in_1_single;
	reg [431:0] mul_in_1_pack;
	reg [431:0] mul_in_2_pack;
	reg [431:0] add_in_1_pack;
	reg [431:0] add_in_2_pack;
	reg [26:0] add_in_2_single;
	reg [7:0] exp;
	reg [1:0] mul_in_1_mux_sel_left;
	reg [1:0] mul_in_1_mux_sel_right;
	reg [1:0] mul_in_2_mux_sel;
	reg sigmoid_pipe_mux_sel;
	reg [1:0] sigmoid_pipe_extend_controll;
	reg add_in_1_mux_sel_left;
	reg [1:0] add_in_1_mux_sel_right;
	reg [1:0] add_in_2_mux_sel;
	reg [1:0] add_in_2_mid_mux_sel;
	reg sigmoid_output_mux_sel;

	// Outputs
	wire [431:0] mul_out_pack;
	wire [431:0] add_out_pack;
	wire [26:0] add_out_single;
	wire [26:0] sigmoid;

	// Instantiate the Unit Under Test (UUT)
	Core uut (
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

	initial begin
		// Initialize Inputs
		clk_pll = 0;
		mul_in_1_single = 0;
		mul_in_1_pack = 0;
		mul_in_2_pack = 0;
		add_in_1_pack = 0;
		add_in_2_pack = 0;
		add_in_2_single = 0;
		exp = 0;
		mul_in_1_mux_sel_left = 0;
		mul_in_1_mux_sel_right = 0;
		mul_in_2_mux_sel = 0;
		sigmoid_pipe_mux_sel = 0;
		sigmoid_pipe_extend_controll = 0;
		add_in_1_mux_sel_left = 0;
		add_in_1_mux_sel_right = 0;
		add_in_2_mux_sel = 0;
		add_in_2_mid_mux_sel = 0;
		sigmoid_output_mux_sel = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		//mul_in_1_pack = 432'b0_00000010_100100110011001100_0_00000001_110100110011001100_0_00000001_101101110111011101_0_00000001_101010011001100110_0_00000001_101000010100011110_0_00000001_100110111011101110_0_00000001_100101111100010101_0_00000001_100101001100110011_0_00000001_100100100111110100_0_00000001_100100001010001111_0_00000001_100011110010000010_0_00000001_100011011101110111_0_00000001_100011001100110011_0_00000001_100010111110001010_0_00000001_100010110001011111_0_00000001_100010100110011001;
		//mul_in_2_pack = 432'b0_00000000_101001100110011001_0_00000001_100100110011001100_0_00000001_110100110011001100_0_00000010_100010011001100110_0_00000010_101010011001100110_0_00000010_110010011001100110_0_00000010_111010011001100110_0_00000011_100001001100110011_0_00000011_100101001100110011_0_00000011_101001001100110011_0_00000011_101101001100110011_0_00000011_110001001100110011_0_00000011_110101001100110011_0_00000011_111001001100110011_0_00000011_111101001100110011_0_00000100_100000100110011001;
		//add_in_2_pack = 432'b0_00000010_101000000000000000_0_00000010_111000000000000000_0_00000011_100100000000000000_0_00000011_101100000000000000_0_00000011_110100000000000000_0_00000011_111100000000000000_0_00000100_100010000000000000_0_00000100_100110000000000000_0_00000100_101010000000000000_0_00000100_101110000000000000_0_00000100_110010000000000000_0_00000100_110110000000000000_0_00000100_111010000000000000_0_00000100_111110000000000000_0_00000101_100001000000000000_0_00000101_100011000000000000;
		//add_in_2_single = 27'b0_00000010_110000000000000000;
		
		mul_in_1_mux_sel_left = 0;
		mul_in_1_mux_sel_right = 0;
		mul_in_2_mux_sel = 1;
		sigmoid_pipe_mux_sel = 0;
		sigmoid_pipe_extend_controll = 3;
		add_in_1_mux_sel_left = 1;
		add_in_1_mux_sel_right = 1;
		add_in_2_mux_sel = 1;
		add_in_2_mid_mux_sel = 1;
		sigmoid_output_mux_sel = 1;
		
		exp = -2;
		mul_in_1_single = 27'b0_00000000_010110000000100001;
		#20;
		mul_in_1_single = 27'b0_00000000_100110101001010100;
		#20;
		mul_in_1_single = 27'b0_00000000_110100000100010101;
		#20;
		mul_in_1_single = 27'b0_00000000_010110000000100001;
		#20;
		mul_in_1_single = 27'b0_00000000_100110101001010100;
		#20;
		mul_in_1_single = 27'b0_00000000_110100000100010101;
		#20;
		mul_in_1_single = 27'b0_00000000_010110000000100001;
		
	end
	
		
	always
	begin
		#10 clk_pll = ~clk_pll;
	end
      
      
endmodule

