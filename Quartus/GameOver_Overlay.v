// The end-of-round panel: YOU WIN (goal reached) or TIMES UP, the score
// next to the goal, and a PLAY AGAIN button.
module GameOver_Overlay(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input        score_neg,        // 1 = the score is negative
	input [3:0]  d3, d2, d1, d0,   // the score's digits (thousands ... ones)
	input        hard,             // 1 = Hard level (goal 300), 0 = Easy (goal 200)
	input        win,              // 1 = the goal was reached
	output reg   on,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	// panel: x 150..490, y 140..360
	localparam PX = 150, PY = 140, PW = 340, PH = 220, PO = 4;
	// button: x 230..410, y 270..310
	localparam BX = 230, BY = 270, BW = 180, BH = 40, BO = 3;
	// the numbers: 4x bigger 5x7 digits, 24 pixels per character
	localparam NUM_Y = 230, NUM_SCALE = 4, NUM_PITCH = 24;
	// two columns: score on the left, goal on the right
	localparam SCORE_CX = 245, GOAL_CX = 405;

	wire t_up, t_win, t_final, t_goal, g200, g300, t_try, t_hint;

	Text_Line #(.X0(200), .Y0(156), .SCALE(5), .LEN(8), .TEXT("TIMES UP"))
		T_UP(pixel_x, pixel_y, t_up);
	Text_Line #(.X0(215), .Y0(156), .SCALE(5), .LEN(7), .TEXT("YOU WIN"))
		T_WIN(pixel_x, pixel_y, t_win);
	Text_Line #(.X0(SCORE_CX-30), .Y0(206), .SCALE(2), .LEN(5), .TEXT("SCORE"))
		T_FINAL(pixel_x, pixel_y, t_final);
	Text_Line #(.X0(GOAL_CX-24), .Y0(206), .SCALE(2), .LEN(4), .TEXT("GOAL"))
		T_GOAL(pixel_x, pixel_y, t_goal);
	// the goal number, same size and style as the score
	Text_Line #(.X0(GOAL_CX-36), .Y0(NUM_Y), .SCALE(NUM_SCALE), .LEN(3), .TEXT("200"))
		T_G200(pixel_x, pixel_y, g200);
	Text_Line #(.X0(GOAL_CX-36), .Y0(NUM_Y), .SCALE(NUM_SCALE), .LEN(3), .TEXT("300"))
		T_G300(pixel_x, pixel_y, g300);
	Text_Line #(.X0(260), .Y0(283), .SCALE(2), .LEN(10), .TEXT("PLAY AGAIN"))
		T_TRY(pixel_x, pixel_y, t_try);
	Text_Line #(.X0(254), .Y0(326), .SCALE(2), .LEN(11), .TEXT("PRESS KEY 3"))
		T_HINT(pixel_x, pixel_y, t_hint);

	// 5x7 digits, top row first. Code 10 = minus sign.
	function [34:0] digit;
		input [3:0] d;
		begin
			case (d)
				4'd0: digit = 35'b01110_10001_10011_10101_11001_10001_01110;
				4'd1: digit = 35'b00100_01100_00100_00100_00100_00100_01110;
				4'd2: digit = 35'b01110_10001_00001_00010_00100_01000_11111;
				4'd3: digit = 35'b11110_00001_00001_01110_00001_00001_11110;
				4'd4: digit = 35'b00010_00110_01010_10010_11111_00010_00010;
				4'd5: digit = 35'b11111_10000_11110_00001_00001_10001_01110;
				4'd6: digit = 35'b00110_01000_10000_11110_10001_10001_01110;
				4'd7: digit = 35'b11111_00001_00010_00100_01000_01000_01000;
				4'd8: digit = 35'b01110_10001_10001_01110_10001_10001_01110;
				4'd9: digit = 35'b01110_10001_10001_01111_00001_00010_01100;
				4'd10: digit = 35'b00000_00000_00000_11111_00000_00000_00000;  // -
				default: digit = 35'd0;
			endcase
		end
	endfunction

	integer px, py, nd, total, nleft, rx, k, w, gx, gy, j, m;
	reg in_panel, in_panel_in, in_btn, in_btn_in;
	reg [3:0]  code;
	reg [34:0] rows;
	reg [4:0]  bits;

	always @(*) begin
		px = pixel_x; py = pixel_y;
		on = 0; red = 0; green = 0; blue = 0;
		nd = 1; total = 0; nleft = 0; rx = 0; k = 0; w = 0; gx = 0; gy = 0; j = 0; m = 0;
		code = 0; rows = 0; bits = 0;

		in_panel    = (px >= PX && px < PX + PW && py >= PY && py < PY + PH);
		in_panel_in = (px >= PX + PO && px < PX + PW - PO && py >= PY + PO && py < PY + PH - PO);
		in_btn      = (px >= BX && px < BX + BW && py >= BY && py < BY + BH);
		in_btn_in   = (px >= BX + BO && px < BX + BW - BO && py >= BY + BO && py < BY + BH - BO);

		// panel
		if (in_panel) begin
			on = 1;
			if (in_panel_in) begin red = 35; green = 60; blue = 90; end      // dark blue
			else             begin red = 255; green = 140; blue = 0; end    // orange edge
		end

		// button
		if (in_btn) begin
			on = 1;
			if (in_btn_in) begin red = 255; green = 220; blue = 110; end
			else           begin red = 255; green = 140; blue = 0;   end
		end

		// ---- the final score number, centered in the left column ----
		if (d3 != 0) nd = 4;
		else if (d2 != 0) nd = 3;
		else if (d1 != 0) nd = 2;
		else nd = 1;

		total = score_neg + nd;                         // number of characters
		nleft = SCORE_CX - total * (NUM_PITCH / 2);     // centered in the left column

		if (py >= NUM_Y && py < NUM_Y + 7 * NUM_SCALE &&
		    px >= nleft && px < nleft + total * NUM_PITCH) begin

			rx = px - nleft;
			k  = rx / NUM_PITCH;          // which character
			w  = rx % NUM_PITCH;          // where inside it
			gx = w / NUM_SCALE;           // font column 0..5 (5 is the gap)
			gy = (py - NUM_Y) / NUM_SCALE;

			if (score_neg && k == 0)
				code = 4'd10;             // minus sign
			else begin
				j = k - score_neg;
				m = nd - 1 - j;
				case (m)
					3: code = d3;
					2: code = d2;
					1: code = d1;
					default: code = d0;
				endcase
			end

			rows = digit(code);
			bits = rows[(6 - gy) * 5 +: 5];

			if (gx < 5 && bits[4 - gx]) begin
				on = 1; red = 255; green = 232; blue = 170;   // cream-gold, like the score sign
			end
		end

		// words
		if (!win && t_up) begin on = 1; red = 255; green = 140; blue = 0;  end   // TIMES UP (orange)
		if (win && t_win) begin on = 1; red = 255; green = 215; blue = 40; end   // YOU WIN (gold)
		if (t_final || t_goal) begin on = 1; red = 255; green = 255; blue = 255; end   // labels (white)
		if ((!hard && g200) || (hard && g300)) begin on = 1; red = 255; green = 232; blue = 170; end   // goal number
		if (t_try)   begin on = 1; red = 35;  green = 75;  blue = 100; end   // PLAY AGAIN (dark blue)
		if (t_hint)  begin on = 1; red = 255; green = 255; blue = 255; end   // PRESS KEY 3 (white)
	end
endmodule