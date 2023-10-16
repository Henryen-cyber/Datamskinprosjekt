`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2023 01:37:22 PM
// Design Name: 
// Module Name: vga_provider
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


module vga_provider(
    input CLK100MHZ,
    input ck_rst,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs,
    output next_line
    );

    // reg[11:0] color_in = 12'b111111111111 ;
    
    logic [9:0]next_y;
    logic [9:0]offset = 10'd0;
    //logic update_offset = 1'b0;
    logic [11:0] color_in;
    
    assign color_in = {2'd0,next_y + offset};
    
//    always @ (negedge next_y[8]) begin
//        offset = offset + 10'd1;
//    end
    
    wire CLK25MHZ;    
    clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(CLK25MHZ),     // output clk_out1
    // Status and control signals
    //.reset(ck_rst), // input reset
   // .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(CLK100MHZ)  // input clk_in1
    );
    
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
    .next_y(next_y),
    .next_line(next_line)
    );
    
endmodule
