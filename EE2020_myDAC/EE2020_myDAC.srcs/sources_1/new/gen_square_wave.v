`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2017 23:18:08
// Design Name: 
// Module Name: gen_square_wave
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


module gen_square_wave(
	input DDS_CLOCK,
	input waveclock,
	input HF_toggle,
	input [11:0]Vmax,
	input [11:0]Vmin,
	input [11:0] pivot,
	output [11:0] squarewave
    );
    reg [9:0] count;
	parameter integer start = 0;
	parameter integer last = 511; //last timebase for 1 cycle
    reg [11:0]squarewave_dds;
    reg [11:0]squarewave_flip;
    assign squarewave = (HF_toggle)?squarewave_flip:squarewave_dds;
    always @(posedge DDS_CLOCK)begin
    	count <= (count == last)? 0 : count + 1;
    	if (count < pivot) begin
    		squarewave_dds <= Vmax;
    	end
    	else begin
    		squarewave_dds <= Vmin;
    	end
    end
    reg flip = 0;
    always @ (posedge waveclock) begin
    	squarewave_flip <= (flip)?(Vmax):Vmin;
    	flip <= flip + 1;
    end
    
endmodule
