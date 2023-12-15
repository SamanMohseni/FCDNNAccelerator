`timescale 1ns / 1ps

module FloatingPointMultiplier( 
	input wire [26 : 0] in_1,
	input wire [26 : 0] in_2,
	input wire clk_pll,
	
	output wire [26 : 0] out
    );
	
	wire in_1_sign;
	wire [7 : 0] in_1_exp;
	wire [17 : 0] in_1_fraction;
	
	wire in_2_sign;
	wire [7 : 0] in_2_exp;
	wire [17 : 0] in_2_fraction;
	
	reg out_sign;
	reg [7 : 0] out_exp;
	reg [17 : 0] out_fraction;
	
	assign in_1_sign = in_1[26];
	assign in_1_exp = in_1[25 : 18];
	assign in_1_fraction = in_1[17 : 0];
	
	assign in_2_sign = in_2[26];
	assign in_2_exp = in_2[25 : 18];
	assign in_2_fraction = in_2[17 : 0];
	
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
	
	//pipeline:
	///////////////////input logic///////////////////
	reg pipe_sign;
	reg [7:0] pipe_exp;
	reg [35:0] pipe_prod;
	
	always @(posedge clk_pll)
	begin
		pipe_sign <= in_1_sign ^ in_2_sign;
		pipe_prod <= in_1_fraction * in_2_fraction;
		pipe_exp <= fp_exp_adder_out;
	end
	
	always @(*)
	begin
		fp_exp_adder_in = in_1_exp;
		fp_exp_adder_change = in_2_exp;
	end
	/////////////////////////////////////////////////
	
	//////////////////output logic///////////////////
	reg [7 : 0] fp_exp_sub_adder_in;
	reg [7 : 0] fp_exp_sub_adder_change;
	wire [7 : 0] fp_exp_sub_adder_out;
	
	FPExpAdder fp_exp_sub_adder (
		.in(fp_exp_sub_adder_in),
		.change(fp_exp_sub_adder_change),
		.out(fp_exp_sub_adder_out)
	);
	
	
	always @(*)
	begin
		out_sign = pipe_sign;
		fp_exp_sub_adder_in = pipe_exp;
		if(pipe_prod[35])
		begin
			fp_exp_sub_adder_change = 0;
			out_fraction = pipe_prod[35:18];
		end
		else
		begin
			fp_exp_sub_adder_change = -1;
			out_fraction = pipe_prod[34:17];
		end
		out_exp = fp_exp_sub_adder_out;
	end
	/////////////////////////////////////////////////
	
endmodule
