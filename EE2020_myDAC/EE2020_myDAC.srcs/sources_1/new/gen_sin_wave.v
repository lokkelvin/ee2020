`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2017 17:58:06
// Design Name: 
// Module Name: gen_sin_wave
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


/*
module gen_sin_wave(
	input CLK,
    input DDS_CLOCK,
    input [11:0] freqwire,
    input [11:0] pivot, //255 for a normal sine wave
    input sin_or_cos,
    input [11:0]Vmax,
    input [11:0]Vmin,
    output [11:0] outputwave
    );
    wire [31:0] leftfreq;
    wire [31:0] rightfreq;
    reg phasefreqclock = 0;
    parameter integer start = 0;
    parameter integer last = 511;
    reg reset;
	reg [7:0] test;
	reg [11:0] Vmax_factor; //for multiplying with the final sine.
	reg [7:0]PHASE_IN = (sin_or_cos)?8'b10011011:0; // -PI <= PHASE_IN <= PI
	wire [15:0]M_AXIS_DOUT; // get Y from XY BUS
    
*//*
    //Logic
    Leftfreq = (end-start)/(pivot-start ) * F_desired
    Rightfreq = (end-start)/(end - pivot) * F_desired
    *//*
   
    assign leftfreq = 50000000/((((last - start +1 )* 200) / (pivot - start + 1) ) * freqwire); //care for int trancation
    assign rightfreq = 50000000/(((last - start +1 )* 200/(last-pivot)) * freqwire); //care for int truncation
    
    reg [27:0] clockcounter = 0;
    reg [9:0] h_pos = 0; //current timebase position count on x asis
	reg [7:0]phasecount = 0;
    
    //Clock that changes output freq according to h_pos
    always @ (posedge CLK) begin
    	if (phasecount <= 50) begin
    		clockcounter <= (clockcounter >= (leftfreq))? 0 : clockcounter + 1 ;
    	end
    	else begin
    		clockcounter <= (clockcounter >= (rightfreq))? 0 : clockcounter + 1 ;
    	end
    	phasefreqclock <= (clockcounter == 0) ? ~phasefreqclock : phasefreqclock;
    end
    
    always @ (posedge DDS_CLOCK)begin
    	h_pos <= (h_pos == 511) ? 0 : h_pos + 1;
    	PHASE_IN <= ((PHASE_IN == 8'b01100101)) ? 8'b10011100: PHASE_IN + 1; //
		phasecount<= ((PHASE_IN == 8'b01100101))?0 : phasecount+1;
    end
    
    
    always @* begin
    Vmax_factor = (Vmax-Vmin) / 127; // 127 veritical steps from cordic
    end
	
    cordic_1 cordic_sin(
        .aclk(DDS_CLOCK),
        .s_axis_phase_tdata(PHASE_IN), 
        .s_axis_phase_tvalid(1'd1),
        .m_axis_dout_tdata(M_AXIS_DOUT));
    
    always @(*) begin
    test = M_AXIS_DOUT[15:8];
	if (M_AXIS_DOUT[15])begin //twos complement
		test[7:0] = test[7:0] - 191;
	end
	else begin test = test + (254-191); end
	end

	assign outputwave = Vmin + ( test * Vmax_factor);	

	
	 
endmodule
*/


module gen_sin_wave2( //sine wave with duty cycle
	input CLK,
    input DDS_CLOCK,
    input [11:0] freqwire,
    input [11:0] pivot,
    input sin_or_cos,
    input [11:0]Vmax,
    input [11:0]Vmin,
    output [11:0] outputwave
    );
    reg [31:0] leftfreq;
    reg [31:0] rightfreq;
    reg [31:0] desiredfreq;
    reg phasefreqclock = 0;
    parameter integer start = 0;
    parameter integer last = 511;
    
    reg [27:0] clockcounter = 0;
    reg [9:0] h_pos = 0; //current timebase position count on x asis
    
    //Logic
    //Leftfreq = (end-start)/(pivot-start ) * F_desired
   // Rightfreq = (end-start)/(end - pivot) * F_desired
//    assign leftfreq = 50000000/((((last - start +1 )* 100) / (pivot - start + 1) ) * freqwire); //care for int trancation
//    assign rightfreq = 50000000/(((last - start +1 )* 100/(last-pivot)) * freqwire); //care for int truncation
    always @* begin
    	if (h_pos <= pivot) desiredfreq = 50000000/((((last - start +1 )* 100) / (pivot - start + 1) ) * freqwire); //care for int trancation
    	else desiredfreq = 50000000/(((last - start +1 )* 100/(last-pivot)) * freqwire); //care for int truncation
    end
    
    always @ (posedge CLK) begin //MUX between 2 different clocks
		clockcounter <= (clockcounter >= (desiredfreq))? 0 : clockcounter + 1 ;
		phasefreqclock <= (clockcounter == 0) ? ~phasefreqclock : phasefreqclock;
	end
    
    always @ (posedge DDS_CLOCK)begin
    	h_pos <= (h_pos == 511) ? 0 : h_pos + 1;
    end
    
    reg [7:0] test;
    reg [11:0] Vmax_factor; //for multiplying with the final sine.
	reg [7:0]PHASE_IN = (sin_or_cos)?8'b10011011:0; // -PI <= PHASE_IN <= PI
    wire [15:0]M_AXIS_DOUT; // get Y from XY BUS
    
    always @* begin
    Vmax_factor = (Vmax-Vmin) / 127; // 127 veritical steps from cordic
    end
	
    always @(posedge phasefreqclock)begin
    // --------[Signed Fixed point counter, [6:0] only]-------
    // --------[2Q5, 8_fix5, Number format]-------
    //PHASE_IN == 8'b01100101 <-- pi <==>  
    //PHASE_IN == 8'b0_11_00101 <--- 1 bit sign, 2 bit integer, 5 bit fractional.
    //8'b10011100 <-- (-pi) <== pi in two's complement 
		PHASE_IN <= ((PHASE_IN == 8'b01100101)) ? 8'b10011100: PHASE_IN + 1; //
    end
    wire tvalid;
    cordic_1 cordic_sin(
        .aclk(DDS_CLOCK),
        .s_axis_phase_tdata(PHASE_IN), 
        .s_axis_phase_tvalid(1'd1),
        .m_axis_dout_tdata(M_AXIS_DOUT),
        .m_axis_dout_tvalid(tvalid));
    
    always @(*) begin
    test = M_AXIS_DOUT[15:8];
	if (M_AXIS_DOUT[15])begin //twos complement
		test[7:0] = test[7:0] - 191;
	end
	else begin test = test + (254-191); end
	end

	assign outputwave = Vmin + ( test * Vmax_factor);	

	
	 
endmodule