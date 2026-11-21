// Draws the timer as a small wooden sign (chunky 3x3 pixel art) hanging on
// two chains to the right of the score sign, from just below the title. It shows the seconds left as two digits.
// The digits turn red for the last 10 seconds.
module Timer_Sign(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input [5:0]  seconds_left,
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam X  = 374;          // 12 pixels right of the score sign
	localparam Y  = 52;           // lined up with the middle of the score sign
	localparam W  = 54;           // 18 art pixels
	localparam H  = 30;           // 10 art pixels
	localparam CH1 = X + 9;       // left chain
	localparam CH2 = X + 39;      // right chain
	localparam CHAIN_TOP = 33;    // chains start at the bottom of the title banner
	localparam TEXT_TOP = Y + 4;  // digits are 21 pixels tall

	// 5x7 digits, top row first
	function [34:0] digit;
		input [3:0] d;
		begin
			case (d)
				4'd0: digit = 35'b01110_10001_10011_10101_11001_10001_01110;
				4'd1: digit = 35'b00100_01100_00100_00100_00100_00100_01110;
				4'd2: digit = 35'b01110_10001_00001_00010_00100_01000_11111;
				4'd3: digit = 35'b11110_00001_00001_01110_00001_00001_11110;
				4'd4: digit = 35'b00010_00110_01010_10010_11111_00010_00010;
				4'd5: digit = 35'b11111_10000_11110_00001_00001_10001_01110;
				4'd6: digit = 35'b00110_01000_10000_11110_10001_10001_01110;
				4'd7: digit = 35'b11111_00001_00010_00100_01000_01000_01000;
				4'd8: digit = 35'b01110_10001_10001_01110_10001_10001_01110;
				default: digit = 35'b01110_10001_10001_01111_00001_00010_01100;  // 9
			endcase
		end
	endfunction

	wire [5:0] tens = seconds_left / 6'd10;
	wire [5:0] ones = seconds_left % 6'd10;

	integer px, py, lx, ly, ax, ay, r, pr, cx, cy;
	integer rx, k, w, gx, gy;
	reg [3:0]  d;
	reg [34:0] rows;
	reg [4:0]  bits;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		px = pixel_x; py = pixel_y;
		lx = 0; ly = 0; ax = 0; ay = 0; r = 0; pr = 0; cx = 0; cy = 0;
		rx = 0; k = 0; w = 0; gx = 0; gy = 0; d = 0; rows = 0; bits = 0;

		// ---------- the two chains ----------
		if (py >= CHAIN_TOP && py < Y + 3 &&
		    ((px >= CH1 && px < CH1 + 6) || (px >= CH2 && px < CH2 + 6))) begin
			cx = (px >= CH2) ? (px - CH2) : (px - CH1);
			cy = ((py - CHAIN_TOP) / 3) % 3;
			if (cy != 2) begin
				opaque = 1;
				if (cx < 3) begin red = 165; green = 170; blue = 182; end
				else        begin red = 110; green = 115; blue = 126; end
			end
		end

		// ---------- the little sign ----------
		if (px >= X && px < X + W && py >= Y && py < Y + H) begin
			opaque = 1;
			lx = px - X;
			ly = py - Y;
			ax = lx / 3;          // 0..17
			ay = ly / 3;          // 0..9

			if (ax == 0 || ax == 17 || ay == 0 || ay == 9) begin
				red = 105; green = 110; blue = 122;            // metal frame
			end
			else begin
				// two wooden planks, 4 art rows each (3 wood + 1 dark gap)
				r  = ay - 1;
				pr = r % 4;
				if (pr == 3) begin
					red = 85; green = 45; blue = 25;           // dark gap
				end
				else if (pr == 0) begin
					red = 185; green = 120; blue = 68;         // light top row
				end
				else begin
					red = 160; green = 100; blue = 55;         // wood
				end
			end

			// ---- the two digits, 3x bigger, centered ----
			if (py >= TEXT_TOP && py < TEXT_TOP + 21 &&
			    px >= X + 9 && px < X + 45) begin

				rx = px - (X + 9);
				k  = rx / 18;            // 0 = tens digit, 1 = ones digit
				w  = rx % 18;
				gx = w / 3;              // art column 0..4 (5 is the gap)
				gy = (py - TEXT_TOP) / 3;   // art row 0..6

				d = (k == 0) ? tens[3:0] : ones[3:0];
				rows = digit(d);
				bits = rows[(6 - gy) * 5 +: 5];

				if (gx < 5 && bits[4 - gx]) begin
					if (seconds_left <= 6'd10) begin
						red = 255; green = 90; blue = 70;      // last 10 seconds: red
					end else begin
						red = 255; green = 232; blue = 170;    // cream-gold
					end
				end
			end
		end
	end
endmodule