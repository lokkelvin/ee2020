`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2017 15:01:31
// Design Name: 
// Module Name: gen_sine_AM
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


module gen_sine_AM(
    input SAMP_CLOCK,
    input phasefreqclock,
    input sin_or_cos,
    input [11:0]Vmax, //sin
    input [11:0]Vmin, //cos
    output [11:0] outputwave
    );
    reg [7:0] test;
    reg [11:0] Vmax_factor;
	reg [7:0]PHASE_IN = (sin_or_cos)?8'b10011011:0; // -PI <= PHASE_IN <= PI
    wire [15:0]M_AXIS_DOUT; // get Y from XY BUS
    reg [11:0]vmaxtemp = 0;
    reg [11:0]vmintemp = 0;
    always @* begin
        Vmax_factor = ((4064+Vmax)-Vmin) / (2*127); //reduce amp to prevent int overflow, when vmax is smaller than vmin
        //translate Vmax up the yaxis by 4064, then scale Vmax and Vmin waveforms by 1/2 in Y axis
        //divide by 127, because cordic outputs 8-bit resolution ==> 128 unique vertical steps
    end
    always @(posedge phasefreqclock)begin
    // --------[Signed Fixed point counter, [6:0] only]-------
    // --------[2Q5, 8_fix5, Number format]-------
    //PHASE_IN == 8'b01100101 <-- pi <==>  
    //PHASE_IN == 8'b0_11_00101 <--- 1 bit sign, 2 bit integer, 5 bit fractional.
    //8'b10011100 <-- (-pi) <== pi in two's complement 
	   PHASE_IN = (PHASE_IN == 8'b01100101) ? 8'b10011100: PHASE_IN + 1; //
    end
    wire tvalid;
    cordic_1 cordic_sin(
        .aclk(SAMP_CLOCK),
        .s_axis_phase_tdata(PHASE_IN), 
        .s_axis_phase_tvalid(1'd1),
        .m_axis_dout_tdata(M_AXIS_DOUT),
        .m_axis_dout_tvalid(tvalid));
    always @(*) begin
        test = M_AXIS_DOUT[15:8]; //gets Y_OUT of DOUT, but doesnt really matter if [7:0] or [15:8]
        if (M_AXIS_DOUT[15])begin //twos complement
            test[7:0] = test[7:0] - 191;
        end
        else begin 
            test = test + (254-191); 
        end
	end
	assign outputwave = (Vmin/2) + ( test * Vmax_factor);		
endmodule



module gen_sine_AM_two( //generates cos and sin
    input DDS_CLOCK,
    input DDS_CLOCK_faster,
    input phasefreqclock, //20*200*freqwire
    input fastphasefreqclock,
    input [11:0]Vmax, //sin
    input [11:0]Vmin, //cos
    input [11:0]pivot,
    output reg[11:0] dumplingwave,
    output reg[11:0] flippingwave
    );
    
    reg [7:0] YOUT=0; //upper bound
    reg [11:0] YOUT_scaled=0;
    reg [7:0] YOUT2=0; //lower bound
    reg [7:0] YOUT3=0; //fast carrier sine
    reg [11:0] YOUT3_scaled=0;
	reg [7:0]PHASE_IN = 8'b10011011; // -PI <= PHASE_IN <= PI
	reg [7:0]PHASE_IN2 = 8'b0; // pi out of phase of phase_in
	reg [7:0]PHASE_IN3 = 8'b10011011; // -PI <= PHASE_IN <= PI
    wire [15:0]M_AXIS_DOUT; // get Y from XY BUS\
    wire [15:0]M_AXIS_DOUT2;
    wire [15:0]M_AXIS_DOUT3;
    reg [11:0]vmaxtemp = 0;
    reg [11:0]vmintemp = 0;
    
    // Upper and Lower bound sine
    always @(posedge phasefreqclock)begin
    //PHASE_IN == 8'b01100101 <-- pi <==>  8'b10011100 <-- (-pi) 
	   PHASE_IN  = (PHASE_IN  == 8'b01100101) ? 8'b10011100: PHASE_IN  + 1; //
	   PHASE_IN2 = (PHASE_IN2 == 8'b01100101) ? 8'b10011100: PHASE_IN2 + 1; //
    end
    
	wire tvalid1,tvalid2,tvalid3;
    cordic_1 cordic_sin_slowerup(
        .aclk(DDS_CLOCK),
        .s_axis_phase_tdata(PHASE_IN), 
        .s_axis_phase_tvalid(1'd1),
        .m_axis_dout_tdata(M_AXIS_DOUT),
        .m_axis_dout_tvalid(tvalid1));
        
	cordic_1 cordic_sin_slowerdown(
	   .aclk(DDS_CLOCK), //change?
	   .s_axis_phase_tdata(PHASE_IN2), 
	   .s_axis_phase_tvalid(1'd1),
	   .m_axis_dout_tdata(M_AXIS_DOUT2),
	   .m_axis_dout_tvalid(tvalid2));
        
	// Carrier Sine
	always @(posedge fastphasefreqclock)begin
           //PHASE_IN == 8'b01100101 <-- pi <==>  8'b10011100 <-- (-pi) 
	   PHASE_IN3 = (PHASE_IN3 == 8'b01100101) ? 8'b10011100: PHASE_IN3 + 1; //
	end
	cordic_1 cordic_sin_faster(
	   .aclk(DDS_CLOCK_faster), //change?
	   .s_axis_phase_tdata(PHASE_IN3), 
	   .s_axis_phase_tvalid(1'd1),
	   .m_axis_dout_tdata(M_AXIS_DOUT3),
		.m_axis_dout_tvalid(tvalid3));
    
    //Code to convert signed 2QN format into unsigned format
    always @(*) begin
        YOUT = M_AXIS_DOUT[15:8]; //gets Y_OUT of DOUT, but doesnt really matter if [7:0] or [15:8]
        if (M_AXIS_DOUT[15]) YOUT[7:0] = YOUT[7:0] - 191;
        else YOUT = YOUT + (254-191); 
	end
	
	always @(*) begin
		YOUT2 = M_AXIS_DOUT2[15:8]; //gets Y_OUT of DOUT, but doesnt really matter if [7:0] or [15:8]
		if (M_AXIS_DOUT2[15]) YOUT2[7:0] = YOUT2[7:0] - 191;
		else YOUT2 = YOUT2 + (254-191); 
		YOUT_scaled = YOUT << 5; //upscale boundary sine into 0-4096 size
	end
	
	always @(*) begin
		YOUT3 = M_AXIS_DOUT3[15:8]; //gets Y_OUT of DOUT, but doesnt really matter if [7:0] or [15:8]
		if (M_AXIS_DOUT3[15]) YOUT3[7:0] = YOUT3[7:0] - 191;
		else YOUT3 = YOUT3 + (254-191); 
		YOUT3_scaled = YOUT3 << 5; //upscale the fastsine into 0-4096 size
	end	
	
	
	wire[11:0] smallpeaktopeak = (Vmax-Vmin)>>1; // Vpp of upper and lower sine = (Vmax-Vmin)/2 
	wire[11:0] middle = Vmin + smallpeaktopeak; //continual assignment shortcut
	
	//Dumpling Waveform
	reg [31:0]upper = 0; //scaled + translated from yout
	reg [31:0]lower = 0; //scaled + translated from yout2
	reg [31:0] temp_dumplingwave; 
	//scaled factor --> getting Amp=(Vmax-middle) from Amp=(128)
	always @ (posedge DDS_CLOCK)begin
		//middle == vmin of upper and vmax of lower
		//find a scaling factor for upper and lower according to middle
		upper = middle + ((YOUT*(smallpeaktopeak))>>7); //yout x (scalefactor) , where scalefactor = ((Vmax-Vmin)/2) / (128) ;
		lower = Vmin + ((YOUT2*(smallpeaktopeak))>>7);
	end
	always @ (*)begin
		temp_dumplingwave = lower + ((YOUT3_scaled * (upper-lower))>>12); //divide by 2^12 because YOUT3_scaled is up to 4096
		dumplingwave = temp_dumplingwave[11:0];
	end
	
	//Flipping Waveform
	reg [31:0]upper2 = 0; //scaled from yout
	reg [31:0]lower2 = 0; 
	reg [31:0]temp_flippingwave;
	wire [11:0]middle_pivot = pivot << 3;
	always @* begin
		if (YOUT_scaled >=middle_pivot)begin
			upper2 = YOUT_scaled;
			lower2 = middle_pivot;
		end
		else begin
			upper2 = middle_pivot;
			lower2 = YOUT_scaled;
		end
	end
	
	always @* begin
		temp_flippingwave = lower2 + ((YOUT3_scaled*(upper2-lower2))>>12);
		flippingwave = temp_flippingwave[11:0];
	end
endmodule