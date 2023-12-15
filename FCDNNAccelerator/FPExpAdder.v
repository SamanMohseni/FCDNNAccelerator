`timescale 1ns / 1ps

module FPExpAdder(
	input wire [7 : 0] in,
	input wire [7 : 0] change,
	
	output reg [7 : 0] out
    );

	reg [8 : 0] res;
	always @(*)
	begin
		res = in + change;
		
		out = res[7:0];
		
		if(in[7] == 1'b0 && change[7] == 1'b0)
		begin
			if(res[7])//overflow
			begin
				out = 127;
			end
		end
		else if(in[7] == 1'b1 && change[7] == 1'b1)
		begin
			if(!res[7])//underflow
			begin
				out = -128;
			end
		end

	end

endmodule
