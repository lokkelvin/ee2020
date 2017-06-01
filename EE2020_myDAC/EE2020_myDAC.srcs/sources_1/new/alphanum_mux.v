`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 23:10:42
// Design Name: 
// Module Name: alphanum_mux
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


module alphanum_mux(
//takes in a selector
//outputs 4'b hex which is hardcoded to ssd_cathode
//to form words and numbers according to ssd_clock refresh rate

//make 4 digits, abcd
//force values into a, b, c, d
//let the top_logic switch case do the multiplexing

//switches to choose
//1 vmax sw15
//2 vmin sw14
//3 freq sw 13

//or 
//cycle with left right, and light the corresponding led
//1 vmax
//2 vmin
//3 freq

//or
//cycle with left right, and ssd the name,vmin,vmax
	//input funct_clock
	input abtoggle,
	input HF_toggle,sw10,sw11,sw12,sw13,sw14,sw15,
	input show_CurrentWave_state_wire, //state to display selectedwave
	input [11:0] selected_wave_wire, //the selected wave number to display on ssd
	input [11:0] Vmax,
	input [11:0] Vmin,
	input [27:0] freqwire_input, 
	input [11:0] voltmax,
	input [11:0] voltmin,
	input [11:0] combinedisplay,
	input [11:0] pivot,
	input [11:0] selected_wave_wire2, //the selected wave number to display on ssd
	input [11:0] Vmax2,
	input [11:0] Vmin2,
	input [27:0] freqwire_input2,
	input [11:0] voltmax2,
	input [11:0] voltmin2,
	input [11:0] combinedisplay2,
	input [11:0] pivot2,
	input [3:0] an,
	output reg [3:0] hex
    );
    reg [11:0]freqwire = 0;
    reg [11:0]freqwire2 = 0;
    always @* begin
    	if (HF_toggle)begin
    		freqwire = freqwire_input / 1000;
    		freqwire2 = freqwire_input2 / 1000;
    	end
    	else begin
    		freqwire = freqwire_input;
    		freqwire2 = freqwire_input2;
    	end
    end
    
    
 	//channel A
	wire [15:0] vmax_bcd;
	wire [15:0] vmin_bcd;
	wire [15:0] freq_bcd;
	wire [15:0] combinedisplay_bcd;
	wire [15:0] voltmax_bcd;
	wire [15:0] voltmin_bcd;	
	wire [15:0] selected_wave_bcd;
	wire [15:0] pivot_bcd;
	//channel B
	wire [15:0] vmax_bcd2;
	wire [15:0] vmin_bcd2;
	wire [15:0] freq_bcd2;
	wire [15:0] combinedisplay_bcd2;
	wire [15:0] voltmax_bcd2;
	wire [15:0] voltmin_bcd2;
	wire [15:0] selected_wave_bcd2;
	wire [15:0] pivot_bcd2;
	
	
	reg [15:0] to_display=0;
	
	//channel A
	BCD bcd1 (Vmax,vmax_bcd);
	BCD bcd2 (Vmin,vmin_bcd);
	BCD bcd3 (freqwire,freq_bcd);
	BCD bcd5 (combinedisplay,combinedisplay_bcd);
	BCD bcd6 (voltmax,voltmax_bcd);
	BCD bcd7 (voltmin,voltmin_bcd);
	BCD bcd8 (selected_wave_wire,selected_wave_bcd); 
	BCD bcd9 (pivot,pivot_bcd); 
	//channel B
	BCD bcd11 (Vmax2,vmax_bcd2);
	BCD bcd12 (Vmin2,vmin_bcd2);
	BCD bcd13 (freqwire2,freq_bcd2);
	BCD bcd15 (combinedisplay2,combinedisplay_bcd2);
	BCD bcd16 (voltmax2,voltmax_bcd2);
	BCD bcd17 (voltmin2,voltmin_bcd2);
	BCD bcd18 (selected_wave_wire2,selected_wave_bcd2); 
	BCD bcd19 (pivot2,pivot_bcd2);
	
	wire [15:0]combinedisplay_bcd_mux;
	assign combinedisplay_bcd_mux = (~abtoggle)?combinedisplay_bcd:combinedisplay_bcd2;
	always @(*)begin
	
		casez ({abtoggle,show_CurrentWave_state_wire,sw15,sw14,sw13,sw12,sw11,sw10})
			//channel A
			8'b00100000: to_display = vmax_bcd  ; //display vmax
			8'b00010000: to_display = vmin_bcd; //display vmin
			8'b00001000: to_display = freq_bcd; //display freq
			8'b00100100: to_display = voltmax_bcd; //vmax in volts
			8'b00010100: to_display = voltmin_bcd; //vmin in volts
			8'b00000010: to_display = pivot_bcd; //vmin in volts
			8'b01??????: to_display = selected_wave_bcd; //wave number in volts
			//channel B
			8'b10100000: to_display = vmax_bcd2  ; //display vmax
			8'b10010000: to_display = vmin_bcd2; //display vmin
			8'b10001000: to_display = freq_bcd2; //display freq
			8'b10100100: to_display = voltmax_bcd2; //vmax in volts
			8'b10010100: to_display = voltmin_bcd2; //vmin in volts
			8'b10000010: to_display = pivot_bcd2; //vmin in volts
			8'b11??????: to_display = selected_wave_bcd2; //wave number in volts
			default: to_display = combinedisplay_bcd_mux; 
		endcase
	end

	always @ (*) begin
    	case (an) //anode is active low driven
    		4'b0111: hex = to_display[15:12]; // [A][0][0][0] where A is the active anode
    		4'b1011: hex = to_display[11:8]; // [0][A][0][0]
    		4'b1101: hex = to_display[7:4]; // [0][0][A][0]
    		4'b1110: hex = to_display[3:0]; // [0][0][0][A]
    		default: hex = 0; 
    	endcase 
    end
endmodule
