`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2017 15:49:42
// Design Name: 
// Module Name: debouncer
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

module debouncer(input clk,D, output MY_PULSE);
    //wire clk;
    wire Q;
    wire Q2;
    //clock_divider_slower cds1 (CLOCK,clk);
    //clock_divider_half cdh1 (CLK,clk);
    d_flipflop dff1 (clk, D, Q);
    d_flipflop dff2 (clk, Q, Q2);
    assign MY_PULSE =  (~Q2) && Q;
endmodule

