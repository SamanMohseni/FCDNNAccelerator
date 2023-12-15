`timescale 1ns / 1ps

module SReg
#(parameter num_of_bits = 27)( 
	input wire [num_of_bits - 1 : 0] in,
	input wire clk_pll,
	
	output reg [num_of_bits - 1 : 0] out
    );
	
	always @(posedge clk_pll)
	begin
		out <= in;
	end
	
endmodule
