`timescale 1ns / 1ps

module FPShiftNormal(
	input wire [26:0] in,
	input wire carry,
	
	output wire [26:0] out
    );
	 
	reg out_sign;
	reg [7 : 0] out_exp;
	reg [17 : 0] out_fraction;	
	
	assign out[26] = out_sign;
	assign out[25 : 18] = out_exp;
	assign out[17 : 0] = out_fraction;
	
	wire in_sign;
	wire [7 : 0] in_exp;
	wire [17 : 0] in_fraction;
	
	assign in_sign = in[26];
	assign in_exp = in[25 : 18];
	assign in_fraction = in[17 : 0];
	
	 
	reg [7 : 0] f_p_exp_adder_in;
	reg [7 : 0] f_p_exp_adder_change;
	wire [7 : 0] f_p_exp_adder_out;
	 
	FPExpAdder f_p_exp_adder (
		.in(f_p_exp_adder_in),
		.change(f_p_exp_adder_change),
		.out(f_p_exp_adder_out)
	);
	
	reg [17 : 0] shift_left_fraction;
	reg [7 : 0] shift_left_shift;
	wire [17 : 0] shift_left_out;
	
	ShiftLeft shift_left (
		.fraction(shift_left_fraction),
		.shift(shift_left_shift), 
		.out(shift_left_out)
	);
	
	reg [5 : 0] highest_set_bit;
	integer i;
	
	always @(*)
	begin
		out_sign = in_sign;
		f_p_exp_adder_in = in_exp;
		out_exp = f_p_exp_adder_out;
		shift_left_fraction = in_fraction;
		shift_left_shift = 0;
		highest_set_bit = 0;
		if(carry)
		begin
			f_p_exp_adder_change = 1;
			out_fraction = {1'b1, in_fraction[17 : 1]};
		end
		else
		begin
			highest_set_bit = 18;
			for (i=0; i<=17; i=i+1)
			begin
				if (in[i]) highest_set_bit = (17 - i);
			end
				
			shift_left_shift = highest_set_bit;
			f_p_exp_adder_change = -highest_set_bit;
			out_fraction = shift_left_out | (18'b1000_0000_0000_0000_00);
		end
	end

endmodule
