// Try-again logic. When time is up and the button is pressed, the signal
// restart_n goes low for a moment. The rest of the game uses it as a reset,
// so everything starts over.
module Restart_Control(
	input clk,
	input time_up,
	input button,          // 1 while the try-again button (KEY3) is held
	output restart_n       // 0 for a short moment = reset the game
);
	reg [4:0] hold;        // keeps the reset on for a few clock ticks

	initial hold = 5'd0;

	always @(posedge clk) begin
		if (hold != 5'd0)
			hold <= hold - 1'b1;
		else if (time_up && button)
			hold <= 5'd20;
	end

	assign restart_n = (hold == 5'd0);
endmodule