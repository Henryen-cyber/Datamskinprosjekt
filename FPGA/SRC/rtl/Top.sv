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


module Top(
    input CLK100MHZ,
    input ck_rst_,
    
    // VGA
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs,
    
    // SPI
    input ck_mosi,
    output ck_miso,
    input ck_ss,
    input ck_sck,
    output ck_io0,
    
    output [3:0] led
    );
    
    
    logic i_SPI_Clk;
    logic o_SPI_MISO;
    logic i_SPI_MOSI;
    logic i_SPI_CS_n;
    
    
    assign i_SPI_Clk = ck_sck;
    assign o_SPI_MISO = ck_miso;
    assign i_SPI_MOSI = ck_mosi;
    assign i_SPI_CS_n = ck_ss;
    
    
    
    logic CLK25MHZ;    
    clk_wiz_0 clock_wiz_0_instance
   (
    // Clock out ports
    .clk_out1(CLK25MHZ),     // output clk_out1
    // Status and control signals
   // Clock in ports
    .clk_in1(CLK100MHZ)  // input clk_in1
    );
    
    
    logic recv_dv;
    logic [63:0] recv_64bit;
    // logic tran_dv;
    // logic [7:0] tran_byte;
    
    SPI_Slave_64 SPI_Slave_instance (
    .i_Rst_L(ck_rst_),
    .i_Clk(CLK100MHZ),
    .o_RX_DV(recv_dv),
    .o_RX_64Bit(recv_64bit),
    // .i_TX_DV(tran_dv),
    // .i_TX_Byte(tran_byte),
    .i_SPI_Clk(i_SPI_Clk),
    .o_SPI_MISO(o_SPI_MISO),
    .i_SPI_MOSI(i_SPI_MOSI),
    .i_SPI_CS_n(i_SPI_CS_n)
    );
    
    Raytracing_Controller controller_instance (    
    .CLK100MHZ(CLK100MHZ), 
    .CLK25MHZ(CLK25MHZ),
    .ck_rst_(ck_rst_),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b),
    .vga_hs(vga_hs),
    .vga_vs(vga_vs),
    .recv_dv(recv_dv),
    .recv_64bit(recv_64bit),
    .recv_interrupt(ck_io0),
    // .tran_dv(tran_dv),
    // .tran_byte(tran_byte),
    .led(led)
    );
endmodule
