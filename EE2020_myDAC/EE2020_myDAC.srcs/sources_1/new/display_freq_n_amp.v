`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2017 00:19:39
// Design Name: 
// Module Name: display_freq_n_amp
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


module display_freq_n_amp(
	input onehzclock,
	input [11:0] Vmax,
	input [11:0] Vmin,
	input [11:0] freqwire,
	output reg [11:0] combinedisplay
    );
    reg [1:0]count = 0;
    always @(posedge onehzclock)begin
    	if (count==0) combinedisplay = Vmax;
		else if (count==1) combinedisplay = Vmin;
    	else if (count==2) combinedisplay = freqwire;
    	count <= (count==2)?0:count +1;
    end
endmodule
