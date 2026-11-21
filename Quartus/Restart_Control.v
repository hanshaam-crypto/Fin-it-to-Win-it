// Try-again logic. When time is up, the TIME UP panel is shown and the game
// waits for a fresh press-and-release of the try-again button (KEY3).
// Then restart_n goes low for a moment. The rest of the game uses it as a
// reset, so everything starts over.
//
// KEY3 is also the fishing button, so it is very likely to be held down at
// the moment the time runs out. To make sure the panel is always shown:
//   S_IDLE  : game running. When time runs out, go to S_LOCK.
//   S_LOCK  : ignore KEY3 for half a second, and until it has been let go.
//   S_READY : panel is up, waiting for KEY3 to be pressed.
//   S_PRESS : KEY3 is down, waiting for it to be let go (so the hook doesn't
//             drop right away when the new round starts).
//   S_FIRE  : hold the reset low for a few clock ticks, then back to S_IDLE.
module Restart_Control(
	input clk,
	input time_up,
	input button,          // 1 while the try-again button (KEY3) is held
	output reg restart_n   // 0 for a short moment = reset the game
);
	localparam S_IDLE = 3'd0, S_LOCK = 3'd1, S_READY = 3'd2,
	           S_PRESS = 3'd3, S_FIRE = 3'd4;
	localparam LOCK_TICKS = 25'd25000000;   // 0.5 seconds at 50 MHz

	reg [2:0]  state;
	reg [24:0] wait_count;
	reg [4:0]  hold;       // keeps the reset on for a few clock ticks

	initial begin
		state = S_IDLE; wait_count = 0; hold = 0; restart_n = 1'b1;
	end

	always @(posedge clk) begin
		case (state)
			S_IDLE: begin
				restart_n <= 1'b1;
				wait_count <= 0;
				if (time_up) state <= S_LOCK;
			end

			S_LOCK: begin
				if (!time_up) state <= S_IDLE;          // KEY0 reset while on the panel
				else if (wait_count < LOCK_TICKS) wait_count <= wait_count + 1'b1;
				else if (!button) state <= S_READY;     // KEY3 has been let go
			end

			S_READY: begin
				if (!time_up) state <= S_IDLE;
				else if (button) state <= S_PRESS;
			end

			S_PRESS: begin
				if (!time_up) state <= S_IDLE;
				else if (!button) begin
					hold <= 5'd20;
					restart_n <= 1'b0;
					state <= S_FIRE;
				end
			end

			S_FIRE: begin
				if (hold != 5'd0) begin
					hold <= hold - 1'b1;
					restart_n <= 1'b0;
				end else begin
					restart_n <= 1'b1;
					state <= S_IDLE;
				end
			end

			default: state <= S_IDLE;
		endcase
	end
endmodule