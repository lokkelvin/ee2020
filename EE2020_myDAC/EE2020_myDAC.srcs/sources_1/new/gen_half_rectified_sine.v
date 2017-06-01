`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2017 22:54:20
// Design Name: 
// Module Name: gen_half_rectified_sine
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


module gen_half_rectified_sine(
    input SAMP_CLOCK,
	input phasefreqclock,
	input [11:0]Vmax,
	input [11:0]Vmin,
	output [11:0] outputwave
	);
	reg [7:0] test;
	reg [11:0] Vmax_factor;
	reg [7:0]PHASE_IN = 8'b1; // -PI <= PHASE_IN <= PI
	wire [15:0]M_AXIS_DOUT; // get Y from XY BUS
	reg [2:0]count = 4;
	
	always @* begin
	Vmax_factor = (Vmax-Vmin) / 64;
	end
	
	always @(posedge phasefreqclock)begin
		if (count==2) begin //essentially making a 1/4 clock 
			PHASE_IN = (PHASE_IN == 8'b01100100) ? 8'b0: PHASE_IN + 1; //
			count = 0;
		end
		count = count + 1;
	end
	
/*	cordic_0 cordic_sin(
		.aclk(SAMP_CLOCK),
		.s_axis_phase_tdata(PHASE_IN), 
		.m_axis_dout_tdata(M_AXIS_DOUT));*/
	wire tvalid;
    cordic_1 cordic_sin(
        .aclk(SAMP_CLOCK),
        .s_axis_phase_tdata(PHASE_IN), 
        .s_axis_phase_tvalid(1'd1),
        .m_axis_dout_tdata(M_AXIS_DOUT),
		.m_axis_dout_tvalid(tvalid));
	always @(*) begin
	test = M_AXIS_DOUT[15:8];
	end
	
	assign outputwave = Vmin + ( test * Vmax_factor);	
	
		
		
endmodule