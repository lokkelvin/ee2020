`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2017 20:48:45
// Design Name: 
// Module Name: gen_trapezium_wave
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


module gen_trapezium_wave(
	
	input DDS_CLOCK, // clock of 512*freqwire => 512 timebase;
	input [11:0] Vmax,
	input [11:0] Vmin,
	input [11:0] pivot, //valid range from [0,128], labelled as pivot outside of this module.
	output reg [11:0] trapwave	
    );
    wire [11:0]gap;
    assign gap = pivot>>2; //input is 512, output is divided by 2^2, 0-128
    /* 
	//logic 
	1-2 flat delay Gap;
	2-3 Gap ramp to A;
	3-4 A ramp to [B(middle)-Gap]
	4-5 flat delay Gap;
	5-6 flat delay Gap;
	6-7 Gap ramp to C;
	7-8 C ramp to (end - Gap);
	8-9 flat delay Gap;
	|      __B__
	|     /     \
	|   A/       \C
	|___/______ __\____
	|
	*/
	//wire gap = pivot/4;
	reg [9:0] count = 0; //horizontal position on timebase
	reg [9:0] first_ramp_count = 0;
	parameter integer start = 0; //starting timebase
	parameter integer A = 127; // mid of first ramp
	parameter integer B = 255; // mid of wave
	parameter integer C = 383; // mid of second wave
	parameter integer last = 511; //last timebase for 1 cycle
	reg [11:0] trapwavetemp;
    reg [31:0] rampfactor = 0;
    integer a=0;
	integer b=0;
	integer c=0;
	integer d=0;
    always @(posedge DDS_CLOCK)	begin
    	rampfactor = (Vmax-Vmin)/(B - (2* gap));
    	count <= (count == last) ? 0 : count + 1;
    	if (count <= gap ) begin 
    		trapwavetemp <= Vmin;
    	end
    	else if ((count > gap )&&(count <= (B-gap))) begin
    		//ramp
    		trapwavetemp <= trapwavetemp + rampfactor;
    		a <= a+1;
    	end
    	
    	else if ((count <= (B+gap))&&(count > (B-gap))) begin
    		trapwavetemp <= Vmax;
    		b <= b+1;
    	end
    	
    	else if ((count < (last - gap)) &&(count > (B+gap)))begin
    		//ramp down
			trapwavetemp <= trapwavetemp - rampfactor;
			c<=c+1;
    	end
    	
    	else if ((count > (last - gap))&&(count < last)) begin
    		trapwavetemp <= Vmin;
    		d<=d+1;
    	end
    	trapwave <= trapwavetemp;
    end
    	
endmodule
