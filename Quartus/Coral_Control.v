// Picks a random layout for the 7 decorative corals (see Coral_Sprite).
// A random number generator (LFSR) runs all the time. Every time the game
// is reset (KEY0 or TRY AGAIN), a new layout is taken from it, so the coral
// moves around, changes shape and changes color each round. Because the
// player presses the button at a random moment, the layout is different
// every time.
//
// 11 bits per coral: [5:0] x offset (0..43), [7:6] shape (0..2),
//                    [9:8] color (0..3), [10] mirrored
module Coral_Control(
	input clk,
	input rst_n,                 // the game reset (KEY0 or TRY AGAIN)
	output reg [76:0] layout
);
	reg [31:0] lfsr;
	reg        r1, r2;           // rst_n brought into the clock domain
	reg        busy;
	reg [2:0]  idx;              // which coral is being filled in
	reg [4:0]  step;             // 32 clocks between corals = fresh random bits

	// the layout shown when the board is first turned on
	initial begin
		layout = 77'h184830d88e50a3aaf006;
		lfsr = 32'hC0FFEE01;
		r1 = 1'b1; r2 = 1'b1; busy = 1'b0; idx = 3'd0; step = 5'd0;
	end

	wire [5:0] off   = (lfsr[5:0] > 6'd43) ? (lfsr[5:0] - 6'd20) : lfsr[5:0];
	wire [1:0] shape = (lfsr[7:6] == 2'd3) ? 2'd0 : lfsr[7:6];   // 0, 1 or 2

	always @(posedge clk) begin
		// random number generator, never stops
		lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};

		r1 <= rst_n;
		r2 <= r1;

		if (r2 && !r1) begin                 // the reset just started
			busy <= 1'b1;
			idx  <= 3'd0;
			step <= 5'd0;
		end
		else if (busy) begin
			step <= step + 1'b1;
			if (step == 5'd31) begin
				layout[idx * 11 +: 11] <= {lfsr[10], lfsr[9:8], shape, off};
				if (idx == 3'd6) busy <= 1'b0;
				else idx <= idx + 1'b1;
			end
		end
	end
endmodule