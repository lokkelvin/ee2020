`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2017 20:08:04
// Design Name: 
// Module Name: sinefy_sim
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


module sinefy_sim(

    );
    reg CLK;
    reg sw13,sw14,sw15;
	wire SAMP_CLOCK; //1.5kHz
    wire SLOWER_CLOCK; // 
    wire phasefreqclock;   
    wire double_freqclock;
    
    wire [15:0]fotfreqwire;
    wire [15:0]freqwire;
	reg PULSE_r = 0;
	reg PULSE_l = 0;
	reg [11:0]vmax = 12'hFFF;
	reg [11:0]vmin = 12'h000;
	wire [11:0]outputwave ;
	wire [11:0]outputwave2 ;
    wire [11:0]slowsinewave ;
	wire [11:0] squarefy_wave;
	wire [11:0] squarefy_invert_wave;
	wire [11:0]combinedwave ;
	wire [11:0]sawtoothwave;
	wire [11:0]	fastsinewave;
	wire [11:0] fastsinewave2;
	wire [11:0] fastsinewave3;
    wire [11:0] fastsinewave4;
	wire [11:0] sinefywave;
    wire [11:0] sinefywave2;
	reg [7:0]stepsize;
	reg[10:0]x;
	wire[11:0] test;
	
	assign freqwire = 100;
	wire [27:0] phasefreqwire;
	assign phasefreqwire = 200*freqwire;

	wire [27:0] double_freqwire;
	assign double_freqwire = 100;
	
	wire [27:0] var_freqwire;
	assign var_freqwire = 20*200*freqwire;
	wire var_freq_clock; 
	
	wire [27:0] var_freqwire2;
	assign var_freqwire2 = 2*200*freqwire;
	wire var_freq_clock2; 
	clock_divider_custom_wave varfreq2 (CLK,var_freqwire2,var_freq_clock2);
	
    clock_divider_slower cds1 (CLK,SLOWER_CLOCK);
	clock_divider cd1 (CLK,freqwire,SAMP_CLOCK);
	clock_divider_custom_wave cd3 (CLK,phasefreqwire,phasefreqclock);  
	clock_divider_custom_wave varfreq (CLK,var_freqwire,var_freq_clock);
	clock_divider_custom_wave doublefreq (CLK,double_freqwire,double_freqclock);
	
	gen_square_wave squarewave1(SAMP_CLOCK,vmax,vmin,outputwave);
	gen_sin_wave slowsine (SAMP_CLOCK,phasefreqclock,1,vmax,vmin,slowsinewave);
	gen_sin_wave fastsine (SAMP_CLOCK,var_freq_clock,1,vmax,vmin,fastsinewave);
	operation_sinefy sinefy (CLK,var_freq_clock,slowsinewave,vmin,sinefywave);
	gen_sin_wave sinefy2 (SAMP_CLOCK,var_freq_clock,1,slowsinewave,vmin,sinefywave2);
 	//operation_squarefy_invert squarefy_invert (outputwave, var_freq_clock,squarefy_invert_wave);
 	
	initial begin
		sw13 = 1; sw14 = 0; sw15 = 0;PULSE_l = 0; PULSE_r = 0; CLK = 0; stepsize = 1; x=0;
/*		#40000000 x = 50; 
		#20000000 x=0; #100 vmin = 12'd1000; 
		#20000000 vmax=12'd3000;
		#20000000 vmin = 0; */
	end
	
	always #5 CLK=~CLK;
endmodule

