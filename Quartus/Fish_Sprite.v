module Fish_Sprite(
    input [10:0] pixel_x,
    input [9:0] pixel_y,
    input [10:0] fish_x,
    input [9:0] fish_y,
    input [2:0] fish_type,
    output reg opaque,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue
);

    reg [2:0] sprite_scale;
    reg [10:0] fish_width;
    reg [9:0] fish_height;

    reg [4:0] sprite_col;
    reg [3:0] sprite_row;
    reg [63:0] row_data;
    reg [3:0] pixel_code;

    always @(*) begin

			// Choose fish size for the 640x480 VGA screen
			if (fish_type <= 1) begin
				 sprite_scale = 2;
				 fish_width = 32;
				 fish_height = 16;
			end
			else if (fish_type <= 3) begin
				 sprite_scale = 3;
				 fish_width = 48;
				 fish_height = 24;
			end
			else begin
				 sprite_scale = 4;
				 fish_width = 64;
				 fish_height = 32;
			end
			
        opaque = 0;
        red = 0;
        green = 0;
        blue = 0;

        sprite_col = 0;
        sprite_row = 0;
        row_data = 0;
        pixel_code = 0;

        if ((pixel_x >= fish_x) &&
            (pixel_x < fish_x + fish_width) &&
            (pixel_y >= fish_y) &&
            (pixel_y < fish_y + fish_height)) begin

            sprite_col = (pixel_x - fish_x) / sprite_scale;
            sprite_row = (pixel_y - fish_y) / sprite_scale;

            case(sprite_row)
                0: row_data = 64'h0000001111000000;
                1: row_data = 64'h0010112222110000;
                2: row_data = 64'h0111222222221100;
                3: row_data = 64'h1122222222223221;
                4: row_data = 64'h1122222222222221;
                5: row_data = 64'h0111222222221100;
                6: row_data = 64'h0010112222110000;
                7: row_data = 64'h0000001111000000;
                default: row_data = 0;
            endcase

            pixel_code = row_data[(15 - sprite_col) * 4 +: 4];

            if (pixel_code != 0) begin
                opaque = 1;

                if (pixel_code == 3) begin
                    red = 0;
                    green = 0;
                    blue = 0;
                end

                else if (pixel_code == 1) begin
                    case(fish_type)
                        0: begin red=30; green=30; blue=60; end
                        1: begin red=70; green=70; blue=30; end
                        2: begin red=120; green=90; blue=0; end
                        3: begin red=80; green=10; blue=10; end
                        4: begin red=120; green=60; blue=0; end
                        5: begin red=50; green=20; blue=70; end
                        default: begin red=30; green=30; blue=60; end
                    endcase
                end

                else begin
                    case(fish_type)
                        0: begin red=140; green=150; blue=170; end
                        1: begin red=200; green=195; blue=120; end
                        2: begin red=250; green=220; blue=60; end
                        3: begin red=230; green=70; blue=60; end
                        4: begin red=240; green=150; blue=60; end
                        5: begin red=130; green=70; blue=160; end
                        default: begin red=140; green=150; blue=170; end
                    endcase
                end
            end
        end
    end

endmodule

