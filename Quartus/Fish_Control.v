// Moves one fish left/right, bouncing off the screen edges and
// randomly turning around now and then.
// When respawn pulses (the fish was delivered) it hides off-screen for a
// random time, then comes back in from the left or right edge.
module Fish_Control(
	input clk,
	input rst_n,
	input [10:0] width,        // fish width in pixels
	input [3:0]  speed,        // pixels per frame
	input [15:0] seed,         // makes each fish behave differently
	output reg [10:0] fish_x,
	output reg fish_direction, // 1 = moving right, 0 = moving left
	input respawn              // 1 = was just delivered
);
	localparam PARK = 11'd700;         // hiding spot, past the right edge of the screen

	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	reg [15:0] lfsr;
	reg [8:0]  wait_frames;            // frames left before it comes back (60 = 1 second)
	reg        side;                   // 1 = comes in from the left, 0 = from the right
	wire [10:0] max_x = 11'd640 - width;

	initial begin
		count = 0; lfsr = 16'hACE1; fish_x = 11'd200; fish_direction = 1'b1;
		wait_frames = 9'd0; side = 1'b1;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0;
			lfsr <= (seed == 16'd0) ? 16'hACE1 : seed;
			fish_x <= {3'b000, seed[7:0]} + 11'd100;
			fish_direction <= seed[0];
			wait_frames <= 9'd0;
			side <= 1'b1;
		end else begin
			if (frame_tick) count <= 0; else count <= count + 1'b1;

			if (respawn) begin
				fish_x <= PARK;                                  // hide
				wait_frames <= {1'b0, lfsr[7:0]} + 9'd90;        // 1.5 to about 6 seconds
				side <= lfsr[10];                                // which edge to come from
			end
			else if (frame_tick) begin
				// random number generator
				lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

				if (wait_frames != 0) begin
					wait_frames <= wait_frames - 1'b1;
					if (wait_frames == 9'd1) begin               // time's up: come back in
						fish_x <= side ? 11'd0 : max_x;
						fish_direction <= side;
					end
				end
				else if (fish_direction) begin
					if (fish_x + speed >= max_x) begin
						fish_x <= max_x;
						fish_direction <= 1'b0;
					end else begin
						fish_x <= fish_x + speed;
						if (lfsr[7:0] == 8'd0) fish_direction <= 1'b0;
					end
				end else begin
					if (fish_x <= speed) begin
						fish_x <= 11'd0;
						fish_direction <= 1'b1;
					end else begin
						fish_x <= fish_x - speed;
						if (lfsr[7:0] == 8'd0) fish_direction <= 1'b1;
					end
				end
			end
		end
	end
endmodule