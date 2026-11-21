// Fades something out after the game starts.
//   While "active" is 0 (the level menu), alpha stays at 16 = fully shown.
//   Once active goes to 1, it waits HOLD_FRAMES, then lowers alpha by one
//   step every STEP_FRAMES until it reaches 0 = invisible.
//   When active goes back to 0 (menu again), it is shown again.
// Default: 7 seconds shown, then a 16-step fade of about 2 seconds.
module Fade_Control #(
	parameter HOLD_FRAMES = 420,   // 60 frames = 1 second (420 = 7 seconds)
	parameter STEP_FRAMES = 8      // frames per fade step (16 steps)
)(
	input clk,
	input active,                  // 1 while the game is being played
	output reg [4:0] alpha         // 16 = fully shown ... 0 = gone
);
	// about 60 ticks per second
	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	reg [10:0] hold;              // counts up to HOLD_FRAMES (up to 2047)
	reg [3:0] step;

	initial begin count = 0; alpha = 5'd16; hold = 0; step = 0; end

	always @(posedge clk) begin
		if (frame_tick) count <= 0; else count <= count + 1'b1;

		if (!active) begin
			alpha <= 5'd16;
			hold  <= 0;
			step  <= 0;
		end
		else if (frame_tick) begin
			if (hold < HOLD_FRAMES)
				hold <= hold + 1'b1;
			else if (alpha != 5'd0) begin
				if (step == STEP_FRAMES - 1) begin
					step  <= 0;
					alpha <= alpha - 1'b1;
				end else
					step <= step + 1'b1;
			end
		end
	end
endmodule