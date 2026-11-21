// The game brain: moves the hook, detects catches, reels things in, keeps the score.
//   S_FISH  : hook is free. Button down = hook goes down, button up = hook goes up.
//             If the hook touches something, grab it and go to S_REEL.
//   S_REEL  : hook rises by itself carrying the item. Shark and chest rise slower.
//             If the shark touches a fish on the hook, it eats it: the fish is
//             gone, the empty hook keeps rising, and it scores 0 points.
//   S_SCORE : hook is back at the top. Add the points, make the item respawn.
//
// Item numbers ("caught"): 0 = nothing, 1..6 = fish 0..5, 7 = shark, 8 = chest,
//                          9,10 = bottles, 11,12 = pop tabs (trash, hard level only)
module Game_Control(
	input clk,
	input rst_n,
	input button,                // 1 while the hook button is held
	input hard,                  // 1 = hard level (trash can be hooked)
	input run,                   // 1 while the game is running (0 once time is up)
	input [10:0] hook_x,
	input [10:0] fish_x0, fish_x1, fish_x2, fish_x3, fish_x4, fish_x5,
	input [10:0] shark_x,        // shark x PLUS 112
	input [9:0]  shark_y,
	input [10:0] chest_x,
	input [9:0]  chest_y,        // the chest sinks in when it comes back
	input [10:0] trash_x0, trash_x1, trash_x2, trash_x3,
	input [9:0]  trash_y0, trash_y1, trash_y2, trash_y3,
	output reg [9:0]  hook_y,    // bottom tip of the hook
	output reg [3:0]  caught,    // what the hook is carrying
	output reg [11:0] respawn,   // one pulse per item when it is delivered
	output reg        drop,      // one pulse when the chest is dropped
	output [3:0] d3, d2, d1, d0, // score digits
	output score_neg,
	output signed [15:0] score_out,  // the score itself (for the win check)
	output reg pop,                  // one-clock pulse when points are added
	output reg signed [15:0] pop_pts,// how many points that was
	output reg eat_pop               // one-clock pulse when the shark eats a fish
);
	localparam HOOK_MIN = 10'd206;   // resting spot, just under the boat
	localparam HOOK_MAX = 10'd452;   // top of the sand
	localparam DOWN = 10'd2;         // speed going down
	localparam UP   = 10'd2;         // speed going up (empty hook, fish, trash)
	localparam SLOW = 10'd1;         // speed going up with the shark or the chest

	// y positions of the fish (these must match the top file)
	localparam FY0 = 10'd215, FY1 = 10'd245, FY2 = 10'd295,
	           FY3 = 10'd335, FY4 = 10'd385, FY5 = 10'd432;

	localparam S_FISH = 2'd0, S_REEL = 2'd1, S_SCORE = 2'd2;
	reg [1:0] state;

	// about 60 ticks per second
	reg [19:0] count;
	wire frame_tick = (count == 20'd833332);

	reg signed [15:0] score;

	// ---------- the hook's hit box ----------
	wire [11:0] hx0 = {1'b0, hook_x} - 12'd6;
	wire [11:0] hx1 = {1'b0, hook_x} + 12'd8;
	wire [11:0] hy0 = {2'b00, hook_y} - 12'd12;
	wire [11:0] hy1 = {2'b00, hook_y} + 12'd1;

	// ---------- does the hook overlap each item? ----------

	// small fish are 32x16, medium 40x20, large 48x24
	wire hit0 = (hx0 < fish_x0 + 12'd32) && (hx1 > fish_x0) && (hy0 < FY0 + 12'd16) && (hy1 > FY0);
	wire hit1 = (hx0 < fish_x1 + 12'd32) && (hx1 > fish_x1) && (hy0 < FY1 + 12'd16) && (hy1 > FY1);
	wire hit2 = (hx0 < fish_x2 + 12'd40) && (hx1 > fish_x2) && (hy0 < FY2 + 12'd20) && (hy1 > FY2);
	wire hit3 = (hx0 < fish_x3 + 12'd40) && (hx1 > fish_x3) && (hy0 < FY3 + 12'd20) && (hy1 > FY3);
	wire hit4 = (hx0 < fish_x4 + 12'd48) && (hx1 > fish_x4) && (hy0 < FY4 + 12'd24) && (hy1 > FY4);
	wire hit5 = (hx0 < fish_x5 + 12'd48) && (hx1 > fish_x5) && (hy0 < FY5 + 12'd24) && (hy1 > FY5);
	
	// the shark is 112x42; its x is stored +112, so it covers (shark_x-112) to shark_x
	wire hitS = (hx0 < shark_x) && (hx1 + 12'd112 > shark_x) && (hy0 < shark_y + 12'd42) && (hy1 > shark_y);

	// the chest is 48x36
	wire hitC = (hx0 < chest_x + 12'd48) && (hx1 > chest_x) && (hy0 < chest_y + 12'd36) && (hy1 > chest_y);

	// the chest being carried (48x36, hanging from the hook) vs the shark
	wire [11:0] cc_x = (hook_x > 11'd24) ? ({1'b0, hook_x} - 12'd24) : 12'd0;
	wire [11:0] cc_y = {2'b00, hook_y} - 12'd18;
	wire shark_hits_chest = (cc_x < shark_x) && (cc_x + 12'd160 > shark_x) &&
	                        (cc_y < shark_y + 12'd42) && (cc_y + 12'd36 > shark_y);
	
	// a fish being carried (hanging from the hook) vs the shark.
	// small fish are 32x16, medium 40x20, large 48x24 (same as the top file)
	wire is_fish = (caught >= 4'd1) && (caught <= 4'd6);
	wire [11:0] cf_w = (caught <= 4'd2) ? 12'd32 : (caught <= 4'd4) ? 12'd40 : 12'd48;
	wire [11:0] cf_h = (caught <= 4'd2) ? 12'd16 : (caught <= 4'd4) ? 12'd20 : 12'd24;
	wire [11:0] cf_l = (caught <= 4'd2) ? 12'd16 : (caught <= 4'd4) ? 12'd20 : 12'd24;   // how far left of the hook
	wire [11:0] cf_u = (caught <= 4'd2) ? 12'd8  : (caught <= 4'd4) ? 12'd10 : 12'd12;   // how far above the hook tip
	wire [11:0] cf_x = ({1'b0, hook_x} > cf_l) ? ({1'b0, hook_x} - cf_l) : 12'd0;
	wire [11:0] cf_y = {2'b00, hook_y} - cf_u;
	wire shark_eats_fish = is_fish &&
	                       (cf_x < shark_x) && (cf_x + cf_w + 12'd112 > shark_x) &&
	                       (cf_y < shark_y + 12'd42) && (cf_y + cf_h > shark_y);

	// trash (hard level only): bottles are 12x24, pop tabs are 16x16
	wire hitT0 = hard && (hx0 < trash_x0 + 12'd12) && (hx1 > trash_x0) && (hy0 < trash_y0 + 12'd24) && (hy1 > trash_y0);
	wire hitT1 = hard && (hx0 < trash_x1 + 12'd12) && (hx1 > trash_x1) && (hy0 < trash_y1 + 12'd24) && (hy1 > trash_y1);
	wire hitT2 = hard && (hx0 < trash_x2 + 12'd16) && (hx1 > trash_x2) && (hy0 < trash_y2 + 12'd16) && (hy1 > trash_y2);
	wire hitT3 = hard && (hx0 < trash_x3 + 12'd16) && (hx1 > trash_x3) && (hy0 < trash_y3 + 12'd16) && (hy1 > trash_y3);

	wire hit_any = hit0 | hit1 | hit2 | hit3 | hit4 | hit5 | hitS | hitC |
	               hitT0 | hitT1 | hitT2 | hitT3;
	wire [3:0] hit_id = hitC  ? 4'd8  : hitS  ? 4'd7  :
	                    hitT3 ? 4'd12 : hitT2 ? 4'd11 : hitT1 ? 4'd10 : hitT0 ? 4'd9 :
	                    hit5  ? 4'd6  : hit4  ? 4'd5  : hit3  ? 4'd4  : hit2  ? 4'd3 :
	                    hit1  ? 4'd2  : 4'd1;

	// ---------- points ----------
	reg signed [15:0] pts;
	always @(*) begin
		case (caught)
			4'd1, 4'd2: pts = 16'sd15;     // small fish
			4'd3, 4'd4: pts = 16'sd30;     // medium fish
			4'd5, 4'd6: pts = 16'sd50;     // large fish
			4'd7:       pts = -16'sd50;    // shark
			4'd8:       pts = 16'sd100;    // chest
			4'd9, 4'd10, 4'd11, 4'd12: pts = -16'sd15;   // trash
			default:    pts = 16'sd0;
		endcase
	end
	wire signed [15:0] sum = score + pts;

	// how fast does the hook rise right now?
	wire [9:0] rise = (caught == 4'd7 || caught == 4'd8) ? SLOW : UP;

	// ---------- score digits for the score board ----------
	assign score_neg = score[15];
	assign score_out = score;
	wire [15:0] absv = score[15] ? (~score + 16'd1) : score;
	assign d3 = absv / 16'd1000;
	assign d2 = (absv / 16'd100) % 16'd10;
	assign d1 = (absv / 16'd10) % 16'd10;
	assign d0 = absv % 16'd10;

	initial begin
		count = 0; hook_y = HOOK_MIN; state = S_FISH; caught = 0; respawn = 0; score = 0; drop = 0;
		pop = 0; pop_pts = 0; eat_pop = 0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			count <= 0; hook_y <= HOOK_MIN; state <= S_FISH;
			caught <= 4'd0; respawn <= 12'd0; score <= 16'sd0; drop <= 1'b0;
			pop <= 1'b0; pop_pts <= 16'sd0; eat_pop <= 1'b0;
		end else begin
			respawn <= 12'd0;                   // pulses last one clock tick
			pop <= 1'b0;
			eat_pop <= 1'b0;
			drop <= 1'b0;
			if (frame_tick) count <= 0; else count <= count + 1'b1;

			case (state)
				S_FISH: begin
					if (frame_tick) begin
						if (button) begin
							if (hook_y + DOWN >= HOOK_MAX) hook_y <= HOOK_MAX;
							else hook_y <= hook_y + DOWN;
						end else begin
							if (hook_y <= HOOK_MIN + UP) hook_y <= HOOK_MIN;
							else hook_y <= hook_y - UP;
						end
						if (hit_any && run) begin      // nothing can be caught after time is up
							caught <= hit_id;
							state <= S_REEL;
						end
					end
				end

				S_REEL: begin
					if (frame_tick) begin
						if (caught == 4'd8 && shark_hits_chest) begin
							drop <= 1'b1;            // the shark knocks the chest loose
							caught <= 4'd0;
							state <= S_FISH;
						end
						else begin
							// the shark eats the fish: it disappears (and swims back in
							// later like any caught fish), but the empty hook still has
							// to reel all the way up, and it scores 0 points
							if (shark_eats_fish) begin
								respawn[caught - 4'd1] <= 1'b1;
								if (run) eat_pop <= 1'b1;      // show EATEN
								caught <= 4'd0;
							end

							if (hook_y <= HOOK_MIN + rise) begin
								hook_y <= HOOK_MIN;
								state <= S_SCORE;
							end else
								hook_y <= hook_y - rise;
						end
					end
				end

				S_SCORE: begin
					// the score is frozen once time is up (an item still
					// being reeled in at 0 seconds does not count)
					if (!run) score <= score;
					else if (sum > 16'sd9999) score <= 16'sd9999;
					else if (sum < -16'sd999) score <= -16'sd999;
					else score <= sum;
					// show the points (not for an empty hook, or after time is up)
					if (run && pts != 16'sd0) begin
						pop <= 1'b1;
						pop_pts <= pts;
					end

					if (caught != 4'd0)                 // empty hook (fish eaten): nothing to respawn
						respawn[caught - 4'd1] <= 1'b1;
					caught <= 4'd0;
					state <= S_FISH;
				end

				default: state <= S_FISH;
			endcase
		end
	end
endmodule