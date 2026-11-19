// Draws the shark (32x12 pixel art, each pixel drawn 3x3 = 96x36 on screen).
module Shark_Sprite(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input [10:0] shark_x,
	input [9:0]  shark_y,
	input        shark_direction,   // 1 = moving right
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	reg [10:0]  dx;
	reg [9:0]   dy;
	reg [4:0]   sx, col;
	reg [3:0]   sy;
	reg [127:0] row;
	reg [3:0]   pix;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		dx = 0; dy = 0; sx = 0; sy = 0; col = 0; row = 0; pix = 0;

		if (pixel_x + 11'd112 >= shark_x && pixel_x + 11'd112 < shark_x + 11'd112 &&
		   pixel_y >= shark_y && pixel_y < shark_y + 10'd42) begin

			dx = pixel_x + 11'd112 - shark_x;
			dy = pixel_y - shark_y;
			sx = (dx * 2) / 7;
			sy = (dy * 2) / 7;

			// the art faces right; flip it when moving left
			col = shark_direction ? sx : (5'd31 - sx);

			// 0 = empty, 1 = gray, 2 = white belly, 3 = eye, 4 = mouth
			case (sy)
				4'd0:  row = 128'h00000000000000010000000000000000;
				4'd1:  row = 128'h11000000000000110000000000000000;
				4'd2:  row = 128'h11110000000001111100000000000000;
				4'd3:  row = 128'h11111100000111111111111110000000;
				4'd4:  row = 128'h00000001111111111111111111111000;
				4'd5:  row = 128'h00000111111111111111111111311110;
				4'd6:  row = 128'h00000111111111111111111111111110;
				4'd7:  row = 128'h00000111111111111111111111111110;
				4'd8:  row = 128'h11111122222222222222222244442220;
				4'd9:  row = 128'h11110002222222222222222222222000;
				4'd10: row = 128'h11000000000222222222222220000000;
				default: row = 128'd0;
			endcase

			pix = row[(5'd31 - col) * 4 +: 4];

			if (pix != 0) begin
				opaque = 1;
				case (pix)
					4'd1: begin red = 8'h6E; green = 8'h78; blue = 8'h87; end // gray
					4'd2: begin red = 8'hE1; green = 8'hE6; blue = 8'hF0; end // belly
					4'd3: begin red = 8'h00; green = 8'h00; blue = 8'h00; end // eye
					4'd4: begin red = 8'h28; green = 8'h28; blue = 8'h32; end // mouth
					default: begin red = 8'hFF; green = 8'h00; blue = 8'hFF; end
				endcase
			end
		end
	end
endmodule