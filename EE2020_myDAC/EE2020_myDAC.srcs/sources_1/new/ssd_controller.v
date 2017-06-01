`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 21:41:49
// Design Name: 
// Module Name: ssd_controller
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


module ssd_anode(
	input SSDCLOCK, //input clock , refresh rate between 1kHz to 60Hz
	input sw1,sw2,sw12,sw13,sw14,sw15,show_CurrentWave_state_wire,
	output reg [3:0]anode,
	/*output        enable_D1, //right most digit
	output        enable_D2, //second right most digit
	output        enable_D3, //second left most digit
	output        enable_D4  //left most digit*/
	output dp //decimal point
		);
	
	//pattern vector variable. each vector represent one digit
	//assign the pattern to 0111 so that only right most digit is asserted (active low)
	reg [3:0] pattern = 4'b1110; 
	reg [1:0] pattern2 = 2'b10;
	// does the same as this :
	/*assign anode[0] = pattern[3]; //assign right most digit to 0 so turn on the right most 
	assign anode[1] = pattern[2]; //assign second right most digit to 1, off
	assign anode[2] = pattern[1]; //assign second left most digit to 1, off
	assign anode[3] = pattern[0]; //assign left most digit to 1, off*/		//code from Stop Watch
	always @(posedge SSDCLOCK) begin
		if (show_CurrentWave_state_wire)begin
			anode <= {{2{1'b1}},pattern2}; //display lsb only because CurrentWave numbers are from 0-9
			pattern2 <= {pattern2[0],pattern2[1]};
		end
		else begin
			anode <= pattern;
			pattern <= {pattern[0],pattern[3:1]}; //shift the vector to enable each digit // circular vector
		end
	end
	
	assign dp = ((~anode[3] && (({sw15,sw14,sw13,sw12}==4'b1001) || ({sw15,sw14,sw13,sw12}==4'b0101) )))? 0 : 1 ;
endmodule