////////////////////////////////////////////////////////////////////////////
//                      Square root algorithm from:                       //
// https://iopscience.iop.org/article/10.1088/1742-6596/1314/1/012008/pdf //
////////////////////////////////////////////////////////////////////////////


// NEEDS STATE-MACHINE //

`include "last_set_bit.sv"
`include "square_root_fsm.sv"

module SquareRoot#(parameter N=16)(

    input  logic clk,
    input  logic rst_,
    input  logic start,
    input  logic[11:0] A,

    output logic[11:0] Q

    );

    logic [11:0] A_norm;
    logic c_k_less_than_A_norm;
    logic [5:0] m;
    logic [3:0] k;
    logic[15:0] x_k;
    logic[15:0] x_k1;
    logic[15:0] c_k;
    logic[15:0] c_k1;
    logic signed[1:0] d_k;
    logic[1:0] state;

    last_set find_m(.clk(clk),
                    .rst_(rst_),
                    .start(start),
                    .fixed_point_vector(A),
                    .location(m));

    SquareRoot_FSM FSM(.start(start),
                       .clk(clk),
                       .rst_(rst_),
                       .k(k),
                       .state(state));

    always_ff @(posedge clk) begin
        if(state == 2'b00) begin
            k <= 0;
            x_k <= 0;
            x_k1 <= 0;
            c_k <= 0;
            c_k1 <= 0;
            d_k <= 0;
        end
    end

    always_ff @(posedge clk) begin
        if(state == 2'b01) begin
            k <= 0;
            x_k <= 0;
            x_k1 <= 0;
            c_k <= 0;
            c_k1 <= 0;
            d_k <= 0;
            A_norm <= A >> (2 * m);
            c_k_less_than_A_norm <= c_k < A_norm;
        end
    end

    always_ff @(posedge clk) begin
        if(state == 2'b10) begin
            if(c_k_less_than_A_norm) begin
                d_k <= 1;
            end else if(!c_k_less_than_A_norm) begin
                d_k <= -1;
            end
            k <= k + 1;
            x_k1 <= x_k + (d_k >> k);
            c_k1 <= c_k + d_k * (x_k >> (k - 1)) + 1 >> (2 * k);
            x_k <= x_k1;
            c_k <= c_k1;
        end
    end

    always_ff @(posedge clk) begin
        if(state == 2'b11) begin
            Q <= x_k << m;
        end
    end
endmodule
