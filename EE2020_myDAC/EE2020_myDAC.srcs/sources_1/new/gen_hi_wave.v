`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2017 02:33:44
// Design Name: 
// Module Name: gen_hi_wave
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


module gen_hi_wave(
	input DDS_CLOCK,
	input squarefy_clock,
	input [11:0]Vmax,
	input [11:0]Vmin,
	output reg[11:0] hiwave
    );
    reg [9:0]count = 0;
    reg [11:0] upper =0;
    reg [11:0] lower = 0;
	parameter integer start = 0;
    parameter integer last = 511; //last timebase for 1 cycle
    wire [11:0] middle = (Vmax-Vmin)/2;
    always @(posedge DDS_CLOCK)begin
    	count <= (count == last)?0:count+1;
    	if ((count>=start)&& (count <=85)) begin
    		upper = Vmax;
    		lower = Vmin;
    	end
    	else if ((count>=86)&& (count <=171)) begin
			upper = (middle) + Vmin + ((Vmax-Vmin)>>3);
			lower = (middle) + Vmin - ((Vmax-Vmin)>>3);
		end
		else if ((count >171) && (count <= 256))begin
			upper = Vmax;
			lower = Vmin;
		end
		else if ((count >256) && (count <= 341))begin
			upper = Vmin;
			lower = Vmin;
		end
		else if ((count>341)&& (count <=426)) begin
			upper = Vmax;
			lower = Vmin;
		end
		else begin
			upper = Vmin;
			lower = Vmin;
		end
    end
    reg on = 0;	
	always @(posedge squarefy_clock) begin
		if (on==0)	hiwave <= upper;
		else hiwave <= lower;
		on <= ~on;
	end
    
endmodule
