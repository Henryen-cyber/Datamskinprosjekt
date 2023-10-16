`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2023 01:28:19 PM
// Design Name: 
// Module Name: thread_example
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


module thread_example(
    input clk
    );
    
    parameter N_THREADS = 15;
    
    logic [N_THREADS:0]DFF_i = 0;
    logic [N_THREADS:0]DFF_o = 0;
    
    generate
      genvar i;
      for (i=0; i<=N_THREADS; i=i+1) begin : thread_instantiation
        logic j = i;
        simple_thread thread_i(
           .index(j), 
           .clk(clk),
           .in(DFF_i[i]),
           .out(DFF_o[i])
          );
      end
    endgenerate
endmodule

module simple_thread(
    input clk,
    input in,
    output out
);
    assign out = in;
endmodule
