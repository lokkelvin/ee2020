`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 22:04:04
// Design Name: 
// Module Name: clock_divider
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
module clock_divider(
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
    	freq_desired = 512 * waveform_freq;//migrated mult to outside my_dac module
    
    	COUNT <= (COUNT == (28'd50000000/freq_desired))? 28'b0: COUNT + 1; //desiredcount == 1000 is 50khz
    	SAMP_CLOCK <= (COUNT == 28'b0)?~SAMP_CLOCK:SAMP_CLOCK; 
    end
endmodule

//module clock_divider(
//	input CLOCK, 
//	output reg SAMP_CLOCK,
//	output reg SSD_CLOCK
//    );
//    initial begin
//    	SAMP_CLOCK = 0;
//    end
//    reg [16:0] COUNT = 17'b0;
//	reg [16:0] COUNT_ssd = 17'b0; //2^17 == 762.939 Hz
//    always @ (posedge CLOCK) begin
//    	COUNT <= (COUNT == 17'd66666)? 17'b0: COUNT + 1;
//    	SAMP_CLOCK <= (COUNT == 17'b0)?~SAMP_CLOCK:SAMP_CLOCK; //inverts every 66666 
//    	// count <= (count==5)?4'b0000:count+1; //6 x of the clock freq
//    	// new_clock <= (count==4'b000)? ~new_clock:new_clock;
//		COUNT_ssd <= COUNT_ssd + 1;
//		SSD_CLOCK <= COUNT_ssd[16];
//    end
//endmodule