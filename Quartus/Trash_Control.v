// One piece of trash floating in the water.
//   S_FLOAT : bobs slowly up and down around its spot (2 pixels each way,
//             one full bob about every 3 seconds).
//   S_HIDE  : it was caught and delivered. It hides off-screen for a short
//             random time (1 to about 3 seconds).
//   S_DROP  : it appears at the same spot it was caught from, 12 pixels
//             higher, and sinks
//             into place while fading in (about 1.5 seconds). Then it floats.
// alpha tells the top file how see-through to draw it: 0 = invisible, 16 = solid.
module Trash_Control #(
	parameter [10:0] INIT_X = 200,
	parameter [9:0]  INIT_Y = 300,
	parameter [15:0] SEED   = 16'hA5A5
)(
	input clk,
	input rst_n,
	input respawn,
	output reg [10:0] trash_x,
	output reg [9:0]  trash_y,     // where it is drawn right now (includes the bob)
	output reg [4:0]  alpha        // 0 = invisible ... 16 = solid
);
	localparam PARK      = 11'd700;   // hiding spot, past the right edge
	localparam DROP_DIST = 10'd12;    // how far above its spot it appears
	localparam BOB_STEP  = 4'd11;     // frames per bob step (16 steps = ~3 seconds)
	localparam FALL_STEP = 4'd7;      // frames per pixel while sinking (12 px = ~1.4 s)
	localparam FADE_STEP = 4'd5;      // frames per fade step (16 steps = ~1.4 s)

	localparam S_FLOAT = 2'd0, S_HIDE = 2'd1, S_DROP = 2'd2;
	reg [1:0] state;

	// about 60 ticks per second
	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	reg [15:0] lfsr;          // random number generator
	reg [10:0] home_x;        // the spot it floats around
	reg [9:0]  home_y;
	reg [8:0]  wait_frames;   // frames left before it comes back
	reg [3:0]  phase;         // where it is in the bob (0..15)
	reg [3:0]  bob_t, fall_t, fade_t;
	reg [9:0]  drop_y;        // how high it is while sinking

	// the bob: a smooth up-and-down shape, 0 .. +2 .. 0 .. -2 .. 0
	reg signed [2:0] bob;
	always @(*) begin
		case (phase)
			4'd0:  bob = 3'sd0;   4'd1:  bob = 3'sd1;   4'd2:  bob = 3'sd1;   4'd3:  bob = 3'sd2;
			4'd4:  bob = 3'sd2;   4'd5:  bob = 3'sd2;   4'd6:  bob = 3'sd1;   4'd7:  bob = 3'sd1;
			4'd8:  bob = 3'sd0;   4'd9:  bob = -3'sd1;  4'd10: bob = -3'sd1;  4'd11: bob = -3'sd2;
			4'd12: bob = -3'sd2;  4'd13: bob = -3'sd2;  4'd14: bob = -3'sd1;  default: bob = -3'sd1;
		endcase
	end

	initial begin
		count = 0; lfsr = SEED; state = S_FLOAT;
		trash_x = INIT_X; home_x = INIT_X; home_y = INIT_Y; trash_y = INIT_Y; alpha = 5'd16;
		wait_frames = 0; phase = SEED[3:0]; bob_t = 0; fall_t = 0; fade_t = 0; drop_y = 0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0; lfsr <= SEED; state <= S_FLOAT;
			trash_x <= INIT_X; home_x <= INIT_X; home_y <= INIT_Y; trash_y <= INIT_Y; alpha <= 5'd16;
			wait_frames <= 0; phase <= SEED[3:0]; bob_t <= 0; fall_t <= 0; fade_t <= 0; drop_y <= 0;
		end else begin
			if (frame_tick) count <= 0; else count <= count + 1'b1;
			lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

			if (respawn) begin
				// caught and delivered: hide for a short random time
				state <= S_HIDE;
				trash_x <= PARK;
				alpha <= 5'd0;
				wait_frames <= {2'b00, lfsr[6:0]} + 9'd60;    // 1 to about 3 seconds
			end
			else if (frame_tick) begin
				case (state)
					S_FLOAT: begin
						if (bob_t == BOB_STEP - 1) begin
							bob_t <= 0;
							phase <= phase + 1'b1;
						end else
							bob_t <= bob_t + 1'b1;
						trash_y <= home_y + {{7{bob[2]}}, bob};
					end

					S_HIDE: begin
						if (wait_frames > 9'd1)
							wait_frames <= wait_frames - 1'b1;
						else begin
							// come back at the same spot, a little higher, invisible
							trash_x <= home_x;
							drop_y  <= home_y - DROP_DIST;
							trash_y <= home_y - DROP_DIST;
							alpha   <= 5'd0;
							fall_t <= 0; fade_t <= 0;
							state <= S_DROP;
						end
					end

					S_DROP: begin
						// fade in
						if (alpha != 5'd16) begin
							if (fade_t == FADE_STEP - 1) begin fade_t <= 0; alpha <= alpha + 1'b1; end
							else fade_t <= fade_t + 1'b1;
						end
						// sink into place
						if (drop_y != home_y) begin
							if (fall_t == FALL_STEP - 1) begin
								fall_t <= 0;
								drop_y  <= drop_y + 1'b1;
								trash_y <= drop_y + 1'b1;
							end else
								fall_t <= fall_t + 1'b1;
						end
						// both done: start bobbing from the middle of the bob
						else if (alpha == 5'd16) begin
							phase <= 4'd0; bob_t <= 0;
							state <= S_FLOAT;
						end
					end

					default: state <= S_FLOAT;
				endcase
			end
		end
	end
endmodule