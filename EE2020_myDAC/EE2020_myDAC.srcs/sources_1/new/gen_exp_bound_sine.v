`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2017 01:36:51
// Design Name: 
// Module Name: gen_exp_bound_sine
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
/*module gen_exp_bound_sin_wave (
	input DDS_CLOCK,
	input var_freq_clock,
	input [11:0] freqwire,
	input [11:0] Vmax,
	input [11:0] Vmin,
	output [11:0] boundsine
	);
	
	wire [11:0] sinewave;
	//gen Vmax,Vmin, push to sine wave
	gen_sin_wave sine_for_exp (DDS_CLOCK,var_freq_clock,1,Vmax,Vmin,sinewave);
	

endmodule*/



module gen_sin_wave(
    input DDS_CLOCK,
    input phasefreqclock,
    input sin_or_cos,
    input [11:0]Vmax,
    input [11:0]Vmin,
    output [11:0] outputwave
    );
    reg [7:0] test;
    reg [11:0] Vmax_factor;
    reg [7:0]PHASE_IN = (sin_or_cos)?8'b10011011:0; // -PI <= PHASE_IN <= PI
    wire [15:0]M_AXIS_DOUT; // get Y from XY BUS
    
    always @* begin
    Vmax_factor = (Vmax-Vmin) / 127;
    end
    
    always @(posedge phasefreqclock)begin
        // --------[Signed Fixed point counter, [6:0] only]-------
        // --------[2Q5, 8_fix5, Number format]-------
        //PHASE_IN == 8'b01100101 <-- pi <==>  
        //PHASE_IN == 8'b0_11_00101 <--- 1 bit sign, 2 bit integer, 5 bit fractional.
        //8'b10011100 <-- (-pi) <== pi in two's complement 
        PHASE_IN = (PHASE_IN == 8'b01100101) ? 8'b10011100: PHASE_IN + 1; //
    end
    
    /*    cordic_0 cordic_sin(
        .aclk(DDS_CLOCK),
        .s_axis_phase_tdata(PHASE_IN), 
        
        .m_axis_dout_tdata(M_AXIS_DOUT));*/
        
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
