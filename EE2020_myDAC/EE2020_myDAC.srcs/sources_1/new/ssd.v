`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 21:17:41
// Design Name: 
// Module Name: ssd
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



module ssd_cathode(
input sw12,
input [3:0] hex, //hexadecimal number, 2^4=16 from 0 to F. 
output reg [6:0] segment // 7 segment output
    );

//active low logic to turn on the segment
//use case statement to represent each hexadecimal number
always @ (*) begin
   case (hex) 
	   4'd0 : segment = 7'b1000000;
	   4'd1 : segment = 7'b1111001;
	   4'd2 : segment = 7'b0100100;
	   4'd3 : segment = 7'b0110000;
	   4'd4 : segment = 7'b0011001;
	   4'd5 : segment = 7'b0010010;
	   4'd6 : segment = 7'b0000010;
	   4'd7 : segment = 7'b1111000;
	   4'd8 : segment = 7'b0000000;
	   4'd9 : segment = 7'b0010000;
      default: segment = 7'b0000001; //default is 0 
   endcase	
end
//assign dp = (sw12)?4'b0000:4'b1111; 
		//dp is active low driven
		//check if sw12 is on, if it is then turn dp on, 
		//else turn off the decimal point as we don't need it
endmodule