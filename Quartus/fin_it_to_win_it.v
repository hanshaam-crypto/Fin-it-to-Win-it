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

    // Menu signals
    wire playing;               // 1 once a level has been chosen
    wire hard_mode;             // 0 = Easy, 1 = Hard
    wire menu_on;
    wire [7:0] menu_r, menu_g, menu_b;

    // Timer and restart signals
    wire [5:0] seconds_left;
    wire time_up;
    wire timer_opaque;
    wire [7:0] timer_r, timer_g, timer_b;
    wire game_on = playing && !time_up;    // the game runs after a level is chosen until time runs out
    wire restart_n;                        // goes low for a moment when TRY AGAIN is pressed
    wire sys_rst_n = KEY[0] & restart_n;   // reset used by the game (KEY0 or try again)
    wire go_on;
    wire [7:0] go_r, go_g, go_b;

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
    wire [3:0]  caught;         // 0 = nothing, 1..6 = fish, 7 = shark, 8 = chest, 9..12 = trash
    wire [11:0] respawn;        // pulses when an item is delivered
    wire drop;                  // pulses when the chest is dropped
    wire [3:0]  d3, d2, d1, d0; // score digits
    wire score_neg;
    wire signed [15:0] score_val;    // the score itself
    wire pop;                        // pulses when points are added
    wire signed [15:0] pop_pts;      // how many points that was
    wire eat_pop;                    // pulses when the shark eats a fish

    // goal: 200 on Easy, 300 on Hard
    wire [15:0] goal = hard_mode ? 16'd300 : 16'd200;
    wire win = !score_val[15] && (score_val >= goal);

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
    wire [9:0]  chest_y;
    wire [4:0]  chest_a;     // fade level (0 = invisible, 16 = solid)
    wire chest_opaque;
    wire [7:0] chest_red, chest_green, chest_blue;

    // Trash signals (hard level only)
    wire [10:0] tr0_x, tr1_x, tr2_x, tr3_x;
    wire [9:0]  tr0_y, tr1_y, tr2_y, tr3_y;
    wire tr0_op, tr1_op, tr2_op, tr3_op;
    wire [4:0] tr0_a, tr1_a, tr2_a, tr3_a;   // fade level (0 = invisible, 16 = solid)
    wire [7:0] tr0_r, tr0_g, tr0_b;
    wire [7:0] tr1_r, tr1_g, tr1_b;
    wire [7:0] tr2_r, tr2_g, tr2_b;
    wire [7:0] tr3_r, tr3_g, tr3_b;

    // Score board signals
    wire sb_opaque;
    wire [7:0] sb_red, sb_green, sb_blue;

    // ------------------------------------------------
    // VGA driver (the teacher's)
    // ------------------------------------------------

    wire        active_pixels;
    wire [9:0]  vx, vy;

    // the driver's sync/blank signals go through the output registers at
    // the bottom of this file, together with the colors
    wire hs_raw, vs_raw, blank_raw;

    vga_driver the_vga(
        .clk(CLOCK_50),
        .rst(KEY[0]),
        .vga_clk(VGA_CLK),
        .hsync(hs_raw),
        .vsync(vs_raw),
        .active_pixels(active_pixels),
        .xPixel(vx),
        .yPixel(vy),
        .VGA_BLANK_N(blank_raw),
        .VGA_SYNC_N(VGA_SYNC_N)
    );

    assign pixel_x = {1'b0, vx};
    assign pixel_y = vy;

    // ------------------------------------------------
    // Level menu: KEY2 = Easy, KEY1 = Hard, KEY3 = start
    // ------------------------------------------------

    // sys_rst_n (KEY0 or TRY AGAIN) sends the game back to the level menu.
    // KEY0 also sets the level back to Easy; TRY AGAIN keeps the last level highlighted.
    Menu_Control MC0(CLOCK_50, sys_rst_n, KEY[0], ~KEY[2], ~KEY[1], ~KEY[3], playing, hard_mode);

    Menu_Overlay MO0(pixel_x, pixel_y, hard_mode, menu_on, menu_r, menu_g, menu_b);

    // ------------------------------------------------
    // Timer (30 seconds) and try again
    // ------------------------------------------------

    Timer_Control TM0(CLOCK_50, sys_rst_n, playing, seconds_left, time_up);

    Timer_Sign TMS0(pixel_x, pixel_y, seconds_left, timer_opaque, timer_r, timer_g, timer_b);

    Restart_Control RC0(CLOCK_50, time_up, ~KEY[3], restart_n);

    GameOver_Overlay GO0(pixel_x, pixel_y, score_neg, d3, d2, d1, d0, hard_mode, win, go_on, go_r, go_g, go_b);

    // ------------------------------------------------
    // Boat: KEY[1] = right, KEY[2] = left (buttons are active-low)
    // The boat can't move while the hook is out, before a level is chosen,
    // or after time runs out.
    // ------------------------------------------------

    wire hook_busy = (hook_y > 10'd206) || (~KEY[3]) || (!game_on);

    Boat_Control BC0(
        CLOCK_50,
        sys_rst_n,
        ~KEY[1] & ~hook_busy,
        ~KEY[2] & ~hook_busy,
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
        .rst_n(sys_rst_n),
        .button(~KEY[3] & game_on),
        .hard(hard_mode),
        .run(game_on),
        .hook_x(hook_x),
        .fish_x0(fish0_x), .fish_x1(fish1_x), .fish_x2(fish2_x),
        .fish_x3(fish3_x), .fish_x4(fish4_x), .fish_x5(fish5_x),
        .shark_x(shark_x), .shark_y(shark_y),
        .chest_x(chest_x),
        .chest_y(chest_y),
        .trash_x0(tr0_x), .trash_x1(tr1_x), .trash_x2(tr2_x), .trash_x3(tr3_x),
        .trash_y0(tr0_y), .trash_y1(tr1_y), .trash_y2(tr2_y), .trash_y3(tr3_y),
        .hook_y(hook_y),
        .caught(caught),
        .respawn(respawn),
        .drop(drop),
        .d3(d3), .d2(d2), .d1(d1), .d0(d0),
        .score_neg(score_neg),
        .score_out(score_val),
        .pop(pop),
        .pop_pts(pop_pts),
        .eat_pop(eat_pop)
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
    wire [9:0]  ch_dy = (caught == 4'd8) ? (hook_y - 10'd18) : chest_y;
    wire [4:0]  ch_a  = (caught == 4'd8) ? 5'd16 : chest_a;   // solid while on the hook

    // bottles are 12x24, pop tabs are 16x16
    wire [10:0] t0_dx = (caught == 4'd9)  ? (hook_x - 11'd6) : tr0_x;
    wire [9:0]  t0_dy = (caught == 4'd9)  ? (hook_y - 10'd12) : tr0_y;
    wire [10:0] t1_dx = (caught == 4'd10) ? (hook_x - 11'd6) : tr1_x;
    wire [9:0]  t1_dy = (caught == 4'd10) ? (hook_y - 10'd12) : tr1_y;
    wire [10:0] t2_dx = (caught == 4'd11) ? (hook_x - 11'd8) : tr2_x;
    wire [9:0]  t2_dy = (caught == 4'd11) ? (hook_y - 10'd8)  : tr2_y;
    wire [10:0] t3_dx = (caught == 4'd12) ? (hook_x - 11'd8) : tr3_x;
    wire [9:0]  t3_dy = (caught == 4'd12) ? (hook_y - 10'd8)  : tr3_y;

    // fade level used to draw each piece of trash (solid while on the hook)
    wire [4:0] t0_a = (caught == 4'd9)  ? 5'd16 : tr0_a;
    wire [4:0] t1_a = (caught == 4'd10) ? 5'd16 : tr1_a;
    wire [4:0] t2_a = (caught == 4'd11) ? 5'd16 : tr2_a;
    wire [4:0] t3_a = (caught == 4'd12) ? 5'd16 : tr3_a;

    // ------------------------------------------------
    // Fish: small near the top of the water, large near the sand
    // ------------------------------------------------

    Fish_Control FC0(CLOCK_50, sys_rst_n, 32, 2, 16'hACE1, fish0_x, fish0_direction, respawn[0]);
    Fish_Control FC1(CLOCK_50, sys_rst_n, 32, 2, 16'hBEEF, fish1_x, fish1_direction, respawn[1]);
    Fish_Control FC2(CLOCK_50, sys_rst_n, 40, 3, 16'h1234, fish2_x, fish2_direction, respawn[2]);
    Fish_Control FC3(CLOCK_50, sys_rst_n, 40, 3, 16'h5678, fish3_x, fish3_direction, respawn[3]);
    Fish_Control FC4(CLOCK_50, sys_rst_n, 48, 4, 16'h9ABC, fish4_x, fish4_direction, respawn[4]);
    Fish_Control FC5(CLOCK_50, sys_rst_n, 48, 4, 16'hDEF0, fish5_x, fish5_direction, respawn[5]);

    Fish_Sprite FS0(pixel_x, pixel_y, f0_dx, f0_dy, 0, fish0_direction, fish0_opaque, fish0_red, fish0_green, fish0_blue);
    Fish_Sprite FS1(pixel_x, pixel_y, f1_dx, f1_dy, 1, fish1_direction, fish1_opaque, fish1_red, fish1_green, fish1_blue);
    Fish_Sprite FS2(pixel_x, pixel_y, f2_dx, f2_dy, 2, fish2_direction, fish2_opaque, fish2_red, fish2_green, fish2_blue);
    Fish_Sprite FS3(pixel_x, pixel_y, f3_dx, f3_dy, 3, fish3_direction, fish3_opaque, fish3_red, fish3_green, fish3_blue);
    Fish_Sprite FS4(pixel_x, pixel_y, f4_dx, f4_dy, 4, fish4_direction, fish4_opaque, fish4_red, fish4_green, fish4_blue);
    Fish_Sprite FS5(pixel_x, pixel_y, f5_dx, f5_dy, 5, fish5_direction, fish5_opaque, fish5_red, fish5_green, fish5_blue);

    // ------------------------------------------------
    // Shark
    // ------------------------------------------------

    Shark_Control SC0(CLOCK_50, sys_rst_n, respawn[6], shark_x, shark_y, shark_direction);

    Shark_Sprite SH0(
        pixel_x, pixel_y, sh_dx, sh_dy, shark_direction,
        shark_opaque, shark_red, shark_green, shark_blue
    );

    // ------------------------------------------------
    // Chest
    // ------------------------------------------------

    // where a dropped chest lands (kept on the screen)
    wire [10:0] chest_drop_x = (att_lx > 11'd592) ? 11'd592 : att_lx;

    Chest_Control CC0(CLOCK_50, sys_rst_n, respawn[7], drop, chest_drop_x, chest_x, chest_y, chest_a);

    Chest_Sprite CS0(
        pixel_x, pixel_y, ch_dx, ch_dy,
        chest_opaque, chest_red, chest_green, chest_blue
    );

    // ------------------------------------------------
    // Trash (only shown and only hookable on the hard level)
    // ------------------------------------------------

    Trash_Control #(.INIT_X(100), .INIT_Y(260), .SEED(16'hA5A5)) TR0(CLOCK_50, sys_rst_n, respawn[8],  tr0_x, tr0_y, tr0_a);
    Trash_Control #(.INIT_X(450), .INIT_Y(330), .SEED(16'h3C3C)) TR1(CLOCK_50, sys_rst_n, respawn[9],  tr1_x, tr1_y, tr1_a);
    Trash_Control #(.INIT_X(280), .INIT_Y(380), .SEED(16'h7E7E)) TR2(CLOCK_50, sys_rst_n, respawn[10], tr2_x, tr2_y, tr2_a);
    Trash_Control #(.INIT_X(540), .INIT_Y(240), .SEED(16'h1B1B)) TR3(CLOCK_50, sys_rst_n, respawn[11], tr3_x, tr3_y, tr3_a);

    Trash_Sprite #(.KIND(0)) TS0(pixel_x, pixel_y, t0_dx, t0_dy, tr0_op, tr0_r, tr0_g, tr0_b);
    Trash_Sprite #(.KIND(0)) TS1(pixel_x, pixel_y, t1_dx, t1_dy, tr1_op, tr1_r, tr1_g, tr1_b);
    Trash_Sprite #(.KIND(1)) TS2(pixel_x, pixel_y, t2_dx, t2_dy, tr2_op, tr2_r, tr2_g, tr2_b);
    Trash_Sprite #(.KIND(1)) TS3(pixel_x, pixel_y, t3_dx, t3_dy, tr3_op, tr3_r, tr3_g, tr3_b);

    // ------------------------------------------------
    // Score board
    // ------------------------------------------------

    Scoreboard SB0(
        pixel_x, pixel_y,
        score_neg, d3, d2, d1, d0,
        sb_opaque, sb_red, sb_green, sb_blue
    );

    // ------------------------------------------------
    // Coral on the sea floor (fixed spots, different heights)
    //   SHAPE: 0 = branch, 1 = fan, 2 = short bush, 3 = tall tree, 4 = medium wide
    //   COLOR: 0 = red, 1 = pink, 2 = orange, 3 = purple
    //   BOTTOM: how deep the base sits in the sand (sand is y 456..479)
    // ------------------------------------------------

    wire cr0_op, cr1_op, cr2_op, cr3_op;
    wire [7:0] cr0_r, cr0_g, cr0_b, cr1_r, cr1_g, cr1_b;
    wire [7:0] cr2_r, cr2_g, cr2_b, cr3_r, cr3_g, cr3_b;

    Coral_Sprite #(.X0(34),  .SHAPE(3), .COLOR(1), .FLIP(0), .BOTTOM(468))   // tall pink tree
        CR0(pixel_x, pixel_y, cr0_op, cr0_r, cr0_g, cr0_b);
    Coral_Sprite #(.X0(199), .SHAPE(2), .COLOR(2), .FLIP(1), .BOTTOM(460))   // short orange bush
        CR1(pixel_x, pixel_y, cr1_op, cr1_r, cr1_g, cr1_b);
    Coral_Sprite #(.X0(379), .SHAPE(4), .COLOR(0), .FLIP(0), .BOTTOM(465))   // medium red, wide
        CR2(pixel_x, pixel_y, cr2_op, cr2_r, cr2_g, cr2_b);
    Coral_Sprite #(.X0(549), .SHAPE(0), .COLOR(3), .FLIP(1), .BOTTOM(471))   // purple branch
        CR3(pixel_x, pixel_y, cr3_op, cr3_r, cr3_g, cr3_b);

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
    // Title and controls text
    // ------------------------------------------------

    wire title_on, title_shadow;
    wire ctl1_on, ctl2_on, ctl3_on, ctl4_on;

    // Title: shadow first (2 pixels down-right), then the orange letters
    Text_Line #(.X0(178), .Y0(6), .SCALE(3), .LEN(16), .TEXT("Fin It To Win It"))
        TT1(pixel_x, pixel_y, title_shadow);
    Text_Line #(.X0(176), .Y0(4), .SCALE(3), .LEN(16), .TEXT("Fin It To Win It"))
        TT0(pixel_x, pixel_y, title_on);

    // The controls and points fade away 7 seconds into a round, and come back on the menu
    wire [4:0] ctl_alpha;     // 16 = fully shown ... 0 = gone
    Fade_Control FD0(CLOCK_50, playing, ctl_alpha);

    // mixes a color into what is already on the screen: a = 0..16
    function [7:0] blend;
        input [7:0] back;
        input [7:0] front;
        input [4:0] a;
        reg [12:0] mix;
        begin
            mix = back * (5'd16 - a) + front * a;
            blend = mix[11:4];      // divide by 16
        end
    endfunction

    // Controls on the far left, in the sky (small 1x text so they cover less of the game)
    Text_Line #(.X0(6), .Y0(36),  .SCALE(1), .LEN(17), .TEXT("KEY 1  BOAT RIGHT"))
        TC1(pixel_x, pixel_y, ctl1_on);
    Text_Line #(.X0(6), .Y0(47),  .SCALE(1), .LEN(16), .TEXT("KEY 2  BOAT LEFT"))
        TC2(pixel_x, pixel_y, ctl2_on);
    Text_Line #(.X0(6), .Y0(58),  .SCALE(1), .LEN(22), .TEXT("HOLD KEY 3  LOWER HOOK"))
        TC3(pixel_x, pixel_y, ctl3_on);
    Text_Line #(.X0(6), .Y0(69),  .SCALE(1), .LEN(25), .TEXT("RELEASE KEY 3  RAISE HOOK"))
        TC4(pixel_x, pixel_y, ctl4_on);

    // Points list on the far right, same style and fade as the controls.
    // The trash line only shows on the hard level.
    wire pts1_on, pts2_on, pts3_on, pts4_on, pts5_on, pts6_on;

    Text_Line #(.X0(538), .Y0(36), .SCALE(1), .LEN(16), .TEXT("SMALL FISH    15"))
        TP1(pixel_x, pixel_y, pts1_on);
    Text_Line #(.X0(538), .Y0(47), .SCALE(1), .LEN(16), .TEXT("MEDIUM FISH   30"))
        TP2(pixel_x, pixel_y, pts2_on);
    Text_Line #(.X0(538), .Y0(58), .SCALE(1), .LEN(16), .TEXT("LARGE FISH    50"))
        TP3(pixel_x, pixel_y, pts3_on);
    Text_Line #(.X0(538), .Y0(69), .SCALE(1), .LEN(16), .TEXT("CHEST        100"))
        TP4(pixel_x, pixel_y, pts4_on);
    Text_Line #(.X0(538), .Y0(80), .SCALE(1), .LEN(16), .TEXT("SHARK        -50"))
        TP5(pixel_x, pixel_y, pts5_on);
    Text_Line #(.X0(538), .Y0(91), .SCALE(1), .LEN(16), .TEXT("TRASH        -15"))
        TP6(pixel_x, pixel_y, pts6_on);

    // headings over the two lists (2x, same red, same fade)
    wire head_ctl_on, head_pts_on;
    Text_Line #(.X0(6),   .Y0(18), .SCALE(2), .LEN(8), .TEXT("CONTROLS"))
        TH1(pixel_x, pixel_y, head_ctl_on);
    Text_Line #(.X0(538), .Y0(18), .SCALE(2), .LEN(6), .TEXT("POINTS"))
        TH2(pixel_x, pixel_y, head_pts_on);

    wire side_text_on = head_ctl_on || head_pts_on ||
                        ctl1_on || ctl2_on || ctl3_on || ctl4_on ||
                        pts1_on || pts2_on || pts3_on || pts4_on || pts5_on ||
                        (pts6_on && hard_mode);

    // "+15" style pop-up just left of the score sign, fades out quickly
    wire popup_on, popup_sh, popup_bad;
    wire [4:0] popup_a;
    Score_Popup SP0(CLOCK_50, sys_rst_n, pop, pop_pts, eat_pop, pixel_x, pixel_y,
                    popup_on, popup_sh, popup_a, popup_bad);

    // Wooden banner behind the title (the score and timer signs hang from it)
    wire banner_on;
    wire [7:0] banner_r, banner_g, banner_b;
    Title_Banner TB0(pixel_x, pixel_y, banner_on, banner_r, banner_g, banner_b);

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

        // Coral (behind everything that moves)
        if (cr0_op) begin red = cr0_r; green = cr0_g; blue = cr0_b; end
        if (cr1_op) begin red = cr1_r; green = cr1_g; blue = cr1_b; end
        if (cr2_op) begin red = cr2_r; green = cr2_g; blue = cr2_b; end
        if (cr3_op) begin red = cr3_r; green = cr3_g; blue = cr3_b; end

        // Clouds (behind the text, the boat and the score board)
        if (cloud0_on || cloud1_on || cloud2_on || cloud3_on ||
            cloud4_on || cloud5_on || cloud6_on || cloud7_on) begin
            red = 8'd255; green = 8'd255; blue = 8'd255;
        end

        // Controls and points (red, fading out during play), banner and title (orange with a dark blue shadow)
        if (side_text_on && ctl_alpha != 5'd0) begin
            red   = blend(red,   8'd210, ctl_alpha);
            green = blend(green, 8'd25,  ctl_alpha);
            blue  = blend(blue,  8'd25,  ctl_alpha);
        end
        if (banner_on) begin red = banner_r; green = banner_g; blue = banner_b; end
        if (title_shadow) begin red = 8'd70; green = 8'd35; blue = 8'd20; end    // dark brown shadow
        if (title_on)     begin red = 8'd255; green = 8'd232; blue = 8'd170; end  // cream-gold, like the score sign

        if (boat_opaque) begin red = boat_red; green = boat_green; blue = boat_blue; end

        if (fish0_opaque) begin red = fish0_red; green = fish0_green; blue = fish0_blue; end
        if (fish1_opaque) begin red = fish1_red; green = fish1_green; blue = fish1_blue; end
        if (fish2_opaque) begin red = fish2_red; green = fish2_green; blue = fish2_blue; end
        if (fish3_opaque) begin red = fish3_red; green = fish3_green; blue = fish3_blue; end
        if (fish4_opaque) begin red = fish4_red; green = fish4_green; blue = fish4_blue; end
        if (fish5_opaque) begin red = fish5_red; green = fish5_green; blue = fish5_blue; end

        // Trash (hard level only)
        // Trash fades in when it comes back (always solid while on the hook)
        if (hard_mode && tr0_op) begin red = blend(red, tr0_r, t0_a); green = blend(green, tr0_g, t0_a); blue = blend(blue, tr0_b, t0_a); end
        if (hard_mode && tr1_op) begin red = blend(red, tr1_r, t1_a); green = blend(green, tr1_g, t1_a); blue = blend(blue, tr1_b, t1_a); end
        if (hard_mode && tr2_op) begin red = blend(red, tr2_r, t2_a); green = blend(green, tr2_g, t2_a); blue = blend(blue, tr2_b, t2_a); end
        if (hard_mode && tr3_op) begin red = blend(red, tr3_r, t3_a); green = blend(green, tr3_g, t3_a); blue = blend(blue, tr3_b, t3_a); end

        if (shark_opaque) begin red = shark_red; green = shark_green; blue = shark_blue; end
        // chest fades in when it comes back (always solid while on the hook)
        if (chest_opaque) begin red = blend(red, chest_red, ch_a); green = blend(green, chest_green, ch_a); blue = blend(blue, chest_blue, ch_a); end

        // Hook on top of the items so you can see what it is holding
        if (hook_opaque) begin red = hook_red; green = hook_green; blue = hook_blue; end

        // Score board on top of everything
        if (sb_opaque) begin red = sb_red; green = sb_green; blue = sb_blue; end

        // Timer sign (hangs from the score sign)
        if (timer_opaque) begin red = timer_r; green = timer_g; blue = timer_b; end

        // points pop-up (white or red, with a dark shadow, fading out)
        if (popup_sh) begin
            red   = blend(red,   8'd35,  popup_a);
            green = blend(green, 8'd60,  popup_a);
            blue  = blend(blue,  8'd90,  popup_a);
        end
        if (popup_on) begin
            // white for points gained, red for anything bad (lost points, EATEN)
            red   = blend(red,   8'd255,                      popup_a);
            green = blend(green, popup_bad ? 8'd60  : 8'd255, popup_a);
            blue  = blend(blue,  popup_bad ? 8'd50  : 8'd255, popup_a);
        end

        // Level menu (only before a level is chosen)
        if (!playing && menu_on) begin red = menu_r; green = menu_g; blue = menu_b; end

        // Time up panel with the TRY AGAIN button
        if (time_up && go_on) begin red = go_r; green = go_g; blue = go_b; end

    end

    // ------------------------------------------------
    // VGA outputs, registered
    // The driver changes the pixel position at the same moment VGA_CLK rises,
    // and the VGA chip reads the color on that same rising edge. With all the
    // drawing logic above, the color may still be changing then, which shows
    // up as static or a bad column. So:
    //   step 1: right before the position changes (VGA_CLK low), save the
    //           finished color and the sync/blank signals for that pixel.
    //   step 2: half a pixel later (VGA_CLK high), copy them to the outputs.
    // The VGA chip then reads values that have been steady for half a pixel.
    // Colors and sync/blank are delayed the same amount, so the picture
    // stays lined up.
    // ------------------------------------------------

    reg [7:0] r1, g1, b1, r2, g2, b2;
    reg hs1, vs1, bl1, hs2, vs2, bl2;

    always @(posedge CLOCK_50) begin
        if (!VGA_CLK) begin                  // the position changes at this edge
            r1 <= red;  g1 <= green;  b1 <= blue;
            hs1 <= hs_raw;  vs1 <= vs_raw;  bl1 <= blank_raw;
        end else begin                       // half a pixel later
            r2 <= r1;   g2 <= g1;     b2 <= b1;
            hs2 <= hs1;     vs2 <= vs1;     bl2 <= bl1;
        end
    end

    assign VGA_R = r2;
    assign VGA_G = g2;
    assign VGA_B = b2;
    assign VGA_HS = hs2;
    assign VGA_VS = vs2;
    assign VGA_BLANK_N = bl2;

endmodule