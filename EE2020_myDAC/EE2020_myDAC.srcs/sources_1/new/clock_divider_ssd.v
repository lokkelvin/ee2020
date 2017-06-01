`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2017 16:42:04
// Design Name: 
// Module Name: clock_divider_ssd
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


module clock_divider_ssd(
	input CLOCK, 
	output reg SSD_CLOCK
    );
	reg [16:0] COUNT_ssd = 17'b0;
    always @ (posedge CLOCK) begin
		COUNT_ssd <= COUNT_ssd + 1;
		SSD_CLOCK <= COUNT_ssd[16];
    end
endmodule