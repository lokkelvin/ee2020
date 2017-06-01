`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2017 00:03:29
// Design Name: 
// Module Name: vga_sim
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


module vga_sim(
    );
    always #5 CLK=~CLK;
    always #20 pix_en=~pix_en;
    
    reg pix_en;
    reg CLK;
    reg rst;
    wire hsync;
    wire vsync;
    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;
    
    vga_controller dut1 (pix_en,CLK,rst,hsync,vsync,red,green,blue);
    integer i;
    integer f;
    initial begin
        rst = 0; CLK=0; pix_en=0;
      f = $fopen("output.txt");
      #10000
      for (i = 0; i<20000;i=i+1) begin
        #20 $fmonitor(f, "%d ns: %b %b %4b %4b %4b/n", $time,hsync,vsync,red,green,blue );
        end
      #1000
      $fclose(f);
      $finish;
    end
endmodule
