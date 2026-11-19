// Draws the score board: an oval with an outline and the text "Score: N".
// Same size and position as the Python version: 190 x 65, 20 pixels from the
// top and right edges of the screen.
module Scoreboard(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input        score_neg,        // 1 = the score is negative
	input [3:0]  d3, d2, d1, d0,   // the score's digits (thousands ... ones)
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam BOARD_X = 430;     // 640 - 20 - 190
	localparam BOARD_Y = 20;
	localparam BOARD_W = 190;
	localparam BOARD_H = 65;
	localparam IN_W    = 184;     // inside of the outline (3 pixels thick)
	localparam IN_H    = 59;
	localparam TEXT_TOP = 45;     // text is 14 pixels tall, centered in the oval
	localparam PITCH    = 12;     // each character takes 12 pixels across

	// Tiny 5x7 letters. Character codes:
	// 0-9 = digits, 10=S 11=c 12=o 13=r 14=e 15=: 16=- 17=space
	function [34:0] font;
		input [4:0] code;
		begin
			case (code)
				5'd0:  font = 35'b01110_10001_10011_10101_11001_10001_01110;
				5'd1:  font = 35'b00100_01100_00100_00100_00100_00100_01110;
				5'd2:  font = 35'b01110_10001_00001_00010_00100_01000_11111;
				5'd3:  font = 35'b11110_00001_00001_01110_00001_00001_11110;
				5'd4:  font = 35'b00010_00110_01010_10010_11111_00010_00010;
				5'd5:  font = 35'b11111_10000_11110_00001_00001_10001_01110;
				5'd6:  font = 35'b00110_01000_10000_11110_10001_10001_01110;
				5'd7:  font = 35'b11111_00001_00010_00100_01000_01000_01000;
				5'd8:  font = 35'b01110_10001_10001_01110_10001_10001_01110;
				5'd9:  font = 35'b01110_10001_10001_01111_00001_00010_01100;
				5'd10: font = 35'b01110_10001_10000_01110_00001_10001_01110; // S
				5'd11: font = 35'b00000_00000_01110_10000_10000_10001_01110; // c
				5'd12: font = 35'b00000_00000_01110_10001_10001_10001_01110; // o
				5'd13: font = 35'b00000_00000_10110_11001_10000_10000_10000; // r
				5'd14: font = 35'b00000_00000_01110_10001_11111_10000_01110; // e
				5'd15: font = 35'b00000_00100_00100_00000_00100_00100_00000; // :
				5'd16: font = 35'b00000_00000_00000_11111_00000_00000_00000; // -
				default: font = 35'd0;                                       // space
			endcase
		end
	endfunction

	integer px, py, dx2, dy2;
	integer nd, total, tleft, rx, k, w, gx, gy, j, m;
	reg     in_outer, in_inner;
	reg [4:0]  code;
	reg [34:0] rows;
	reg [4:0]  bits;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		px = pixel_x; py = pixel_y;
		dx2 = 0; dy2 = 0; in_outer = 0; in_inner = 0;
		nd = 1; total = 0; tleft = 0; rx = 0; k = 0; w = 0; gx = 0; gy = 0; j = 0; m = 0;
		code = 5'd17; rows = 0; bits = 0;

		if (px >= BOARD_X && px < BOARD_X + BOARD_W &&
		    py >= BOARD_Y && py < BOARD_Y + BOARD_H) begin

			// Is this pixel inside the oval? (ellipse equation, doubled to avoid fractions)
			dx2 = 2*px + 1 - (2*BOARD_X + BOARD_W);
			dy2 = 2*py + 1 - (2*BOARD_Y + BOARD_H);
			in_outer = (dx2*dx2*(BOARD_H*BOARD_H) + dy2*dy2*(BOARD_W*BOARD_W))
			           <= (BOARD_W*BOARD_W*BOARD_H*BOARD_H);
			in_inner = (dx2*dx2*(IN_H*IN_H) + dy2*dy2*(IN_W*IN_W))
			           <= (IN_W*IN_W*IN_H*IN_H);

			if (in_outer) begin
				opaque = 1;
				if (in_inner) begin
					red = 8'hDC; green = 8'hF5; blue = 8'hFF;   // fill
				end else begin
					red = 8'h3C; green = 8'h82; blue = 8'hAA;   // outline
				end
			end

			// ---- the text "Score: N" ----
			if (d3 != 0) nd = 4;
			else if (d2 != 0) nd = 3;
			else if (d1 != 0) nd = 2;
			else nd = 1;

			total = 7 + score_neg + nd;                       // number of characters
			tleft = BOARD_X + BOARD_W/2 - total*(PITCH/2);    // centered

			if (py >= TEXT_TOP && py < TEXT_TOP + 14 &&
			    px >= tleft && px < tleft + total*PITCH) begin

				rx = px - tleft;
				k  = rx / PITCH;        // which character
				w  = rx % PITCH;        // where inside the character
				gx = w / 2;             // art column 0..4
				gy = (py - TEXT_TOP) / 2;  // art row 0..6

				// which character is it?
				if (k < 7) begin
					case (k)
						0: code = 5'd10;  // S
						1: code = 5'd11;  // c
						2: code = 5'd12;  // o
						3: code = 5'd13;  // r
						4: code = 5'd14;  // e
						5: code = 5'd15;  // :
						default: code = 5'd17; // space
					endcase
				end
				else if (score_neg && k == 7) begin
					code = 5'd16;         // minus sign
				end
				else begin
					j = k - 7 - score_neg;    // which digit from the left
					m = nd - 1 - j;           // 3 = thousands ... 0 = ones
					case (m)
						3: code = {1'b0, d3};
						2: code = {1'b0, d2};
						1: code = {1'b0, d1};
						default: code = {1'b0, d0};
					endcase
				end

				rows = font(code);
				bits = rows[(6 - gy) * 5 +: 5];

				if (w < 10 && bits[4 - gx]) begin
					opaque = 1;
					red = 8'h23; green = 8'h4B; blue = 8'h64;   // text color
				end
			end
		end
	end
endmodule