`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2017 21:53:09
// Design Name: 
// Module Name: clock_divider_var
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


module clock_divider_var(
	input CLOCK, 
	output reg SAMP_CLOCK,
	output reg SSD_CLOCK
    );
    initial begin
    	SAMP_CLOCK = 0;
    end
    reg [16:0] COUNT = 17'b0;
reg [16:0] COUNT_ssd = 17'b0; 
    always @ (posedge CLOCK) begin
    	COUNT <= (COUNT == 17'd1000)? 17'b0: COUNT + 1; //desiredcount == 1000 is 50khz
    	SAMP_CLOCK <= (COUNT == 17'b0)?~SAMP_CLOCK:SAMP_CLOCK; 
	COUNT_ssd <= COUNT_ssd + 1;
	SSD_CLOCK <= COUNT_ssd[16];
    end
endmodule