`timescale 1ns / 1ps

module SelectablePipeReg
#(parameter num_of_pipes = 0, num_of_bits = 27)( 
	input wire [num_of_bits - 1 : 0] in,
	input wire enable,
	input wire clk_pll,
	
	output reg [num_of_bits - 1 : 0] out
    );
	
	reg [num_of_bits - 1 : 0] pipe [num_of_pipes - 1 : 0];
	
	
	integer i;
	always @(posedge clk_pll)
	begin
		pipe [0] <= in;
		for(i = 1; i < num_of_pipes; i = i + 1)
		begin
			pipe[i]  <= pipe[i - 1];
		end
	end
	
	always @(*)
	begin
		if(enable)
		begin
			out = pipe[num_of_pipes - 1];
		end
		else
		begin
			out = in;
		end
	end
	
endmodule
