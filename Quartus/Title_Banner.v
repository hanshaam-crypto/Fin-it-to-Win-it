// A wooden banner behind the title, in the same chunky style as the score
// sign (every art pixel is 3x3 screen pixels). The score sign and the timer
// hang from it on chains. Size 312 x 33, centered at the top of the screen.
module Title_Banner(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam BX = 164;     // left edge  (title is x 176..464)
	localparam BY = 0;       // top edge
	localparam BW = 312;     // 104 art pixels
	localparam BH = 33;      // 11 art pixels

	integer px, py, ax, ay, r, pr;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		px = pixel_x; py = pixel_y; ax = 0; ay = 0; r = 0; pr = 0;

		if (px >= BX && px < BX + BW && py >= BY && py < BY + BH) begin
			opaque = 1;
			ax = (px - BX) / 3;    // 0..103
			ay = (py - BY) / 3;    // 0..10

			if (ax == 0 || ax == 103 || ay == 10) begin
				red = 105; green = 110; blue = 122;            // metal frame
			end
			else begin
				// two wooden planks, 5 art rows each (4 wood + 1 dark gap)
				r  = ay;
				pr = r % 5;
				if (pr == 4) begin
					red = 85; green = 45; blue = 25;           // dark gap
				end
				else if (pr == 0) begin
					red = 185; green = 120; blue = 68;         // light top row
				end
				else if (pr == 2 && ((ax * 7 + (r / 5) * 5) % 11) == 0) begin
					red = 138; green = 84; blue = 44;          // wood grain
				end
				else begin
					red = 160; green = 100; blue = 55;         // wood
				end

				// nails
				if ((ax == 2 || ax == 101) && (ay == 2 || ay == 8)) begin
					red = 60; green = 60; blue = 70;
				end
			end
		end
	end
endmodule