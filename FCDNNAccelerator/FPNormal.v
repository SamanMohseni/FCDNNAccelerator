`timescale 1ns / 1ps

module FPNormal(
	input wire [26 : 0] in_1,
	input wire [26 : 0] in_2,
	
	output wire [26 : 0] out_1,
	output wire [26 : 0] out_2
    );
	
	wire in_1_sign;
	wire signed [7 : 0] in_1_exp;
	wire [17 : 0] in_1_fraction;
	
	wire in_2_sign;
	wire signed [7 : 0] in_2_exp;
	wire [17 : 0] in_2_fraction;
	
	reg out_1_sign;
	reg out_2_sign;
	reg [7 : 0] out_exp;
	reg [17 : 0] out_1_fraction;
	reg [17 : 0] out_2_fraction;
	
	assign in_1_sign = in_1[26];
	assign in_1_exp = in_1[25 : 18];
	assign in_1_fraction = in_1[17 : 0];
	
	assign in_2_sign = in_2[26];
	assign in_2_exp = in_2[25 : 18];
	assign in_2_fraction = in_2[17 : 0];
	
	assign out_1[26] = out_1_sign;
	assign out_2[26] = out_2_sign;
	assign out_1[25 : 18] = out_exp;
	assign out_2[25 : 18] = out_exp;
	assign out_1[17 : 0] = out_1_fraction;
	assign out_2[17 : 0] = out_2_fraction;
	
	reg [17 : 0] shifter_fraction;
	reg [7 : 0] shifter_shift;
	wire [17 : 0] shifter_out;
	ShiftRight shifter(.fraction(shifter_fraction), .shift(shifter_shift), .out(shifter_out));
	
	always @(*)
	begin
		out_1_sign = in_1_sign;
		out_2_sign = in_2_sign;
		
		if(in_1_exp < in_2_exp)
		begin
			out_exp = in_2_exp;
			out_2_fraction = in_2_fraction;
			shifter_fraction = in_1_fraction;
			shifter_shift = in_2_exp - in_1_exp;
			out_1_fraction = shifter_out;
		end
		else
		begin
			out_exp = in_1_exp;
			out_1_fraction = in_1_fraction;
			shifter_fraction = in_2_fraction;
			shifter_shift = in_1_exp - in_2_exp;
			out_2_fraction = shifter_out;
		end
	end
	
endmodule
	