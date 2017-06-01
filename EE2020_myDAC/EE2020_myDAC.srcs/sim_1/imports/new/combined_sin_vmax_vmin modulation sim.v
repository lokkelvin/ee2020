`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2017 15:20:24
// Design Name: 
// Module Name: combined_sin_vmax_vmin modulation sim
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


module combined_sin_vmax_vmin_modulation_sim(

    );
    reg CLK;
    reg sw13,sw14,sw15;
	wire SAMP_CLOCK; //1.5kHz
	wire DDS_CLOCK_faster;
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
    wire [11:0]outputwave3 ;
	wire [11:0]outputwave4 ;
	wire [11:0] squarefy_wave;
	wire [11:0] squarefy_invert_wave;
	wire [11:0]combinedwave ;
	wire [11:0]sawtoothwave;
	wire [11:0]	fastsinewave;
	wire [11:0] fastsinewave2;
	wire [11:0] fastsinewave3;
    wire [11:0] fastsinewave4;
	reg [7:0]stepsize;
	reg[10:0]x;
	wire[11:0] test;
	
	assign freqwire = 1000;
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
	clock_divider cd2 (CLK,var_freqwire,DDS_CLOCK_faster);
	clock_divider_custom_wave cd3 (CLK,phasefreqwire,phasefreqclock);  
	clock_divider_custom_wave varfreq (CLK,var_freqwire,var_freq_clock);
	clock_divider_custom_wave doublefreq (CLK,double_freqwire,double_freqclock);
	
	wire fastclock;
	wire [15:0] fastwire;
	assign fastwire = 10000;
	clock_divider fastfreq (CLK,fastwire,fastclock);
		
	//gen_sawtooth_wave sawtoothdut(SAMP_CLOCK,vmax,vmin,sawtoothwave);	
	gen_sine_AM dut1 (SAMP_CLOCK,phasefreqclock,1,fastsinewave,fastsinewave2,outputwave);
	gen_sine_AM dut2 (SAMP_CLOCK,phasefreqclock,1,fastsinewave2,fastsinewave2,outputwave2);
	gen_sin_wave fastsine (SAMP_CLOCK,var_freq_clock,1,vmax,vmin,fastsinewave);
	gen_sin_wave fastsine2 (SAMP_CLOCK,var_freq_clock,0,vmax,vmin,fastsinewave2);
	

	gen_sine_AM dut3 (SAMP_CLOCK,var_freq_clock,1,fastsinewave3,fastsinewave4,outputwave3); 
    gen_sin_wave fastsine3 (SAMP_CLOCK,phasefreqclock,1,vmax,vmin,fastsinewave3);
    gen_sin_wave fastsine4 (SAMP_CLOCK,phasefreqclock,0,vmax,vmin,fastsinewave4);
	wire[11:0] flippingwave; reg [11:0]middle_pivot = 2048;
    gen_sine_AM_two dut4 (SAMP_CLOCK,DDS_CLOCK_faster,phasefreqclock,var_freq_clock,vmax,vmin,middle_pivot,outputwave4,flippingwave);
	//gen_combine_sine_ramp dut2 (double_freqclock,outputwave,sawtoothwave,vmax,vmin,combinedwave);
	//assign test = (fastsinewave/10)+(sawtoothwave/2);
	//assign test = (fastsinewave/10)*(outputwave/2); 
	
	//operation_squarefy squarefy (outputwave, var_freq_clock, squarefy_wave);
 	//operation_squarefy_invert squarefy_invert (outputwave, var_freq_clock,squarefy_invert_wave);
 	
	initial begin
		sw13 = 1; sw14 = 0; sw15 = 0;PULSE_l = 0; PULSE_r = 0; CLK = 0; stepsize = 1; x=0;
/*		#40000000 x = 50; 
		#20000000 x=0; #100 vmin = 12'd1000;*/ 
		#5000000 vmax=12'd3000;
		vmin = 12'd1000; 
		middle_pivot = 1024;
	end
	
	always #5 CLK=~CLK;
endmodule

