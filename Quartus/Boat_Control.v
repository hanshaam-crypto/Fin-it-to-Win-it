// Moves the boat left/right once per frame (60 times a second).
module Boat_Control(
	input clk,
	input rst_n,            // 0 = reset
	input move_right,       // 1 while right button held
	input move_left,        // 1 while left button held
	output reg [10:0] boat_x,
	output reg boat_direction   // 1 = facing right, 0 = facing left
);
	localparam MAX_X = 11'd544;   // 640 - boat width (96)
	localparam SPEED = 11'd3;

	// 50 MHz / 833333 = about 60 ticks per second
	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	initial begin count = 0; boat_x = 11'd272; boat_direction = 1'b0; end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0;
			boat_x <= 11'd272;
			boat_direction <= 1'b0;
		end else begin
			if (frame_tick) count <= 0; else count <= count + 1'b1;

			if (frame_tick) begin
				if (move_right && !move_left) begin
					boat_direction <= 1'b1;
					if (boat_x + SPEED > MAX_X) boat_x <= MAX_X;
					else boat_x <= boat_x + SPEED;
				end else if (move_left && !move_right) begin
					boat_direction <= 1'b0;
					if (boat_x < SPEED) boat_x <= 11'd0;
					else boat_x <= boat_x - SPEED;
				end
			end
		end
	end
endmodule
