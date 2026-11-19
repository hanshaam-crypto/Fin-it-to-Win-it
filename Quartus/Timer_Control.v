// Countdown timer: counts down from 30 seconds, one second at a time,
// but only while "run" is 1 (the game is being played). Stops at 0.
module Timer_Control(
	input clk,
	input rst_n,
	input run,                      // 1 while the game is being played
	output reg [5:0] seconds_left,  // 30 down to 0
	output time_up                  // 1 when the time has run out
);
	localparam START = 6'd30;

	reg [25:0] ticks;               // counts 50,000,000 clock ticks = 1 second

	initial begin seconds_left = START; ticks = 0; end

	assign time_up = (seconds_left == 6'd0);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			seconds_left <= START;
			ticks <= 0;
		end
		else if (run && seconds_left != 6'd0) begin
			if (ticks == 26'd49999999) begin
				ticks <= 0;
				seconds_left <= seconds_left - 1'b1;
			end else
				ticks <= ticks + 1'b1;
		end
	end
endmodule