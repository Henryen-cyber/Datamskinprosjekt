`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 03:20:58 PM
// Design Name: 
// Module Name: controller_tb
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



module controller_tb(

    );
    
    logic CLK25MHZ = 1;
    logic CLK100MHZ = 1;
    logic  ck_rst_ = 1'b0;
    logic  [3:0] vga_r;
    logic  [3:0] vga_g;
    logic  [3:0] vga_b;
    logic  vga_hs;
    logic  vga_vs;

    Raytracing_Controller dut (    
    .CLK25MHZ(CLK25MHZ),
    .CLK100MHZ(CLK100MHZ),
    .ck_rst_(ck_rst_),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs)
    );
    
    initial begin 
        #3 ck_rst_ = 1'b1;
        #4000000 $finish;
    end
    
    always #1 CLK100MHZ = ~CLK100MHZ;
    always #4 CLK25MHZ = ~CLK25MHZ;


endmodule
