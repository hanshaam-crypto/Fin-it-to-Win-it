


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
    wire [7:0] boat_red;
    wire [7:0] boat_green;
    wire [7:0] boat_blue;

    // Hook signals
    wire [10:0] hook_x;
    wire [9:0] hook_y;
    wire hook_opaque;
    wire [7:0] hook_red;
    wire [7:0] hook_green;
    wire [7:0] hook_blue;

    // Fish horizontal positions
    wire [10:0] fish0_x;
    wire [10:0] fish1_x;
    wire [10:0] fish2_x;
    wire [10:0] fish3_x;
    wire [10:0] fish4_x;
    wire [10:0] fish5_x;

    // Fish directions
    wire fish0_direction;
    wire fish1_direction;
    wire fish2_direction;
    wire fish3_direction;
    wire fish4_direction;
    wire fish5_direction;

    // Fish display signals
    wire fish0_opaque;
    wire fish1_opaque;
    wire fish2_opaque;
    wire fish3_opaque;
    wire fish4_opaque;
    wire fish5_opaque;

    wire [7:0] fish0_red, fish0_green, fish0_blue;
    wire [7:0] fish1_red, fish1_green, fish1_blue;
    wire [7:0] fish2_red, fish2_green, fish2_blue;
    wire [7:0] fish3_red, fish3_green, fish3_blue;
    wire [7:0] fish4_red, fish4_green, fish4_blue;
    wire [7:0] fish5_red, fish5_green, fish5_blue;

    // Chest signals
    wire chest_opaque;
    wire [7:0] chest_red;
    wire [7:0] chest_green;
    wire [7:0] chest_blue;

    // ------------------------------------------------
    // VGA Controller
    // ------------------------------------------------

    VGA_Controller VC0(
        CLOCK_50,
        KEY[0],
        VGA_CLK,
        VGA_HS,
        VGA_VS,
        VGA_BLANK_N,
        VGA_SYNC_N,
        pixel_x,
        pixel_y
    );

    // ------------------------------------------------
    // Boat Control
    // ------------------------------------------------

    // KEY[1] moves left and KEY[2] moves right.
    // Buttons are active-low.
    Boat_Control BC0(
        CLOCK_50,
        KEY[0],
        ~KEY[2],
        ~KEY[1],
        boat_x,
        boat_direction
    );

    Boat_Sprite BS0(
        pixel_x,
        pixel_y,
        boat_x,
        boat_direction,
        boat_opaque,
        boat_red,
        boat_green,
        boat_blue
    );

    // ------------------------------------------------
    // Hook Control
    // ------------------------------------------------

    assign hook_x = boat_x;

    Hook_Control HC0(
        CLOCK_50,
        KEY[0],
        ~KEY[3],
        hook_y
    );

    Hook_Sprite HS0(
        pixel_x,
        pixel_y,
        hook_x,
        hook_y,
        hook_opaque,
        hook_red,
        hook_green,
        hook_blue
    );

    // ------------------------------------------------
    // Fish Movement Controllers
    // ------------------------------------------------

    // Small fish: speed 2
    Fish_Control FC0(
        CLOCK_50, KEY[0], 32, 2, 16'hACE1,
        fish0_x, fish0_direction
    );

    Fish_Control FC1(
        CLOCK_50, KEY[0], 32, 2, 16'hBEEF,
        fish1_x, fish1_direction
    );

    // Medium fish: speed 3
    Fish_Control FC2(
        CLOCK_50, KEY[0], 48, 3, 16'h1234,
        fish2_x, fish2_direction
    );

    Fish_Control FC3(
        CLOCK_50, KEY[0], 48, 3, 16'h5678,
        fish3_x, fish3_direction
    );

    // Large fish: speed 4
    Fish_Control FC4(
        CLOCK_50, KEY[0], 64, 4, 16'h9ABC,
        fish4_x, fish4_direction
    );

    Fish_Control FC5(
        CLOCK_50, KEY[0], 64, 4, 16'hDEF0,
        fish5_x, fish5_direction
    );

    // ------------------------------------------------
    // Fish Sprites
    // ------------------------------------------------

    Fish_Sprite FS0(
        pixel_x, pixel_y, fish0_x, 250, 0, fish0_direction,
        fish0_opaque, fish0_red, fish0_green, fish0_blue
    );

    Fish_Sprite FS1(
        pixel_x, pixel_y, fish1_x, 265, 1, fish1_direction,
        fish1_opaque, fish1_red, fish1_green, fish1_blue
    );

    Fish_Sprite FS2(
        pixel_x, pixel_y, fish2_x, 310, 2, fish2_direction,
        fish2_opaque, fish2_red, fish2_green, fish2_blue
    );

    Fish_Sprite FS3(
        pixel_x, pixel_y, fish3_x, 335, 3, fish3_direction,
        fish3_opaque, fish3_red, fish3_green, fish3_blue
    );

    Fish_Sprite FS4(
        pixel_x, pixel_y, fish4_x, 390, 4, fish4_direction,
        fish4_opaque, fish4_red, fish4_green, fish4_blue
    );

    Fish_Sprite FS5(
        pixel_x, pixel_y, fish5_x, 405, 5, fish5_direction,
        fish5_opaque, fish5_red, fish5_green, fish5_blue
    );

    // ------------------------------------------------
    // Chest Sprite
    // ------------------------------------------------

    Chest_Sprite CS0(
        pixel_x,
        pixel_y,
        430,
        438,
        chest_opaque,
        chest_red,
        chest_green,
        chest_blue
    );

    // ------------------------------------------------
    // Background and Sprite Drawing
    // ------------------------------------------------

    always @(*) begin

        // Sky
        if (pixel_y < 202) begin
            red = 190;
            green = 230;
            blue = 255;
        end

        // Ocean
        else if (pixel_y < 456) begin
            red = 120;
            green = 195;
            blue = 235;
        end

        // Sand
        else begin
            red = 194;
            green = 178;
            blue = 128;
        end

        // Draw boat
        if (boat_opaque) begin
            red = boat_red;
            green = boat_green;
            blue = boat_blue;
        end

        // Draw hook
        if (hook_opaque) begin
            red = hook_red;
            green = hook_green;
            blue = hook_blue;
        end

        // Draw fish 0
        if (fish0_opaque) begin
            red = fish0_red;
            green = fish0_green;
            blue = fish0_blue;
        end

        // Draw fish 1
        if (fish1_opaque) begin
            red = fish1_red;
            green = fish1_green;
            blue = fish1_blue;
        end

        // Draw fish 2
        if (fish2_opaque) begin
            red = fish2_red;
            green = fish2_green;
            blue = fish2_blue;
        end

        // Draw fish 3
        if (fish3_opaque) begin
            red = fish3_red;
            green = fish3_green;
            blue = fish3_blue;
        end

        // Draw fish 4
        if (fish4_opaque) begin
            red = fish4_red;
            green = fish4_green;
            blue = fish4_blue;
        end

        // Draw fish 5
        if (fish5_opaque) begin
            red = fish5_red;
            green = fish5_green;
            blue = fish5_blue;
        end

        // Draw chest last
        if (chest_opaque) begin
            red = chest_red;
            green = chest_green;
            blue = chest_blue;
        end

    end

    // ------------------------------------------------
    // VGA Color Outputs
    // ------------------------------------------------

    assign VGA_R = red;
    assign VGA_G = green;
    assign VGA_B = blue;

endmodule
