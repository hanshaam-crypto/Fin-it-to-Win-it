// The chest sits on the sand.
//   respawn : it was delivered, so it reappears somewhere else at random
//   drop    : it was dropped while being carried, so it lands at drop_x
module Chest_Control(
	input clk,
	input rst_n,
	input respawn,
	input drop,
	input [10:0] drop_x,
	output reg [10:0] chest_x
);
	reg [15:0] lfsr;   // random number generator

	initial begin lfsr = 16'hBEEF; chest_x = 11'd430; end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			lfsr <= 16'hBEEF;
			chest_x <= 11'd430;
		end else begin
			lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
			if (respawn)
				chest_x <= (lfsr[9:0] > 10'd592) ? {2'b00, lfsr[9:1]} : {1'b0, lfsr[9:0]};
			else if (drop)
				chest_x <= drop_x;
		end
	end
endmodule