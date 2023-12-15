`timescale 1ns / 1ps

module ShiftRight(
	input wire [17 : 0] fraction,
	input wire [7 : 0] shift,
	
	output reg [17 : 0] out
    );
	
	always @(*)
	begin
		case (shift)
			0: out = fraction;
			1: out = {1'b0, fraction[17: 1]};
			2: out = {2'b00, fraction[17: 2]};
			3: out = {3'b000, fraction[17: 3]};
			4: out = {4'b0000, fraction[17: 4]};
			5: out = {5'b00000, fraction[17: 5]};
			6: out = {6'b000000, fraction[17: 6]};
			7: out = {7'b0000000, fraction[17: 7]};
			8: out = {8'b00000000, fraction[17: 8]};
			9: out = {9'b000000000, fraction[17: 9]};
			10: out = {10'b0000000000, fraction[17: 10]};
			11: out = {11'b00000000000, fraction[17: 11]};
			12: out = {12'b000000000000, fraction[17: 12]};
			13: out = {13'b0000000000000, fraction[17: 13]};
			14: out = {14'b00000000000000, fraction[17: 14]};
			15: out = {15'b000000000000000, fraction[17: 15]};
			16: out = {16'b0000000000000000, fraction[17: 16]};
			17: out = {17'b00000000000000000, fraction[17: 17]};
			default: out = 18'b000000000000000000;
		endcase
	end
	
	
endmodule