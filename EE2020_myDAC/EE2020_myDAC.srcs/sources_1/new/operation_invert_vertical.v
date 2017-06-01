`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2017 02:44:15
// Design Name: 
// Module Name: operation_invert_vertical
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


module operation_invert_vertical(
	input [11:0]currentwave,
	output reg[11:0] outputwave
    );
    
    reg [11:0] distance_from_top;
    always @ (*)begin
    	distance_from_top = 12'hFFF - currentwave;
    	outputwave = distance_from_top; 
    end
endmodule
