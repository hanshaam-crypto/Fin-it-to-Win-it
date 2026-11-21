// Draws one decorative coral on the sea floor (one instance per coral,
// like the clouds). Up to 20 art pixels wide, each art pixel drawn 3x3,
// like the chest and the fish. The bottom two art rows sit in the sand.
//
// Parameters:
//   X0    : left edge on the screen (the coral box is 60 pixels wide)
//   SHAPE : 0 = branch (16 rows)       1 = fan (16 rows)
//           2 = bush, short (12 rows)  3 = tall tree (22 rows)
//           4 = wide, medium (19 rows)
//   COLOR : 0 = red, 1 = pink, 2 = orange, 3 = purple
//   FLIP  : 1 = mirrored
//   BOTTOM: bottom edge on the screen (sand is y 456..479), so corals can
//           sit at different depths
module Coral_Sprite #(
	parameter X0    = 0,
	parameter SHAPE = 0,
	parameter COLOR = 0,
	parameter FLIP  = 0,
	parameter BOTTOM = 462    // bottom edge on the screen (sand starts at 456)
)(
	input [10:0] pixel_x,
	input [9:0]  pixel_y,
	output reg   opaque,
	output reg [7:0] red,
	output reg [7:0] green,
	output reg [7:0] blue
);
	localparam ROWS   = (SHAPE == 3) ? 22 : (SHAPE == 4) ? 19 : 16;
	localparam TOP    = BOTTOM - ROWS * 3;

	reg [10:0] dx;
	reg [9:0]  dy;
	reg [4:0]  ax, col, ay;
	reg [79:0] row;
	reg [3:0]  pix;

	always @(*) begin
		opaque = 0; red = 0; green = 0; blue = 0;
		dx = 0; dy = 0; ax = 0; col = 0; ay = 0; row = 0; pix = 0;

		if (pixel_x >= X0 && pixel_x < X0 + 60 &&
		    pixel_y >= TOP && pixel_y < BOTTOM) begin

			dx  = pixel_x - X0;
			dy  = pixel_y - TOP;
			ax  = dx / 3;                           // 0..19
			ay  = dy / 3;                           // 0..ROWS-1
			col = FLIP ? (5'd19 - ax) : ax;

			// 0 = empty, 1 = dark, 2 = main color, 3 = highlight
			case ({SHAPE[2:0], ay})
				// shape 0: branch, 16 rows
				{3'd0, 5'd0}: row = 80'h00000002000002000000;
				{3'd0, 5'd1}: row = 80'h00002002300023020000;
				{3'd0, 5'd2}: row = 80'h00002302302023023000;
				{3'd0, 5'd3}: row = 80'h00000232302302320000;
				{3'd0, 5'd4}: row = 80'h00200022302300220200;
				{3'd0, 5'd5}: row = 80'h00230002322300232300;
				{3'd0, 5'd6}: row = 80'h00023002232002232000;
				{3'd0, 5'd7}: row = 80'h00002322322022320000;
				{3'd0, 5'd8}: row = 80'h00000223222223100000;
				{3'd0, 5'd9}: row = 80'h00000012222221000000;
				{3'd0, 5'd10}: row = 80'h00000001222210000000;
				{3'd0, 5'd11}: row = 80'h00000000222100000000;
				{3'd0, 5'd12}: row = 80'h00000000222100000000;
				{3'd0, 5'd13}: row = 80'h00000001222210000000;
				{3'd0, 5'd14}: row = 80'h00000011222211000000;
				{3'd0, 5'd15}: row = 80'h00000111111111100000;
				// shape 1: fan, 16 rows
				{3'd1, 5'd0}: row = 80'h00000000320000000000;
				{3'd1, 5'd1}: row = 80'h00003200321003200000;
				{3'd1, 5'd2}: row = 80'h00003210321003210000;
				{3'd1, 5'd3}: row = 80'h00003210321032103200;
				{3'd1, 5'd4}: row = 80'h00320321321032103200;
				{3'd1, 5'd5}: row = 80'h00321032321321032100;
				{3'd1, 5'd6}: row = 80'h00032103222210321000;
				{3'd1, 5'd7}: row = 80'h00003213222213210000;
				{3'd1, 5'd8}: row = 80'h00000322222222100000;
				{3'd1, 5'd9}: row = 80'h00000012222221000000;
				{3'd1, 5'd10}: row = 80'h00000001222210000000;
				{3'd1, 5'd11}: row = 80'h00000000222100000000;
				{3'd1, 5'd12}: row = 80'h00000000222100000000;
				{3'd1, 5'd13}: row = 80'h00000001222210000000;
				{3'd1, 5'd14}: row = 80'h00000011222211000000;
				{3'd1, 5'd15}: row = 80'h00000111111111100000;
				// shape 2: bush, 16 rows
				{3'd2, 5'd0}: row = 80'h00000000000000000000;
				{3'd2, 5'd1}: row = 80'h00000000000000000000;
				{3'd2, 5'd2}: row = 80'h00000000000000000000;
				{3'd2, 5'd3}: row = 80'h00000000000000000000;
				{3'd2, 5'd4}: row = 80'h00000020000002000000;
				{3'd2, 5'd5}: row = 80'h00002023002002302000;
				{3'd2, 5'd6}: row = 80'h00002323002302323000;
				{3'd2, 5'd7}: row = 80'h00020232023202320000;
				{3'd2, 5'd8}: row = 80'h00023022323223202000;
				{3'd2, 5'd9}: row = 80'h00002301222221023000;
				{3'd2, 5'd10}: row = 80'h00000223122212230000;
				{3'd2, 5'd11}: row = 80'h00000012222222100000;
				{3'd2, 5'd12}: row = 80'h00000001222221000000;
				{3'd2, 5'd13}: row = 80'h00000001222221000000;
				{3'd2, 5'd14}: row = 80'h00000011222221100000;
				{3'd2, 5'd15}: row = 80'h00000111111111110000;
				// shape 3: tree, 22 rows
				{3'd3, 5'd0}: row = 80'h00000000000032000000;
				{3'd3, 5'd1}: row = 80'h00000000000322100000;
				{3'd3, 5'd2}: row = 80'h00003200000321032000;
				{3'd3, 5'd3}: row = 80'h00032210000321322100;
				{3'd3, 5'd4}: row = 80'h00032100000322210000;
				{3'd3, 5'd5}: row = 80'h00032103200321000000;
				{3'd3, 5'd6}: row = 80'h00003232210321000320;
				{3'd3, 5'd7}: row = 80'h03203221000321003221;
				{3'd3, 5'd8}: row = 80'h32213210003210003210;
				{3'd3, 5'd9}: row = 80'h03213210320321003210;
				{3'd3, 5'd10}: row = 80'h00322103221321032100;
				{3'd3, 5'd11}: row = 80'h00032100321321032100;
				{3'd3, 5'd12}: row = 80'h00032210322210321000;
				{3'd3, 5'd13}: row = 80'h00003221322103221000;
				{3'd3, 5'd14}: row = 80'h00000322221032210000;
				{3'd3, 5'd15}: row = 80'h00000032222322100000;
				{3'd3, 5'd16}: row = 80'h00000003222221000000;
				{3'd3, 5'd17}: row = 80'h00000000322210000000;
				{3'd3, 5'd18}: row = 80'h00000000322210000000;
				{3'd3, 5'd19}: row = 80'h00000001222221000000;
				{3'd3, 5'd20}: row = 80'h00000011222221100000;
				{3'd3, 5'd21}: row = 80'h00000111111111110000;
				// shape 4: wide, 19 rows
				{3'd4, 5'd0}: row = 80'h00000003200000003200;
				{3'd4, 5'd1}: row = 80'h00000032210000032210;
				{3'd4, 5'd2}: row = 80'h00320003210320003210;
				{3'd4, 5'd3}: row = 80'h03221003210321032100;
				{3'd4, 5'd4}: row = 80'h00321003213221032100;
				{3'd4, 5'd5}: row = 80'h00321032100321321032;
				{3'd4, 5'd6}: row = 80'h32032132100322100321;
				{3'd4, 5'd7}: row = 80'h32103221000321003210;
				{3'd4, 5'd8}: row = 80'h03210321003210032100;
				{3'd4, 5'd9}: row = 80'h00321321003210321000;
				{3'd4, 5'd10}: row = 80'h00032221032103210000;
				{3'd4, 5'd11}: row = 80'h00003222132132100000;
				{3'd4, 5'd12}: row = 80'h00000322222221000000;
				{3'd4, 5'd13}: row = 80'h00000003222100000000;
				{3'd4, 5'd14}: row = 80'h00000000322100000000;
				{3'd4, 5'd15}: row = 80'h00000000322100000000;
				{3'd4, 5'd16}: row = 80'h00000001222210000000;
				{3'd4, 5'd17}: row = 80'h00000011222211000000;
				{3'd4, 5'd18}: row = 80'h00000111111111100000;
				default: row = 80'd0;
			endcase

			pix = row[(5'd19 - col) * 4 +: 4];

			if (pix != 0) begin
				opaque = 1;
				case ({COLOR[1:0], pix[1:0]})
					{2'd0, 2'd1}: begin red = 8'd110; green = 8'd20; blue = 8'd30; end   // red dark
					{2'd0, 2'd2}: begin red = 8'd200; green = 8'd40; blue = 8'd45; end   // red main
					{2'd0, 2'd3}: begin red = 8'd255; green = 8'd105; blue = 8'd85; end   // red light
					{2'd1, 2'd1}: begin red = 8'd140; green = 8'd40; blue = 8'd85; end   // pink dark
					{2'd1, 2'd2}: begin red = 8'd230; green = 8'd95; blue = 8'd140; end   // pink main
					{2'd1, 2'd3}: begin red = 8'd255; green = 8'd170; blue = 8'd195; end   // pink light
					{2'd2, 2'd1}: begin red = 8'd150; green = 8'd65; blue = 8'd30; end   // orange dark
					{2'd2, 2'd2}: begin red = 8'd235; green = 8'd120; blue = 8'd55; end   // orange main
					{2'd2, 2'd3}: begin red = 8'd255; green = 8'd185; blue = 8'd115; end   // orange light
					{2'd3, 2'd1}: begin red = 8'd60; green = 8'd45; blue = 8'd120; end   // purple dark
					{2'd3, 2'd2}: begin red = 8'd115; green = 8'd90; blue = 8'd190; end   // purple main
					{2'd3, 2'd3}: begin red = 8'd170; green = 8'd150; blue = 8'd240; end   // purple light
					default: begin red = 8'd255; green = 8'd0; blue = 8'd255; end
				endcase
			end
		end
	end
endmodule