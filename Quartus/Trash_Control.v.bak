// One piece of trash floating at a spot in the water.
// When it is caught and delivered, it appears somewhere else at random.
module Trash_Control #(
	parameter [10:0] INIT_X = 200,
	parameter [9:0]  INIT_Y = 300,
	parameter [15:0] SEED   = 16'hA5A5
)(
	input clk,
	input rst_n,
	input respawn,
	output reg [10:0] trash_x,
	output reg [9:0]  trash_y
);
	reg [15:0] lfsr;   // random number generator

	initial begin lfsr = SEED; trash_x = INIT_X; trash_y = INIT_Y; end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			lfsr <= SEED;
			trash_x <= INIT_X;
			trash_y <= INIT_Y;
		end else begin
			lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
			if (respawn) begin
				// anywhere across the screen, and anywhere in the water
				trash_x <= (lfsr[9:0] > 10'd620) ? {2'b00, lfsr[9:1]} : {1'b0, lfsr[9:0]};
				trash_y <= 10'd215 + ((lfsr[15:8] > 8'd200) ? {3'b000, lfsr[14:8]} : {2'b00, lfsr[15:8]});
			end
		end
	end
endmodule