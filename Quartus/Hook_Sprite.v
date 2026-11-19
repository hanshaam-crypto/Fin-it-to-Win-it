// Draws the fishing line (from the rod tip down to hook_y) and a J-shaped hook.
module Hook_Sprite(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input [10:0] hook_x,        // x of the rod tip (the line hangs from here)
	input [9:0]  hook_y,        // bottom of the hook
	input        facing_right,  // 1 = the J curls to the right
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam LINE_TOP = 10'd141;   // top of the boat = rod tip
	localparam HIDE_TOP = 10'd183;   // the line passes behind the boat's side here
	localparam HIDE_BOT = 10'd192;

	wire in_bar_rows = (pixel_y + 10'd4  > hook_y) && (pixel_y <= hook_y);
	wire in_tip_rows = (pixel_y + 10'd12 > hook_y) && (pixel_y <= hook_y);

	always @(*) begin
		opaque = 0; red = 8'h3C; green = 8'h3C; blue = 8'h46;

		// the line (2 pixels wide), hidden while it is behind the boat
		if (pixel_x >= hook_x && pixel_x < hook_x + 11'd2 &&
		    pixel_y >= LINE_TOP && pixel_y <= hook_y &&
		    !(pixel_y >= HIDE_TOP && pixel_y < HIDE_BOT))
			opaque = 1;

		if (facing_right) begin
			// bottom of the J, going right from the line
			if (pixel_x >= hook_x && pixel_x < hook_x + 11'd12 && in_bar_rows)
				opaque = 1;
			// tip of the J: a thin piece (2 wide) at the right end
			if (pixel_x >= hook_x + 11'd10 && pixel_x < hook_x + 11'd12 && in_tip_rows)
				opaque = 1;
		end
		else begin
			// bottom of the J, going left from the line
			if (pixel_x + 11'd10 >= hook_x && pixel_x < hook_x + 11'd2 && in_bar_rows)
				opaque = 1;
			// tip of the J: a thin piece (2 wide) at the left end
			if (pixel_x + 11'd10 >= hook_x && pixel_x + 11'd8 < hook_x && in_tip_rows)
				opaque = 1;
		end
	end
endmodule
