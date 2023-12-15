`timescale 1ns / 1ps

module FPExpMultiplier( 
	input wire [26 : 0] in,
	input wire [7 : 0] exp,
	
	output wire [26 : 0] out
    );
	
	wire in_sign;
	wire [7 : 0] in_exp;
	wire [17 : 0] in_fraction;
	
	reg out_sign;
	reg [7 : 0] out_exp;
	reg [17 : 0] out_fraction;
	
	assign in_sign = in[26];
	assign in_exp = in[25 : 18];
	assign in_fraction = in[17 : 0];
	
	assign out[26] = out_sign;
	assign out[25 : 18] = out_exp;
	assign out[17 : 0] = out_fraction;
	
	reg [7 : 0] fp_exp_adder_in;
	reg [7 : 0] fp_exp_adder_change;
	wire [7 : 0] fp_exp_adder_out;
	
	FPExpAdder fp_exp_adder (
		.in(fp_exp_adder_in),
		.change(fp_exp_adder_change),
		.out(fp_exp_adder_out)
	);
	
	always @(*)
	begin
		out_sign = in_sign;
		out_fraction = in_fraction;
		fp_exp_adder_in = in_exp;
		fp_exp_adder_change = exp;
		out_exp = fp_exp_adder_out;
	end
	
endmodule