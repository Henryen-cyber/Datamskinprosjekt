`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 01:40:42 PM
// Design Name: 
// Module Name: thread_tb
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


module thread_tb(

    );
    
    logic clk = 1'b0;
    
    always #1 clk = ~clk;
    
    thread_example dut (
        .clk(clk)
    );
   
endmodule
