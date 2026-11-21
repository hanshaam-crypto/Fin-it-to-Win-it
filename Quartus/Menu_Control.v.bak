// Level menu.
//   S_MENU : choose a level. KEY2 (left) = Easy, KEY1 (right) = Hard. KEY3 confirms.
//   S_WAIT : wait for KEY3 to be let go (so the hook doesn't drop right away)
//   S_PLAY : the game is running. Press the reset key (KEY0) to come back to the menu.
module Menu_Control(
	input clk,
	input rst_n,
	input left,          // 1 while the left button is held
	input right,         // 1 while the right button is held
	input select,        // 1 while the select button is held
	output reg playing,  // 1 once a level has been chosen
	output reg hard      // 0 = Easy, 1 = Hard (also tells which box is highlighted)
);
	localparam S_MENU = 2'd0, S_WAIT = 2'd1, S_PLAY = 2'd2;
	reg [1:0] state;

	initial begin state = S_MENU; playing = 1'b0; hard = 1'b0; end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= S_MENU;
			playing <= 1'b0;
			hard <= 1'b0;
		end else begin
			case (state)
				S_MENU: begin
					if (left)  hard <= 1'b0;
					if (right) hard <= 1'b1;
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
endmodule