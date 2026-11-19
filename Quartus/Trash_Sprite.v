// Draws a piece of trash.
//   KIND 0 = green glass bottle (6x12 art, drawn 2x = 12x24)
//   KIND 1 = pop-top ring pull tab (8x8 art, drawn 2x = 16x16)
module Trash_Sprite #(
	parameter KIND = 0
)(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input [10:0] trash_x,
	input [9:0]  trash_y,
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam AW = (KIND == 0) ? 6 : 8;    // art width
	localparam AH = (KIND == 0) ? 12 : 8;   // art height

	integer px, py, dx, dy, sx, sy;
	reg [23:0] row;
	reg [2:0]  pix;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		px = pixel_x; py = pixel_y;
		dx = 0; dy = 0; sx = 0; sy = 0; row = 0; pix = 0;

		dx = px - trash_x;
		dy = py - trash_y;

		if (dx >= 0 && dx < AW*2 && dy >= 0 && dy < AH*2) begin
			sx = dx / 2;
			sy = dy / 2;

			if (KIND == 0) begin
				// 1 = dark green, 2 = green glass, 3 = shine, 4 = cap
				case (sy)
					0:  row = 24'o004400;
					1:  row = 24'o001100;
					2:  row = 24'o012210;
					3:  row = 24'o012210;
					4:  row = 24'o122221;
					5:  row = 24'o123221;
					6:  row = 24'o123221;
					7:  row = 24'o122221;
					8:  row = 24'o122221;
					9:  row = 24'o122221;
					10: row = 24'o122221;
					11: row = 24'o011110;
					default: row = 24'd0;
				endcase
			end else begin
				// 1 = dark edge, 2 = silver
				case (sy)
					0: row = 24'o00111100;
					1: row = 24'o01222210;
					2: row = 24'o12211221;
					3: row = 24'o12100121;
					4: row = 24'o12100121;
					5: row = 24'o12211221;
					6: row = 24'o01222210;
					7: row = 24'o00111100;
					default: row = 24'd0;
				endcase
			end

			pix = row[3*(AW - 1 - sx) +: 3];

			if (pix != 0) begin
				opaque = 1;
				if (KIND == 0) begin
					case (pix)
						3'd1: begin red = 8'd20;  green = 8'd80;  blue = 8'd40;  end
						3'd2: begin red = 8'd50;  green = 8'd170; blue = 8'd80;  end
						3'd3: begin red = 8'd170; green = 8'd240; blue = 8'd190; end
						default: begin red = 8'd150; green = 8'd150; blue = 8'd160; end
					endcase
				end else begin
					case (pix)
						3'd1: begin red = 8'd110; green = 8'd110; blue = 8'd120; end
						default: begin red = 8'd205; green = 8'd210; blue = 8'd220; end
					endcase
				end
			end
		end
	end
endmodule