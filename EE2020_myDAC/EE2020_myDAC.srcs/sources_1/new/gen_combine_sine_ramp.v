`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2017 14:11:49
// Design Name: 
// Module Name: gen_combine_sine_ramp
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


module gen_combine_sine_ramp(
	input double_freqclock,
	input [11:0]sinewave,
	input [11:0]sawtoothwave,
	input [11:0] Vmax,
	input [11:0] Vmin,
	output reg [11:0]combinedwave
    );
    reg [7:0] count=0;
    always @(posedge double_freqclock) begin
    	count <= (count==5)?0:count+1;
    end
    
    always @* begin
		case (count)
			1: combinedwave = sinewave;
			2: combinedwave = sinewave;
			3: combinedwave = sawtoothwave;
			4: combinedwave = Vmin;
			5: combinedwave = sawtoothwave;
		endcase
	end
    
    
endmodule
