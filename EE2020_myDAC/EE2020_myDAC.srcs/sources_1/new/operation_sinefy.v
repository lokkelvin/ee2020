`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2017 19:09:20
// Design Name: 
// Module Name: operation_sinefy
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module operation_sinefy(
    input cordic_clock,
	input phasefreqclock, //fastclock
	input [11:0]currentwave, //input is data_a
	input [11:0]Vmin,
	output [11:0] outputwave
	);
	reg [7:0] test;
	reg [11:0] Vmax_factor;
	reg [7:0]PHASE_IN = 0;
	wire [15:0]M_AXIS_DOUT; // get Y from XY BUS
	
	always @* begin
	Vmax_factor = currentwave / 127; // 127 vertical steps from cordic
	end

	always @(posedge phasefreqclock)begin
	// --------[Signed Fixed point counter, [6:0] only]-------
	// --------[2Q5, 8_fix5, Number format]-------
	//PHASE_IN == 8'b01100101 <-- pi <==>  
	//PHASE_IN == 8'b0_11_00101 <--- 1 bit sign, 2 bit integer, 5 bit fractional.
	//8'b10011100 <-- (-pi) <== pi in two's complement 
	PHASE_IN = (PHASE_IN == 8'b01100101) ? 8'b10011100: PHASE_IN + 1; //
	end
	
/*    cordic_0 cordic_sin(
		.aclk(SAMP_CLOCK),
		.s_axis_phase_tdata(PHASE_IN), 
		
		.m_axis_dout_tdata(M_AXIS_DOUT));*/
	cordic_1 cordic_sin(
	    .aclk(cordic_clock),
	    .s_axis_phase_tdata(PHASE_IN), 
	    .s_axis_phase_tvalid(1'd1),
	    .m_axis_dout_tdata(M_AXIS_DOUT));
	
	always @(*) begin
	test = M_AXIS_DOUT[15:8];
	if (M_AXIS_DOUT[15])begin //twos complement
		test[7:0] = test[7:0] - 191;
	end
	else begin test = test + (254-191); end
	end

	assign outputwave = ( test * Vmax_factor);	

	
	
endmodule