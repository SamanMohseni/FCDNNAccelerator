`timescale 1ns / 1ps

module SelectableExtendablePipeReg
#(parameter num_of_extra_pipes = 0, num_of_bits = 27)( 
	input wire [num_of_bits - 1 : 0] in,
	input wire [1 : 0] mode,
	input wire clk_pll,
	
	output reg [num_of_bits - 1 : 0] out
    );
	
	localparam disabled = 2'b00;
	localparam not_extended = 2'b10;
	localparam extended = 2'b11;
	
	localparam num_of_pipes = num_of_extra_pipes + 7;
	
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
		case (mode)
			disabled: out = in;
			not_extended: out = pipe[num_of_extra_pipes - 1];
			extended: out = pipe[num_of_pipes - 1];
			default : out = 27'bxxxxxxxxxxxxxxxxxxxxxxxxxxx;
		endcase
	end
	
endmodule
