// The "time up" panel: a message and a TRY AGAIN button.
module GameOver_Overlay(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	output reg   on,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	// panel: x 170..470, y 175..335
	localparam PX = 170, PY = 175, PW = 300, PH = 160, PO = 4;
	// button: x 230..410, y 245..285
	localparam BX = 230, BY = 245, BW = 180, BH = 40, BO = 3;

	wire t_up, t_try, t_hint;

	Text_Line #(.X0(215), .Y0(190), .SCALE(5), .LEN(7), .TEXT("TIME UP"))
		T_UP(pixel_x, pixel_y, t_up);
	Text_Line #(.X0(266), .Y0(258), .SCALE(2), .LEN(9), .TEXT("TRY AGAIN"))
		T_TRY(pixel_x, pixel_y, t_try);
	Text_Line #(.X0(254), .Y0(298), .SCALE(2), .LEN(11), .TEXT("PRESS KEY 3"))
		T_HINT(pixel_x, pixel_y, t_hint);

	integer px, py;
	reg in_panel, in_panel_in, in_btn, in_btn_in;

	always @(*) begin
		px = pixel_x; py = pixel_y;
		on = 0; red = 0; green = 0; blue = 0;

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

		// words
		if (t_up)   begin on = 1; red = 255; green = 140; blue = 0;   end   // TIME UP (orange)
		if (t_try)  begin on = 1; red = 35;  green = 75;  blue = 100; end   // TRY AGAIN (dark blue)
		if (t_hint) begin on = 1; red = 255; green = 255; blue = 255; end   // PRESS KEY 3 (white)
	end
endmodule