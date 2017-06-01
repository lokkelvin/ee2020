`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2017 01:47:25
// Design Name: 
// Module Name: operation_squarefy_invert
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


module operation_squarefy_invert(
	input [11:0]currentwave,
	input squarefy_clock, //16*freqwire
	output reg[11:0] outputwave
	);
	reg on = 0;
	always @(posedge squarefy_clock) begin
		if (on==0)	outputwave <= 12'hFFF;
		else outputwave <= currentwave;
		on <= ~on;
	end
		
endmodule