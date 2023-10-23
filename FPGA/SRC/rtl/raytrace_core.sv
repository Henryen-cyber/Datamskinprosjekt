`include "types.sv"
module RayTraceCore(

    input logic clk,

    input World_s world,
    input Pixel_s pixel,

    output logic less_than_zero

    );

    // Pixel square registers     All of these are much smaller due to Fixed
    //                            Point representation!
    logic [16:0]    pixelx_sr; // Max possible value:                102'400
    logic [15:0]    pixely_sr; // Max possible value:                 57'600
    logic  [9:0]    pixelz_sr; // Max possible value:                    961
    // Origin square registers
    logic [30:0]    originx_sr; // Max possible value:         1'073'741'824
    logic [26:0]    originy_sr; // Max possible value:            67'108'864
    logic [30:0]    originz_sr; // Max possible value:         1'073'741'824
    logic [17:0]    originr_sr; // Max possible value:               261'121
    // Dot-product registers
    logic signed[24:0] dotx_r;  // Max possible value:            10'485'440
    logic signed[21:0] doty_r;  // Max possible value:               982'800
    logic signed[20:0] dotz_r;  // Max possible value:             1'048'544
    // Quadratic formula registers
    logic       [17:0] a_r;     // Max possible value:               160'961
    logic signed[32:0] c_r;     // Max possible value:         2'214'592'511
    logic signed[25:0] b_r;     // Max possible value:            25'033'568
    logic       [49:0] br_sr;   // Max possible value:   626'679'526'810'624
    logic signed[51:0] arcr_r;  // Max possible value: 1'425'683'980'107'004
    logic signed[51:0] dis_r;   // Max possible value: 1'425'683'980'107'004

    always_ff @(posedge clk) begin
        pixelx_sr <= pixel.x ** 2;
        pixely_sr <= pixel.y ** 2;
        pixelz_sr <= pixel.z ** 2;
        a_r <= (pixelx_sr + pixely_sr + pixelz_sr);
        dotx_r <= pixel.x * world.sphere.origin.x;
        doty_r <= pixel.y * world.sphere.origin.y;
        dotz_r <= pixel.z * world.sphere.origin.z;
        b_r <= (dotx_r + doty_r + dotz_r) << 1;
        originx_sr <= world.sphere.origin.x ** 2;
        originy_sr <= world.sphere.origin.y ** 2;
        originz_sr <= world.sphere.origin.z ** 2;
        originr_sr <= world.sphere.radius ** 2;
        c_r <= (originx_sr + originy_sr + originz_sr) - originr_sr;
        arcr_r <= ((a_r * c_r) << 2);
        br_sr <= b_r ** 2;
        dis_r <= br_sr - arcr_r;
        if(dis_r < 0) begin
            less_than_zero <= 1'b1;
        end else begin
            less_than_zero <= 1'b0;
        end
    end
endmodule
