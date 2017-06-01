`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 14:51:35
// Design Name: 
// Module Name: clock_divider_samp
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
// p0l0l0
//////////////////////////////////////////////////////////////////////////////////


module clock_divider_samp(
//f at 50M/16 = 3.125M
	input CLOCK, 
	//input HF_toggle,
	//input [27:0] waveform_freq, //freqwire
	output reg SAMP_CLOCK
		);
		
	reg [27:0] COUNT = 28'b0;
	//reg [27:0] freq_desired = 28'd0;
		always @ (posedge CLOCK) begin
			//freq_desired = (HF_toggle)? 128* waveform_freq :2048 * waveform_freq;
		
			COUNT <= (COUNT == 50)? 28'b0: COUNT + 1; 
			SAMP_CLOCK <= (COUNT == 28'b0)?~SAMP_CLOCK:SAMP_CLOCK; 
		end
endmodule