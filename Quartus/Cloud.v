// One slowly drifting cloud (16x6 pixel art), looping around the screen.
// Y0               = height of the cloud's top
// SCALE            = size (screen pixels per art pixel)
// START            = starting x position
// FRAMES_PER_PIXEL = how slowly it moves (bigger = slower; 60 frames = 1 second)
module Cloud #(
	parameter Y0 = 40,
	parameter SCALE = 4,
	parameter START = 100,
	parameter FRAMES_PER_PIXEL = 6
)(
	input clk,
	input rst_n,
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	output reg   on
);
	localparam W = 16 * SCALE;
	localparam H = 6 * SCALE;
	localparam END_POS = 640 + W;      // position counted from W to the left of the screen

	// about 60 ticks per second
	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	reg [7:0]  slow;                   // counts frames between steps
	reg [10:0] x_off;                  // the cloud's x position PLUS W (so it can slide in from off-screen)

	initial begin count = 0; slow = 0; x_off = START + W; end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0; slow <= 0; x_off <= START + W;
		end else begin
			if (frame_tick) count <= 0; else count <= count + 1'b1;

			if (frame_tick) begin
				if (slow >= FRAMES_PER_PIXEL - 1) begin
					slow <= 0;
					if (x_off + 1 >= END_POS) x_off <= 0;   // loop around
					else x_off <= x_off + 1'b1;
				end else
					slow <= slow + 1'b1;
			end
		end
	end

	// ---------- drawing ----------
	integer px, py, xo, dx, sx, sy;
	reg [15:0] row;

	always @(*) begin
		on = 0;
		px = pixel_x; py = pixel_y; xo = x_off;
		dx = 0; sx = 0; sy = 0; row = 0;

		dx = px + W - xo;     // how far into the cloud this pixel is
		if (dx >= 0 && dx < W && py >= Y0 && py < Y0 + H) begin
			sx = dx / SCALE;
			sy = (py - Y0) / SCALE;
			case (sy)
				0: row = 16'b0000011110000000;
				1: row = 16'b0001111111101100;
				2: row = 16'b0011111111111110;
				3: row = 16'b0111111111111111;
				4: row = 16'b1111111111111111;
				5: row = 16'b0111111111111110;
				default: row = 16'd0;
			endcase
			on = row[15 - sx];
		end
	end
endmodule