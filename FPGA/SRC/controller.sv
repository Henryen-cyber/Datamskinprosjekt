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
module controller(
    input CLK100MHZ,
    input CLK25MHZ,
    input ck_rst,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs
    );
    
    // Raytracing Threads //
    
    parameter N_THREADS = 480;
    parameter HIGH = 1'b1;
    parameter LOW = 1'b0;
    
    logic activate;
    logic [N_THREADS - 1:0] t_busy;
    Color [N_THREADS - 1:0] t_color;
    
    generate
      genvar i;
      for (i=0; i<N_THREADS; i=i+1) begin : thread_instantiation
        logic [15:0] j = i;
        thread thread_i(
           .activate(activate),
           .index(j),
           .busy(t_busy[i]),
           .color(t_color[i]),
           .clk(CLK100MHZ)
          );
      end
    endgenerate
    
    logic t_any_busy;
    
    assign activate = next_line;
    
    Color [N_THREADS - 1: 0] color_in;
    always @ (negedge t_any_busy) begin
           color_in <= t_color;
     end
    
    assign t_any_busy = (t_busy == 0) ? LOW : HIGH;
    
    
    // VGA //
    
    vga vga_instance
    (
    .CLK25MHZ(CLK25MHZ),
    .ck_rst(ck_rst),
    .color_in(color_in),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .next_line(next_line)
    );
    
endmodule

module thread(
    input clk,
    input activate,
    input logic [15:0]index,
    output logic busy,
    output Color color
);
    parameter HIGH = 1'b1;
    parameter LOW = 1'b0;
    
    parameter STATE_READY = 4'd0;
    parameter STATE_COLORING = 4'd1;
    parameter STATE_FINISHED = 4'd2;
    
    logic [3:0] state;
    
    always @ (posedge clk) begin
        if (state == STATE_READY && activate == HIGH) begin
            state <= (state == STATE_READY) ? STATE_COLORING : state;
            busy <= (state == STATE_READY) ? HIGH : busy;
        end
        else if (busy == HIGH && state == STATE_COLORING) begin
            color <= {index[11:8], index[7:4], index[3:0] };
            state <= (state == STATE_COLORING) ? STATE_FINISHED : state;
        end
        else if (busy == HIGH && state == STATE_FINISHED) begin
            busy <= (state == STATE_FINISHED) ? LOW : busy;
        end
        else if (activate == LOW) begin
            state <= STATE_READY;
        end
    end
endmodule