`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2017 18:05:15
// Design Name: 
// Module Name: change_wave_amp
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


module change_wave_amp(
	input CLOCK, //100mhz
	input SLOWER_CLOCK,
	input RESET,
	input abtoggle,
	input sw11, //duty cycle
	input sw12, //volts toggle
	input sw13, //freq toggle currenly unused
	input sw14, //vmin toggle
	input sw15, //vmax toggle
	input btnU,btnD,
	input [11:0]input_stepsize,
	input PULSE_u,PULSE_d,
	output reg [11:0] Vmax,
	output reg [11:0] Vmin,
	output reg [11:0] voltmax, //outputs vmax in terms of (0-3.3v) *1000, represented as 3300v. 
	output reg [11:0] voltmin,
	output reg [11:0] pivotout,
	output reg [11:0] Vmax2,
	output reg [11:0] Vmin2,
	output reg [11:0] voltmax2, //outputs vmax in terms of (0-3.3v) *1000, represented as 3300v. 
	output reg [11:0] voltmin2,
	output reg [11:0] pivotout2
    );
    
    //channel A
    reg [12:0] Vmaxtemp = 13'hFFF; //4095. // Set to 13 bits to avoid overflow when adding or subtracting stepstep.
	reg [12:0] Vmintemp = 13'b0;
	reg [27:0]voltmaxtemp = 0;
	reg [27:0]voltmintemp = 0;
    reg [11:0] pivottemp = 255;
    
    //channel B
    reg [12:0] Vmaxtemp2 = 13'hFFF; //4095. // Set to 13 bits to avoid overflow when adding or subtracting stepstep.
	reg [12:0] Vmintemp2 = 13'b0;
	reg [27:0]voltmaxtemp2 = 0;
	reg [27:0]voltmintemp2 = 0;
	reg [11:0] pivottemp2 = 255;
	//common
    reg [7:0] hold_count=0;
    
    parameter integer voltage_stepsize1 = 124; //stepsize of Vmax/Vmin to increase/decrease volts by 0.1V
    parameter integer voltage_stepsize2 = 248; 
    parameter integer voltage_stepsize3 = 1241; 
    parameter integer _MAXPIVOT = 511;
    parameter integer _MINPIVOT = 0;
    			
	reg [27:0]stepsize;
	always @* begin
		case(input_stepsize)
			10: stepsize <= (sw12)?voltage_stepsize1:input_stepsize;
			100: stepsize <= (sw12)?voltage_stepsize2:input_stepsize;
			1000: stepsize <= (sw12)?voltage_stepsize3:input_stepsize;
			default: stepsize <= input_stepsize;
		endcase
	end
	
	//parameter integer stepsize = 12'd10;
	always @(posedge SLOWER_CLOCK) begin
		if (RESET) begin
			Vmaxtemp = 13'hFFF;
			Vmintemp = 13'b0;
			pivottemp = 255;
			Vmaxtemp2 = 13'hFFF;
			Vmintemp2 = 13'b0;
			pivottemp2 = 255;
		end
		//Hold count to implement the Hold button function
		//When U or D is held, hold_count begins incrementing
		//Action triggers when hold_cout >= 50 (at 47Hz is around 1 second of button press time)
		if (btnU || btnD) begin
			hold_count <= hold_count + 1;
		end
		else if (~(btnU || btnD))begin
			hold_count <= 0;
		end
		
		//Logic 
		//-> Vmax and Vmin are independently adjustable
		// Vmax can never go below Vmin
		// Vmin can never go above Vmax
		
		if (sw15 && ~sw14 && ~sw11) begin //adjust vmax
			//if (~sw12) begin
				//Vmax
			if (PULSE_u)begin
				if (~abtoggle) Vmaxtemp <= ((Vmaxtemp) < (12'hFFF - stepsize))?(Vmaxtemp + stepsize):12'hFFF;
				else Vmaxtemp2 <= ((Vmaxtemp2) < (12'hFFF - stepsize))?(Vmaxtemp2 + stepsize):12'hFFF;
			end
			else if (PULSE_d) begin
				if (~abtoggle) Vmaxtemp <= (((Vmaxtemp - stepsize) >= Vmintemp)&& (Vmaxtemp >= Vmintemp+stepsize) )? (Vmaxtemp - stepsize) : Vmaxtemp; //vmax will not decrement if overlaps vmin
				else Vmaxtemp2 <= (((Vmaxtemp2 - stepsize) >= Vmintemp2)&& (Vmaxtemp2 >= Vmintemp2+stepsize) )? (Vmaxtemp2 - stepsize) : Vmaxtemp2;
			end
			else if (btnU && hold_count >= 50) begin
				if (~abtoggle) Vmaxtemp <= ((Vmaxtemp) < (12'hFFF - stepsize))?(Vmaxtemp + stepsize):12'hFFF;	
				else Vmaxtemp2 <= ((Vmaxtemp2) < (12'hFFF - stepsize))?(Vmaxtemp2 + stepsize):12'hFFF;
			end
			else if (btnD && hold_count >= 50) begin
				if (~abtoggle) Vmaxtemp <= ((Vmaxtemp>=(Vmintemp+stepsize)) && ((Vmaxtemp - stepsize) >= Vmintemp)) ? (Vmaxtemp - stepsize) : Vmaxtemp;	//redundancy to prevent overflow on both ends
				else Vmaxtemp2 <= ((Vmaxtemp2>=(Vmintemp2+stepsize)) && ((Vmaxtemp2 - stepsize) >= Vmintemp2)) ? (Vmaxtemp2 - stepsize) : Vmaxtemp2;
				//example overflow when Vmax = 3 , Vmin = 0, stepsize = 10 | (Vmax - stepsize) >= Vmin -->overflow
			end
		end //adjust vmax
		
		else if (~sw15 && sw14 && ~sw11)begin//adjust vmin
			if (PULSE_u)begin
				if (~abtoggle) Vmintemp <= (((Vmintemp+stepsize) <= Vmaxtemp) && (Vmintemp <= (Vmaxtemp-stepsize)))?(Vmintemp + stepsize):Vmintemp;	//so that lower bound never touches upper bound
				else Vmintemp2 <= (((Vmintemp2+stepsize) <= Vmaxtemp2) && (Vmintemp2 <= (Vmaxtemp2-stepsize)))?(Vmintemp2 + stepsize):Vmintemp2;
			end
			else if (PULSE_d) begin
				if (~abtoggle) Vmintemp <= (Vmintemp >= stepsize) ? Vmintemp - stepsize : 12'd0;
				else Vmintemp2 <= (Vmintemp2 >= stepsize) ? Vmintemp2 - stepsize : 12'd0;
			end
			else if (btnU && hold_count >= 50) begin
				if (~abtoggle) Vmintemp <= ((Vmintemp <= (Vmaxtemp-stepsize))&&((Vmintemp+stepsize) <= Vmaxtemp))?(Vmintemp + stepsize):Vmintemp;
				else Vmintemp2 <= ((Vmintemp2 <= (Vmaxtemp2-stepsize))&&((Vmintemp2+stepsize) <= Vmaxtemp2))?(Vmintemp2 + stepsize):Vmintemp2;
				// example overflow when Vmin = 4094 , Vmax = 4095 and stepsize = 10| Vmin+stepsize < Vmax --> overflow
			end
			else if (btnD && hold_count >= 50) begin
				if (~abtoggle) Vmintemp <= (Vmintemp >= stepsize) ? Vmintemp - stepsize : 12'd0;
				else Vmintemp2 <= (Vmintemp2 >= stepsize) ? Vmintemp2 - stepsize : 12'd0;
			end
		end //adjust vmin
		
		else if (sw15 && sw14  && ~sw11) begin //adjust dc offset
			if (PULSE_u) begin
				if ((Vmaxtemp) < (12'hFFF - stepsize) && (~abtoggle))begin
					Vmaxtemp <= (Vmaxtemp + stepsize);
					Vmintemp <= (Vmintemp + stepsize);
				end
				if ((Vmaxtemp2) < (12'hFFF - stepsize) && (abtoggle))begin
					Vmaxtemp2 <= (Vmaxtemp2 + stepsize);
					Vmintemp2 <= (Vmintemp2 + stepsize);
				end		
			end
			
			else if (PULSE_d) begin
				if ((Vmintemp >= stepsize ) && ~abtoggle)  begin
					Vmaxtemp <= (Vmaxtemp - stepsize);
					Vmintemp <= Vmintemp - stepsize;
				end
				if ((Vmintemp2 >= stepsize ) && abtoggle)  begin
					Vmaxtemp2 <= (Vmaxtemp2 - stepsize);
					Vmintemp2 <= Vmintemp2 - stepsize;
				end
			end
		end //adjust dc offset
		
		else if (~sw15 && ~sw14 && ~sw12 && sw11)begin //adjust pivot for duty cycle
			if (PULSE_u)begin
				if (~abtoggle) pivottemp <= (((pivottemp+stepsize) <= _MAXPIVOT) && (pivottemp < (_MAXPIVOT - stepsize)))?(pivottemp + stepsize):pivottemp;	//so that lower bound never touches upper bound
				else pivottemp2 <= (((pivottemp2+stepsize) <= _MAXPIVOT) && (pivottemp2 < (_MAXPIVOT - stepsize)))?(pivottemp2 + stepsize):pivottemp2; 
			end
			else if (PULSE_d) begin
				if (~abtoggle) pivottemp <= (pivottemp >= (stepsize+_MINPIVOT)) ? pivottemp - stepsize : 12'd0;
				else pivottemp2 <= (pivottemp2 >= (stepsize+_MINPIVOT)) ? pivottemp2 - stepsize : 12'd0;
			end
			else if (btnU && hold_count >= 50) begin
				if (~abtoggle) pivottemp <= ((pivottemp <= (_MAXPIVOT-stepsize))&&((pivottemp+stepsize) <= _MAXPIVOT))?(pivottemp + stepsize):pivottemp;
				else pivottemp2 <= ((pivottemp2 <= (_MAXPIVOT-stepsize))&&((pivottemp2+stepsize) <= _MAXPIVOT))?(pivottemp2 + stepsize):pivottemp2;
			end
			else if (btnD && hold_count >= 50) begin
				if (~abtoggle) pivottemp <= (pivottemp >= (stepsize+_MINPIVOT)) ? pivottemp - stepsize : 12'd0;
				else pivottemp2 <= (pivottemp2 >= (stepsize+_MINPIVOT)) ? pivottemp2 - stepsize : 12'd0;
			end		
		end
		Vmax = Vmaxtemp[11:0]; // Truncate 13 bits VmaxTemp to 12 bits Vmax
		Vmin = Vmintemp[11:0];
		Vmax2 = Vmaxtemp2[11:0];
		Vmin2 = Vmintemp2[11:0];
	end 
	always @* begin
		voltmaxtemp <= (Vmaxtemp * 1000 / 4096) * 3300 /1000;
		voltmintemp <= (Vmintemp * 1000 / 4096) * 3300 /1000;
		//voltmintemp <= (((Vmintemp << 10) >> 12 ) * 3300) >> 10;
		voltmax = voltmaxtemp[11:0];
		voltmin = voltmintemp[11:0];
	end
	always @* begin
		voltmaxtemp2 <= (Vmaxtemp2 * 1000 / 4096) * 3300 /1000;
		voltmintemp2 <= (Vmintemp2 * 1000 / 4096) * 3300 /1000;
		//voltmintemp <= (((Vmintemp << 10) >> 12 ) * 3300) >> 10;
		voltmax2 = voltmaxtemp2[11:0];
		voltmin2 = voltmintemp2[11:0];
	end
	
	always @* begin
		pivotout = pivottemp;
	end
	
	always @* begin
		pivotout2 = pivottemp2;
	end
endmodule
