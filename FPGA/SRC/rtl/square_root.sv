// Square root algorithm from: 
// https://iopscience.iop.org/article/10.1088/1742-6596/1314/1/012008/pdf
//

`include "last_set_bit.sv"

module SquareRoot#(parameter N=16)(
    
    input  logic clk,
    input  logic rst_,
    input  logic start,
    input  logic[11:0] A,

    output logic[11:0] Q

    );

    logic [11:0] A_norm;

    logic [5:0] m;
    logic [3:0] k <= 3'b000;
    logic[15:0] x_k;
    logic[15:0] x_k1;
    logic[15:0] c_k;
    logic[15:0] c_k1;
    logic signed[15:0] d_k;

    last_set find_m(.clk(clk),
                    .rst_(rst_),
                    .start(start),
                    .fixed_point_vector(A),
                    .location(m));



    always_ff @(posedge clk) begin

        if(k == 0) begin
            A_norm <= A >> 2 * m;
            k <= 0;
            x_k <= 0;
            c_k <= 0;
        end
        if(c_k < A_norm) begin
            d_k <= 1;
        end
        else if(c_k > A_norm) begin
            d_k <= -1;
        end

        k <= k + 1;
        x_k1 <= x_k + (d_k >> 2*k);
        c_k1 <= c_k + d_k * (x_k >> 2*(k-1)) + (1 >> 2*k);

        c_k <= c_k1;
        x_k <= x_k1;

        if(k == N) begin
            Q <= x_k << m;
            k <= 0;
        end
    end
    
endmodule

