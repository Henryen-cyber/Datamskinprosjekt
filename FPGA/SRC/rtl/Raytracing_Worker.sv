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
    input signed[11:0] x,
    input signed[11:0] y,
    input Types::Sphere sphere,
    output logic busy,
    output Types::Color [JOBS_SUBDIVISION-1:0] buffer
);
    logic [2:0] state;
    localparam [2:0] READY = 3'd0;
    localparam [2:0] CALCULATING_1 = 3'd1;
    localparam [2:0] CALCULATING_2 = 3'd2;
    localparam [2:0] CALCULATING_3 = 3'd3;
    localparam [2:0] COLORING = 3'd4;
    localparam [2:0] FINISHED = 3'd5;
    
    // Calculation registers
    logic[5:0] current_job;
    
    logic unsigned [12:0] offset_x;
    logic unsigned [15:0] local_x;
    logic unsigned [15:0] dist_x_sqrd;
    //logic signed [15:0] dist_y_sqrd;
    logic unsigned [15:0] r_sqrd;
    
    
    // Raytracing Worker State-machine //
    always @ (posedge clk) begin
        if (state == READY && activate == HIGH) begin
            local_x <= x + offset_x;
            state <= (state == READY) ? state + 1: state;
            busy <= (state == READY) ? HIGH : LOW;
        end
        else if (state == CALCULATING_1 && busy == HIGH) begin
            dist_x_sqrd <= (local_x - sphere.x) ** 2;
            state <= (state == CALCULATING_1) ? state + 1: state;
        end
        else if (state == CALCULATING_2 && busy == HIGH) begin
            dist_x_sqrd <= dist_x_sqrd + (y - sphere.y) ** 2; 
            state <= (state == CALCULATING_2) ? state + 1: state;
        end
        else if (state == CALCULATING_3 && busy == HIGH) begin
            r_sqrd <= sphere.r ** 2;
            state <= (state == CALCULATING_3) ? state + 1: state;
        end
        else if (state == COLORING && busy == HIGH) begin
            buffer[current_job] <= (dist_x_sqrd < r_sqrd) ? 12'b111100000000 : 12'b0;
            state <= (state == COLORING) ? state + 1: state;
        end
        else if (state == FINISHED && busy == HIGH) begin
            current_job <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? 0 : current_job + 1;
            offset_x <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? 0 : offset_x + N_WORKERS;
            busy <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? LOW : HIGH;
            state <= (state == FINISHED && current_job == JOBS_SUBDIVISION - 1) ? FINISHED : READY;
        end
        else if (activate == LOW) begin
            state <= READY;
            busy <= LOW;
            current_job <= 0;
            offset_x <= 0;
        end
    end
endmodule