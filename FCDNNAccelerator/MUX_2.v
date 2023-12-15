`timescale 1ns / 1ps

module MUX_2
#(parameter data_length = 27)
	(
	input wire [data_length - 1 : 0] in_0,
	input wire [data_length - 1 : 0] in_1,
	input wire  sel,
	
	output reg [data_length - 1 : 0] out
    );
	
	always @(*)
	begin
		if(sel)
			out = in_1;
		else
			out = in_0;
	end

endmodule
