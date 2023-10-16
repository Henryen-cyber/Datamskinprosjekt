`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 04:00:02 PM
// Design Name: 
// Module Name: top
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


module top(
    input CLK100MHZ,
    input ck_rst,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs
    );
    
    
    logic CLK25MHZ;    
    clk_wiz_0 clock_wiz_0_instance
   (
    // Clock out ports
    .clk_out1(CLK25MHZ),     // output clk_out1
    // Status and control signals
   // Clock in ports
    .clk_in1(CLK100MHZ)  // input clk_in1
    );
    
    controller controller_instance (    
    .CLK100MHZ(CLK100MHZ), 
    .CLK25MHZ(CLK25MHZ),
    .ck_rst(ck_rst),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs)
    );
endmodule
