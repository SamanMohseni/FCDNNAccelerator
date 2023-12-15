`timescale 1ns / 1ps

module ShiftLeft(
	input wire [17 : 0] fraction,
	input wire [7 : 0] shift,
	
	output reg [17 : 0] out
    );

	always @(*)
	begin
		case (shift)
			0: out = fraction;
			1: out = {fraction[16: 0], 1'b0};
			2: out = {fraction[15: 0], 2'b00};
			3: out = {fraction[14: 0], 3'b000};
			4: out = {fraction[13: 0], 4'b0000};
			5: out = {fraction[12: 0], 5'b00000};
			6: out = {fraction[11: 0], 6'b000000};
			7: out = {fraction[10: 0], 7'b0000000};
			8: out = {fraction[9: 0], 8'b00000000};
			9: out = {fraction[8: 0], 9'b000000000};
			10: out = {fraction[7: 0], 10'b0000000000};
			11: out = {fraction[6: 0], 11'b00000000000};
			12: out = {fraction[5: 0], 12'b000000000000};
			13: out = {fraction[4: 0], 13'b0000000000000};
			14: out = {fraction[3: 0], 14'b00000000000000};
			15: out = {fraction[2: 0], 15'b000000000000000};
			16: out = {fraction[1: 0], 16'b0000000000000000};
			17: out = {fraction[0: 0], 17'b00000000000000000};
			default: out = 18'b000000000000000000;
		endcase
	end

endmodule
