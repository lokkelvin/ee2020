`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 16:31:45
// Design Name: 
// Module Name: clock_twenty
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


module clock_twenty(
	input CLOCK, 
	output reg TwentyHzCLOCK
    );
    reg [25:0] COUNT = 26'b0;
    always @ (posedge CLOCK) begin
    	COUNT <= COUNT + 1;
    	TwentyHzCLOCK = COUNT[21]; //23.8hz
    end
endmodule
