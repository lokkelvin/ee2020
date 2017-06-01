`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2017 23:34:16
// Design Name: 
// Module Name: vga_controller
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


module vga_controller(
	input wire pix_en,		//pixel clock: 25MHz
	input wire clk,			//100MHz
	input wire rst,			//asynchronous reset,
//	input wire [8:0] o_vec,
//	input wire [8:0] x_vec,
//	input wire [2:0] game_status,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [3:0] red,	//red vga output
	output reg [3:0] green, //green vga output
	output reg [3:0] blue	//blue vga output
	);

// video structure constants
parameter [9:0] hpixels = 800;// horizontal pixels per line
parameter [9:0] vlines = 521; // vertical lines per frame
parameter [9:0] hpulse = 96; 	// hsync pulse length
parameter [9:0] vpulse = 2; 	// vsync pulse length
parameter [9:0] hbp = 144; 	// end of horizontal back porch
parameter [9:0] hfp = 784; 	// beginning of horizontal front porch
parameter [9:0] vbp = 31; 		// end of vertical back porch
parameter [9:0] vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge clk)
begin
	// reset condition
	if (rst == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else if (pix_en == 1)
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

parameter [9:0] line_thickness = 2;
parameter [9:0] tile_offset = 10;
parameter [9:0] tile_width = 50;
parameter [9:0] radius = 15;
parameter [9:0] circle_thickness = 2;
parameter [9:0] o_vec = 9'b111111111;
parameter [9:0] x_vec = 9'b000000000;
reg [50:0] x_arr [50:0];//INDEX {..., 1, 0}. Note that 50 should be equal to tile_width
reg [50:0] y_arr [50:0];//INDEX {..., 1, 0}. Note that 50 should be equal to tile_width
parameter [2500:0] o_pic = {
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000001111111111100000000000000000000},
{50'b00000000000000001111111111111111100000000000000000},
{50'b00000000000000011111111111111111110000000000000000},
{50'b00000000000001111110000000000011111100000000000000},
{50'b00000000000011111000000000000000111110000000000000},
{50'b00000000000111100000000000000000001111000000000000},
{50'b00000000001111000000000000000000000111100000000000},
{50'b00000000001110000000000000000000000011100000000000},
{50'b00000000011100000000000000000000000001110000000000},
{50'b00000000111100000000000000000000000001111000000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000001110000000000000000000000000000011100000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000000111000000000000000000000000000111000000000},
{50'b00000000111100000000000000000000000001111000000000},
{50'b00000000011100000000000000000000000001110000000000},
{50'b00000000001110000000000000000000000011100000000000},
{50'b00000000001111000000000000000000000111100000000000},
{50'b00000000000111100000000000000000001111000000000000},
{50'b00000000000011111000000000000000111110000000000000},
{50'b00000000000001111110000000000011111100000000000000},
{50'b00000000000000011111111111111111110000000000000000},
{50'b00000000000000001111111111111111100000000000000000},
{50'b00000000000000000001111111111100000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000},
{50'b00000000000000000000000000000000000000000000000000}
};

parameter [2500:0] x_pic = {
{50'b00000000000000000000000000000000000000000000000000},
{50'b01110000000000000000000000000000000000000000000111},
{50'b00111000000000000000000000000000000000000000001110},
{50'b00011100000000000000000000000000000000000000011100},
{50'b00001110000000000000000000000000000000000000111000},
{50'b00000111000000000000000000000000000000000001110000},
{50'b00000011100000000000000000000000000000000011100000},
{50'b00000001110000000000000000000000000000000111000000},
{50'b00000000111000000000000000000000000000001110000000},
{50'b00000000011100000000000000000000000000011100000000},
{50'b00000000001110000000000000000000000000111000000000},
{50'b00000000000111000000000000000000000001110000000000},
{50'b00000000000011100000000000000000000011100000000000},
{50'b00000000000001110000000000000000000111000000000000},
{50'b00000000000000111000000000000000001110000000000000},
{50'b00000000000000011100000000000000011100000000000000},
{50'b00000000000000001110000000000000111000000000000000},
{50'b00000000000000000111000000000001110000000000000000},
{50'b00000000000000000011100000000011100000000000000000},
{50'b00000000000000000001110000000111000000000000000000},
{50'b00000000000000000000111000001110000000000000000000},
{50'b00000000000000000000011100011100000000000000000000},
{50'b00000000000000000000001110111000000000000000000000},
{50'b00000000000000000000000111110000000000000000000000},
{50'b00000000000000000000000011100000000000000000000000},
{50'b00000000000000000000000111110000000000000000000000},
{50'b00000000000000000000001110111000000000000000000000},
{50'b00000000000000000000011100011100000000000000000000},
{50'b00000000000000000000111000001110000000000000000000},
{50'b00000000000000000001110000000111000000000000000000},
{50'b00000000000000000011100000000011100000000000000000},
{50'b00000000000000000111000000000001110000000000000000},
{50'b00000000000000001110000000000000111000000000000000},
{50'b00000000000000011100000000000000011100000000000000},
{50'b00000000000000111000000000000000001110000000000000},
{50'b00000000000001110000000000000000000111000000000000},
{50'b00000000000011100000000000000000000011100000000000},
{50'b00000000000111000000000000000000000001110000000000},
{50'b00000000001110000000000000000000000000111000000000},
{50'b00000000011100000000000000000000000000011100000000},
{50'b00000000111000000000000000000000000000001110000000},
{50'b00000001110000000000000000000000000000000111000000},
{50'b00000011100000000000000000000000000000000011100000},
{50'b00000111000000000000000000000000000000000001110000},
{50'b00001110000000000000000000000000000000000000111000},
{50'b00011100000000000000000000000000000000000000011100},
{50'b00111000000000000000000000000000000000000000001110},
{50'b01110000000000000000000000000000000000000000000111},
{50'b01100000000000000000000000000000000000000000000011},
{50'b01000000000000000000000000000000000000000000000001}
};

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// Tic-Tac-Toe Lines
		if ( (hc >= (hbp + tile_offset + tile_width) && hc < (hbp + tile_offset + tile_width + line_thickness) 
					&& vc >= (vbp + tile_offset) && vc < (vbp + tile_offset + 3*tile_width + 2*line_thickness))
			|| (hc >= (hbp + tile_offset + tile_width*2 + line_thickness) && hc < (hbp + tile_offset + tile_width*2 + line_thickness*2) 
					&& vc >= (vbp + tile_offset) && vc < (vbp + tile_offset + 3*tile_width + 2*line_thickness))
			|| (vc >= (vbp + tile_offset + tile_width*2 + line_thickness) && vc < (vbp + tile_offset + tile_width*2 + line_thickness*2) 
					&& hc >= (hbp + tile_offset) && hc < (hbp + tile_offset + 3*tile_width + 2*line_thickness))
			|| (vc >= (vbp + tile_offset + tile_width) && vc < (vbp + tile_offset + tile_width + line_thickness) 
					&& hc >= (hbp + tile_offset) && hc < (hbp + tile_offset + 3*tile_width + 2*line_thickness)))
		begin
			red = 3'b010;
			green = 3'b100;
			blue = 2'b11;
		end
		
		
		// Tile Blocks
		// 0 | 1 | 2
		// 3 | 4 | 5
		// 6 | 7 | 8
		// Begin Row 1
		else if (   (hc >= (hbp + tile_offset) && hc < (hbp + tile_offset + tile_width))
					&& (vc >= (vbp + tile_offset) && vc < (vbp + tile_offset + tile_width)))
		begin // Tile 0

			if (o_vec[0])
			begin
				if (o_pic[(hc - hbp - tile_offset) + (vc - vbp - tile_offset) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b111;
					green = 3'b000;
					blue = 2'b00;
				end
			end
			else if (x_vec[0])
			begin
				if (x_pic[(hc - hbp - tile_offset) + (vc - vbp - tile_offset) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b111;
					green = 3'b000;
					blue = 2'b00;
				end
			end
			else
			begin
				red = 3'b111;
				green = 3'b000;
				blue = 2'b00;
			end
			
		end
		else if (   (hc >= (hbp + tile_offset + line_thickness + tile_width) && hc < (hbp + tile_offset + tile_width*2 + line_thickness))
					&& (vc >= (vbp + tile_offset) && vc < (vbp + tile_offset + tile_width)))
		begin //Tile 1
			if (o_vec[1])
			begin
				if (o_pic[(hc - hbp - tile_offset - tile_width - line_thickness) + (vc - vbp - tile_offset) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b111;
					blue = 2'b00;
				end
			end
			else if (x_vec[1])
			begin
				if (x_pic[(hc - hbp - tile_offset - tile_width - line_thickness) + (vc - vbp - tile_offset) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b111;
					blue = 2'b00;
				end
			end
			else
			begin
				red = 3'b000;
				green = 3'b111;
				blue = 2'b00;
			end
		end
		else if (   (hc >= (hbp + tile_offset + line_thickness*2 + tile_width*2) && hc < (hbp + tile_offset + tile_width*3 + line_thickness*2))
					&& (vc >= (vbp + tile_offset) && vc < (vbp + tile_offset + tile_width)))
		begin // Tile 2
			if (o_vec[2])
			begin
				if (o_pic[(hc - hbp - tile_offset - tile_width * 2 - line_thickness*2) + (vc - vbp - tile_offset) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b000;
					blue = 2'b11;
				end
			end
			else if (x_vec[2])
			begin
				if (x_pic[(hc - hbp - tile_offset - tile_width * 2 - line_thickness*2) + (vc - vbp - tile_offset) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b000;
					blue = 2'b11;
				end
			end
			else
			begin
				red = 3'b000;
				green = 3'b000;
				blue = 2'b11;
			end
		end
		// Begin Row 2
		else if (   (hc >= (hbp + tile_offset) && hc < (hbp + tile_offset + tile_width))
					&& (vc >= (vbp + tile_offset + line_thickness + tile_width) && vc < (vbp + tile_offset + tile_width*2 + line_thickness)))
		begin // Tile 3
			if (o_vec[3])
			begin
				if (o_pic[(hc - hbp - tile_offset) + (vc - vbp - tile_offset - tile_width - line_thickness) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b00;
				end
			end
			else if (x_vec[3])
			begin
				if (x_pic[(hc - hbp - tile_offset) + (vc - vbp - tile_offset - tile_width - line_thickness) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b00;
				end
			end
			else
			begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b00;
			end
		end
		else if (   (hc >= (hbp + tile_offset + line_thickness + tile_width) && hc < (hbp + tile_offset + tile_width*2 + line_thickness))
					&& (vc >= (vbp + tile_offset + line_thickness + tile_width) && vc < (vbp + tile_offset + tile_width*2 + line_thickness)))
		begin // Tile 4
			if (o_vec[4])
			begin
				if (o_pic[(hc - hbp - tile_offset - tile_width - line_thickness) + (vc - vbp - tile_offset - tile_width - line_thickness) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b111;
					green = 3'b000;
					blue = 2'b11;
				end
			end
			else if (x_vec[4])
			begin
				if (x_pic[(hc - hbp - tile_offset - tile_width - line_thickness) + (vc - vbp - tile_offset - tile_width - line_thickness) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b111;
					green = 3'b000;
					blue = 2'b11;
				end
			end
			else
			begin
				red = 3'b111;
				green = 3'b000;
				blue = 2'b11;
			end
		end
		else if (   (hc >= (hbp + tile_offset + line_thickness*2 + tile_width*2) && hc < (hbp + tile_offset + tile_width*3 + line_thickness*2))
					&& (vc >= (vbp + tile_offset + line_thickness + tile_width) && vc < (vbp + tile_offset + tile_width*2 + line_thickness)))
		begin // Tile 5
			if (o_vec[5])
			begin
				if (o_pic[(hc - hbp - tile_offset - tile_width * 2 - line_thickness*2) + (vc - vbp - tile_offset - tile_width - line_thickness) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b111;
					blue = 2'b11;
				end
			end
			else if (x_vec[5])
			begin
				if (x_pic[(hc - hbp - tile_offset - tile_width * 2 - line_thickness*2) + (vc - vbp - tile_offset - tile_width - line_thickness) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b111;
					blue = 2'b11;
				end
			end
			else
			begin
				red = 3'b000;
				green = 3'b111;
				blue = 2'b11;
			end
		end
		// Begin Row 3
		else if (   (hc >= (hbp + tile_offset) && hc < (hbp + tile_offset + tile_width))
					&& (vc >= (vbp + tile_offset + line_thickness*2 + tile_width*2) && vc < (vbp + tile_offset + tile_width*3 + line_thickness*2)))
		begin // Tile 6
			if (o_vec[6])
			begin
				if (o_pic[(hc - hbp - tile_offset) + (vc - vbp - tile_offset - tile_width * 2 - line_thickness * 2) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b010;
					green = 3'b000;
					blue = 2'b00;
				end
			end
			else if (x_vec[6])
			begin
				if (x_pic[(hc - hbp - tile_offset) + (vc - vbp - tile_offset - tile_width * 2 - line_thickness * 2) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b010;
					green = 3'b000;
					blue = 2'b00;
				end
			end
			else
			begin
				red = 3'b010;
				green = 3'b000;
				blue = 2'b00;
			end
		end
		else if (   (hc >= (hbp + tile_offset + line_thickness + tile_width) && hc < (hbp + tile_offset + tile_width*2 + line_thickness))
					&& (vc >= (vbp + tile_offset + line_thickness*2 + tile_width*2) && vc < (vbp + tile_offset + tile_width*3 + line_thickness*2)))
		begin // Tile 7
			if (o_vec[7])
			begin
				if (o_pic[(hc - hbp - tile_offset - tile_width - line_thickness) + (vc - vbp - tile_offset - tile_width * 2 - line_thickness*2) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b010;
					blue = 2'b00;
				end
			end
			else if (x_vec[7])
			begin
				if (x_pic[(hc - hbp - tile_offset - tile_width - line_thickness) + (vc - vbp - tile_offset - tile_width * 2 - line_thickness*2) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b000;
					green = 3'b010;
					blue = 2'b00;
				end
			end
			else
			begin
				red = 3'b000;
				green = 3'b010;
				blue = 2'b00;
			end
		end
		else if (   (hc >= (hbp + tile_offset + line_thickness*2 + tile_width*2) && hc < (hbp + tile_offset + tile_width*3 + line_thickness*2))
					&& (vc >= (vbp + tile_offset + line_thickness*2 + tile_width*2) && vc < (vbp + tile_offset + tile_width*3 + line_thickness*2)))
		begin // Tile 8
			if (o_vec[8])
			begin
				if (o_pic[(hc - hbp - tile_offset - tile_width * 2 - line_thickness * 2) + (vc - vbp - tile_offset - tile_width * 2 - line_thickness * 2) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b010;
					green = 3'b010;
					blue = 2'b00;
				end
			end
			else if (x_vec[8])
			begin
				if (x_pic[(hc - hbp - tile_offset - tile_width * 2 - line_thickness * 2) + (vc - vbp - tile_offset - tile_width * 2 - line_thickness * 2) * 50])
				begin
					red = 3'b111;
					green = 3'b111;
					blue = 2'b11;
				end
				else 
				begin
					red = 3'b010;
					green = 3'b010;
					blue = 2'b00;
				end
			end
			else
			begin
				red = 3'b010;
				green = 3'b010;
				blue = 2'b00;
			end
		end
		
		else if (hc >= (hbp) && hc < (hfp))
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule