`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2017 16:40:18
// Design Name: 
// Module Name: gen_ramp_square_wave
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


module gen_ramp_square_wave(
	input ramp_square_clock, //256 times of waveclock
	input SAMP_CLOCK,
	input [11:0]Vmax,
	input [11:0]Vmin,
	output [11:0]outputwave
    );
    reg [9:0]count = 0; 
    reg [11:0] ampli = 0;
 
	//obtain amplitude using sawtooth code
	always @(posedge SAMP_CLOCK)begin
		ampli = Vmin + (count * ((Vmax-Vmin)/512));
		count <= (count==10'd512)?1:count+1; 
    end
    
    //toggle sawtooth on and off with ramp_square_clock square signal
	assign outputwave = (ramp_square_clock)?ampli:Vmin; 
    
endmodule
