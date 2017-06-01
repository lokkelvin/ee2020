`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2017 21:58:15
// Design Name: 
// Module Name: sawtooth_sim
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


module sawtooth_sim(

    );
    reg CLK;
    reg sw13,sw14,sw15;
	wire DDS_CLOCK; //1.5kHz
    wire SLOWER_CLOCK; // 
    wire [11:0]freqwire;
	reg PULSE_r = 0;
	reg PULSE_l = 0;
	reg [11:0]vmax = 12'hFFF;
	reg [11:0]vmin = 12'h000;
	reg [11:0]pivot = 0;
	wire [11:0]sawtoothwave ;
	wire [11:0]sawtoothwave2;
	wire [11:0]trapwave;
	reg [7:0]stepsize;
	assign freqwire = 12'd100;
	clock_divider cd1 (CLK,{{4{0}},freqwire},DDS_CLOCK);
	gen_sawtooth_wave sawtooth1 (DDS_CLOCK,vmax,vmin,pivot,sawtoothwave,sawtoothwave2);
	gen_trapezium_wave trapwave1 (DDS_CLOCK,vmax,vmin,pivot,trapwave);
	
	
	initial begin
		sw13 = 1; sw14 = 0; sw15 = 0;PULSE_l = 0; PULSE_r = 0; CLK = 0; stepsize = 1;pivot = 0;
		#25000000 ;
		vmax = 3500;
		vmin = 1000;
		pivot = 64;
		#25000000 ;
		pivot = 180;
		vmin = 0;
		vmax = 4095;
	end
	
	always #5 CLK=~CLK;
endmodule
