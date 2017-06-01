`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2017 00:17:37
// Design Name: 
// Module Name: gen_tri_wave
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


module gen_tri_wave(
	input SAMP_CLOCK, //256 times of waveclock
	input [11:0]Vmax,
	input [11:0]Vmin,
	output reg [11:0]outputwave
    );
    reg [9:0]count = 0; 
    reg direction=1; //rising
    always @(posedge SAMP_CLOCK)begin
    	outputwave = (direction)? Vmin + (count * ((Vmax-Vmin)/256)) : (Vmin + (256 * ((Vmax-Vmin)/256))) - (Vmin + ((count-256) * ((Vmax-Vmin)/256)));// Vmin + (Vmin + (count * ((Vmax-Vmin)/256)))-((count * ((Vmax-Vmin)/256))) ;
    	if (count == 10'd256)begin
    		count <= count +1;
    		direction = 0;//falling
    	end
    	else if (count == 10'd512)begin
    		count <= 0;
    		direction = 1;
    	end
    	
    	else begin
    		count <= count+1;
    	end 
    end
    
endmodule
