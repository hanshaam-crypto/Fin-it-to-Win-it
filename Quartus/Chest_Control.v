// The chest sits on the sand.
//   respawn : it was delivered. It hides for a short moment, then appears at
//             a new spot a little higher up and sinks onto the sand while
//             fading in (like the trash).
//   drop    : it was knocked off the hook by the shark, so it lands at drop_x.
//
// The sand is split into three zones: left (x 0..176), middle (208..384)
// and right (416..592). On respawn the chest always moves to one of the
// OTHER two zones, at a random spot inside it, so it uses the whole row.
// At the start of every round it is put at a random spot in any zone.
//
// alpha tells the top file how see-through to draw it: 0 = invisible, 16 = solid.
module Chest_Control(
	input clk,
	input rst_n,
	input respawn,
	input drop,
	input [10:0] drop_x,
	output reg [10:0] chest_x,
	output reg [9:0]  chest_y,
	output reg [4:0]  alpha
);
	localparam SAND_Y    = 10'd438;   // where the chest rests
	localparam PARK      = 11'd700;   // hiding spot, past the right edge
	localparam DROP_DIST = 10'd30;    // how far above the sand it appears
	localparam FALL_STEP = 4'd3;      // frames per pixel while sinking (30 px = 1.5 s)
	localparam FADE_STEP = 4'd5;      // frames per fade step (16 steps = ~1.4 s)

	localparam S_REST = 2'd0, S_HIDE = 2'd1, S_DROP = 2'd2;
	reg [1:0] state;

	// about 60 ticks per second
	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	reg [15:0] lfsr;          // random number generator (never reset, so it is
	                          // in a different state every time a round starts)
	reg        place;         // 1 = pick a random starting spot on the next clock
	reg [10:0] next_x;        // where it will come back
	reg [6:0]  wait_frames;   // frames left before it comes back
	reg [3:0]  fall_t, fade_t;

	initial begin
		lfsr = 16'hBEEF; chest_x = 11'd430; chest_y = SAND_Y; alpha = 5'd16;
		place = 1'b0; state = S_REST; count = 0; next_x = 0; wait_frames = 0;
		fall_t = 0; fade_t = 0;
	end

	// which zone the chest is in right now
	wire [1:0] zone_now = (chest_x < 11'd208) ? 2'd0 :
	                      (chest_x < 11'd416) ? 2'd1 : 2'd2;

	// respawn: move one or two zones over (wrapping around), so it never stays put
	wire [1:0] step     = lfsr[8] ? 2'd2 : 2'd1;
	wire [2:0] zsum     = zone_now + step;
	wire [1:0] zone_mv  = (zsum >= 3'd3) ? (zsum - 3'd3) : zsum[1:0];

	// start of a round: any of the three zones
	wire [1:0] zone_any = (lfsr[10:9] == 2'd3) ? (lfsr[11] ? 2'd0 : 2'd2) : lfsr[10:9];

	wire [1:0] zone_new = place ? zone_any : zone_mv;

	// random spot inside the zone: 0..176
	wire [7:0] off = (lfsr[7:0] > 8'd176) ? (lfsr[7:0] - 8'd80) : lfsr[7:0];

	wire [10:0] zone_start = (zone_new == 2'd0) ? 11'd0 :
	                         (zone_new == 2'd1) ? 11'd208 : 11'd416;

	// the random number generator runs all the time
	always @(posedge clk)
		lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			chest_x <= 11'd430; chest_y <= SAND_Y; alpha <= 5'd16;
			state <= S_REST; count <= 0; wait_frames <= 0; fall_t <= 0; fade_t <= 0;
			place <= 1'b1;               // choose a random spot once the reset ends
		end else begin
			place <= 1'b0;
			if (frame_tick) count <= 0; else count <= count + 1'b1;

			if (place) begin
				// start of a round: just sit at a random spot, fully shown
				chest_x <= zone_start + off;
				chest_y <= SAND_Y; alpha <= 5'd16; state <= S_REST;
			end
			else if (respawn) begin
				// delivered: pick the next spot now, hide for 0.75 to 1.5 seconds
				next_x  <= zone_start + off;
				chest_x <= PARK;
				alpha   <= 5'd0;
				wait_frames <= {2'b00, lfsr[12:8]} + 7'd45;
				state <= S_HIDE;
			end
			else if (drop) begin
				// knocked off the hook by the shark: lands where it was hit
				chest_x <= drop_x;
				chest_y <= SAND_Y; alpha <= 5'd16; state <= S_REST;
			end
			else if (frame_tick) begin
				case (state)
					S_HIDE: begin
						if (wait_frames > 7'd1)
							wait_frames <= wait_frames - 1'b1;
						else begin
							// come back a little higher, invisible
							chest_x <= next_x;
							chest_y <= SAND_Y - DROP_DIST;
							alpha <= 5'd0;
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
						// sink onto the sand
						if (chest_y != SAND_Y) begin
							if (fall_t == FALL_STEP - 1) begin
								fall_t <= 0;
								chest_y <= chest_y + 1'b1;
							end else
								fall_t <= fall_t + 1'b1;
						end
						else if (alpha == 5'd16)
							state <= S_REST;
					end

					default: state <= S_REST;
				endcase
			end
		end
	end
endmodule