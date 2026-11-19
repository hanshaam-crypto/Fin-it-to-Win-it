module VGA_Controller(
    input CLOCK_50,
    input reset_n,

    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,

    output VGA_CLK,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,

    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,

    output reg [10:0] pixel_x,
    output reg [9:0] pixel_y
);

    reg pixel_clk;

    // Divide the 50 MHz clock by 2
    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n)
            pixel_clk <= 0;
        else
            pixel_clk <= ~pixel_clk;
    end

    assign VGA_CLK = pixel_clk;

    // Horizontal and vertical pixel counters
    always @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            pixel_x <= 0;
            pixel_y <= 0;
        end
        else begin
            if (pixel_x == 799) begin
                pixel_x <= 0;

                if (pixel_y == 524)
                    pixel_y <= 0;
                else
                    pixel_y <= pixel_y + 1;
            end
            else
                pixel_x <= pixel_x + 1;
        end
    end

    // Generate synchronization signals
    assign VGA_HS = ~((pixel_x >= 656) && (pixel_x < 752));
    assign VGA_VS = ~((pixel_y >= 490) && (pixel_y < 492));

    // Determine whether the current pixel is visible
    wire visible;

    assign visible = (pixel_x < 640) && (pixel_y < 480);

    assign VGA_BLANK_N = visible;
    assign VGA_SYNC_N = 1'b0;

    // Send RGB values to the VGA output
    assign VGA_R = visible ? red : 8'd0;
    assign VGA_G = visible ? green : 8'd0;
    assign VGA_B = visible ? blue : 8'd0;

endmodule
