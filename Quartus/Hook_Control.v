// Hook goes down while the button is held, and rises when released.
module Hook_Control(
	input clk,
	input rst_n,
	input button,            // 1 while held
	output reg [9:0] hook_y  // y of the bottom tip of the hook
);
	localparam HOOK_MIN = 10'd215;   // resting position, just under the boat
	localparam HOOK_MAX = 10'd452;   // just above the sand
	localparam SPEED    = 10'd2;

	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	initial begin count = 0; hook_y = HOOK_MIN; end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0;
			hook_y <= HOOK_MIN;
		end else begin
			if (frame_tick) count <= 0; else count <= count + 1'b1;

			if (frame_tick) begin
				if (button) begin
					if (hook_y + SPEED >= HOOK_MAX) hook_y <= HOOK_MAX;
					else hook_y <= hook_y + SPEED;
				end else begin
					if (hook_y <= HOOK_MIN + SPEED) hook_y <= HOOK_MIN;
					else hook_y <= hook_y - SPEED;
				end
			end
		end
	end
endmodule
