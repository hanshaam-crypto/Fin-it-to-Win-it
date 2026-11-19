// Draws one line of text from a tiny 5x7 pixel font.
// X0, Y0   = top-left corner of the text
// SCALE    = how many screen pixels per font pixel
// LEN      = number of characters
// TEXT     = the words
// 'on' is 1 when the current pixel is part of a letter.
module Text_Line #(
	parameter X0    = 0,
	parameter Y0    = 0,
	parameter SCALE = 2,
	parameter LEN   = 4,
	parameter [8*32-1:0] TEXT = 0
)(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	output reg   on
);
	// Each letter is 7 rows of 5 bits, top row first.
	function [34:0] font;
		input [7:0] c;
		begin
			case (c)
				"A": font = 35'b01110_10001_10001_11111_10001_10001_10001;
				"D": font = 35'b11110_10001_10001_10001_10001_10001_11110;
				"E": font = 35'b11111_10000_10000_11110_10000_10000_11111;
				"F": font = 35'b11111_10000_10000_11110_10000_10000_10000;
				"G": font = 35'b01110_10001_10000_10111_10001_10001_01111;
				"H": font = 35'b10001_10001_10001_11111_10001_10001_10001;
				"I": font = 35'b01110_00100_00100_00100_00100_00100_01110;
				"K": font = 35'b10001_10010_10100_11000_10100_10010_10001;
				"L": font = 35'b10000_10000_10000_10000_10000_10000_11111;
				"N": font = 35'b10001_11001_10101_10011_10001_10001_10001;
				"O": font = 35'b01110_10001_10001_10001_10001_10001_01110;
				"R": font = 35'b11110_10001_10001_11110_10100_10010_10001;
				"S": font = 35'b01111_10000_10000_01110_00001_00001_11110;
				"T": font = 35'b11111_00100_00100_00100_00100_00100_00100;
				"W": font = 35'b10001_10001_10001_10101_10101_11011_10001;
				"Y": font = 35'b10001_10001_01010_00100_00100_00100_00100;
				"i": font = 35'b00100_00000_01100_00100_00100_00100_01110;
				"n": font = 35'b00000_00000_10110_11001_10001_10001_10001;
				"t": font = 35'b01000_01000_11100_01000_01000_01001_00110;
				"o": font = 35'b00000_00000_01110_10001_10001_10001_01110;
				"1": font = 35'b00100_01100_00100_00100_00100_00100_01110;
				"2": font = 35'b01110_10001_00001_00010_00100_01000_11111;
				"3": font = 35'b11110_00001_00001_01110_00001_00001_11110;
				default: font = 35'd0;   // space
			endcase
		end
	endfunction

	integer px, py, rx, ry, k, w, gx, gy;
	reg [7:0]  ch;
	reg [34:0] rows;
	reg [4:0]  bits;

	always @(*) begin
		on = 0;
		px = pixel_x; py = pixel_y;
		rx = 0; ry = 0; k = 0; w = 0; gx = 0; gy = 0;
		ch = 8'd32; rows = 0; bits = 0;

		if (px >= X0 && px < X0 + LEN*6*SCALE &&
		    py >= Y0 && py < Y0 + 7*SCALE) begin

			rx = px - X0;
			ry = py - Y0;
			k  = rx / (6*SCALE);     // which letter
			w  = rx % (6*SCALE);     // where inside the letter's box
			gx = w / SCALE;          // font column 0..5 (5 is the gap)
			gy = ry / SCALE;         // font row 0..6

			if (gx < 5) begin
				ch   = TEXT[8*(LEN-1-k) +: 8];
				rows = font(ch);
				bits = rows[(6 - gy) * 5 +: 5];
				on   = bits[4 - gx];
			end
		end
	end
endmodule