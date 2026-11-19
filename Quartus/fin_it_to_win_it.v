
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

    wire [10:0] pixel_x;
    wire [9:0] pixel_y;

    wire [10:0] boat_x;
    wire [10:0] hook_x;
    wire [9:0] hook_y;

    wire boat_opaque;
    wire hook_opaque;
    wire chest_opaque;

    wire [7:0] boat_red, boat_green, boat_blue;
    wire [7:0] hook_red, hook_green, hook_blue;
    wire [7:0] chest_red, chest_green, chest_blue;

    wire [7:0] fish_red [0:5];
    wire [7:0] fish_green [0:5];
    wire [7:0] fish_blue [0:5];
    wire [5:0] fish_opaque;

    wire [7:0] bg_red, bg_green, bg_blue;
    wire [7:0] red, green, blue;

    // Background.

    assign bg_red = (pixel_y < 202) ? 8'd190 :
                    (pixel_y < 456) ? 8'd120 : 8'd194;

    assign bg_green = (pixel_y < 202) ? 8'd230 :
                      (pixel_y < 456) ? 8'd195 : 8'd178;

    assign bg_blue = (pixel_y < 202) ? 8'd255 :
                     (pixel_y < 456) ? 8'd235 : 8'd128;

    // Boat movement.

    Boat_Control BC0(
        CLOCK_50, KEY[0], ~KEY[1], ~KEY[2], boat_x
    );

    // Hook movement.

    Hook_Control HC0(
        CLOCK_50, KEY[0], ~KEY[3], hook_y
    );

    assign hook_x = boat_x + 0;

    // Boat sprite.

    Boat_Sprite BS0(
        pixel_x, pixel_y, boat_x,
        boat_opaque, boat_red, boat_green, boat_blue
    );

    // Hook sprite.

    Hook_Sprite HS0(
        pixel_x, pixel_y, hook_x, hook_y,
        hook_opaque, hook_red, hook_green, hook_blue
    );

    // Fish 1: Gray.

    Fish_Sprite F0(
        pixel_x, pixel_y, 11'd45, 10'd275, 3'd0,
        fish_opaque[0], fish_red[0], fish_green[0], fish_blue[0]
    );

    // Fish 2: Gray/yellow.

    Fish_Sprite F1(
        pixel_x, pixel_y, 11'd145, 10'd350, 3'd1,
        fish_opaque[1], fish_red[1], fish_green[1], fish_blue[1]
    );

    // Fish 3: Yellow.

    Fish_Sprite F2(
        pixel_x, pixel_y, 11'd245, 10'd260, 3'd2,
        fish_opaque[2], fish_red[2], fish_green[2], fish_blue[2]
    );

    // Fish 4: Red.

    Fish_Sprite F3(
        pixel_x, pixel_y, 11'd350, 10'd330, 3'd3,
        fish_opaque[3], fish_red[3], fish_green[3], fish_blue[3]
    );

    // Fish 5: Orange.

    Fish_Sprite F4(
        pixel_x, pixel_y, 11'd455, 10'd275, 3'd4,
        fish_opaque[4], fish_red[4], fish_green[4], fish_blue[4]
    );

    // Fish 6: Purple.

    Fish_Sprite F5(
        pixel_x, pixel_y, 11'd550, 10'd370, 3'd5,
        fish_opaque[5], fish_red[5], fish_green[5], fish_blue[5]
    );

    // Treasure chest.
    // Y = 420 makes its bottom line up with the sand at 456.

    Chest_Sprite CS0(
        pixel_x, pixel_y,
        11'd430, 10'd438,
        chest_opaque, chest_red, chest_green, chest_blue
    );

    // Display priority:
    // Boat, hook, fish, chest, background.

    assign red = boat_opaque ? boat_red :
                 hook_opaque ? hook_red :
                 fish_opaque[0] ? fish_red[0] :
                 fish_opaque[1] ? fish_red[1] :
                 fish_opaque[2] ? fish_red[2] :
                 fish_opaque[3] ? fish_red[3] :
                 fish_opaque[4] ? fish_red[4] :
                 fish_opaque[5] ? fish_red[5] :
                 chest_opaque ? chest_red : bg_red;

    assign green = boat_opaque ? boat_green :
                   hook_opaque ? hook_green :
                   fish_opaque[0] ? fish_green[0] :
                   fish_opaque[1] ? fish_green[1] :
                   fish_opaque[2] ? fish_green[2] :
                   fish_opaque[3] ? fish_green[3] :
                   fish_opaque[4] ? fish_green[4] :
                   fish_opaque[5] ? fish_green[5] :
                   chest_opaque ? chest_green : bg_green;

    assign blue = boat_opaque ? boat_blue :
                  hook_opaque ? hook_blue :
                  fish_opaque[0] ? fish_blue[0] :
                  fish_opaque[1] ? fish_blue[1] :
                  fish_opaque[2] ? fish_blue[2] :
                  fish_opaque[3] ? fish_blue[3] :
                  fish_opaque[4] ? fish_blue[4] :
                  fish_opaque[5] ? fish_blue[5] :
                  chest_opaque ? chest_blue : bg_blue;

    // VGA controller.

    VGA_Controller VGA0(
        .CLOCK_50(CLOCK_50),
        .reset_n(KEY[0]),
        .red(red),
        .green(green),
        .blue(blue),
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

endmodule

