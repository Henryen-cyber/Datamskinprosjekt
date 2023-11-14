`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/24/2023 09:20:07 AM
// Design Name:
// Module Name: ray_worker
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "Types.sv"

module Raytracing_Worker(
    input clk,
    input activate,
    input signed[11:0] pixel_start_x,
    // input signed[11:0] pixel_y,
    input logic signed[`DOT_Y_B-1:0] doty_r,  // Max possible value:               982'800
    input logic signed [`PX_Y_B-1:0] pixel_y,
    input logic [`PX_Y_SQRD_B-1:0]    pixel_y_sqrd, // Max possible value:                 57'600
    input logic [`S_Y_SQRD_B-1:0]    sphere_y_sqrd, // Max possible value:            67'108'864
    
    input Types::Sphere sphere,
    output logic busy,
    output Types::Color [JOBS_SUBDIVISION-1:0] buffer
);
    logic [3:0] state;
    localparam [3:0] READY = 0;
    localparam [3:0] CALCULATING_1 = 1;
    localparam [3:0] CALCULATING_2 = 2;
    localparam [3:0] CALCULATING_3 = 3;
    localparam [3:0] CALCULATING_4 = 4;
    localparam [3:0] CALCULATING_5 = 5;
    localparam [3:0] CALCULATING_6 = 6;
    localparam [3:0] CALCULATING_7 = 7;
    localparam [3:0] CALCULATING_8 = 8;
    localparam [3:0] CALCULATING_9 = 9;
    localparam [3:0] CALCULATING_10 = 10;
    localparam [3:0] CALCULATING_11 = 11;
    localparam [3:0] COLORING = 12;
    localparam [3:0] FINISHED = 13;
    
    // Calculation registers
    logic[5:0] current_job;

    logic sqrt_start;
    logic sqrt_busy;
    logic [`DIS_SQRT_B-1:0] dis_sqrt_r;

    SquareRoot#(
        .A_INT_B(`DIS_B - `FP_B),
        .A_FP_B(`FP_B)
    ) square_root_instance (
        .clk(clk),
        .rst_(1),
        .A(dis_r),
        .start(sqrt_start),
        .busy(sqrt_busy),
        .Q(dis_sqrt_r)
    );


    logic div_start, div_busy, div_done, div_valid, dbz, div_ovf;
    logic signed[`PX_X_B-1:0] div_a, div_b, div_result;

    div division_instance (
        .clk(clk),
        .rst(rst_),
        .start(div_start),
        .busy(div_busy),
        .done(div_done),
        .valid(div_valid),
        .dbz(dbz),
        .ovf(div_ovf),
        .a(div_a),
        .b(div_b),
        .val(div_result)
    );

    logic        [`PX_X_B-1:0]        pixel_offset_x;
    logic signed [`PX_X_B-1:0]        pixel_x;
    localparam signed                 pixel_z = 320;
    localparam                        pixel_z_sqrd = pixel_z ** 2;


    // Pixel square registers     All of these are much smaller due to Fixed
    //                            Point representation!
    //                            Needs to be updated accordingly
    logic        [`PX_X_SQRD_B-1:0]   pixel_x_sqrd; // Max possible value:                102'400
    
    // Origin square registers
    logic        [`S_X_SQRD_B-1:0]    sphere_x_sqrd; // Max possible value:         1'073'741'824
    logic        [`S_Z_SQRD_B-1:0]    sphere_z_sqrd; // Max possible value:         1'073'741'824
    logic        [`S_R_SQRD_B-1:0]    sphere_r_sqrd; // Max possible value:               261'121
    
    // Dot-product registers
    logic signed [`DOT_X_B-1:0]       dotx_r;  // Max possible value:            10'485'440
    logic        [`DOT_Z_B-1:0]       dotz_r;  // Max possible value:             1'048'544
    
    // Quadratic formula registers
    logic        [`TWO_A_B-1:0]       a_times_two_r;     // Max possible value:               160'961
    logic signed [`TWO_C_B-1:0]       c_times_two_r;     // Max possible value:         2'214'592'511
    logic signed [`B_B-1:0] b_r;     // Max possible value:            25'033'568
    logic        [`B_SQRD_B-1:0]      br_sr;   // Max possible value:   626'679'526'810'624
    logic signed [`A_TIMES_C_B-1:0]   a_times_c_r;  // Max possible value: 1'425'683'980'107'004
    logic signed [`DIS_B-1:0]         dis_r;   // Max possible value: 1'425'683'980'107'004
    
    logic signed [`DIST_B-1:0]        dist_r;

    logic signed [`INTERSECT_X_B-1:0] intersect_x;
    logic signed [`INTERSECT_Y_B-1:0] intersect_y;
    logic signed [`INTERSECT_Z_B-1:0] intersect_z;



    // Raytracing Worker State-machine //
    always @ (posedge clk) begin
        if (state == READY && activate == HIGH) begin
            buffer[current_job] <= 0;
            pixel_x <= `PX_X_B'(pixel_start_x) + `PX_X_B'(pixel_offset_x);
            busy <= (state == READY) ? HIGH : LOW;
            state <= (state == READY) ? state + 1: state;
            sqrt_start <= LOW;
        end
        else if (state == CALCULATING_1 && busy == HIGH) begin
            pixel_x_sqrd <= pixel_x ** 2;
            sphere_r_sqrd <= (`S_R_SQRD_B'b1 << sphere.r) ** 2;
            state <= (state == CALCULATING_1) ? state + 1: state;
        end
        else if (state == CALCULATING_2 && busy == HIGH) begin

            a_times_two_r <= (pixel_x_sqrd + pixel_y_sqrd + pixel_z_sqrd) << 1;

            dotx_r <= `DOT_X_B'(`DOT_X_B'(pixel_x) * `DOT_X_B'(sphere.x));
            dotz_r <= `DOT_Z_B'(`DOT_Z_B'(pixel_z) * `DOT_Z_B'(sphere.z));

            state <= (state == CALCULATING_2) ? state + 1: state;
        end
        else if (state == CALCULATING_3 && busy == HIGH) begin
            b_r <= (`B_B'(dotx_r) + `B_B'(doty_r) + `B_B'(dotz_r)) <<< 1;
            sphere_x_sqrd <= (sphere.x ** 2) >>> `FP_B;
            // sphere_y_sqrd <= sphere.y ** 2;
            sphere_z_sqrd <= (sphere.z ** 2) >>> `FP_B;

            state <= (state == CALCULATING_3) ? state + 1: state;
        end
        else if (state == CALCULATING_4 && busy == HIGH) begin
            c_times_two_r <= (`TWO_C_B'(sphere_x_sqrd + sphere_y_sqrd + sphere_z_sqrd) - (`TWO_C_B'(sphere_r_sqrd) << `FP_B)) <<< 1;
            br_sr <= (b_r ** 2) >> `FP_B;
            state <= (state == CALCULATING_4) ? state + 1: state;
        end
        else if (state == CALCULATING_5 && busy == HIGH) begin
            a_times_c_r <= `A_TIMES_C_B'(a_times_two_r) * `A_TIMES_C_B'(c_times_two_r);
            state <= (state == CALCULATING_5) ? state + 1: state;
        end
        else if (state == CALCULATING_6 && busy == HIGH && sqrt_busy == LOW) begin 
            dis_r <= (`DIS_B'(br_sr) - `DIS_B'(a_times_c_r));
            sqrt_start <= HIGH;
        end
        else if (state == CALCULATING_6 && busy == HIGH && sqrt_start == HIGH && sqrt_busy == HIGH) begin
            sqrt_start <= LOW;
            state <= (state == CALCULATING_6) ? state + 1: state;
        end
        else if (state == CALCULATING_7 && busy == HIGH && sqrt_busy == LOW) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
            dist_r <= (((b_r - dis_sqrt_r) <<< `FP_B ) / (a_times_two_r));

            state <= (state == CALCULATING_7) ? state + 1: state;
        end
        else if (state == CALCULATING_8 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
            intersect_x <= (`INTERSECT_X_B'(pixel_x) * `INTERSECT_X_B'(dist_r));
            intersect_y <= (`INTERSECT_Y_B'(pixel_y) * `INTERSECT_Y_B'(dist_r));
            intersect_z <= (`INTERSECT_Z_B'(pixel_z) * `INTERSECT_Z_B'(dist_r));
            state <= (state == CALCULATING_8) ? state + 1: state;
        end
        else if (state == CALCULATING_9 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
            intersect_x <= (intersect_x - (`INTERSECT_X_B'(sphere.x) <<< `FP_B));
            intersect_y <= (intersect_y - (`INTERSECT_Y_B'(sphere.y) <<< `FP_B));
            intersect_z <= (intersect_z - (`INTERSECT_Z_B'(sphere.z) <<< `FP_B));
            state <= (state == CALCULATING_9) ? state + 1: state;
        end
        else if (state == CALCULATING_10 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
            intersect_x <= intersect_x >>> (sphere.r);
            intersect_y <= intersect_y >>> (sphere.r);
            intersect_z <= intersect_z >>> (sphere.r);
            state <= (state == CALCULATING_10) ? state + 1: state;
        end
        else if (state == CALCULATING_11 && busy == HIGH) begin //&& sqrt_busy == HIGH) begin && sqrt_busy == LOW) begin
            intersect_x <= (((intersect_x * 7) + (7 <<< (2 * `FP_B))) >>> (2 * `FP_B));
            intersect_y <= (((intersect_y * 7) + (7 <<< (2 * `FP_B))) >>> (2 * `FP_B));
            intersect_z <= (((intersect_z * 7) + (7 <<< (2 * `FP_B))) >>> (2 * `FP_B));
            state <= (state == CALCULATING_11) ? state + 1: state;
        end
        else if (state == COLORING && busy == HIGH) begin
            buffer[current_job] <= (dis_r >= 0) ? {intersect_x[3:0], intersect_y[3:0], intersect_z[3:0]} : `BACKGROUND_COLOR;
            // dis_r <= (dis_r == 0) ? -1 : (dis_r > 0) ? dis_r >> 1 : -1;
            state <= (state == COLORING) ? state + 1: state;
        end
        else if (state == FINISHED && busy == HIGH) begin
            current_job <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? 0 : current_job + 1;
            pixel_offset_x <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? 0 : pixel_offset_x + N_WORKERS;
            busy <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? LOW : HIGH;
            state <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? FINISHED : READY;
        end
        else if (activate == LOW) begin
            state <= READY;
            busy <= LOW;
            current_job <= 0;
            pixel_offset_x <= 0;
            sqrt_start <= LOW;
        end
    end
endmodule
