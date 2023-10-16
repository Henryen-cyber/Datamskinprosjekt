`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2023 11:03:51 AM
// Design Name: 
// Module Name: blinky
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


module blinky(
    input CLK100MHZ,
    // input ck_rst,
    output led
    );
    
    wire CLK25MHZ;
    // logic locked;
    
    reg [24:0] count = 0;
 
    assign led = count[24];
    
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
 
    always @ (posedge(CLK25MHZ)) count <= count + 1;
endmodule
