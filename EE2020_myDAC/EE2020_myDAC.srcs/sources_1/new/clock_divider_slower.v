`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2017 02:08:25
// Design Name: 
// Module Name: clock_divider_slower
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


module clock_divider_slower(
/*	input CLOCK,
	output reg SLOWCLOCK
    );
    reg [17:0] COUNT = 18'b0; //381hz
    always @ (posedge CLOCK) begin 
    	COUNT <= COUNT + 1;
    	SLOWCLOCK = COUNT[18];
    end*/
	input CLOCK, 
    output reg TwentyHzCLOCK
    );
    reg [25:0] COUNT = 26'b0;
    always @ (posedge CLOCK) begin
    	COUNT <= COUNT + 1;
    	TwentyHzCLOCK = COUNT[20]; //
    end
endmodule
