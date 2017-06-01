`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2017 22:51:06
// Design Name: 
// Module Name: clock_divider_custom_wave
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


module clock_divider_custom_wave(
	//outputs a clock that is 512 * desired frequency.
	input CLOCK, 
	input [27:0] waveform_freq, //freqwire
	output reg SAMP_CLOCK
    );
    initial begin
    	SAMP_CLOCK = 0;
    end
    reg [27:0] COUNT = 28'b0;
	reg [27:0] freq_desired = 28'd0;
    always @ (posedge CLOCK) begin
    	freq_desired = 1 * waveform_freq;//migrated mult to outside my_dac module
    
    	COUNT <= (COUNT >= (28'd50000000/freq_desired))? 28'b0: COUNT + 1; //desiredcount == 1000 is 50khz
    	SAMP_CLOCK <= (COUNT == 28'b0)?~SAMP_CLOCK:SAMP_CLOCK; 
    end
endmodule
