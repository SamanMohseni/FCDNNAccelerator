`timescale 1ns / 1ps

module FPSubAdder(
	input wire [26 : 0] in_1,
	input wire [26 : 0] in_2,
	
	output wire [26 : 0] out,
	output reg carry
    );
	 
	localparam negative = 1'b1;
	localparam possetive = 1'b0;

	wire in_1_sign;
	wire [17 : 0] in_1_fraction;
	
	wire in_2_sign;
	wire [17 : 0] in_2_fraction;
	
	wire [7 : 0] in_exp;
	
	reg out_sign;
	reg [7 : 0] out_exp;
	reg [17 : 0] out_fraction;
	
	assign in_1_sign = in_1[26];
	assign in_1_fraction = in_1[17 : 0];
	
	assign in_2_sign = in_2[26];
	assign in_2_fraction = in_2[17 : 0];
	
	assign in_exp = in_1[25 : 18];
	
	assign out[26] = out_sign;
	assign out[25 : 18] = out_exp;
	assign out[17 : 0] = out_fraction;
	
	reg [18 : 0] op_1;
	reg [18 : 0] op_2;
	reg signed [18 : 0] res;
	
	always @(*)
	begin
		out_exp = in_exp;
		
		if(in_1_sign == possetive)
		begin
			op_1 = {1'b0, in_1_fraction};
		end
		else
		begin
			op_1 = -{1'b0, in_1_fraction};
		end
		
		if(in_2_sign == possetive)
		begin
			op_2 = {1'b0, in_2_fraction};
		end
		else
		begin
			op_2 = -{1'b0, in_2_fraction};
		end
		
		res = op_1 + op_2;
		
		if(in_1_sign ^ in_2_sign)
		begin
			out_sign = res[18];
			if(out_sign == negative)
			begin
				res = -res;
			end
			out_fraction = res[17:0];
			carry = 0;
		end
		else if(in_1_sign == possetive)
		begin
			out_sign = possetive;
			out_fraction = res[17:0];
			carry = res[18];
		end
		else
		begin
			out_sign = negative;
			res = -res;
			out_fraction = res[17:0];
			carry = res[18];
		end
	end

endmodule
