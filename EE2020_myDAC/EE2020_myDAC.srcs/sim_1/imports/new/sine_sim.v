`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2017 01:26:37
// Design Name: 
// Module Name: sine_sim
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


module sine_sim(

    );
    reg CLK;
    reg sw13,sw14,sw15;
	wire DDS_CLOCK;
    wire SLOWER_CLOCK; // 
    wire phasefreqclock;
	wire var_freq_clock;    
    
    wire [15:0]fotfreqwire;
    wire [15:0]freqwire;
	reg PULSE_r = 0;
	reg PULSE_l = 0;
	reg [11:0]vmax = 12'hFFF;
	reg [11:0]vmin = 12'h000;
	reg [11:0]pivot;
	wire [11:0]outputwave ;
	wire [11:0]outputwave2 ;
	wire [11:0] squarefy_wave;
	wire [11:0] squarefy_invert_wave;
	
	reg [7:0]stepsize;
	reg[10:0]x;
	
	assign freqwire = 100-x;
	wire [15:0] phasefreqwire;
	assign phasefreqwire = 200*freqwire;
	wire [15:0] var_freqwire;
	assign var_freqwire = 32*100;
	
    clock_divider_slower cds1 (CLK,SLOWER_CLOCK);
	clock_divider cd1 (CLK,freqwire,DDS_CLOCK);
	clock_divider_custom_wave cd3 (CLK,phasefreqwire,phasefreqclock);
	clock_divider_custom_wave varfreq (CLK,var_freqwire,var_freq_clock);
	
		
	gen_sin_wave dut1 (CLK,DDS_CLOCK,freqwire,pivot,1,vmax,vmin,outputwave);
 	//gen_half_rectified_sine dut2 (SAMP_CLOCK,phasefreqclock,vmax,vmin,outputwave2);
	
	//operation_squarefy squarefy (outputwave, var_freq_clock, squarefy_wave);
 	//operation_squarefy_invert squarefy_invert (outputwave, var_freq_clock,squarefy_invert_wave);
	initial begin
		sw13 = 1; sw14 = 0; sw15 = 0;PULSE_l = 0; PULSE_r = 0; CLK = 0; stepsize = 1; x=0; pivot = 128;
/*		#40000000 x = 50; 
		#20000000 x=0; #100 vmin = 12'd1000; 
		#20000000 vmax=12'd3000;
		#20000000 vmin = 0; */
		#30000000 ; pivot = 384;
		#30000000 ; pivot = 200;
	end
	
	always #5 CLK=~CLK;
endmodule
