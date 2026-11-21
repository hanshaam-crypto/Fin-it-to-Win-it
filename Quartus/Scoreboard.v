// Draws the score board as a wooden hanging sign (chunky pixel art, every art
// pixel is 3x3 screen pixels, like the fisherman and the fish).
// Size 150 x 51, under the title. The score sign and the timer sign (to its
// right) are centered under the title as a pair. Chains start just below the title.
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
	localparam BOARD_X = 212;     // sign + 12 gap + timer = 216 wide, centered on x 320
	localparam BOARD_Y = 42;   // was 22 (lowered 20 pixels)
	localparam BOARD_W = 150;     // 50 art pixels
	localparam BOARD_H = 51;      // 17 art pixels
	localparam CHAIN_TOP = 33;            // chains start at the bottom of the title banner
	localparam CH1     = BOARD_X + 18;    // left chain
	localparam CH2     = BOARD_X + 126;   // right chain
	localparam TEXT_TOP = BOARD_Y + 18;   // text is 14 pixels tall, centered on the sign
	localparam PITCH    = 12;             // each character takes 12 pixels across

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

	integer px, py, lx, ly, ax, ay, r, pl, pr, cx, cy;
	integer nd, total, tleft, rx, k, w, gx, gy, j, m;
	reg [4:0]  code;
	reg [34:0] rows;
	reg [4:0]  bits;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		px = pixel_x; py = pixel_y;
		lx = 0; ly = 0; ax = 0; ay = 0; r = 0; pl = 0; pr = 0; cx = 0; cy = 0;
		nd = 1; total = 0; tleft = 0; rx = 0; k = 0; w = 0; gx = 0; gy = 0; j = 0; m = 0;
		code = 5'd17; rows = 0; bits = 0;

		// ---------- the two chains (block links: 2 wide, 2 tall, 1 gap) ----------
		if (py >= CHAIN_TOP && py < BOARD_Y + 3 &&
		    ((px >= CH1 && px < CH1 + 6) || (px >= CH2 && px < CH2 + 6))) begin
			cx = (px >= CH2) ? (px - CH2) : (px - CH1);   // 0..5
			cy = ((py - CHAIN_TOP) / 3) % 3;               // 0,1 = link, 2 = gap
			if (cy != 2) begin
				opaque = 1;
				if (cx < 3) begin red = 165; green = 170; blue = 182; end   // light side
				else        begin red = 110; green = 115; blue = 126; end   // dark side
			end
		end

		// ---------- the sign ----------
		if (px >= BOARD_X && px < BOARD_X + BOARD_W &&
		    py >= BOARD_Y && py < BOARD_Y + BOARD_H) begin

			opaque = 1;
			lx = px - BOARD_X;
			ly = py - BOARD_Y;
			ax = lx / 3;          // art pixel column 0..49
			ay = ly / 3;          // art pixel row 0..16

			if (ax == 0 || ax == 49 || ay == 0 || ay == 16) begin
				red = 105; green = 110; blue = 122;            // metal frame
			end
			else begin
				// three wooden planks, 5 art rows each (4 wood + 1 dark gap)
				r  = ay - 1;
				pl = r / 5;
				pr = r % 5;
				if (pr == 4) begin
					red = 85; green = 45; blue = 25;           // dark gap
				end
				else if (pr == 0) begin
					red = 185; green = 120; blue = 68;         // light top row
				end
				else if (pr == 2 && ((ax * 7 + pl * 5) % 11) == 0) begin
					red = 138; green = 84; blue = 44;          // a block of wood grain
				end
				else begin
					red = 160; green = 100; blue = 55;         // wood
				end

				// nails
				if ((ax == 2 || ax == 47) && (ay == 2 || ay == 14)) begin
					red = 60; green = 60; blue = 70;
				end
			end

			// ---- the text "Score: N" painted on the sign ----
			if (d3 != 0) nd = 4;
			else if (d2 != 0) nd = 3;
			else if (d1 != 0) nd = 2;
			else nd = 1;

			total = 7 + score_neg + nd;                          // number of characters
			tleft = BOARD_X + BOARD_W/2 - total*(PITCH/2);       // centered

			if (py >= TEXT_TOP && py < TEXT_TOP + 14 &&
			    px >= tleft && px < tleft + total*PITCH) begin

				rx = px - tleft;
				k  = rx / PITCH;
				w  = rx % PITCH;
				gx = w / 2;
				gy = (py - TEXT_TOP) / 2;

				if (k < 7) begin
					case (k)
						0: code = 5'd10;   // S
						1: code = 5'd11;   // c
						2: code = 5'd12;   // o
						3: code = 5'd13;   // r
						4: code = 5'd14;   // e
						5: code = 5'd15;   // :
						default: code = 5'd17;   // space
					endcase
				end
				else if (score_neg && k == 7) begin
					code = 5'd16;          // minus sign
				end
				else begin
					j = k - 7 - score_neg;
					m = nd - 1 - j;
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
					red = 255; green = 232; blue = 170;     // cream-gold lettering
				end
			end
		end
	end
endmodule