`timescale 1ns / 1ps

module Core( 
	input wire clk_pll,
	
	
	//data inputs: ///////////////////////////////////////////////////////////////
	input wire [26 : 0] mul_in_1_single,
	
	input wire [431 : 0] mul_in_1_pack, //unpack into 16, 27 bit array.
	
	input wire [431 : 0] mul_in_2_pack, //unpack into 16, 27 bit array.

	input wire [431 : 0] add_in_1_pack, //unpack into 16, 27 bit array.
	
	input wire [431 : 0] add_in_2_pack, //unpack into 16, 27 bit array.	
	
	input wire [26 : 0] add_in_2_single,
	
	input wire [7 : 0] exp,
	//////////////////////////////////////////////////////////////////////////////
	
	
	//controll inputs: ///////////////////////////////////////////////////////////
	input wire [1 : 0] mul_in_1_mux_sel_left,
	input wire [1 : 0] mul_in_1_mux_sel_right,
	
	input wire [1 : 0] mul_in_2_mux_sel,
	
	input wire sigmoid_pipe_mux_sel,
	input wire [1 : 0] sigmoid_pipe_extend_controll, // 00: disable, 10: half, 11: full
	
	input wire add_in_1_mux_sel_left,
	input wire [1 : 0] add_in_1_mux_sel_right,
	
	input wire [1 : 0] add_in_2_mux_sel, //except for the middle one
	input wire [1 : 0] add_in_2_mid_mux_sel,
	
	input wire sigmoid_output_mux_sel,
	//////////////////////////////////////////////////////////////////////////////
	
	
	//outputs: ///////////////////////////////////////////////////////////////////
	output wire [431 : 0] mul_out_pack, //packed form 16, 27 bit array.
	
	output wire [431 : 0] add_out_pack, //packed form 16, 27 bit array.
	
	output wire [26 : 0] add_out_single,
	
	output wire [26 : 0] sigmoid
	//////////////////////////////////////////////////////////////////////////////
    );
	
	//localparams: ///////////////////////////////////////////////////////////////
	localparam [26 : 0] fp_one = 27'b0_00000001_100000000000000000;
	
	localparam [26 : 0] ln_2_div_1 = 27'b0_00000000_101100010111001000;
	localparam [26 : 0] ln_2_div_2 = 27'b0_11111111_101100010111001000;
	localparam [26 : 0] ln_2_div_3 = 27'b0_11111110_111011001001100000;
	localparam [26 : 0] ln_2_div_4 = 27'b0_11111110_101100010111001000;
	localparam [26 : 0] ln_2_div_5 = 27'b0_11111110_100011011111010011;
	localparam [26 : 0] ln_2_div_6 = 27'b0_11111101_111011001001100000;
	localparam [26 : 0] ln_2_div_7 = 27'b0_11111101_110010101100101110;
	localparam [26 : 0] ln_2_div_8 = 27'b0_11111101_101100010111001000;
	//////////////////////////////////////////////////////////////////////////////
	
	genvar i;
	
	//unpack, packed inputs: /////////////////////////////////////////////////////
	//mul_in_1_pack:
	wire [26 : 0] mul_in_1 [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : mul_in_1_unpack
		assign mul_in_1[i] = mul_in_1_pack[((i+1)*27)-1 : i*27];
	end
	endgenerate
	
	//mul_in_2_pack:
	wire [26 : 0] mul_in_2 [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : mul_in_2_unpack
		assign mul_in_2[i] = mul_in_2_pack[((i+1)*27)-1 : i*27];
	end
	endgenerate
	
	//add_in_1_pack:
	wire [26 : 0] add_in_1 [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : add_in_1_unpack
		assign add_in_1[i] = add_in_1_pack[((i+1)*27)-1 : i*27];
	end
	endgenerate
	
	//add_in_2_pack:
	wire [26 : 0] add_in_2 [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : add_in_2_unpack
		assign add_in_2[i] = add_in_2_pack[((i+1)*27)-1 : i*27];
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//pack outputs: //////////////////////////////////////////////////////////////
	//mul_out_pack:
	wire [26 : 0] mul_out [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : mul_out_packed
		assign mul_out_pack[((i+1)*27)-1 : i*27] = mul_out[i];
	end
	endgenerate
	
	//add_out_pack:
	wire [26 : 0] add_out [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : add_out_packed
		assign add_out_pack[((i+1)*27)-1 : i*27] = add_out[i];
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 SRegs, mul_prod_regs array: ////////////////////////////////////
	wire [26 : 0] mul_prod_reg_out [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : mul_prod_regs
		SReg mul_prod_reg_instance(
			.in(mul_out[i]),
			.clk_pll(clk_pll),
			.out(mul_prod_reg_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 multiplexrs, mul_in_1_mux array: ///////////////////////////////
	wire [26 : 0] mul_in_1_mux_out [15 : 0];
	
	MUX_3 mul_in_1_mux_0(
		.in_0(mul_in_1_single),
		.in_1(mul_in_1[0]),
		.in_2(mul_in_1_single),
		.sel(mul_in_1_mux_sel_right),
		.out(mul_in_1_mux_out[0])
	);
	
	generate
	for(i=1; i<8; i=i+1)
	begin : mul_in_1_mux_r
		MUX_3 mul_in_1_mux_instance(
			.in_0(mul_prod_reg_out[i - 1]),
			.in_1(mul_in_1[i]),
			.in_2(mul_in_1_single),
			.sel(mul_in_1_mux_sel_right),
			.out(mul_in_1_mux_out[i])
		);
	end
	endgenerate
	
	generate
	for(i=8; i<16; i=i+1)
	begin : mul_in_1_mux_l
		MUX_3 mul_in_1_mux_instance(
			.in_0(mul_prod_reg_out[i - 1]),
			.in_1(mul_in_1[i]),
			.in_2(mul_in_1_single),
			.sel(mul_in_1_mux_sel_left),
			.out(mul_in_1_mux_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	wire [26 : 0] mul_in_2_mux_out [15 : 0];
	
	
	//generate 16 multipliers: ///////////////////////////////////////////////////
	//outputs already defined.
	generate
	for(i=0; i<16; i=i+1)
	begin : multipliers
		FloatingPointMultiplier fp_mul_instance(
			.in_1(mul_in_1_mux_out[i]),
			.in_2(mul_in_2_mux_out[i]),
			.clk_pll(clk_pll),
			.out(mul_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	wire [26 : 0] sigmoid_pipe_mux_out_0;
	wire [26 : 0] sigmoid_pipe_mux_out_1;
	
	
	//generate sigmoid_X2_triangle_pipe: /////////////////////////////////////////
	//layer 1:
	wire [26 : 0] sigmoid_X2_triangle_pipe_L1_out [5 : 0];
	
	PipeReg sigmoid_X2_triangle_pipe_L1_0(
		.in(mul_prod_reg_out[0]),
		.clk_pll(clk_pll),
		.out(sigmoid_X2_triangle_pipe_L1_out[0])
	);
	
	PipeReg sigmoid_X2_triangle_pipe_L1_1(
		.in(sigmoid_pipe_mux_out_0),
		.clk_pll(clk_pll),
		.out(sigmoid_X2_triangle_pipe_L1_out[1])
	);
	
	PipeReg sigmoid_X2_triangle_pipe_L1_2(
		.in(sigmoid_pipe_mux_out_1),
		.clk_pll(clk_pll),
		.out(sigmoid_X2_triangle_pipe_L1_out[2])
	);
	
	generate
	for(i=3; i<6; i=i+1)
	begin : sigmoid_X2_triangle_pipe_L1_LH //left half
		PipeReg sigmoid_X2_triangle_pipe_L1_instance(
			.in(mul_prod_reg_out[i]),
			.clk_pll(clk_pll),
			.out(sigmoid_X2_triangle_pipe_L1_out[i])
		);
	end
	endgenerate
	
	//layer 2:
	wire [26 : 0] sigmoid_X2_triangle_pipe_L2_out [4 : 0];
	
	generate
	for(i=0; i<5; i=i+1)
	begin : sigmoid_X2_triangle_pipe_L2
		PipeReg sigmoid_X2_triangle_pipe_L2_instance(
			.in(sigmoid_X2_triangle_pipe_L1_out[i]),
			.clk_pll(clk_pll),
			.out(sigmoid_X2_triangle_pipe_L2_out[i])
		);
	end
	endgenerate
	
	//layer 3:
	wire [26 : 0] sigmoid_X2_triangle_pipe_L3_out [3 : 0];
	
	generate
	for(i=0; i<4; i=i+1)
	begin : sigmoid_X2_triangle_pipe_L3
		PipeReg sigmoid_X2_triangle_pipe_L3_instance(
			.in(sigmoid_X2_triangle_pipe_L2_out[i]),
			.clk_pll(clk_pll),
			.out(sigmoid_X2_triangle_pipe_L3_out[i])
		);
	end
	endgenerate
	
	//layer 4:
	wire [26 : 0] sigmoid_X2_triangle_pipe_L4_out [2 : 0];
	
	generate
	for(i=0; i<3; i=i+1)
	begin : sigmoid_X2_triangle_pipe_L4
		PipeReg sigmoid_X2_triangle_pipe_L4_instance(
			.in(sigmoid_X2_triangle_pipe_L3_out[i]),
			.clk_pll(clk_pll),
			.out(sigmoid_X2_triangle_pipe_L4_out[i])
		);
	end
	endgenerate
	
	//layer 5:
	wire [26 : 0] sigmoid_X2_triangle_pipe_L5_out [1 : 0];
	
	generate
	for(i=0; i<2; i=i+1)
	begin : sigmoid_X2_triangle_pipe_L5
		PipeReg sigmoid_X2_triangle_pipe_L5_instance(
			.in(sigmoid_X2_triangle_pipe_L4_out[i]),
			.clk_pll(clk_pll),
			.out(sigmoid_X2_triangle_pipe_L5_out[i])
		);
	end
	endgenerate
	
	//layer 6:
	wire [26 : 0] sigmoid_X2_triangle_pipe_L6_out;
	
	PipeReg sigmoid_X2_triangle_pipe_L6(
		.in(sigmoid_X2_triangle_pipe_L5_out[0]),
		.clk_pll(clk_pll),
		.out(sigmoid_X2_triangle_pipe_L6_out)
	);
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 2 multiplexrs, sigmoid_pipe_mux: //////////////////////////////////
	//outputs already defined.
	MUX_2 sigmoid_pipe_mux_0(
		.in_0(sigmoid_X2_triangle_pipe_L6_out),
		.in_1(mul_prod_reg_out[1]),
		.sel(sigmoid_pipe_mux_sel),
		.out(sigmoid_pipe_mux_out_0)
	);
	
	MUX_2 sigmoid_pipe_mux_1(
		.in_0(sigmoid_X2_triangle_pipe_L5_out[1]),
		.in_1(mul_prod_reg_out[2]),
		.sel(sigmoid_pipe_mux_sel),
		.out(sigmoid_pipe_mux_out_1)
	);
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 multiplexrs, mul_in_2_mux array: ///////////////////////////////
	//outputs already defined.
	MUX_3 mul_in_2_mux_0(
		.in_0(mul_in_2[0]),
		.in_1(fp_one),
		.in_2(ln_2_div_8),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[0])
	);
	
	MUX_3 mul_in_2_mux_1(
		.in_0(mul_in_2[1]),
		.in_1(mul_prod_reg_out[0]),
		.in_2(ln_2_div_7),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[1])
	);
	
	MUX_3 mul_in_2_mux_2(
		.in_0(mul_in_2[2]),
		.in_1(sigmoid_X2_triangle_pipe_L1_out[0]),
		.in_2(ln_2_div_6),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[2])
	);
	
	MUX_3 mul_in_2_mux_3(
		.in_0(mul_in_2[3]),
		.in_1(sigmoid_X2_triangle_pipe_L2_out[0]),
		.in_2(ln_2_div_5),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[3])
	);
	
	MUX_3 mul_in_2_mux_4(
		.in_0(mul_in_2[4]),
		.in_1(sigmoid_X2_triangle_pipe_L3_out[0]),
		.in_2(ln_2_div_4),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[4])
	);
	
	MUX_3 mul_in_2_mux_5(
		.in_0(mul_in_2[5]),
		.in_1(sigmoid_X2_triangle_pipe_L4_out[0]),
		.in_2(ln_2_div_3),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[5])
	);
	
	MUX_3 mul_in_2_mux_6(
		.in_0(mul_in_2[6]),
		.in_1(sigmoid_X2_triangle_pipe_L5_out[0]),
		.in_2(ln_2_div_2),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[6])
	);
	
	MUX_3 mul_in_2_mux_7(
		.in_0(mul_in_2[7]),
		.in_1(sigmoid_X2_triangle_pipe_L6_out),
		.in_2(ln_2_div_1),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[7])
	);
	
	MUX_3 mul_in_2_mux_8(
		.in_0(mul_in_2[8]),
		.in_1(sigmoid_X2_triangle_pipe_L1_out[1]),
		.in_2(mul_prod_reg_out[6]),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[8])
	);
	
	MUX_3 mul_in_2_mux_9(
		.in_0(mul_in_2[9]),
		.in_1(sigmoid_X2_triangle_pipe_L2_out[1]),
		.in_2(sigmoid_X2_triangle_pipe_L1_out[5]),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[9])
	);
	
	MUX_3 mul_in_2_mux_10(
		.in_0(mul_in_2[10]),
		.in_1(sigmoid_X2_triangle_pipe_L3_out[1]),
		.in_2(sigmoid_X2_triangle_pipe_L2_out[4]),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[10])
	);
	
	MUX_3 mul_in_2_mux_11(
		.in_0(mul_in_2[11]),
		.in_1(sigmoid_X2_triangle_pipe_L4_out[1]),
		.in_2(sigmoid_X2_triangle_pipe_L3_out[3]),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[11])
	);
	
	MUX_3 mul_in_2_mux_12(
		.in_0(mul_in_2[12]),
		.in_1(sigmoid_X2_triangle_pipe_L5_out[1]),
		.in_2(sigmoid_X2_triangle_pipe_L4_out[2]),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[12])
	);
	
	MUX_3 mul_in_2_mux_13(
		.in_0(mul_in_2[13]),
		.in_1(sigmoid_X2_triangle_pipe_L1_out[2]),
		.in_2(sigmoid_X2_triangle_pipe_L5_out[1]),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[13])
	);
	
	MUX_3 mul_in_2_mux_14(
		.in_0(mul_in_2[14]),
		.in_1(sigmoid_X2_triangle_pipe_L2_out[2]),
		.in_2(sigmoid_X2_triangle_pipe_L6_out),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[14])
	);
	
	MUX_3 mul_in_2_mux_15(
		.in_0(mul_in_2[15]),
		.in_1(sigmoid_X2_triangle_pipe_L3_out[2]),
		.in_2(27'bxxxxxxxxxxxxxxxxxxxxxxxxxxx),
		.sel(mul_in_2_mux_sel),
		.out(mul_in_2_mux_out[15])
	);
	//////////////////////////////////////////////////////////////////////////////
	
	//generate 15 selectable and/or extendable pipes: ////////////////////////////
	wire [26 : 0] selectable_extendable_pipe_out [15 : 1];
	
	generate
	for(i=1; i<8; i=i+1)
	begin : selectable_pipe_right
		SelectablePipeReg #(.num_of_pipes(i)) selectable_pipe_right_instance(
			.in(mul_prod_reg_out[i]),
			.enable(sigmoid_pipe_extend_controll[0]),
			.clk_pll(clk_pll),
			.out(selectable_extendable_pipe_out[i])
		);
	end
	endgenerate
	
	generate
	for(i=8; i<15; i=i+1)
	begin : selectable_extendable_pipe
		SelectableExtendablePipeReg #(.num_of_extra_pipes(i - 7)) selectable_extendable_pipe_instance(
			.in(mul_prod_reg_out[i]),
			.mode(sigmoid_pipe_extend_controll),
			.clk_pll(clk_pll),
			.out(selectable_extendable_pipe_out[i])
		);
	end
	endgenerate
	
	SelectablePipeReg #(.num_of_pipes(15)) selectable_pipe_left(
		.in(mul_prod_reg_out[15]),
		.enable(sigmoid_pipe_extend_controll[0]),
		.clk_pll(clk_pll),
		.out(selectable_extendable_pipe_out[15])
	);
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 SRegs, add_res_regs array: /////////////////////////////////////
	wire [26 : 0] add_res_reg_out [15 : 0];
	generate
	for(i=0; i<16; i=i+1)
	begin : add_res_regs
		SReg add_res_reg_instance(
			.in(add_out[i]),
			.clk_pll(clk_pll),
			.out(add_res_reg_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 multiplexrs, add_in_1_mux array: ///////////////////////////////
	wire [26 : 0] add_in_1_mux_out [15 : 0];
	
	MUX_3 add_in_1_mux_0(
		.in_0(add_in_1[0]),
		.in_1(mul_prod_reg_out[0]),
		.in_2(add_res_reg_out[1]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[0])
	);
	
	MUX_3 add_in_1_mux_1(
		.in_0(add_in_1[1]),
		.in_1(selectable_extendable_pipe_out[1]),
		.in_2(add_res_reg_out[3]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[1])
	);
	
	MUX_3 add_in_1_mux_2(
		.in_0(add_in_1[2]),
		.in_1(selectable_extendable_pipe_out[2]),
		.in_2(add_res_reg_out[6]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[2])
	);
	
	MUX_3 add_in_1_mux_3(
		.in_0(add_in_1[3]),
		.in_1(selectable_extendable_pipe_out[3]),
		.in_2(add_res_reg_out[7]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[3])
	);
	
	MUX_3 add_in_1_mux_4(
		.in_0(add_in_1[4]),
		.in_1(selectable_extendable_pipe_out[4]),
		.in_2(add_res_reg_out[12]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[4])
	);
	
	MUX_3 add_in_1_mux_5(
		.in_0(add_in_1[5]),
		.in_1(selectable_extendable_pipe_out[5]),
		.in_2(add_res_reg_out[13]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[5])
	);
	
	MUX_3 add_in_1_mux_6(
		.in_0(add_in_1[6]),
		.in_1(selectable_extendable_pipe_out[6]),
		.in_2(add_res_reg_out[14]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[6])
	);
	
	MUX_3 add_in_1_mux_7(
		.in_0(add_in_1[7]),
		.in_1(selectable_extendable_pipe_out[7]),
		.in_2(add_res_reg_out[15]),
		.sel(add_in_1_mux_sel_right),
		.out(add_in_1_mux_out[7])
	);
	
	generate
	for(i=8; i<16; i=i+1)
	begin : add_in_1_mux
		MUX_2 add_in_1_mux_instance(
			.in_0(add_in_1[i]),
			.in_1(selectable_extendable_pipe_out[i]),
			.sel(add_in_1_mux_sel_left),
			.out(add_in_1_mux_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 multiplexrs, add_in_2_mux array: ///////////////////////////////
	wire [26 : 0] add_in_2_mux_out [15 : 0];
	
	MUX_3 add_in_2_mux_0(
		.in_0(add_in_2_single),
		.in_1(fp_one),
		.in_2(add_in_2[0]),
		.sel(add_in_2_mux_sel),
		.out(add_in_2_mux_out[0])
	);
	
	MUX_3 add_in_2_mux_1(
		.in_0(add_res_reg_out[2]),
		.in_1(add_res_reg_out[0]),
		.in_2(add_in_2[1]),
		.sel(add_in_2_mux_sel),
		.out(add_in_2_mux_out[1])
	);
	
	generate
	for(i=2; i<4; i=i+1)
	begin : add_in_2_mux_2_3
		MUX_3 add_in_2_mux_i_2_3(
			.in_0(add_res_reg_out[7-i]),
			.in_1(add_res_reg_out[i-1]),
			.in_2(add_in_2[i]),
			.sel(add_in_2_mux_sel),
			.out(add_in_2_mux_out[i])
		);
	end
	endgenerate
	
	generate
	for(i=4; i<7; i=i+1)
	begin : add_in_2_mux_4_6
		MUX_3 add_in_2_mux_i_4_6(
			.in_0(add_res_reg_out[15-i]),
			.in_1(add_res_reg_out[i-1]),
			.in_2(add_in_2[i]),
			.sel(add_in_2_mux_sel),
			.out(add_in_2_mux_out[i])
		);
	end
	endgenerate
	
	MUX_4 add_in_2_mux_7(
		.in_0(add_res_reg_out[8]),
		.in_1(add_res_reg_out[6]),
		.in_2(add_in_2[7]),
		.in_3(fp_one),
		.sel(add_in_2_mid_mux_sel),
		.out(add_in_2_mux_out[7])
	);	
	
	generate
	for(i=8; i<16; i=i+1)
	begin : add_in_2_mux_LH
		MUX_3 add_in_2_mux_LH_instance(
			.in_0(mul_prod_reg_out[i-8]),
			.in_1(add_res_reg_out[i-1]),
			.in_2(add_in_2[i]),
			.sel(add_in_2_mux_sel),
			.out(add_in_2_mux_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate 16 adders: ////////////////////////////////////////////////////////
	//outputs already defined.
	generate
	for(i=0; i<16; i=i+1)
	begin : adders
		FloatingPointAdder fp_add_instance(
			.in_1(add_in_1_mux_out[i]),
			.in_2(add_in_2_mux_out[i]),
			.clk_pll(clk_pll),
			.out(add_out[i])
		);
	end
	endgenerate
	//////////////////////////////////////////////////////////////////////////////
	
	
	//generate sigmoid_output_mux_1: /////////////////////////////////////////////
	wire [26 : 0] sigmoid_output_mux_1_out;
	MUX_2 sigmoid_output_mux_1(
		.in_0(add_res_reg_out[14]),
		.in_1(add_res_reg_out[15]),
		.sel(sigmoid_output_mux_sel),
		.out(sigmoid_output_mux_1_out)
	);
	//////////////////////////////////////////////////////////////////////////////
	
	//generate sigmoid_exp_multiplier: ///////////////////////////////////////////
	wire [26 : 0] sigmoid_exp_multiplier_out;
	FPExpMultiplier sigmoid_exp_multiplier(
		.in(sigmoid_output_mux_1_out),
		.exp(exp),
		.out(sigmoid_exp_multiplier_out)
	);
	//////////////////////////////////////////////////////////////////////////////
	
	//generate sigmoid_increamentor: /////////////////////////////////////////////
	wire [26 : 0] sigmoid_increamentor_out;
	FloatingPointAdder sigmoid_increamentor(
		.in_1(sigmoid_exp_multiplier_out),
		.in_2(fp_one),
		.clk_pll(clk_pll),
		.out(sigmoid_increamentor_out)
	);
	//////////////////////////////////////////////////////////////////////////////
	
	//generate sigmoid_output_mux_2: /////////////////////////////////////////////
	//output already defined.
	MUX_2 sigmoid_output_mux_2(
		.in_0(sigmoid_increamentor_out),
		.in_1(sigmoid_exp_multiplier_out),
		.sel(sigmoid_output_mux_sel),
		.out(sigmoid)
	);
	//////////////////////////////////////////////////////////////////////////////
	
	
	//assign add_out_single: /////////////////////////////////////////////////////
	assign add_out_single = add_res_reg_out[0];
	//////////////////////////////////////////////////////////////////////////////
	
endmodule
