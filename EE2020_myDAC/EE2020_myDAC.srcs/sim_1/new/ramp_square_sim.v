`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2017 19:04:05
// Design Name: 
// Module Name: ramp_square_sim
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


module ramp_square_sim(

    );
    reg clk;
    reg sw13,sw14,sw15;
	wire SAMP_CLOCK; //1.5kHz
    wire SLOWER_CLOCK; // 
    wire rampclock;
    wire [11:0]freqwire;
	reg PULSE_r = 0;
	reg PULSE_l = 0;
	reg [7:0]stepsize = 10;
	reg [11:0]vmax = 12'hFFF;
	reg [11:0]vmin = 12'h000;
	wire [11:0]outputwave ;
	assign freqwire = 100;
    clock_divider_slower cds1 (clk,SLOWER_CLOCK);
	clock_divider cd1 (clk,freqwire,SAMP_CLOCK);
	clock_divider ramp_square_clock_div1 (clk,freqwire*8,rampclock);
	gen_ramp_square_wave dut1 (rampclock,SAMP_CLOCK,vmax,vmin,outputwave);
	
	
	initial begin
		sw13 = 1; sw14 = 0; sw15 = 0;PULSE_l = 0; PULSE_r = 0; clk = 0; stepsize = 1;
		#5000000 ;
	end
	
	always #5 clk=~clk;
endmodule
