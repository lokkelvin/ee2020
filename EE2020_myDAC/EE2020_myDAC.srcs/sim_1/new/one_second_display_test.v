`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2017 14:51:45
// Design Name: 
// Module Name: one_second_display_test
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


module one_second_display_test(

    );

	reg show_CurrentWave_state;
	reg PULSE_c;
	reg finish;
	reg [28:0]display_timer;
	reg CLK;
	
	always @* begin
		if (PULSE_c)begin
			show_CurrentWave_state = 1;
		end
		if (finish) begin
			show_CurrentWave_state <= 1;
		end
	end
	
	always @(posedge CLK) begin
		if ((show_CurrentWave_state == 1) || (display_timer > 0))begin
			if (display_timer == 27'd10_000_000) begin
				finish <= 1;
				display_timer <= display_timer + 1;
			end
			else if (display_timer == 27'd10_001_000)begin
				finish <= 0;
				display_timer <= 0;
			end
			else begin
				display_timer <= display_timer + 1;
			end
		end
	end
	
		
	initial begin
		PULSE_c = 0; CLK = 0; show_CurrentWave_state=0; finish=0; display_timer=0;
		#10000
		PULSE_c =1;
		#10000;
		PULSE_c = 0;
	end
	
	always #5 CLK=~CLK;


endmodule
