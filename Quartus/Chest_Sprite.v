// Draws the treasure chest (16x12 pixel art, each pixel drawn 3x3 = 48x36 on screen).
module Chest_Sprite(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input [10:0] chest_x,
	input [9:0]  chest_y,

	output reg opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	reg [10:0] dx;
	reg [9:0]  dy;
	reg [3:0]  sx, sy;
	reg [63:0] row;
	reg [3:0]  pix;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		dx = 0; dy = 0; sx = 0; sy = 0; row = 0; pix = 0;

		if (pixel_x >= chest_x && pixel_x < chest_x + 11'd48 &&
		    pixel_y >= chest_y && pixel_y < chest_y + 10'd36) begin

			dx = pixel_x - chest_x;
			dy = pixel_y - chest_y;
			sx = dx / 3;
			sy = dy / 3;

			// 0 = empty, 1 = dark edge, 2 = wood, 3 = gold
			case (sy)
				4'd0:  row = 64'h0011111111111100;
				4'd1:  row = 64'h0122322222232210;
				4'd2:  row = 64'h0122322222232210;
				4'd3:  row = 64'h0122322222232210;
				4'd4:  row = 64'h0111311331131110;
				4'd5:  row = 64'h0122322332232210;
				4'd6:  row = 64'h0122322332232210;
				4'd7:  row = 64'h0122322222232210;
				4'd8:  row = 64'h0122322222232210;
				4'd9:  row = 64'h0122322222232210;
				4'd10: row = 64'h0122322222232210;
				4'd11: row = 64'h0111111111111110;
				default: row = 64'd0;
			endcase

			pix = row[(4'd15 - sx) * 4 +: 4];

			if (pix != 0) begin
				opaque = 1;
				case (pix)
					4'd1: begin red = 8'h50; green = 8'h32; blue = 8'h1E; end // dark edge
					4'd2: begin red = 8'h82; green = 8'h55; blue = 8'h32; end // wood
					4'd3: begin red = 8'hF0; green = 8'hC8; blue = 8'h3C; end // gold
					default: begin red = 8'hFF; green = 8'h00; blue = 8'hFF; end
				endcase
			end
		end
	end
endmodule