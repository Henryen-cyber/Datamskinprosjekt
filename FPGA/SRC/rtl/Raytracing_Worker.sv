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
    input                                   clk,
    input                                   activate,
    input  logic signed [11:0]              pixel_start_x,
    input  logic signed [`PX_Y_B-1:0]       pixel_y,
    input  logic        [`PX_Y_SQRD_B-1:0]  pixel_y_sqrd,
    output logic                            busy,

    input                                   World world,
    input logic [1:0]                       num_spheres,

    output Color [JOBS_SUBDIVISION-1:0]     buffer
);
    logic rst_;
    assign rst_ = HIGH;
    // Closest sphere logic
    logic [1:0]         index;
    logic               next_sphere;
    logic [1:0]         closest_index;
    logic [`DIST_B-1:0] closest_dist;
    logic [1:0]         num_misses;

    logic [4:0] state, next_state;
    localparam [4:0] READY = 0;
    localparam [4:0] CALCULATING_1 = 1;
    localparam [4:0] CALCULATING_2 = 2;
    localparam [4:0] CALCULATING_3 = 3;
    localparam [4:0] CALCULATING_4 = 4;
    localparam [4:0] CALCULATING_5 = 5;
    localparam [4:0] CALCULATING_6 = 6;
    localparam [4:0] CALCULATING_7 = 7;
    localparam [4:0] CALCULATING_8 = 8;
    localparam [4:0] CALCULATING_9 = 9;
    localparam [4:0] CALCULATING_10 = 10;
    localparam [4:0] CALCULATING_11 = 11;
    localparam [4:0] CALCULATING_12 = 12;
    localparam [4:0] CALCULATING_13 = 13;
    localparam [4:0] COLORING_1 = 14;
    localparam [4:0] COLORING_2 = 15;
    localparam [4:0] FINISHED = 16;
    localparam [4:0] IDLE = 17;

    localparam JOBS = 640;
    localparam JOBS_SUBDIVISION = 64; // Must be divisible with JOBS
    localparam N_WORKERS = JOBS / JOBS_SUBDIVISION;
    localparam HIGH = 1'b1;
    localparam LOW = 1'b0;

    // Calculation registers
    logic[5:0] current_job;

    logic [`S_X_INT_B + `FP_B - 1:0] sphere_x;
    logic [`S_Y_INT_B + `FP_B - 1:0] sphere_y;
    logic [`S_Z_INT_B + `FP_B - 1:0] sphere_z;
    logic [5:0]                      sphere_r;

    logic [`S_X_SQRD_B-1:0] spherex_sr;
    logic [`S_Y_SQRD_B-1:0] spherey_sr;
    logic [`S_Z_SQRD_B-1:0] spherez_sr;
    logic [`S_R_SQRD_B-1:0] spherer_sr;

    logic sqrt_start;
    logic sqrt_busy;
    logic [`DIS_SQRT_B-1:0] dis_sqrt_r;

    logic        [`PX_X_B-1:0]          pixel_offset_x;
    logic signed [`PX_X_B-1:0]          pixel_x;
    localparam signed                   pixel_z = 320;
    localparam                          pixel_z_sqrd = pixel_z ** 2;

    // Pixel square registers
    logic        [`PX_X_SQRD_B-1:0]     pixel_x_sqrd;   // Max possible value:                102'400

    // Dot-product registers
    logic signed [`DOT_X_B-1:0]         dotx_r;         // Max possible value:            10'485'440
    logic signed [`DOT_Y_B-1:0]         doty_r;         // Max possible value:             1'048'544
    logic        [`DOT_Z_B-1:0]         dotz_r;         // Max possible value:             1'048'544

    // Quadratic formula registers
    logic        [`TWO_A_B-1:0]         a_times_two_r;  // Max possible value:               160'961
    logic signed [`TWO_C_B-1:0]         c_times_two_r;  // Max possible value:         2'214'592'511
    logic signed [`B_B-1:0]             b_r;            // Max possible value:            25'033'568
    logic        [`B_SQRD_B-1:0]        br_sr;          // Max possible value:   626'679'526'810'624
    logic signed [`A_TIMES_C_B-1:0]     a_times_c_r;    // Max possible value: 1'425'683'980'107'004
    logic signed [`DIS_B-1:0]           dis_r;          // Max possible value: 1'425'683'980'107'004

    logic        [`DIST_B-1:0]          dist_r;

    logic        [`INTERSECT_X_B-1:0]   intersect_x;
    logic        [`INTERSECT_Y_B-1:0]   intersect_y;
    logic        [`INTERSECT_Z_B-1:0]   intersect_z;

    logic        [3:0]                  norm_x;
    logic        [3:0]                  norm_y;
    logic        [3:0]                  norm_z;

    SquareRoot#(
        .A_INT_B(`DIS_B - `FP_B),
        .A_FP_B(`FP_B)
    ) square_root_instance (
        .clk(clk),
        .rst_(1'b1),
        .A(dis_r),
        .start(sqrt_start),
        .busy(sqrt_busy),
        .Q(dis_sqrt_r)
    );

    // Raytracing Worker State-machine //
    always_ff @(posedge clk) begin

        case(state)

            READY : begin
                index               <= 2'b00;
                next_sphere         <= 0;
                closest_dist        <= 0;
                closest_index       <= 0;
                num_misses          <= 2'b00;
                current_job         <= current_job;
                sphere_x            <= 0;
                sphere_y            <= 0;
                sphere_z            <= 0;
                sphere_r            <= 0;
                spherex_sr          <= 0;
                spherey_sr          <= 0;
                spherez_sr          <= 0;
                spherer_sr          <= 0;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= `PX_X_B'(pixel_start_x) + `PX_X_B'(pixel_offset_x);
                pixel_x_sqrd        <= 0;
                dotx_r              <= 0;
                doty_r              <= 0;
                dotz_r              <= 0;
                a_times_two_r       <= 0;
                c_times_two_r       <= 0;
                b_r                 <= 0;
                br_sr               <= 0;
                a_times_c_r         <= 0;
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= (state == READY) ? HIGH : LOW;
                next_state          <= (state == READY) ? state + 1 : state;
            end

            CALCULATING_1 : begin
                if(next_sphere) begin
                    index           <= index + 1;
                    next_sphere     <= 0;
                end else begin
                    index           <= index;
                    next_sphere     <= next_sphere;
                end
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= index;
                current_job         <= current_job;
                sphere_x            <= world.spheres[index].x;
                sphere_y            <= world.spheres[index].y;
                sphere_z            <= world.spheres[index].z;
                sphere_r            <= world.spheres[index].r;
                spherex_sr          <= world.spheres[index].spherex_sr;
                spherey_sr          <= world.spheres[index].spherey_sr;
                spherez_sr          <= world.spheres[index].spherez_sr;
                spherer_sr          <= world.spheres[index].spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= `PX_X_B'(pixel_start_x) + `PX_X_B'(pixel_offset_x);
                pixel_x_sqrd        <= pixel_x ** 2;
                dotx_r              <= 0;
                doty_r              <= 0;
                dotz_r              <= 0;
                a_times_two_r       <= 0;
                c_times_two_r       <= 0;
                b_r                 <= 0;
                br_sr               <= 0;
                a_times_c_r         <= 0;
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_1) ? state + 1: state;
            end

            CALCULATING_2 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= `PX_X_B'(pixel_start_x) + `PX_X_B'(pixel_offset_x);
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= `DOT_X_B'(`DOT_X_B'(pixel_x) * `DOT_X_B'(sphere_x));
                doty_r              <= `DOT_Y_B'(`DOT_Z_B'(pixel_y) * `DOT_Y_B'(sphere_y));
                dotz_r              <= `DOT_Z_B'(`DOT_Z_B'(pixel_z) * `DOT_Z_B'(sphere_z));
                a_times_two_r       <= (pixel_x_sqrd + pixel_y_sqrd + pixel_z_sqrd) <<< 1;
                c_times_two_r       <= 0;
                b_r                 <= 0;
                br_sr               <= 0;
                a_times_c_r         <= 0;
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_2) ? state + 1: state;
            end

            CALCULATING_3 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= 0;
                b_r                 <= (`B_B'(dotx_r) + `B_B'(doty_r) + `B_B'(dotz_r)) <<< 1;
                br_sr               <= 0;
                a_times_c_r         <= 0;
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_3) ? state + 1: state;
            end

            CALCULATING_4 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= (`TWO_C_B'(spherex_sr + spherey_sr + spherez_sr) - (`TWO_C_B'(spherer_sr) << `FP_B)) <<< 1;
                b_r                 <= b_r;
                br_sr               <= (b_r ** 2) >>> `FP_B;
                a_times_c_r         <= 0;
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_4) ? state + 1: state;
            end

            CALCULATING_5 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= `A_TIMES_C_B'(a_times_two_r) * `A_TIMES_C_B'(c_times_two_r);
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_5) ? state + 1: state;
            end

            CALCULATING_6 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= (`DIS_B'(br_sr) - `DIS_B'(a_times_c_r));
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_6) ? state + 1 : state;
            end

            CALCULATING_7 : begin
                index               <= index;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                if(dis_r < 0) begin
                    num_misses      <= num_misses + 1;
                    if(index == num_spheres - 1) begin
                        next_state  <= COLORING_2;
                    end else begin
                        next_sphere <= HIGH;
                        next_state  <= CALCULATING_1;
                    end
                end else begin
                    if(sqrt_start == HIGH) begin
                        sqrt_start  <= LOW;
                        if(sqrt_busy == LOW) begin
                            next_state  <= (state == CALCULATING_7) ? state + 1 : state;
                        end else begin
                            next_state  <= CALCULATING_7;
                        end
                    end else begin
                        sqrt_start  <= HIGH;
                        next_state  <= CALCULATING_7;
                    end
                end
            end

            CALCULATING_8 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= (((b_r - dis_sqrt_r) <<< `FP_B ) / (a_times_two_r));
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_8) ? state + 1: state;
            end

            CALCULATING_9 : begin
                if(closest_dist == 0) begin
                    next_sphere     <= (index == num_spheres - 1) ? LOW : HIGH;
                    closest_dist    <= dist_r;
                    closest_index   <= index;
                end else if(dist_r < closest_dist) begin
                    next_sphere     <= (index == num_spheres - 1) ? LOW : HIGH;
                    closest_dist    <= dist_r;
                    closest_index   <= index;
                end else begin
                    next_sphere     <= (index == num_spheres - 1) ? LOW : HIGH;
                    closest_dist    <= closest_dist;
                    closest_index   <= closest_index;
                end
                index               <= index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_x;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= (((b_r - dis_sqrt_r) <<< `FP_B ) / (a_times_two_r));
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                if(index == num_spheres - 1) begin
                    next_state      <= (state == CALCULATING_9) ? state + 1: state;
                end else begin
                    next_state      <= CALCULATING_1;
                end
            end

            CALCULATING_10 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= world.spheres[closest_index].x;
                sphere_y            <= world.spheres[closest_index].y;
                sphere_z            <= world.spheres[closest_index].z;
                sphere_r            <= world.spheres[closest_index].r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= (`INTERSECT_X_B'(pixel_x) * `INTERSECT_X_B'(closest_dist));
                intersect_y         <= (`INTERSECT_Y_B'(pixel_y) * `INTERSECT_Y_B'(closest_dist));
                intersect_z         <= (`INTERSECT_Z_B'(pixel_z) * `INTERSECT_Z_B'(closest_dist));
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_10) ? state + 1: state;
            end

            CALCULATING_11 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_z;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= (intersect_x - (`INTERSECT_X_B'(sphere_x) <<< `FP_B));
                intersect_y         <= (intersect_y - (`INTERSECT_Y_B'(sphere_y) <<< `FP_B));
                intersect_z         <= (intersect_z - (`INTERSECT_Z_B'(sphere_z) <<< `FP_B));
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_11) ? state + 1: state;
            end

            CALCULATING_12 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_z;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= intersect_x >>> sphere_r;
                intersect_y         <= intersect_y >>> sphere_r;
                intersect_z         <= intersect_z >>> sphere_r;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_12) ? state + 1: state;
            end

            CALCULATING_13 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_z;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= (((intersect_x * 7) + (7 <<< (2 * `FP_B))) >>> (2 * `FP_B));
                intersect_y         <= (((intersect_y * 7) + (7 <<< (2 * `FP_B))) >>> (2 * `FP_B));
                intersect_z         <= (((intersect_z * 7) + (7 <<< (2 * `FP_B))) >>> (2 * `FP_B));
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= busy;
                next_state          <= (state == CALCULATING_13) ? state + 1 : state;
            end

            COLORING_1 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_z;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= intersect_x;
                intersect_y         <= intersect_y;
                intersect_z         <= intersect_z;
                norm_x              <= intersect_x[3:0];
                norm_y              <= intersect_y[3:0];
                norm_z              <= intersect_z[3:0];
                busy                <= busy;
                next_state          <= (state == COLORING_1) ? state + 1 : state;
            end

            COLORING_2 : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= current_job;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_z;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= pixel_offset_x;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= intersect_x;
                intersect_y         <= intersect_y;
                intersect_z         <= intersect_z;
                norm_x              <= norm_x;
                norm_y              <= norm_y;
                norm_z              <= norm_z;
                busy                <= busy;
                next_state          <= (state == COLORING_2) ? state + 1: state;
            end

            FINISHED : begin
                index               <= index;
                next_sphere         <= next_sphere;
                closest_dist        <= closest_dist;
                closest_index       <= closest_index;
                num_misses          <= num_misses;
                current_job         <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? 0 : current_job + 1;
                sphere_x            <= sphere_x;
                sphere_y            <= sphere_y;
                sphere_z            <= sphere_z;
                sphere_r            <= sphere_r;
                spherex_sr          <= spherex_sr;
                spherey_sr          <= spherey_sr;
                spherez_sr          <= spherez_sr;
                spherer_sr          <= spherer_sr;
                sqrt_start          <= LOW;
                pixel_offset_x      <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? 0 : pixel_offset_x + N_WORKERS;
                pixel_x             <= pixel_x;
                pixel_x_sqrd        <= pixel_x_sqrd;
                dotx_r              <= dotx_r;
                doty_r              <= doty_r;
                dotz_r              <= dotz_r;
                a_times_two_r       <= a_times_two_r;
                c_times_two_r       <= c_times_two_r;
                b_r                 <= b_r;
                br_sr               <= br_sr;
                a_times_c_r         <= a_times_c_r;
                dis_r               <= dis_r;
                dist_r              <= dist_r;
                intersect_x         <= intersect_x;
                intersect_y         <= intersect_y;
                intersect_z         <= intersect_z;
                norm_x              <= norm_x;
                norm_y              <= norm_y;
                norm_z              <= norm_z;
                busy                <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? LOW : HIGH;
                next_state          <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? FINISHED : READY;
            end

            IDLE : begin
                index               <= 0;
                next_sphere         <= 0;
                closest_dist        <= 0;
                closest_index       <= 0;
                num_misses          <= 0;
                current_job         <= 0;
                sphere_x            <= 0;
                sphere_y            <= 0;
                sphere_z            <= 0;
                sphere_r            <= 0;
                spherex_sr          <= 0;
                spherey_sr          <= 0;
                spherez_sr          <= 0;
                spherer_sr          <= 0;
                sqrt_start          <= LOW;
                pixel_offset_x      <= 0;
                pixel_x             <= 0;
                pixel_x_sqrd        <= 0;
                dotx_r              <= 0;
                doty_r              <= 0;
                dotz_r              <= 0;
                a_times_two_r       <= 0;
                c_times_two_r       <= 0;
                b_r                 <= 0;
                br_sr               <= 0;
                a_times_c_r         <= 0;
                dis_r               <= 0;
                dist_r              <= 0;
                intersect_x         <= 0;
                intersect_y         <= 0;
                intersect_z         <= 0;
                norm_x              <= 0;
                norm_y              <= 0;
                norm_z              <= 0;
                busy                <= LOW;
                if(activate) begin
                    next_state      <= READY;
                end else begin
                    next_state      <= IDLE;
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if(!activate) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
        if(state == COLORING_2) begin
            buffer[current_job] <= (num_misses == num_spheres) ? `BACKGROUND_COLOR : {norm_x[3:0], norm_y[3:0], norm_z[3:0]};
        end
    end
endmodule
