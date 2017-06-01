`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2017 02:51:53
// Design Name: 
// Module Name: change_wave_freq
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

//n is the intended freq of waveform, from 1-100hz
//outputclock outputs freq close to n
module change_wave_freq(
	input CLOCK,
	input SLOWER_CLOCK,
	input RESET,
	input abtoggle,
	input HF_toggle,
	input sw13,sw14,sw15,
	input btnL,btnR,
	input [11:0]stepsize_input,
	input PULSE_l,PULSE_r,
	output reg [27:0] frequency,
	output reg [27:0] frequency2,
	output reg outputclock,
	output reg outputclock2
    );
    //channel A
    reg [27:0]count = 28'b0; // to hold up to (100 x 10^6)
    reg [27:0]n = 12'd100; // changed from 8 bits to 27 because f goes to 10khz now
    
    //channel B
    reg [27:0]count2 = 28'b0; // to hold up to (100 x 10^6)
	reg [27:0]n2 = 12'd100; // changed from 8 bits to 27 because f goes to 10khz now
    
    wire [27:0]stepsize;
    assign stepsize = (HF_toggle)?stepsize_input*100:stepsize_input;
    parameter _MAXFREQ = 200000; //100kHz
    parameter _MINFREQ = 0;

	initial begin
		outputclock = 0;
		outputclock2 = 0;
	end

	always @ (posedge CLOCK)begin
	   //when count = 50*10^6 / desired_f, that number of clock cycles gives us desired_freq
    	count <= (count >= (50000000/n))?0:count+1; 
    	outputclock = (count == 0)?~outputclock:outputclock;
    	count2 <= (count2 >= (50000000/n2))?0:count2+1; 
		outputclock2 = (count2 == 0)?~outputclock2:outputclock2;
    end
    
    reg [7:0] hold_count=0;
    always @ (posedge SLOWER_CLOCK)begin
    	if (RESET) begin
    		n = 100;
    		n2 = 100;
    	end
    	//Hold count to implement the Hold button function
		//When L or R is held, hold_count begins incrementing
		//Action triggers when hold_cout >= 50 (at 47Hz is around 1 second of button press time)
        if (btnL || btnR) begin
            hold_count <= hold_count + 1;
        end
        else if (~(btnL || btnR))begin
            hold_count <= 0;
        end
        
        //Logic 
        //-->n is the temp variable for frequency
        //n can never go below MINFREQ
        //n can never go above MAXFREQ
        
    	if (~sw15 && ~sw14 && sw13 && PULSE_l)begin
    		if (~abtoggle) n <= ((n + stepsize )<_MAXFREQ)? n + stepsize : _MAXFREQ;
    		else n2 <= ((n2 + stepsize )<_MAXFREQ)? n2 + stepsize : _MAXFREQ;
    	end
    	else if (~sw15 && ~sw14 && sw13 && PULSE_r) begin
    		if (~abtoggle) n <= (n > stepsize)? n - stepsize : _MINFREQ;
    		else  n2 <= (n2 > stepsize)? n2 - stepsize : _MINFREQ;
    	end
    	else if (~sw15 && ~sw14 && sw13 && btnL && ~PULSE_l && hold_count >= 50)begin
    	    if (~abtoggle) n <= ((n + stepsize )<_MAXFREQ)?n+stepsize:_MAXFREQ;
    	    else  n2 <= ((n2 + stepsize )<_MAXFREQ)? n2 + stepsize : _MAXFREQ;
    	end
    	else if (~sw15 && ~sw14 && sw13 && btnR && ~PULSE_r && hold_count >= 50)begin
            if (~abtoggle) n <= (n > stepsize)?n-stepsize:_MINFREQ;
            else n2 <= (n2 > stepsize)? n2 - stepsize : _MINFREQ;
        end
        
    	frequency <= n;
    	frequency2 <= n2;
    end
endmodule
