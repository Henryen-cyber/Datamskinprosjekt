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
localparam JOBS_SUBDIVISION = 64; // Must be divisible with JOBS
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
    input [63:0] recv_64bit,
    output logic recv_interrupt,
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
    Types::Sphere spherer =  {16'd0, 14'd0, 16'd200, 6'd40, 12'd0};
    Types::Sphere sphere;
    assign sphere = spherer;
    
    logic [63:0] recv_64bitr;
    
    // Raytracing controller //
    
    logic [1:0] state;
    localparam READY = 2'd0;
    localparam SETUP_1 = 2'd1;
    localparam SETUP_2 = 2'd2;
    localparam RENDERING = 2'd3;
    
    Types::Color [JOBS - 1:0] line_color_buffer; // Buffer filled by workers
    Types::Color [JOBS - 1: 0] line_color; // Line sent to vga
    
    // Raytracing workers //
    logic activate_workersr;
    logic signed [11:0] next_y;
    logic signed [11:0] pixel_y;
    logic signed[21:0] doty_r;  // Max possible value:               982'800
    logic [15:0]    pixely_sr; // Max possible value:                 57'600
    logic [26:0]    originy_sr; // Max possible value:            67'108'864
    logic next_line;
    
    logic [N_WORKERS - 1:0] worker_busyr;
    logic worker_any_busy;
    assign worker_any_busy = (worker_busyr == '0) ? LOW : HIGH;
    
    generate
      genvar i;
      genvar j;
      for (i=0; i<N_WORKERS; i=i+1) begin : worker_instantiation
        
        // Variables unique for each worker
        logic signed [11:0] x_i = i - (JOBS / 2);
        
        // Connection to line buffer
        // Creates an evenly distributed interleaving pattern
        Types::Color [JOBS_SUBDIVISION-1:0] worker_line_color_buffer = 0;
        for (j=0; j<JOBS_SUBDIVISION; j=j+1) begin : thread_jobs
            assign line_color_buffer[i + j * N_WORKERS] = worker_line_color_buffer[j];
        end
        
        Raytracing_Worker worker_i(
           .activate(activate_workersr),
           .sphere(sphere),
           .pixel_start_x(x_i),
        //    .pixel_y(pixel_y),
           .pixely_sr(pixely_sr),
           .doty_r(doty_r),
           .originy_sr(originy_sr),
           .busy(worker_busyr[i]),
           .buffer(worker_line_color_buffer),
           .clk(CLK100MHZ)
          );
      end
    endgenerate
    
    // Raytracing Controller State-machine //
    
    always @ (posedge CLK100MHZ) begin
        if (~ck_rst_) begin
            recv_64bitr <= {16'd100, -14'd100, 16'd200, 6'd40, 12'd0};
            recv_interrupt <= LOW;
        end
        if (recv_dv == HIGH) begin
            // recv_64bitr <= recv_64bit;
        end
        if (state == READY && next_line == LOW && recv_dv == LOW) begin
            recv_interrupt <= HIGH;
            spherer <= recv_64bitr;
        end
        
        if (state == READY && next_line == HIGH) begin
            // Start writing a new line
            state <= (state == READY) ? state + 1: state;
        end
        else if (state == SETUP_1 && activate_workersr == LOW && worker_any_busy == LOW) begin
            pixel_y <= next_y - 12'd240;
            originy_sr <= sphere.y ** 2;
            state <= (state == SETUP_1) ? state + 1: state;
        end
        else if (state == SETUP_2 && activate_workersr == LOW && worker_any_busy == LOW) begin
            pixely_sr <= pixel_y ** 2;
            doty_r <= 22'(14'(pixel_y) * sphere.y);
            
            recv_interrupt <= LOW;
            activate_workersr <= HIGH;
        end
        else if (state == SETUP_2 && activate_workersr == HIGH && worker_any_busy == HIGH) begin
            recv_interrupt <= LOW;
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
    
    assign led = recv_64bitr[3:0];
    
endmodule