// Draws the level menu: a dark panel with an orange edge (like the TIME UP
// panel), a SELECT MODE heading, the two level boxes (EASY / HARD) and the
// help text under them.
// The chosen box is orange-yellow, the other one is light blue.
module Menu_Overlay(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	input        hard,          // 1 = Hard box is highlighted
	output reg   on,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam EX = 150;   // Easy box left edge
	localparam HX = 350;   // Hard box left edge
	localparam BY = 210;   // top of both boxes
	localparam BW = 140;   // box width
	localparam BH = 60;    // box height
	localparam OT = 4;     // outline thickness
	// panel behind everything: x 130..510, y 160..362
	localparam PX = 130, PY = 160, PW = 380, PH = 202, PO = 4;

	wire title_text, easy_text, hard_text, goal_e, goal_h, hint1, hint2;

	Text_Line #(.X0(221), .Y0(176), .SCALE(3), .LEN(11), .TEXT("SELECT MODE"))
		T_TITLE(pixel_x, pixel_y, title_text);

	Text_Line #(.X0(EX+22), .Y0(BY+16), .SCALE(4), .LEN(4), .TEXT("EASY"))
		T_EASY(pixel_x, pixel_y, easy_text);
	Text_Line #(.X0(HX+22), .Y0(BY+16), .SCALE(4), .LEN(4), .TEXT("HARD"))
		T_HARD(pixel_x, pixel_y, hard_text);
	// the goal score under each box
	Text_Line #(.X0(EX+22), .Y0(BY+BH+8), .SCALE(2), .LEN(8), .TEXT("GOAL 200"))
		T_GE(pixel_x, pixel_y, goal_e);
	Text_Line #(.X0(HX+22), .Y0(BY+BH+8), .SCALE(2), .LEN(8), .TEXT("GOAL 300"))
		T_GH(pixel_x, pixel_y, goal_h);
	Text_Line #(.X0(212), .Y0(308), .SCALE(2), .LEN(18), .TEXT("KEY 1 OR 2  CHOOSE"))
		T_H1(pixel_x, pixel_y, hint1);
	Text_Line #(.X0(248), .Y0(334), .SCALE(2), .LEN(12), .TEXT("KEY 3  START"))
		T_H2(pixel_x, pixel_y, hint2);

	integer px, py;
	reg in_panel, in_panel_in, in_easy, in_hard, in_easy_in, in_hard_in;

	always @(*) begin
		px = pixel_x; py = pixel_y;
		on = 0; red = 0; green = 0; blue = 0;

		in_easy    = (px >= EX && px < EX + BW && py >= BY && py < BY + BH);
		in_hard    = (px >= HX && px < HX + BW && py >= BY && py < BY + BH);
		in_easy_in = (px >= EX + OT && px < EX + BW - OT && py >= BY + OT && py < BY + BH - OT);
		in_hard_in = (px >= HX + OT && px < HX + BW - OT && py >= BY + OT && py < BY + BH - OT);

		in_panel    = (px >= PX && px < PX + PW && py >= PY && py < PY + PH);
		in_panel_in = (px >= PX + PO && px < PX + PW - PO && py >= PY + PO && py < PY + PH - PO);

		// panel
		if (in_panel) begin
			on = 1;
			if (in_panel_in) begin red = 35; green = 60; blue = 90; end      // dark blue
			else             begin red = 255; green = 140; blue = 0; end    // orange edge
		end

		// Easy box
		if (in_easy) begin
			on = 1;
			if (!hard) begin   // highlighted
				if (in_easy_in) begin red = 255; green = 220; blue = 110; end
				else            begin red = 255; green = 140; blue = 0;   end
			end else begin
				if (in_easy_in) begin red = 220; green = 245; blue = 255; end
				else            begin red = 60;  green = 130; blue = 170; end
			end
		end

		// Hard box
		if (in_hard) begin
			on = 1;
			if (hard) begin    // highlighted
				if (in_hard_in) begin red = 255; green = 220; blue = 110; end
				else            begin red = 255; green = 140; blue = 0;   end
			end else begin
				if (in_hard_in) begin red = 220; green = 245; blue = 255; end
				else            begin red = 60;  green = 130; blue = 170; end
			end
		end

		// words inside the boxes (dark blue)
		if (easy_text || hard_text) begin
			on = 1; red = 35; green = 75; blue = 100;
		end

		// heading (orange, like TIME UP)
		if (title_text) begin
			on = 1; red = 255; green = 140; blue = 0;
		end

		// goal scores (cream-gold, like the score sign)
		if (goal_e || goal_h) begin
			on = 1; red = 255; green = 232; blue = 170;
		end

		// help text (white)
		if (hint1 || hint2) begin
			on = 1; red = 255; green = 255; blue = 255;
		end
	end
endmodule