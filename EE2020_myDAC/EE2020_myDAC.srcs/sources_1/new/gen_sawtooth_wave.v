`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2017 23:57:28
// Design Name: 
// Module Name: gen_sawtooth_wave
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


module gen_sawtooth_wave(
	input DDS_CLOCK, //512 times of waveclock
	input [11:0]Vmax,
	input [11:0]Vmin,
	input [11:0]pivot, //Max = number of timebase = 512 <-- depends on DDS_clock
	output reg [11:0]outputwave,
	output reg [11:0]outputwave2

    );
    reg [9:0]count = 0; //internal counter for 512 clock cycles.
    //reg [9:0]pivot = 0; //point to pivot the waveform to make duty cycle
    reg [31:0] leftfactor = 0;
    reg [31:0] rightfactor = 0;
    reg [31:0] outputwave2_temp = 0;
	//reg [11:0]outputwave = 0; //for debugging
	parameter integer start = 0;
    parameter integer last = 511; //last timebase for 1 cycle
    
    /****************************************
    Logic
    left : 0 - (pivot-1)
    right : pivot - (last-1)
    leftrightfactor = (vmax-vmin)/(timebase)*/
    
    
    always @(posedge DDS_CLOCK)begin
    	outputwave <= Vmin + (count * ((Vmax-Vmin+1)/512));
    	leftfactor = (pivot == 0)? 0 : ((Vmax-Vmin+1))/((pivot-1)+1);
    	rightfactor = (pivot == last) ? 0 : ( (Vmax-Vmin+1)/(last - pivot +1) ) ;
    	
    	if ((count == start )|| (count == last)) begin
    		outputwave2_temp = (pivot==0)?Vmax: 0;//starting point only starts vmax for a rising ramp, else all start at 0
		end
    	
    	else if (count<pivot) begin
    		outputwave2_temp = outputwave2 + leftfactor;
    	end //end left loop
    	
    	else if (count>=pivot)begin
			outputwave2_temp = (outputwave2_temp > rightfactor)?(outputwave2_temp - rightfactor):0;
    	end//end right loop							
    			 
    	outputwave2 = outputwave2_temp[11:0];
    	count <= (count == last)?0:count+1; //reset count after it reaches last timebase (511)
    end
    
endmodule
