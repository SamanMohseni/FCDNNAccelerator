`timescale 1ns / 1ps

module MUX_4
#(parameter data_length = 27)
	(
	input wire [data_length - 1 : 0] in_0,
	input wire [data_length - 1 : 0] in_1,
	input wire [data_length - 1 : 0] in_2,
	input wire [data_length - 1 : 0] in_3,
	input wire [1 : 0] sel,
	
	output reg [data_length - 1 : 0] out
    );
	
	always @(*)
	begin
		case(sel)
			0 : out = in_0;
			1 : out = in_1;
			2 : out = in_2;
			default : out = in_3;
		endcase
	end

endmodule
