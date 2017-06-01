`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 14:48:48
// Design Name: 
// Module Name: clock_divider_half
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


module clock_divider_half(
	input CLOCK,
	output reg HALFCLOCK
    );
    reg COUNT = 1'b0;
    always @ (posedge CLOCK) begin 
    	COUNT <= ~COUNT;
    	HALFCLOCK = COUNT; //1/4
    end
endmodule
