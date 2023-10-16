`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2023 11:43:58 AM
// Design Name: 
// Module Name: vga_tb
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


module vga_tb();

    logic CLK25MHZ = 1;
    logic  ck_rst = 1'b1;
    logic  [3:0] vga_r;
    logic  [3:0] vga_g;
    logic  [3:0] vga_b;
    logic  vga_hs;
    logic  vga_vs;
    logic  next_line;
    
    logic[11:0] color_in = 12'b111111111111 ;
    
    
    initial begin 
        #3 ck_rst = 1'b0;
    end
    
    always #1 CLK25MHZ = ~CLK25MHZ;
    
//    clk_wiz_0 instance_name
//   (
//    // Clock out ports
//    .clk_out1(CLK25MHZ),     // output clk_out1
//    // Status and control signals
//    //.reset(ck_rst), // input reset
//   // .locked(locked),       // output locked
//   // Clock in ports
//    .clk_in1(CLK100MHZ)  // input clk_in1
//    );
    
    vga dut 
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
