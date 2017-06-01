`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2017 01:32:01
// Design Name: 
// Module Name: operation_squarefy
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


module operation_squarefy(
    //square wave modulation
	input [11:0]currentwave,
	input squarefy_clock, //16*freqwire == 8 squarewaveforms
	output reg[11:0] outputwave
    );
    reg on = 0;	
    always @(posedge squarefy_clock) begin
    	if (on==0)	outputwave <= currentwave;
    	else outputwave <= 12'h0;
		on <= ~on;
    end
    
endmodule
