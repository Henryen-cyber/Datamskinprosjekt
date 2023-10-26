////////////////////////////////////////////////////////////////////////////
//                      Square root algorithm from:                       //
// https://iopscience.iop.org/article/10.1088/1742-6596/1314/1/012008/pdf //
////////////////////////////////////////////////////////////////////////////

`include "last_set_bit.sv"

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

    last_set find_m(.clk(clk),
                    .rst_(rst_),
                    .start(start),
                    .fixed_point_vector(A),
                    .location(m)); // Probably need to bitshift m to account for fixed-point

    enum { IDLE, START, LOOP, DONE } CURRENT_STATE, NEXT_STATE;
    
    always_comb begin : data_logic
        case(CURRENT_STATE)

            IDLE : begin
                k <= 0;
                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                d_k <= 0;
                A_norm <= 0;
                c_k_less_than_A_norm <= 0;
                Q <= 0;
                if(start) begin
                    NEXT_STATE <= START;
                end else begin
                    NEXT_STATE <= IDLE;
                end
            end

            START : begin
                k <= 0;
                x_k <= 0;
                x_k1 <= 0;
                c_k <= 0;
                c_k1 <= 0;
                d_k <= 0;
                A_norm <= A >> (2 * m);
                c_k_less_than_A_norm <= 0;
                NEXT_STATE <= LOOP;
                Q <= 0;
            end

            LOOP : begin
                c_k_less_than_A_norm <= c_k < A_norm;
                if(c_k_less_than_A_norm) begin
                    d_k <= 1;
                end else if(!c_k_less_than_A_norm) begin
                    d_k <= -1;
                end
                x_k1 <= x_k + (d_k >> k);
                c_k1 <= c_k + d_k * (x_k >> (k - 1)) + 1 >> (2 * k);
                x_k <= x_k1;
                c_k <= c_k1;
                A_norm <= A_norm;
                Q <= 0;
            end

            DONE : begin
                Q <= x_k << m;
                k <= 0;
                x_k <= x_k;
                x_k1 <= x_k1;
                c_k <= c_k;
                c_k1 <= c_k1;
                d_k <= d_k;
                A_norm <= A_norm;
                c_k_less_than_A_norm <= c_k_less_than_A_norm;
                NEXT_STATE <= IDLE;
            end

        endcase
    end

    always_ff @(posedge clk) begin : next_state_logic
        if(rst_) begin
            CURRENT_STATE <= NEXT_STATE;
        end else if(!rst_) begin
            CURRENT_STATE <= IDLE;
        end
        if(CURRENT_STATE == LOOP) begin
            k <= k + 1;
            if(k == (N - 1)) begin
                NEXT_STATE <= DONE;
            end
        end
    end
endmodule
