`timescale 1ns / 1ps

module FloatingPointAdder( 
	input wire [26 : 0] in_1,
	input wire [26 : 0] in_2,
	input wire clk_pll,
	
	output wire [26 : 0] out
    );
	
	localparam negative = 1'b1;
	localparam possetive = 1'b0;
	
	wire [26:0] f_p_normal_out_1;
	wire [26:0] f_p_normal_out_2;
	
	//pipe layer 1:  ///////////////////////////
	FPNormal f_p_normal (
		.in_1(in_1), 
		.in_2(in_2), 
		.out_1(f_p_normal_out_1), 
		.out_2(f_p_normal_out_2)
	);
	
	//pipe line layer 1:
	reg [26:0] pipe_1_out_1;
	reg [26:0] pipe_1_out_2;
	
	//send to pipe layer 1:
	always @(posedge clk_pll)
	begin
		pipe_1_out_1 <= f_p_normal_out_1;
		pipe_1_out_2 <= f_p_normal_out_2;
	end
	///////////////////////////////////////////
	
	wire [26:0] f_p_sub_adder_out;
	wire f_p_sub_adder_carry;
	
	//pipe layer 2:  ///////////////////////////
	FPSubAdder f_p_sub_adder (
		.in_1(pipe_1_out_1),
		.in_2(pipe_1_out_2),
		.out(f_p_sub_adder_out),
		.carry(f_p_sub_adder_carry)
	);
	
	//pipe line layer 2:
	reg [26:0] pipe_2_out;
	reg pipe_2_carry;
	
	//send to pipe layer 2:
	always @(posedge clk_pll)
	begin
		pipe_2_out <= f_p_sub_adder_out;
		pipe_2_carry <= f_p_sub_adder_carry;
	end
	///////////////////////////////////////////
	
	FPShiftNormal f_p_shift_normal (
		.in(pipe_2_out),
		.carry(pipe_2_carry),
		.out(out)
	);
	
	
endmodule
