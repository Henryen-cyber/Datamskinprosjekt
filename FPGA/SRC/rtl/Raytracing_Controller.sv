`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 02:22:24 PM
// Design Name: 
// Module Name: controller
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

// Worker instantiation parameters
localparam JOBS = 640;
localparam JOBS_SUBDIVISION = 32; // Must be divisible with JOBS
localparam N_WORKERS = JOBS / JOBS_SUBDIVISION;
localparam HIGH = 1'b1;
localparam LOW = 1'b0;

module Raytracing_Controller(
    // Clocks
    input CLK100MHZ,
    input CLK25MHZ,
    
    // Board
    input ck_rst_,
    output [3:0] led,
    
    // SPI
    input recv_dv,
    input [7:0] recv_byte,
    // output tran_dv,
    // output [7:0] tran_byte,
    
    // VGA
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs
    );
    
    // World
    Types::Circle circler =  {12'd0, 12'd0, 12'd20};
    Types::Circle circle;
    assign circle = circler;
    
    logic [7:0] recv_byter;
    
    // Raytracing controller //
    
    logic [1:0] state;
    localparam READY = 2'd0;
    localparam SETUP = 2'd1;
    localparam RENDERING = 2'd2;
    
    Types::Color [JOBS- 1:0] line_color_buffer; // Buffer filled by workers
    Types::Color [JOBS - 1: 0] line_color; // Line sent to vga
    
    // Raytracing workers //
    logic activate_workersr;
    
    logic [N_WORKERS - 1:0] worker_busyr;
    logic worker_any_busy = (worker_busyr == 0) ? LOW : HIGH;
    
    generate
      genvar i;
      genvar j;
      for (i=0; i<N_WORKERS; i=i+1) begin : worker_instantiation
        
        // Variables unique for each worker
        logic [11:0] x_i = i;
        
        // Connection to line buffer
        // Creates an evenly distributed interleaving pattern
        Types::Color [JOBS_SUBDIVISION-1:0] worker_line_color_buffer = 0;
        for (j=0; j<JOBS_SUBDIVISION; j=j+1) begin : thread_jobs
            assign line_color_buffer[i + j * N_WORKERS] = worker_line_color_buffer[j];
        end
        
        Raytracing_Worker worker_i(
           .activate(activate_workersr),
           .circle(circle),
           .x(x_i),
           .y(next_y),
           .busy(worker_busyr[i]),
           .buffer(worker_line_color_buffer),
           .clk(CLK100MHZ)
          );
      end
    endgenerate
    
    // Raytracing Controller State-machine //
    
    always @ (posedge CLK100MHZ) begin
        if (~ck_rst_) begin
            recv_byter <= 0;
        end
        if (recv_dv == HIGH) begin
            recv_byter <= recv_byte;
        end
        if (state == READY && next_line == LOW) begin
            circler.x <= {4'b0, recv_byter};
        end
        
        if (state == READY && next_line == HIGH) begin
            // Start writing a new line
            state <= (state == READY) ? state + 1: state;
        end
        else if (state == SETUP && activate_workersr == LOW && worker_any_busy == LOW) begin
            activate_workersr <= HIGH;
        end
        else if (state == SETUP && activate_workersr == HIGH && worker_any_busy == HIGH) begin
            state <= RENDERING;
        end
        else if (next_line == LOW) begin
            line_color <= line_color_buffer;
            state <= READY;
            activate_workersr <= LOW;
        end
        
    end
    
    // VGA //
    
    VGA vga_instance
    (
    .CLK25MHZ(CLK25MHZ),
    .ck_rst_(ck_rst_),
    .color_in(line_color),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .next_line(next_line),
    .next_y(next_y)
    );
    
    // Debugging //
    
    assign led = recv_byter[3:0];
    
endmodule