// Level menu.
//   S_MENU : choose a level. KEY2 (left) = Easy, KEY1 (right) = Hard. KEY3 confirms.
//   S_WAIT : wait for KEY3 to be let go (so the hook doesn't drop right away)
//   S_PLAY : the game is running.
// rst_n (KEY0 or TRY AGAIN) brings the game back to the menu.
// full_rst_n (KEY0 only) also sets the level back to Easy, so after TRY AGAIN
// the level you played last is still highlighted.
module Menu_Control(
	input clk,
	input rst_n,         // 0 = back to the menu (KEY0 or TRY AGAIN)
	input full_rst_n,    // 0 = KEY0 reset (also resets the level to Easy)
	input left,          // 1 while the left button is held
	input right,         // 1 while the right button is held
	input select,        // 1 while the select button is held
	output reg playing,  // 1 once a level has been chosen
	output reg hard      // 0 = Easy, 1 = Hard (also tells which box is highlighted)
);
	localparam S_MENU = 2'd0, S_WAIT = 2'd1, S_PLAY = 2'd2;
	reg [1:0] state;

	initial begin state = S_MENU; playing = 1'b0; hard = 1'b0; end

	// menu state
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= S_MENU;
			playing <= 1'b0;
		end else begin
			case (state)
				S_MENU: begin
					if (select) state <= S_WAIT;
				end
				S_WAIT: begin
					if (!select) begin
						playing <= 1'b1;
						state <= S_PLAY;
					end
				end
				S_PLAY: state <= S_PLAY;
				default: state <= S_MENU;
			endcase
		end
	end

	// chosen level (only changes while the menu is showing)
	always @(posedge clk or negedge full_rst_n) begin
		if (!full_rst_n)
			hard <= 1'b0;
		else if (state == S_MENU) begin
			if (left)  hard <= 1'b0;
			if (right) hard <= 1'b1;
		end
	end
endmodule