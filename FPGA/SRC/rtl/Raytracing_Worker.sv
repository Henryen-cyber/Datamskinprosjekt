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
    logic signed[21:0] doty_r,  // Max possible value:               982'800
    logic [15:0]    pixely_sr, // Max possible value:                 57'600
    logic [26:0]    originy_sr, // Max possible value:            67'108'864
    
    input Types::Sphere sphere,
    output logic busy,
    output Types::Color [JOBS_SUBDIVISION-1:0] buffer
);
    logic [2:0] state;
    localparam [2:0] READY = 3'd0;
    localparam [2:0] CALCULATING_1 = 3'd1;
    localparam [2:0] CALCULATING_2 = 3'd2;
    localparam [2:0] CALCULATING_3 = 3'd3;
    localparam [2:0] CALCULATING_4 = 3'd4;
    localparam [2:0] COLORING = 3'd5;
    localparam [2:0] FINISHED = 3'd6;
    
    // Calculation registers
    logic[5:0] current_job;
    
    logic unsigned [12:0] pixel_offset_x;
    logic signed [15:0] pixel_x;
    logic unsigned [15:0] dist_x_sqrd;
    //logic signed [15:0] dist_y_sqrd;
    logic unsigned [15:0] r_sqrd;
    

    // Pixel square registers     All of these are much smaller due to Fixed
    //                            Point representation!
    //                            Needs to be updated accordingly
    logic [16:0]    pixelx_sr; // Max possible value:                102'400
    logic [15:0]    pixely_sr; // Max possible value:                 57'600
    // logic  [9:0]    pixelz_sr; // Max possible value:                    961
    // Origin square registers
    logic [30:0]    originx_sr; // Max possible value:         1'073'741'824
    // logic [26:0]    originy_sr; // Max possible value:            67'108'864
    logic [30:0]    originz_sr; // Max possible value:         1'073'741'824
    logic [17:0]    originr_sr; // Max possible value:               261'121
    // Dot-product registers
    logic signed[24:0] dotx_r;  // Max possible value:            10'485'440
    // logic signed[21:0] doty_r;  // Max possible value:               982'800
    logic signed[20:0] dotz_r;  // Max possible value:             1'048'544
    // Quadratic formula registers
    logic       [19:0] a_r;     // Max possible value:               160'961
    logic signed[32:0] c_r;     // Max possible value:         2'214'592'511
    logic signed[25:0] b_r;     // Max possible value:            25'033'568
    logic       [49:0] br_sr;   // Max possible value:   626'679'526'810'624
    logic signed[51:0] arcr_r;  // Max possible value: 1'425'683'980'107'004
    logic signed[51:0] dis_r;   // Max possible value: 1'425'683'980'107'004
    
    localparam pixel_z = 100;
    localparam pixelz_sr = pixel_z ** 2;


    // Raytracing Worker State-machine //
    always @ (posedge clk) begin
        if (state == READY && activate == HIGH) begin
            pixel_x <= 16'(pixel_start_x) + 16'(pixel_offset_x);
            a_r <= pixelz_sr;
            state <= (state == READY) ? state + 1: state;
            busy <= (state == READY) ? HIGH : LOW;
            buffer[current_job] <= 0;
        end
        else if (state == CALCULATING_1 && busy == HIGH) begin
            pixelx_sr <= pixel_x ** 2;
            // pixely_sr <= pixel_y ** 2;
            originr_sr <= (10'(sphere.r) << 3) ** 2;
            state <= (state == CALCULATING_1) ? state + 1: state;
        end
        else if (state == CALCULATING_2 && busy == HIGH) begin
            a_r <= pixelx_sr + pixely_sr + pixelz_sr;
            dotx_r <= 25'(pixel_x * sphere.x);
            // doty_r <= 22'(14'(pixel_y) * sphere.y);
            dotz_r <= 21'(pixel_z * sphere.z);
        
            state <= (state == CALCULATING_2) ? state + 1: state;
        end
        else if (state == CALCULATING_3 && busy == HIGH) begin
            b_r <= (dotx_r + doty_r + dotz_r) << 1;
            originx_sr <= sphere.x ** 2;
            // originy_sr <= sphere.y ** 2;
            originz_sr <= sphere.z ** 2;
        
            state <= (state == CALCULATING_3) ? state + 1: state;
        end
        else if (state == CALCULATING_4 && busy == HIGH) begin
            c_r <= 33'(originx_sr + originy_sr + originz_sr) - 33'(originr_sr);
            arcr_r <= (52'(a_r * c_r) * 4);
            br_sr <= b_r ** 2;
            dis_r <= (br_sr - arcr_r);
            state <= (state == CALCULATING_4) ? state + 1: state;
        end
        else if (state == COLORING && busy == HIGH) begin
            buffer[current_job] <= (dis_r >= 0) ? buffer[current_job] + 1 : 0;
            dis_r <= (dis_r == 0) ? -1 : (dis_r > 0) ? dis_r >> 1 : -1;

            state <= (state == COLORING && dis_r <= 0) ? state + 1: state;
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
        end
    end
endmodule