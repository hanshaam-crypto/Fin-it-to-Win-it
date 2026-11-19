module Chest_Sprite(
    input [10:0] pixel_x,
    input [9:0] pixel_y,
    input [10:0] chest_x,
    input [9:0] chest_y,

    output reg opaque,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue
);

    reg [4:0] sprite_col;
    reg [3:0] sprite_row;

    always @(*) begin
        opaque = 0;
        red = 0;
        green = 0;
        blue = 0;
        sprite_col = 0;
        sprite_row = 0;

        if ((pixel_x >= chest_x) &&
            (pixel_x < chest_x + 48) &&
            (pixel_y >= chest_y) &&
            (pixel_y < chest_y + 36)) begin

            sprite_col = (pixel_x - chest_x) / 3;
            sprite_row = (pixel_y - chest_y) / 3;

            // Chest body.
            opaque = 1;

            // Dark brown outer border.
            if ((sprite_col == 0) || (sprite_col == 15) ||
                (sprite_row == 0) || (sprite_row == 11)) begin
                red = 80;
                green = 50;
                blue = 30;
            end

            // Gold latch.
            else if ((sprite_col == 7 || sprite_col == 8) &&
                     (sprite_row >= 3 && sprite_row <= 7)) begin
                red = 240;
                green = 200;
                blue = 60;
            end

            // Wooden chest.
            else begin
                red = 130;
                green = 85;
                blue = 50;
            end
        end
    end

endmodule
