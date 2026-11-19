module fin_it_to_win_it(
    input CLOCK_50,
    input [3:0] KEY,

    output VGA_CLK,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,

    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);

    // VGA pixel coordinates
    wire [10:0] pixel_x;
    wire [9:0] pixel_y;

    // RGB signals
    reg [7:0] red;
    reg [7:0] green;
    reg [7:0] blue;

    // Boat signals
    wire [10:0] boat_x;
    wire boat_direction;
    wire boat_opaque;
    wire [7:0] boat_red, boat_green, boat_blue;

    // Hook signals
    wire [10:0] hook_x;
    wire [9:0] hook_y;
    wire hook_opaque;
    wire [7:0] hook_red, hook_green, hook_blue;

    // Game signals
    wire [3:0] caught;          // 0 = nothing, 1..6 = fish, 7 = shark, 8 = chest
    wire [7:0] respawn;         // pulses when an item is delivered
    wire [3:0] d3, d2, d1, d0;  // score digits
    wire score_neg;

    // Fish positions, directions and display signals
    wire [10:0] fish0_x, fish1_x, fish2_x, fish3_x, fish4_x, fish5_x;
    wire fish0_direction, fish1_direction, fish2_direction;
    wire fish3_direction, fish4_direction, fish5_direction;
    wire fish0_opaque, fish1_opaque, fish2_opaque, fish3_opaque, fish4_opaque, fish5_opaque;
    wire [7:0] fish0_red, fish0_green, fish0_blue;
    wire [7:0] fish1_red, fish1_green, fish1_blue;
    wire [7:0] fish2_red, fish2_green, fish2_blue;
    wire [7:0] fish3_red, fish3_green, fish3_blue;
    wire [7:0] fish4_red, fish4_green, fish4_blue;
    wire [7:0] fish5_red, fish5_green, fish5_blue;

    // Shark signals
    wire [10:0] shark_x;
    wire [9:0] shark_y;
    wire shark_direction;
    wire shark_opaque;
    wire [7:0] shark_red, shark_green, shark_blue;

    // Chest signals
    wire [10:0] chest_x;
    wire chest_opaque;
    wire [7:0] chest_red, chest_green, chest_blue;

    // Score board signals
    wire sb_opaque;
    wire [7:0] sb_red, sb_green, sb_blue;

    // ------------------------------------------------
    // VGA driver (the teacher's)
    // ------------------------------------------------

    wire        active_pixels;
    wire [9:0]  vx, vy;

    vga_driver the_vga(
        .clk(CLOCK_50),
        .rst(KEY[0]),
        .vga_clk(VGA_CLK),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .active_pixels(active_pixels),
        .xPixel(vx),
        .yPixel(vy),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N)
    );

    assign pixel_x = {1'b0, vx};
    assign pixel_y = vy;

    // ------------------------------------------------
    // Boat: KEY[1] = right, KEY[2] = left (buttons are active-low)
    // ------------------------------------------------

    Boat_Control BC0(
        CLOCK_50,
        KEY[0],
        ~KEY[1],
        ~KEY[2],
        boat_x,
        boat_direction
    );

    Boat_Sprite BS0(
        pixel_x, pixel_y, boat_x, boat_direction,
        boat_opaque, boat_red, boat_green, boat_blue
    );

    // ------------------------------------------------
    // Hook: hangs from the rod tip (left when facing left, right when facing right)
    // ------------------------------------------------

    assign hook_x = boat_direction ? (boat_x + 11'd81) : (boat_x + 11'd12);

    Hook_Sprite HS0(
        pixel_x, pixel_y, hook_x, hook_y, boat_direction,
        hook_opaque, hook_red, hook_green, hook_blue
    );

    // ------------------------------------------------
    // Game controller: hook movement, catching, scoring
    // ------------------------------------------------

    Game_Control GC0(
        .clk(CLOCK_50),
        .rst_n(KEY[0]),
        .button(~KEY[3]),
        .hook_x(hook_x),
        .fish_x0(fish0_x), .fish_x1(fish1_x), .fish_x2(fish2_x),
        .fish_x3(fish3_x), .fish_x4(fish4_x), .fish_x5(fish5_x),
        .shark_x(shark_x), .shark_y(shark_y),
        .chest_x(chest_x),
        .hook_y(hook_y),
        .caught(caught),
        .respawn(respawn),
        .d3(d3), .d2(d2), .d1(d1), .d0(d0),
        .score_neg(score_neg)
    );

    // ------------------------------------------------
    // Where a carried item is drawn: hanging on the hook
    // ------------------------------------------------

    wire [10:0] att_sx = (hook_x > 11'd16) ? (hook_x - 11'd16) : 11'd0;   // small fish
    wire [10:0] att_mx = (hook_x > 11'd20) ? (hook_x - 11'd20) : 11'd0;   // medium fish
    wire [10:0] att_lx = (hook_x > 11'd24) ? (hook_x - 11'd24) : 11'd0;   // large fish, chest

    wire [10:0] f0_dx = (caught == 4'd1) ? att_sx : fish0_x;
    wire [9:0]  f0_dy = (caught == 4'd1) ? (hook_y - 10'd8)  : 10'd215;
    wire [10:0] f1_dx = (caught == 4'd2) ? att_sx : fish1_x;
    wire [9:0]  f1_dy = (caught == 4'd2) ? (hook_y - 10'd8)  : 10'd245;
    wire [10:0] f2_dx = (caught == 4'd3) ? att_mx : fish2_x;
    wire [9:0]  f2_dy = (caught == 4'd3) ? (hook_y - 10'd10) : 10'd295;
    wire [10:0] f3_dx = (caught == 4'd4) ? att_mx : fish3_x;
    wire [9:0]  f3_dy = (caught == 4'd4) ? (hook_y - 10'd10) : 10'd335;
    wire [10:0] f4_dx = (caught == 4'd5) ? att_lx : fish4_x;
    wire [9:0]  f4_dy = (caught == 4'd5) ? (hook_y - 10'd12) : 10'd385;
    wire [10:0] f5_dx = (caught == 4'd6) ? att_lx : fish5_x;
    wire [9:0]  f5_dy = (caught == 4'd6) ? (hook_y - 10'd12) : 10'd432;

    wire [10:0] sh_dx = (caught == 4'd7) ? (hook_x + 11'd56) : shark_x;   // shark x is stored +112
    wire [9:0]  sh_dy = (caught == 4'd7) ? (hook_y - 10'd21) : shark_y;

    wire [10:0] ch_dx = (caught == 4'd8) ? att_lx : chest_x;
    wire [9:0]  ch_dy = (caught == 4'd8) ? (hook_y - 10'd18) : 10'd438;

    // ------------------------------------------------
    // Fish: small near the top of the water, large near the sand
    // ------------------------------------------------

    Fish_Control FC0(CLOCK_50, KEY[0], 32, 2, 16'hACE1, fish0_x, fish0_direction, respawn[0]);
    Fish_Control FC1(CLOCK_50, KEY[0], 32, 2, 16'hBEEF, fish1_x, fish1_direction, respawn[1]);
    Fish_Control FC2(CLOCK_50, KEY[0], 40, 3, 16'h1234, fish2_x, fish2_direction, respawn[2]);
    Fish_Control FC3(CLOCK_50, KEY[0], 40, 3, 16'h5678, fish3_x, fish3_direction, respawn[3]);
    Fish_Control FC4(CLOCK_50, KEY[0], 48, 4, 16'h9ABC, fish4_x, fish4_direction, respawn[4]);
    Fish_Control FC5(CLOCK_50, KEY[0], 48, 4, 16'hDEF0, fish5_x, fish5_direction, respawn[5]);

    Fish_Sprite FS0(pixel_x, pixel_y, f0_dx, f0_dy, 0, fish0_direction, fish0_opaque, fish0_red, fish0_green, fish0_blue);
    Fish_Sprite FS1(pixel_x, pixel_y, f1_dx, f1_dy, 1, fish1_direction, fish1_opaque, fish1_red, fish1_green, fish1_blue);
    Fish_Sprite FS2(pixel_x, pixel_y, f2_dx, f2_dy, 2, fish2_direction, fish2_opaque, fish2_red, fish2_green, fish2_blue);
    Fish_Sprite FS3(pixel_x, pixel_y, f3_dx, f3_dy, 3, fish3_direction, fish3_opaque, fish3_red, fish3_green, fish3_blue);
    Fish_Sprite FS4(pixel_x, pixel_y, f4_dx, f4_dy, 4, fish4_direction, fish4_opaque, fish4_red, fish4_green, fish4_blue);
    Fish_Sprite FS5(pixel_x, pixel_y, f5_dx, f5_dy, 5, fish5_direction, fish5_opaque, fish5_red, fish5_green, fish5_blue);

    // ------------------------------------------------
    // Shark
    // ------------------------------------------------

    Shark_Control SC0(CLOCK_50, KEY[0], respawn[6], shark_x, shark_y, shark_direction);

    Shark_Sprite SH0(
        pixel_x, pixel_y, sh_dx, sh_dy, shark_direction,
        shark_opaque, shark_red, shark_green, shark_blue
    );

    // ------------------------------------------------
    // Chest
    // ------------------------------------------------

    Chest_Control CC0(CLOCK_50, KEY[0], respawn[7], chest_x);

    Chest_Sprite CS0(
        pixel_x, pixel_y, ch_dx, ch_dy,
        chest_opaque, chest_red, chest_green, chest_blue
    );

    // ------------------------------------------------
    // Score board
    // ------------------------------------------------

    Scoreboard SB0(
        pixel_x, pixel_y,
        score_neg, d3, d2, d1, d0,
        sb_opaque, sb_red, sb_green, sb_blue
    );

	 
	 // ------------------------------------------------
    // Title and controls text
    // ------------------------------------------------

    wire title_on, title_shadow;
    wire ctl1_on, ctl2_on, ctl3_on, ctl4_on;

    // Title: shadow first (2 pixels down-right), then the white letters
    Text_Line #(.X0(178), .Y0(6), .SCALE(3), .LEN(16), .TEXT("Fin It To Win It"))
        TT1(pixel_x, pixel_y, title_shadow);
    Text_Line #(.X0(176), .Y0(4), .SCALE(3), .LEN(16), .TEXT("Fin It To Win It"))
        TT0(pixel_x, pixel_y, title_on);

    // Controls on the far left, in the sky
    Text_Line #(.X0(8), .Y0(32),  .SCALE(2), .LEN(12), .TEXT("KEY 1  RIGHT"))
        TC1(pixel_x, pixel_y, ctl1_on);
    Text_Line #(.X0(8), .Y0(58),  .SCALE(2), .LEN(11), .TEXT("KEY 2  LEFT"))
        TC2(pixel_x, pixel_y, ctl2_on);
    Text_Line #(.X0(8), .Y0(84),  .SCALE(2), .LEN(17), .TEXT("KEY 3  HOLD  DOWN"))
        TC3(pixel_x, pixel_y, ctl3_on);
    Text_Line #(.X0(8), .Y0(110), .SCALE(2), .LEN(20), .TEXT("KEY 3  RELEASE  REST"))
        TC4(pixel_x, pixel_y, ctl4_on);
	 
	 
	 // ------------------------------------------------
    // Clouds (drift slowly to the right and loop around)
    // ------------------------------------------------

    wire cloud0_on, cloud1_on, cloud2_on, cloud3_on;
    wire cloud4_on, cloud5_on, cloud6_on, cloud7_on;

    Cloud #(.Y0(45),  .SCALE(4), .START(480), .FRAMES_PER_PIXEL(7))
        CL0(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud0_on);
    Cloud #(.Y0(100), .SCALE(3), .START(200), .FRAMES_PER_PIXEL(9))
        CL1(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud1_on);
    Cloud #(.Y0(108), .SCALE(5), .START(40),  .FRAMES_PER_PIXEL(5))
        CL2(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud2_on);
    Cloud #(.Y0(12),  .SCALE(3), .START(330), .FRAMES_PER_PIXEL(8))
        CL3(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud3_on);
    Cloud #(.Y0(28),  .SCALE(4), .START(600), .FRAMES_PER_PIXEL(11))
        CL4(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud4_on);
    Cloud #(.Y0(72),  .SCALE(3), .START(90),  .FRAMES_PER_PIXEL(10))
        CL5(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud5_on);
    Cloud #(.Y0(125), .SCALE(4), .START(380), .FRAMES_PER_PIXEL(6))
        CL6(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud6_on);
    Cloud #(.Y0(62),  .SCALE(5), .START(260), .FRAMES_PER_PIXEL(12))
        CL7(CLOCK_50, KEY[0], pixel_x, pixel_y, cloud7_on);
	 
	 
    // ------------------------------------------------
    // Background and sprite drawing (later items are drawn on top)
    // ------------------------------------------------

    always @(*) begin

        // Sky
        if (pixel_y < 201) begin
            red = 190; green = 230; blue = 255;
        end
		  
        // Ocean: light at the surface, darker toward the sand
        else if (pixel_y < 456) begin
            red   = 120 - ((pixel_y - 201) * 80) / 255;
            green = 195 - ((pixel_y - 201) * 95) / 255;
            blue  = 235 - ((pixel_y - 201) * 65) / 255;
        end
		  
        // Sand
        else begin
            red = 194; green = 178; blue = 128;
        end
		  
		  // Clouds (behind the text, the boat and the score board)
        if (cloud0_on || cloud1_on || cloud2_on || cloud3_on ||
            cloud4_on || cloud5_on || cloud6_on || cloud7_on) begin
            red = 8'd255; green = 8'd255; blue = 8'd255;
        end

		  // Controls (red) and title (orange with a dark blue shadow)
        if (ctl1_on || ctl2_on || ctl3_on || ctl4_on) begin red = 8'd210; green = 8'd25; blue = 8'd25; end
        if (title_shadow) begin red = 8'd35; green = 8'd75; blue = 8'd100; end
        if (title_on)     begin red = 8'd255; green = 8'd140; blue = 8'd0; end
        
		  if (boat_opaque) begin red = boat_red; green = boat_green; blue = boat_blue; end

        if (fish0_opaque) begin red = fish0_red; green = fish0_green; blue = fish0_blue; end
        if (fish1_opaque) begin red = fish1_red; green = fish1_green; blue = fish1_blue; end
        if (fish2_opaque) begin red = fish2_red; green = fish2_green; blue = fish2_blue; end
        if (fish3_opaque) begin red = fish3_red; green = fish3_green; blue = fish3_blue; end
        if (fish4_opaque) begin red = fish4_red; green = fish4_green; blue = fish4_blue; end
        if (fish5_opaque) begin red = fish5_red; green = fish5_green; blue = fish5_blue; end

        if (shark_opaque) begin red = shark_red; green = shark_green; blue = shark_blue; end
        if (chest_opaque) begin red = chest_red; green = chest_green; blue = chest_blue; end

        // Hook on top of the items so you can see what it is holding
        if (hook_opaque) begin red = hook_red; green = hook_green; blue = hook_blue; end

        // Score board on top of everything
        if (sb_opaque) begin red = sb_red; green = sb_green; blue = sb_blue; end

    end

    // ------------------------------------------------
    // VGA color outputs
    // ------------------------------------------------

    assign VGA_R = red;
    assign VGA_G = green;
    assign VGA_B = blue;

endmodule